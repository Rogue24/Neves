//
//  JYXBOTODrawingBoard.swift
//  JYXBDrawingBoard-swift
//
//  Created by xy_yanfa_imac on 2019/1/16.
//

import UIKit

public class JYXBOTODrawingBoard: JYXBDrawingBoard {

    public var peerOpertor: JYXBDrawingBoardOperator!

    public var peerColor = UIColor.red {
        didSet {
            if peerOpertor != nil {
                peerOpertor.color = peerColor
            }
        }
    }

    public var selfColor = UIColor.black {
        didSet {
            internalOperator.color = selfColor
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        peerOpertor = JYXBDrawingBoardOperator(type: .externalOperator, color: peerColor, width: 2, eraserWidth: 0)
        externalOperators.append(peerOpertor)
        internalOperator = JYXBDrawingBoardOperator.internalOperator(eraserWidth: 0, color: selfColor)
        isDataManageBySelf = false
        isEnable = true
        isDirectRenderInternal = true
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        if bounds != .zero {
            peerOpertor.eraserWidth = bounds.height * 0.1
            internalOperator.eraserWidth = bounds.height * 0.1
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public var internalOptorStatus: JYXBDrawingBoardOperatorStatus {
        internalOperator.status
    }
}

extension JYXBOTODrawingBoard {

    public func add(peerPoint point: JYXBDrawingBoardElement) {
        self.add(point: point, with: peerOpertor)
    }

    public func peerChangeToWriteStatus() {
        self.changeToWriteStatus(with: peerOpertor)
    }

    public func peerChangeToEraserStatus() {
        self.changeToEraserStatus(with: peerOpertor)
    }

    public func peerUndo() {
        self.undo(with: peerOpertor)
    }

    public func peerEmptyDrawingBoard() {
        self.emptyDrawingBoard(with: peerOpertor)
    }

    public func peerChange(color: UIColor) {
        self.change(color: color, with: peerOpertor)
    }

    public func peerChange(width: CGFloat) {
        self.change(width: width, with: peerOpertor)
    }
}
