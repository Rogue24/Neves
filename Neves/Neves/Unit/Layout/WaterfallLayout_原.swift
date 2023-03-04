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
    
    var attributesArray: [UICollectionViewLayoutAttributes] = []
    var attributesColumns: [AttributesColumn] = []
    
    var oldColCount = 0
    lazy var oldAttributesColumns: [AttributesColumn] = Array(0 ..< colCount).map {
        AttributesColumn(col: $0, colHeight: edgeInsets.top)
    }
    var appearingInitialYs: [Seat: CGFloat] = [:]
    var disappearingFinalYs: [Seat: CGFloat] = [:]
    
    override func prepare() {
        super.prepare()
        setupAllAttributes()
        setupContentSize()
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        attributesArray
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
        
        let colCount = self.colCount
        guard isReloadSection, oldColCount == colCount else { return }
        let rowMargin = self.rowMargin
        let edgeInsets = self.edgeInsets
        
        for col in 0 ..< colCount {
            let oldAttrColumn = oldAttributesColumns[col]
            let newAttrColumn = attributesColumns[col]
            
            let oldAttrSeats = oldAttrColumn.attributesSeats
            let newAttrSeats = newAttrColumn.attributesSeats
            
            let oldRowCount = oldAttrSeats.count
            let newRowCount = newAttrSeats.count
            
            guard oldRowCount != newRowCount else { continue }
            
            if oldRowCount > newRowCount {
                var beginY = newAttrColumn.colHeight
                for row in newRowCount ..< oldRowCount {
                    let attrSeat = oldAttrSeats[row]
                    let attrY = beginY + (beginY > edgeInsets.top ? rowMargin : 0)
                    disappearingFinalYs[attrSeat.seat] = attrY
                    beginY += attrSeat.attributes.frame.height
                }
            } else {
                var beginY = oldAttrColumn.colHeight
                for row in oldRowCount ..< newRowCount {
                    let attrSeat = newAttrSeats[row]
                    let attrY = beginY + (beginY > edgeInsets.top ? rowMargin : 0)
                    appearingInitialYs[attrSeat.seat] = attrY
                    beginY += attrSeat.attributes.frame.height
                }
            }
        }
    }
    
    override func finalizeCollectionViewUpdates() {
        insertIndexPaths.removeAll()
        deleteIndexPaths.removeAll()
        reloadIndexPaths.removeAll()
        isReloadSection = false
        
        oldColCount = colCount
        oldAttributesColumns = attributesColumns
        appearingInitialYs.removeAll()
        disappearingFinalYs.removeAll()
    }
    
    
    // 从 刚创建出来时的样式设置 --到--> 正常状态：这里设置的是展示动画的【初始状态】，例如设置了alpha为0，动画会自动变为1
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if isReloadSection {
            let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath) ?? UICollectionViewLayoutAttributes(forCellWith: itemIndexPath)
            attributes.zIndex = 1
            attributes.alpha = 0
            if let seat = findSeat(with: itemIndexPath.item, in: attributesColumns) {
                if let attrSeat = findAttributesSeat(with: seat, in: oldAttributesColumns) {
                    attributes.frame = attrSeat.attributes.frame
                } else {
                    let attributesColumn = attributesColumns[seat.col]
                    let attributesSeat = attributesColumn.attributesSeats[seat.row]
                    attributes.frame = attributesSeat.attributes.frame
                    if let initialY = appearingInitialYs[attributesSeat.seat] {
                        attributes.frame.origin.y = initialY
                    }
                }
            }
            return attributes
        }
        
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

    // 从 正常状态 --到--> 最后消失时的样式设置：这里设置的是消失动画的【最终状态】
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath) else { return nil }
        
        if isReloadSection {
            attributes.zIndex = 0
            attributes.alpha = 0
            if let seat = findSeat(with: itemIndexPath.item, in: oldAttributesColumns) {
                if let attrSeat = findAttributesSeat(with: seat, in: attributesColumns) {
                    attributes.frame = attrSeat.attributes.frame
                } else {
                    let attributesColumn = oldAttributesColumns[seat.col]
                    let attributesSeat = attributesColumn.attributesSeats[seat.row]
                    attributes.frame = attributesSeat.attributes.frame
                    if let finalY = disappearingFinalYs[attributesSeat.seat] {
                        attributes.frame.origin.y = finalY
                    }
                }
            }
            return attributes
        }
        
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
    func setupAllAttributes() {
        let colCount = self.colCount
        let colMargin = self.colMargin
        let rowMargin = self.rowMargin
        let edgeInsets = self.edgeInsets
        
        attributesArray.removeAll()
        attributesColumns = Array(0 ..< colCount).map {
            AttributesColumn(col: $0, colHeight: edgeInsets.top)
        }
        
        let collectionViewW = collectionView?.frame.width ?? 0
        let width = (collectionViewW - edgeInsets.left - edgeInsets.right - CGFloat(colCount - 1) * colMargin) / CGFloat(colCount)
        
        let numberOfItems = collectionView?.numberOfItems(inSection: 0) ?? 0
        for i in 0 ..< numberOfItems {
            // 找出高度最小的那一列
            var minColumn = findMinHeightColumn()
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: i, section: 0))
            attributes.frame = CGRect(
                x: edgeInsets.left + CGFloat(minColumn.col) * (width + colMargin),
                y: minColumn.colHeight + (minColumn.colHeight > edgeInsets.top ? rowMargin : 0),
                width: width,
                height: delegate?.waterfallLayout(self, heightForItemAtIndex: i, itemWidth: width) ?? width
            )
            
            let attributesSeat = AttributesSeat(seat: Seat(col: minColumn.col, row: minColumn.attributesSeats.count), attributes: attributes)
            minColumn.attributesSeats.append(attributesSeat)
            minColumn.colHeight = attributes.frame.maxY // 刷新最短那列的高度
            
            attributesColumns[minColumn.col] = minColumn
            attributesArray.append(attributes)
        }
    }
    
    func setupContentSize() {
        let maxColumn = findMaxHeightColumn()
        contentSize = CGSize(width: 0, height: maxColumn.colHeight + edgeInsets.bottom)
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
    
    struct AttributesSeat {
        var seat: Seat
        var attributes: UICollectionViewLayoutAttributes
    }
    
    struct AttributesColumn {
        var col: Int
        var colHeight: CGFloat
        var attributesSeats: [AttributesSeat] = []
    }
}

extension WaterfallLayout {
    func findMinHeightColumn() -> AttributesColumn {
        var destColumn = attributesColumns[0]
        for column in attributesColumns where destColumn.colHeight > column.colHeight {
            destColumn = column
        }
        return destColumn
    }
    
    func findMaxHeightColumn() -> AttributesColumn {
        var destColumn = attributesColumns[0]
        for column in attributesColumns where destColumn.colHeight < column.colHeight {
            destColumn = column
        }
        return destColumn
    }
    
    func findSeat(with item: Int, in attributesColumns: [AttributesColumn]) -> Seat? {
        for col in 0 ..< attributesColumns.count {
            let column = attributesColumns[col]
            guard let attributesSeat = column.attributesSeats.first(where: { $0.attributes.indexPath.item == item }) else {
                continue
            }
            return attributesSeat.seat
        }
        return nil
    }
    
    func findAttributesSeat(with seat: Seat, in attributesColumns: [AttributesColumn]) -> AttributesSeat? {
        guard seat.col < attributesColumns.count else {
            return nil
        }
        let column = attributesColumns[seat.col]
        
        guard seat.row < column.attributesSeats.count else {
            return nil
        }
        return column.attributesSeats[seat.row]
    }
}
