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
        let colCount = delegate?.colCountInWaterFlowLayout?(self) ?? Self.defaultColCount
        return colCount > 0 ? colCount : 1
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
    
    var contentSize: CGSize = .zero
    
    var insertIndexPaths: [IndexPath] = []
    var deleteIndexPaths: [IndexPath] = []
    var reloadIndexPaths: [IndexPath] = []
    var isReloadSection = false
    
    var attrsArray: [UICollectionViewLayoutAttributes] = []
    var nowAttrsGrid: AttributesGrid = AttributesGrid()
    var oldAttrsGrid: AttributesGrid = AttributesGrid()
    var appearingInitialYs: [AttributesSeat: CGFloat] = [:]
    var disappearingFinalYs: [AttributesSeat: CGFloat] = [:]
    
    override func prepare() {
        super.prepare()
        setupAttributes()
        setupContentSize()
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        attrsArray
    }
    
    override var collectionViewContentSize: CGSize {
        contentSize
    }
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        for updateItem in updateItems {
            switch updateItem.updateAction {
            case .insert:
                insertIndexPaths.append(updateItem.indexPathAfterUpdate!)
                
            case .delete:
                deleteIndexPaths.append(updateItem.indexPathBeforeUpdate!)
                
            case .reload:
                if updateItem.indexPathAfterUpdate!.item < Int.max {
                    // indexPathBeforeUpdate indexPathAfterUpdate 都一样
                    reloadIndexPaths.append(updateItem.indexPathAfterUpdate!)
                } else {
                    // item 为 NSIntegerMax 时就是 reloadSections 更新整个 section 的（NSIndexSet）
                    isReloadSection = true
                }
                
            default:
                break
            }
        }
        
        guard isReloadSection, oldAttrsGrid.attrsColumns.count == nowAttrsGrid.attrsColumns.count else {
            return
        }
        
        let colCount = self.colCount
        let rowMargin = self.rowMargin
        let topInset = self.edgeInsets.top
        
        let oldAttrsColumns = oldAttrsGrid.attrsColumns
        let nowAttrsColumns = nowAttrsGrid.attrsColumns
        
        for col in 0 ..< colCount {
            let oldAttrColumn = oldAttrsColumns[col]
            let nowAttrColumn = nowAttrsColumns[col]
            
            let oldAttributes = oldAttrColumn.attributes
            let nowAttributes = nowAttrColumn.attributes
            
            let oldRowCount = oldAttributes.count
            let nowRowCount = nowAttributes.count
            
            guard oldRowCount != nowRowCount else { continue }
            
            if oldRowCount > nowRowCount {
                JPrint("col: \(col), 数量减少，oldRowCount: \(oldRowCount), nowRowCount: \(nowRowCount)")
                var itemY = nowAttrColumn.colHeight
                for row in nowRowCount ..< oldRowCount {
                    let seat = AttributesSeat(col: col, row: row)
                    let finalY = itemY + (itemY > topInset ? rowMargin : 0)
                    disappearingFinalYs[seat] = finalY

                    let attrs = oldAttributes[row]
                    itemY += attrs.frame.height
                }
            } else {
                JPrint("col: \(col), 数量增多，oldRowCount: \(oldRowCount), nowRowCount: \(nowRowCount)")
                var itemY = oldAttrColumn.colHeight
                for row in oldRowCount ..< nowRowCount {
                    let seat = AttributesSeat(col: col, row: row)
                    let initialY = itemY + (itemY > topInset ? rowMargin : 0)
                    appearingInitialYs[seat] = initialY

                    let attrs = nowAttributes[row]
                    itemY += attrs.frame.height
                }
            }
        }
    }
    
    override func finalizeCollectionViewUpdates() {
        insertIndexPaths.removeAll()
        deleteIndexPaths.removeAll()
        reloadIndexPaths.removeAll()
        isReloadSection = false
        
        oldAttrsGrid.attrsColumns = nowAttrsGrid.attrsColumns
        appearingInitialYs.removeAll()
        disappearingFinalYs.removeAll()
        
        JPrint("========finalizeCollectionViewUpdates=======")
    }
    
    
    // 从 刚创建出来时的样式设置 --到--> 正常状态：这里设置的是展示动画的【初始状态】，例如设置了alpha为0，动画会自动变为1
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if isReloadSection {
            return reloadSectionAttributesForAppearingItem(at: itemIndexPath)
        } else {
            return updateAttributesForAppearingItem(at: itemIndexPath)
        }
    }

    // 从 正常状态 --到--> 最后消失时的样式设置：这里设置的是消失动画的【最终状态】
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if isReloadSection {
            return reloadSectionAttributesForDisappearingItem(at: itemIndexPath)
        } else {
            return updateAttributesForDisappearingItem(at: itemIndexPath)
        }
    }
}

extension WaterfallLayout {
    func setupAttributes() {
        attrsArray.removeAll()
        nowAttrsGrid.attrsColumns.removeAll()
        
        let colCount = self.colCount
        let colMargin = self.colMargin
        let rowMargin = self.rowMargin
        let edgeInsets = self.edgeInsets
        
        let attrsColumns = Array(0 ..< colCount).map { _ in
            AttributesColumn(attributes: [], colHeight: edgeInsets.top)
        }
        
        let collectionViewW = collectionView?.frame.width ?? 0
        let itemTotal = collectionView?.numberOfItems(inSection: 0) ?? 0
        let itemWidth = (collectionViewW - edgeInsets.left - edgeInsets.right - CGFloat(colCount - 1) * colMargin) / CGFloat(colCount)
        
        for item in 0 ..< itemTotal {
            // 找出高度最小的那一列
            var destCol = 0
            var destColumn = attrsColumns[destCol]
            for col in 0..<attrsColumns.count {
                let attrsColumn = attrsColumns[col]
                guard destColumn.colHeight > attrsColumn.colHeight else { continue }
                destColumn = attrsColumn
                destCol = col
            }
            
            let attrs = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: item, section: 0))
            attrs.frame = CGRect(
                x: edgeInsets.left + CGFloat(destCol) * (itemWidth + colMargin),
                y: destColumn.colHeight + (destColumn.colHeight > edgeInsets.top ? rowMargin : 0),
                width: itemWidth,
                height: delegate?.waterfallLayout(self, heightForItemAtIndex: item, itemWidth: itemWidth) ?? itemWidth
            )
            destColumn.attributes.append(attrs)
            destColumn.colHeight = attrs.frame.maxY // 刷新最短那列的高度
            
            attrsArray.append(attrs)
        }
        
        nowAttrsGrid.attrsColumns = attrsColumns
    }
    
    func setupContentSize() {
        let attrsColumns = nowAttrsGrid.attrsColumns
        var colHeight = attrsColumns[0].colHeight
        for attrsColumn in attrsColumns where colHeight < attrsColumn.colHeight {
            colHeight = attrsColumn.colHeight
        }
        colHeight += edgeInsets.bottom
        contentSize = CGSize(width: 0, height: colHeight)
    }
}

extension WaterfallLayout {
    func reloadSectionAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        // 当刷新整个Section：
        // 如果super获取为空，则说明是新增的item，新增的item默认就直接在最终位置停留，只有透明度的过渡
        // 为了让item能有过渡动画，为空时则手动创建一个来实现过渡动画
        let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath) ?? UICollectionViewLayoutAttributes(forCellWith: itemIndexPath)
        attributes.zIndex = 1
        attributes.alpha = 0
        
        guard let nowSeat = nowAttrsGrid[itemIndexPath] else {
            return attributes
        }
        
        if let oldAttrs = oldAttrsGrid[nowSeat] {
            attributes.frame = oldAttrs.frame
            return attributes
        }
        
        let nowAttrs = nowAttrsGrid[nowSeat]!
        attributes.frame = nowAttrs.frame
        if let initialY = appearingInitialYs[nowSeat] {
            JPrint("新增 col: \(nowSeat.col), row: \(nowSeat.row), oy: \(attributes.frame.origin.y), ny: \(initialY)")
            attributes.frame.origin.y = initialY
        } else {
            JPrint("新增 col: \(nowSeat.col), row: \(nowSeat.row), oy: \(attributes.frame.origin.y)")
        }
        if nowSeat.col == 0 {
            JPrint("col: 0 appearingInitialYs: \(appearingInitialYs)")
        }
        
        return attributes
    }
    
    func reloadSectionAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath) else { return nil }
        attributes.zIndex = 0
        attributes.alpha = 0
        
        guard let oldSeat = oldAttrsGrid[itemIndexPath] else {
            return attributes
        }
        
        if let nowAttrs = nowAttrsGrid[oldSeat]  {
            attributes.frame = nowAttrs.frame
            return attributes
        }
        
        let oldAttrs = oldAttrsGrid[oldSeat]!
        attributes.frame = oldAttrs.frame
        if let finalY = disappearingFinalYs[oldSeat] {
            JPrint("移除 col: \(oldSeat.col), row: \(oldSeat.row), oy: \(attributes.frame.origin.y), ny: \(finalY)")
            attributes.frame.origin.y = finalY
        } else {
            JPrint("移除 col: \(oldSeat.col), row: \(oldSeat.row), oy: \(attributes.frame.origin.y)")
        }
        if oldSeat.col == 0 {
            JPrint("col: 0 disappearingFinalYs: \(disappearingFinalYs)")
        }
        
        return attributes
    }
    
    func updateAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath) else { return nil }
        
        if insertIndexPaths.contains(itemIndexPath) {
            attributes.alpha = 0
        } else if deleteIndexPaths.contains(itemIndexPath) {
            attributes.alpha = 1
        } else if reloadIndexPaths.contains(itemIndexPath) {
            attributes.alpha = 1
        }
        // 删除不会走这里，不用判断 deleteIndexPaths
        
        return attributes
    }
    
    func updateAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath) else { return nil }
        
        if insertIndexPaths.contains(itemIndexPath) {
            attributes.alpha = 1
        } else if deleteIndexPaths.contains(itemIndexPath) {
            attributes.alpha = 0
        } else if reloadIndexPaths.contains(itemIndexPath) {
            // 刷新：旧的是覆盖在新的上面，现在对旧的进行渐变消失
            attributes.alpha = 0
        }
        
        return attributes
    }
}

extension WaterfallLayout {
    struct AttributesSeat: Hashable {
        let col: Int
        let row: Int
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(col)
            hasher.combine(row)
        }
        
        static func == (lhs: AttributesSeat, rhs: AttributesSeat) -> Bool {
            lhs.col == rhs.col && lhs.row == rhs.row
        }
    }
    
    class AttributesColumn {
        var attributes: [UICollectionViewLayoutAttributes] = []
        var colHeight: CGFloat = 0
        
        init(attributes: [UICollectionViewLayoutAttributes], colHeight: CGFloat) {
            self.attributes = attributes
            self.colHeight = colHeight
        }
    }
    
    class AttributesGrid {
        var attrsColumns: [AttributesColumn] = []
        
        func resetAll(colCount: Int, topInset: CGFloat) {
            attrsColumns = Array(0..<colCount).map { _ in
                AttributesColumn(attributes: [], colHeight: topInset)
            }
        }
        
        subscript(seat: AttributesSeat) -> UICollectionViewLayoutAttributes? {
            get {
                guard seat.col >= 0, seat.col < attrsColumns.count else {
                    return nil
                }
                let attributes = attrsColumns[seat.col].attributes
                
                guard seat.row >= 0, seat.row < attributes.count else {
                    return nil
                }
                return attributes[seat.row]
            }
        }
        
        subscript(indexPath: IndexPath) -> AttributesSeat? {
            get {
                let item = indexPath.item
                for col in 0 ..< attrsColumns.count {
                    let attributes = attrsColumns[col].attributes
                    guard let row = attributes.firstIndex(where: { $0.indexPath.item == item }) else {
                        continue
                    }
                    return AttributesSeat(col: col, row: row)
                }
                return nil
            }
        }
        
        func log() {
            var str = "\n"
            for col in 0 ..< attrsColumns.count {
                str += "-------col: \(col)-------\n"
                let column = attrsColumns[col]
                for row in 0 ..< column.attributes.count {
                    let attrs = column.attributes[row]
                    str += "["
                    str += "row: \(row), item: \(attrs.indexPath.item), x: \(attrs.frame.origin.x)"
                    str += "]\n"
                }
                str += "\n"
            }
            JPrint(str)
        }
    }
}

