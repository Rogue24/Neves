//
//  EMLUserTitleFlowView.swift
//  Falla
//
//  Created by aa on 2025/6/10.
//

import UIKit

protocol EMLUserTitleFlowViewDelegate: AnyObject {
    func userTitleFlowView(_ titleFlowView: EMLUserTitleFlowView, didSelectCellFor jumpUrl: String)
}

@objcMembers
class EMLUserTitleFlowView: UIView {
    weak var delegate: EMLUserTitleFlowViewDelegate?
    
    private var _layout: Layout
    var layout: Layout {
        get { _layout }
        set {
            guard _layout != newValue else { return }
            _layout = newValue
            reloadData(viewModel.cellModels, animated: true)
        }
    }
    
    var cellAnimated = false
    
    var viewFrame: CGRect { viewModel.frame }
    
    private var viewModel: ViewModel
    private var visibleCells: [SVGAExImageView] = []
    private var reusableCells: [SVGAExImageView] = []
    private var animTag: UUID?
    
    init(_ layout: Layout) {
        self._layout = layout
        self.viewModel = .build(forLayout: layout, dataSource: [CellModel]())
        super.init(frame: viewModel.frame)
        clipsToBounds = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func tapCell(_ tapGR: UITapGestureRecognizer) {
        let index = tapGR.view?.tag ?? 0
        let cellModels = viewModel.cellModels
        guard let delegate, index < cellModels.count else { return }
        delegate.userTitleFlowView(self, didSelectCellFor: cellModels[index].jumpUrl)
    }
}

// MARK: - 布局 Define
extension EMLUserTitleFlowView {
    enum Alignment: Int {
        case leading
        case center
        case trailing
    }
    
    struct Layout: Equatable {
        var viewOrigin: CGPoint
        var viewWidth: CGFloat
        var contentInset: UIEdgeInsets
        var contentAlignment: Alignment
        var interitemSpacing: CGFloat
        var lineSpacing: CGFloat
        var itemHeight: CGFloat
        
        init(viewOrigin: CGPoint = .zero, viewWidth: CGFloat,
             contentInset: UIEdgeInsets = .zero,
             contentAlignment: Alignment = .leading,
             interitemSpacing: CGFloat, lineSpacing: CGFloat,
             itemHeight: CGFloat) {
            self.viewOrigin = viewOrigin
            self.viewWidth = viewWidth
            self.contentInset = contentInset
            self.contentAlignment = contentAlignment
            self.interitemSpacing = interitemSpacing
            self.lineSpacing = lineSpacing
            self.itemHeight = itemHeight
        }
    }
}

// MARK: - ViewModel
private extension EMLUserTitleFlowView {
    struct ViewModel {
        var frame: CGRect
        let contentFrame: CGRect
        let cellModels: [CellModel]
        
        static func build<T: EMLUserTitleCellModel>(forLayout layout: Layout, dataSource: [T]) -> ViewModel {
            let viewOrigin = layout.viewOrigin
            let viewWidth = layout.viewWidth
            let contentInset = layout.contentInset
            
            guard dataSource.count > 0 else {
                return ViewModel(frame: CGRect(origin: viewOrigin, size: [viewWidth, 0]),
                                 contentFrame: [contentInset.left, contentInset.top, 0, 0],
                                 cellModels: [])
            }
            
            let lineSpacing = layout.lineSpacing
            let interitemSpacing = layout.interitemSpacing
            let itemHeight = layout.itemHeight
            
            let contentW = viewWidth - contentInset.left - contentInset.right
            let contentMaxX = contentInset.left + contentW
            
            var cellX = contentInset.left
            var cellY = contentInset.top
            
            var cellModels: [CellModel] = []
            var allRowCellModels: [[CellModel]] = [[]]
            var row = 0
            
            for i in 0 ..< dataSource.count {
                if i > 0 {
                    let lastCellModel = cellModels[i - 1]
                    if lastCellModel.frame.origin.y == cellY {
                        cellX = lastCellModel.frame.maxX + interitemSpacing
                    }
                }
                
                let data = dataSource[i]
                let itemSize: CGSize = [itemHeight * data.aspectRatio, itemHeight]
                
                if cellX > contentInset.left, (cellX + itemSize.width) > contentMaxX {
                    cellX = contentInset.left
                    cellY += itemSize.height + lineSpacing
                    allRowCellModels.append([])
                    row += 1
                }
                
                let cellModel = CellModel(frame: CGRect(origin: [cellX, cellY], size: itemSize),
                                          source: data.source, jumpUrl: data.jumpUrl)
                cellModels.append(cellModel)
                
                var rowCellModels = allRowCellModels[row]
                rowCellModels.append(cellModel)
                allRowCellModels[row] = rowCellModels
            }
            
            let alignment = layout.contentAlignment
            if (!Env.isRTL && alignment != .leading) || (Env.isRTL && alignment != .trailing) {
                cellModels.removeAll()
                
                for r in 0 ..< allRowCellModels.count {
                    let rowCellModels = allRowCellModels[r]
                    let totalWidth = (rowCellModels.last?.frame.maxX ?? 0) - contentInset.left
                    
                    let diffX: CGFloat
                    switch alignment {
                    case .leading, .trailing:
                        diffX = contentW - totalWidth
                    case .center:
                        diffX = (contentW - totalWidth) / 2
                    }
                    
                    rowCellModels.forEach {
                        var cellModel = $0
                        cellModel.frame.origin.x += diffX
                        cellModels.append(cellModel)
                    }
                }
            }
            
            let contentH = CGFloat(row + 1) * itemHeight + CGFloat(row) * lineSpacing
            let viewHeight = contentInset.top + contentH + contentInset.bottom
            
            return ViewModel(frame: CGRect(origin: viewOrigin, size: [viewWidth, viewHeight]),
                             contentFrame: [contentInset.left, contentInset.top, contentW, contentH],
                             cellModels: cellModels)
        }
    }
}

extension EMLUserTitleFlowView {
    // MARK: - API: 计算整体高度
    static func calculateHeight<T: EMLUserTitleCellModel>(forLayout layout: Layout, dataSource: [T]) -> CGFloat {
        guard dataSource.count > 0 else { return 0 }
        
        let viewWidth = layout.viewWidth
        let contentInset = layout.contentInset
        let lineSpacing = layout.lineSpacing
        let interitemSpacing = layout.interitemSpacing
        let itemHeight = layout.itemHeight
        
        let contentW = viewWidth - contentInset.left - contentInset.right
        let contentMaxX = contentInset.left + contentW
        
        var cellX = contentInset.left
        var cellY = contentInset.top
        
        var cellFrame: CGRect = .zero
        var row = 0
        
        for i in 0 ..< dataSource.count {
            if i > 0 {
                cellX = cellFrame.maxX + interitemSpacing
            }
            
            let data = dataSource[i]
            let itemSize: CGSize = [itemHeight * data.aspectRatio, itemHeight]
            
            if cellX > contentInset.left, (cellX + itemSize.width) > contentMaxX {
                cellX = contentInset.left
                cellY += itemSize.height + lineSpacing
                row += 1
            }
            
            cellFrame = CGRect(origin: [cellX, cellY], size: itemSize)
        }
        
        let contentH = CGFloat(row + 1) * itemHeight + CGFloat(row) * lineSpacing
        let viewHeight = contentInset.top + contentH + contentInset.bottom
        
        return viewHeight
    }
    
    // MARK: - API: 刷新数据和UI布局
    func reloadData<T: EMLUserTitleCellModel>(_ dataSource: [T],
                                              layout: Layout? = nil,
                                              viewFrameHandler: ((_ frame: CGRect) -> CGRect)? = nil,
                                              animated: Bool = false) {
        if let layout {
            _layout = layout
        }
        
        viewModel = .build(forLayout: _layout, dataSource: dataSource)
        
        if let viewFrameHandler {
            viewModel.frame = viewFrameHandler(viewModel.frame)
            _layout.viewOrigin = viewModel.frame.origin
            _layout.viewWidth = viewModel.frame.width
        }
        
        let frame = viewModel.frame
        let cellModels = viewModel.cellModels
        
        var displayCells: [SVGAExImageView] = []
        var dismissCells: [SVGAExImageView] = []
        
        if visibleCells.count > cellModels.count {
            for i in 0 ..< visibleCells.count {
                let cell = visibleCells[i]
                if i < cellModels.count {
                    displayCells.append(cell)
                } else {
                    dismissCells.append(cell)
                }
            }
        } else {
            for i in 0 ..< cellModels.count {
                let cell: SVGAExImageView
                if i < visibleCells.count {
                    cell = visibleCells[i]
                } else {
                    cell = reusableCells.count > 0 ? reusableCells.removeFirst() : {
                        let imgView = SVGAExImageView()
                        imgView.imageContentMode = .scaleToFill
                        imgView.playerContentMode = .scaleToFill
                        imgView.imgViewUseType = .sweep
                        imgView.isUseCurrentImageAsPlaceholder = true
                        imgView.isUserInteractionEnabled = true
                        imgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCell(_:))))
                        return imgView
                    }()
                    cell.frame = cellModels[i].frame
                    cell.alpha = 0
                    addSubview(cell)
                }
                displayCells.append(cell)
            }
        }
        
//        EML_DebugLog("EMLUserTitleFlowView 目标：显示\(dataSource.count)个cell")
//        EML_DebugLog("EMLUserTitleFlowView 目前：显示\(visibleCells.count)个cell，回收\(reusableCells.count)个cell")
//        EML_DebugLog("EMLUserTitleFlowView 需要：显示\(displayCells.count)个cell，回收\(dismissCells.count)个cell")
//        EML_DebugLog("EMLUserTitleFlowView --------------------------------------")
        
        visibleCells = displayCells
        reusableCells = dismissCells
        
        guard animated else {
            for i in 0 ..< displayCells.count {
                let cell = displayCells[i]
                let cellModel = cellModels[i]
                cell.updateUI(source: cellModel.source, animated: cellAnimated)
                cell.frame = cellModel.frame
                cell.alpha = 1
                cell.tag = i
            }
            
            dismissCells.forEach {
                $0.clean()
                $0.removeFromSuperview()
            }
            
            self.frame = frame
            return
        }
        
        let newTag = UUID()
        animTag = newTag
        
        UIView.animate(withDuration: 0.65, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0) {
            for i in 0 ..< displayCells.count {
                let cell = displayCells[i]
                let cellModel = cellModels[i]
                cell.updateUI(source: cellModel.source, animated: self.cellAnimated)
                cell.frame = cellModel.frame
                cell.alpha = 1
                cell.tag = i
            }
            
            dismissCells.forEach {
                $0.alpha = 0
            }
            
            self.frame = frame
        } completion: { _ in
            guard self.animTag == newTag else {
//                EML_DebugLog("EMLUserTitleCollectionView 中途被打断！！！")
                return
            }
            
            dismissCells.forEach {
                $0.clean()
                $0.removeFromSuperview()
            }
            
            self.animTag = nil
        }
    }
}
