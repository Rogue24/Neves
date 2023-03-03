//
//  WaterfallLayout.swift
//  JPMovieWriter_Example
//
//  Created by aa on 2023/2/27.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

@objc protocol WaterfallLayoutDelegate: NSObjectProtocol {
    /**
     * 让代理根据给出的宽度计算出item高度
     */
    func waterfallLayout(_ waterfallLayout: WaterfallLayout, heightForItemAtIndex index: Int, itemWidth: CGFloat) -> CGFloat

    /// cell的总列数
    @objc optional func colCountInWaterFlowLayout(_ waterfallLayout: WaterfallLayout) -> Int
    
    /// cell的列间距
    @objc optional func colMarginInWaterFlowLayout(_ waterfallLayout: WaterfallLayout) -> CGFloat
    
    /// cell的行间距
    @objc optional func rowMarginInWaterFlowLayout(_ waterfallLayout: WaterfallLayout) -> CGFloat
    
    /// collectionView的内容间距
    @objc optional func edgeInsetsInWaterFlowLayout(_ waterfallLayout: WaterfallLayout) -> UIEdgeInsets
}


class WaterfallLayout: UICollectionViewLayout {
    
    /// 默认列数
    static let defaultColCount: Int = 3

    /// 默认cell列间距
    static let defaultColMargin: CGFloat = 10

    /// 默认cell行间距
    static let defaultRowMargin: CGFloat = 10

    /// collectionView的内容间距
    static let defaultEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    weak var delegate: (AnyObject & WaterfallLayoutDelegate)? = nil
    
    
    //*****  协议数据处理
    var colCount: Int {
        delegate?.colCountInWaterFlowLayout?(self) ?? Self.defaultColCount
    }

    var colMargin: CGFloat {
        delegate?.colMarginInWaterFlowLayout?(self) ?? Self.defaultColMargin
    }
    
    var rowMargin: CGFloat {
        delegate?.rowMarginInWaterFlowLayout?(self) ?? Self.defaultRowMargin
    }
    
    var edgeInsets: UIEdgeInsets {
        delegate?.edgeInsetsInWaterFlowLayout?(self) ?? Self.defaultEdgeInsets
    }
    //*****
    
    var attrsDict: [Int: UICollectionViewLayoutAttributes] = [:]
    var attrsSeats: [[UICollectionViewLayoutAttributes]] = []
    var colHeights: [CGFloat] = []
    
    var oldAttrsDict: [Int: UICollectionViewLayoutAttributes] = [:]
    var oldAttrsSeats: [[UICollectionViewLayoutAttributes]] = []
    lazy var oldColHeights: [CGFloat] = Array(repeating: edgeInsets.top, count: colCount)
    var oldColCount = 0
    
    var appearAttrsYDict: [Int: CGFloat] = [:]
    var disappearAttrsYDict: [Int: CGFloat] = [:]
    
    var contentHeight: CGFloat = 0
    
    var insertIndexPaths: [IndexPath] = []
    var deleteIndexPaths: [IndexPath] = []
    var reloadIndexPaths: [IndexPath] = []
    var isReloadSection = false
    
    /**
     * 初始化（每次collectionView刷新一遍都会重新调用一次prepareLayout，例如上下拉刷新）
     */
    override func prepare() {
        super.prepare()
        
        contentHeight = 0
        
        setupAttributes()
        
        // 刷新内容高度
        let maxColInfo = findMaxHeightColInfo()
        contentHeight = maxColInfo.height + edgeInsets.bottom
    }
    
    
    func reset() {
        
    }
    
    
    func setupAttributes() {
        // 清除之前所有的布局属性
        attrsDict.removeAll()
        attrsSeats = Array(repeating: [], count: colCount)
        // 先清除之前计算的所有高度并初始化
        colHeights = Array(repeating: edgeInsets.top, count: colCount)
        
        let collectionViewW = collectionView?.frame.width ?? 0
        let numberOfItems = collectionView?.numberOfItems(inSection: 0) ?? 0
        
        for i in 0 ..< numberOfItems {
            // 获取cell对应的布局属性
            let attrs = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: i, section: 0))
            
            // 找出高度最小的那一列
            let minColInfo = findMinHeightColInfo()
            
            let width = (collectionViewW - edgeInsets.left - edgeInsets.right - CGFloat(colCount - 1) * colMargin) / CGFloat(colCount)
            
            let height = delegate?.waterfallLayout(self, heightForItemAtIndex: i, itemWidth: width) ?? width
            
            let x = edgeInsets.left + CGFloat(minColInfo.col) * (width + colMargin)
            
            let y = minColInfo.height > edgeInsets.top ? (minColInfo.height + rowMargin) : edgeInsets.top
            
            attrs.frame = CGRect(x: x, y: y, width: width, height: height)
            
            
            attrsDict[i] = attrs
            attrsSeats[minColInfo.col].append(attrs)
            
            // 刷新最短那列的高度
            colHeights[minColInfo.col] = attrs.frame.maxY
        }
    }
    
    /**
     * 决定cell的排布（在继承UICollectionViewLayout会多次调用此方法，将计算过程放到prepareLayout确保计算过程只执行一次，除非刷新collectionView）
     */
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        attrsDict.values.map { $0 }
    }
    
    /**
     * 返回indexPath位置cell对应的布局属性
     */
//    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//        guard indexPath.item < attrsDict.count else { return nil }
//        return attrsDict[indexPath.item]
//    }

    override var collectionViewContentSize: CGSize {
        CGSize(width: 0, height: contentHeight)
    }
    
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        for updateItem in updateItems {
            if updateItem.updateAction == .insert {
                insertIndexPaths.append(updateItem.indexPathAfterUpdate!)
            }
            if updateItem.updateAction == .delete {
                deleteIndexPaths.append(updateItem.indexPathBeforeUpdate!)
            }
            if updateItem.updateAction == .reload {
                if updateItem.indexPathAfterUpdate!.item < Int.max {
                    // indexPathBeforeUpdate indexPathAfterUpdate 都一样
                    reloadIndexPaths.append(updateItem.indexPathAfterUpdate!)
                } else {
                    // item 为 NSIntegerMax 时就是 reloadSections 更新整个 section 的（NSIndexSet）
                    isReloadSection = true
                }
            }
        }
        
        
        if oldColCount == colCount, oldAttrsDict.count > 0 {
            for col in 0 ..< colCount {
                let oldRowCount = oldAttrsSeats[col].count
                let newRowCount = attrsSeats[col].count
                
                
                guard oldRowCount != newRowCount else { continue }
                
                
                
                if oldRowCount > newRowCount {
                    var beginY = colHeights[col]
                    
                    for row in newRowCount ..< oldRowCount {
                        let key = (col << 16) | row
                        
                        let y = beginY > edgeInsets.top ? (beginY + rowMargin) : edgeInsets.top
                        disappearAttrsYDict[key] = y
                        
                        beginY += oldAttrsSeats[col][row].frame.height
                    }
                    
                } else {
                    var beginY = oldColHeights[col]
                    
                    
                    for row in oldRowCount ..< newRowCount {
                        let key = (col << 16) | row
                        
                        let y = beginY > edgeInsets.top ? (beginY + rowMargin) : edgeInsets.top
                        appearAttrsYDict[key] = y
                        
                        beginY += attrsSeats[col][row].frame.height
                    }
                    
                }
                
                
            }
            
            
            
            
            
        }
    }
    
    override func finalizeCollectionViewUpdates() {
        insertIndexPaths.removeAll()
        deleteIndexPaths.removeAll()
        reloadIndexPaths.removeAll()
        isReloadSection = false
        
        oldAttrsDict = attrsDict
        oldAttrsSeats = attrsSeats
        oldColHeights = colHeights
        oldColCount = colCount
        
        appearAttrsYDict.removeAll()
        disappearAttrsYDict.removeAll()
        
        JPrint("============finalizeCollectionViewUpdates============")
    }
    
    
    
    
    

    // 从 刚创建出来时的样式设置 --到--> 正常状态：这里设置的是展示动画的【初始状态】，例如设置了alpha为0，动画会自动变为1
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let item = itemIndexPath.item
        
        
        if isReloadSection {
//            guard let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath) else { return nil }
            let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath) ?? UICollectionViewLayoutAttributes(forCellWith: itemIndexPath)
            attributes.zIndex = 1
            attributes.alpha = 0
            
            if let colRow = findColRow(with: item, in: attrsSeats) {
                if let attrs = findAttributes(with: colRow, in: oldAttrsSeats) {
                    attributes.frame = attrs.frame
                } else {
                    attributes.frame = attrsSeats[colRow.col][colRow.row].frame
                    
                    let key = (colRow.col << 16) | colRow.row
                    if let y = appearAttrsYDict[key] {
                        attributes.frame.origin.y = y
                    }
                }
            }
            
            JPrint("initialLayout item: \(item),", "alpha: \(attributes.alpha),", logFrame(attributes.frame))
            return attributes
        }
        
        guard let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath) else { return nil }
        
        if insertIndexPaths.contains(itemIndexPath) {
            attributes.alpha = 0
        } else if deleteIndexPaths.contains(itemIndexPath) {
            attributes.alpha = 1
        } else if reloadIndexPaths.contains(itemIndexPath) {
            attributes.alpha = 1
            // 下面这句是用来观察差异的
//            attributes.transform = CGAffineTransformMakeScale(1.5, 1.5)
        }
        
        // 删除不会走这里，不用判断 deleteIndexPaths
        
        return attributes
    }

    // 从 正常状态 --到--> 最后消失时的样式设置：这里设置的是消失动画的【最终状态】
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let item = itemIndexPath.item
        guard let attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath) else { return nil }
        
        if isReloadSection {
            attributes.zIndex = 0
            attributes.alpha = 0
            
            if let colRow = findColRow(with: item, in: oldAttrsSeats) {
                if let attrs = findAttributes(with: colRow, in: attrsSeats) {
                    attributes.frame = attrs.frame
                } else {
                    attributes.frame = oldAttrsSeats[colRow.col][colRow.row].frame
                    
                    let key = (colRow.col << 16) | colRow.row
                    if let y = disappearAttrsYDict[key] {
                        attributes.frame.origin.y = y
                    }
                }
            }
            
            JPrint("finalLayout item: \(item),", "alpha: \(attributes.alpha),", logFrame(attributes.frame))
            return attributes
        }
        
        if insertIndexPaths.contains(itemIndexPath) {
            attributes.alpha = 1
        } else if deleteIndexPaths.contains(itemIndexPath) {
            attributes.alpha = 0
        } else if reloadIndexPaths.contains(itemIndexPath) {
            // 刷新：旧的是覆盖在新的上面，现在对旧的进行渐变消失
            attributes.alpha = 0
            // 下面两句是用来观察差异的
//            attributes.alpha = 1
//            attributes.transform = CGAffineTransformMakeScale(0.5, 0.5)
        }
        
        return attributes
    }
    
    func logFrame(_ frame: CGRect) -> String {
        "frame: [\(CGFloat(Int(frame.origin.x * 100)) / 100), \(CGFloat(Int(frame.origin.y * 100)) / 100), \(CGFloat(Int(frame.width * 100)) / 100), \(CGFloat(Int(frame.height * 100)) / 100)])"
    }
    
    
    
}


extension WaterfallLayout {
    struct Seat: Hashable {
        let col: Int
        let row: Int
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(col)
            hasher.combine(row)
        }
        
        static func == (lhs: Seat, rhs: Seat) -> Bool {
            lhs.col == rhs.col && lhs.row == rhs.row
        }
    }
}

private extension WaterfallLayout {
    typealias ColInfo = (col: Int, height: CGFloat)
    
    func findMinHeightColInfo() -> ColInfo {
        var destCol = 0
        var destColHeight = colHeights[0]
        
        for i in 0 ..< colCount {
            let colHeight = colHeights[i]
            if destColHeight > colHeight {
                destColHeight = colHeight
                destCol = i
            }
        }
        
        return (destCol, destColHeight)
    }
    
    func findMaxHeightColInfo() -> ColInfo {
        var destCol = 0
        var destColHeight = colHeights[0]
        
        for i in 0 ..< colCount {
            let colHeight = colHeights[i]
            if destColHeight < colHeight {
                destColHeight = colHeight
                destCol = i
            }
        }
        
        return (destCol, destColHeight)
    }
    
    typealias ColRow = (col: Int, row: Int)
    
    func findColRow(with item: Int, in attrsSeats: [[UICollectionViewLayoutAttributes]]) -> ColRow? {
        for col in 0 ..< attrsSeats.count {
            let kAttrsArray = attrsSeats[col]
            guard let row = kAttrsArray.firstIndex(where: { $0.indexPath.item == item }) else {
                continue
            }
            return (col, row)
        }
        return nil
    }
    
    func findAttributes(with colRow: ColRow, in attrsSeats: [[UICollectionViewLayoutAttributes]]) -> UICollectionViewLayoutAttributes? {
        guard colRow.col < attrsSeats.count else {
            return nil
        }
        let kAttrsArray = attrsSeats[colRow.col]
        
        guard colRow.row < kAttrsArray.count else {
            return nil
        }
        return kAttrsArray[colRow.row]
    }
}
