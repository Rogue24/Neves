//
//  JYXBDrawingBoard.swift
//  JYXBDrawingBoard-swift
//
//  Created by xy_yanfa_imac on 2019/1/14.
//

import UIKit

public enum JYXBDrawingBoardCommand {
    case changeToWrite
    case changeToEraser
    case changeToColor(UIColor)
    case undo
    case empty
}

public typealias PointActionClosure = (_ point: JYXBDrawingBoardElement) -> Void
public typealias JYXBDrawingBoardClosure = (_ command: JYXBDrawingBoardCommand) -> Void

open class JYXBDrawingBoard: UIView {

    // 白板数据是由自己管理
    public var isDataManageBySelf: Bool = true
    // 白板是否可用
    public var isEnable: Bool = false
    // 内部操作者画的线是否直接显示在白板上
    public var isDirectRenderInternal: Bool = false

    private var originLines = [XBDrawingBoardRender]()

    public var internalOperator = JYXBDrawingBoardOperator.internalOperator(eraserWidth: 25)
    public var externalOperators = [JYXBDrawingBoardOperator]()
    public var pointActionClosure: PointActionClosure?
    public var commandClosure: JYXBDrawingBoardClosure?

    var context: CGContext?

    deinit {
        deinitHelper?.displayLink.invalidate()
        deinitHelper?.displayLink = nil
    }

    var deinitHelper: TimerDeinitHelper?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        deinitHelper = TimerDeinitHelper()
        deinitHelper?.weakObj = self
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func reset(with originLines: [XBDrawingBoardRender], scale: CGFloat = 1) {
        let lines = originLines.map { line -> XBDrawingBoardRender in
            if var item = line as? JYXBDrawingBoardLine {
                item.width = item.width * scale
                return item
            } else if var item = line as? JYXBDrawingBoardDrawTool {
                if let font = item.font {
                    item.font = font * scale
                }
                if let bold = item.bold {
                    item.bold = bold * scale
                }
                return item
            } else {
                return line
            }
        }
        self.originLines = lines
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        if context == nil {
            UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
            context = UIGraphicsGetCurrentContext()
            context?.setBlendMode(.copy)
            context?.setAllowsAntialiasing(false)
        }
    }

    @objc func render() {

        guard context != nil else {
            return
        }

        if let context = context {
            var lines = internalOperator.popLines()
            for externalOperator in externalOperators {
                lines += externalOperator.popLines()
            }
            if !originLines.isEmpty {
                lines += originLines
                originLines.removeAll()
            }
            guard !lines.isEmpty else {
                return
            }
            for line in lines {
                line.drawing(ctx: context, bounds: bounds)
            }

            let image = context.makeImage()
            layer.contents = image
        }
    }
}

// 内部操作者调用的方法
extension JYXBDrawingBoard {

    public func add(point: JYXBDrawingBoardElement) {
        self.add(point: point, with: internalOperator)
    }

    public func changeToWriteStatus() {
        self.changeToWriteStatus(with: internalOperator)
    }

    public func changeToEraserStatus() {
        self.changeToEraserStatus(with: internalOperator)
    }

    public func change(color: UIColor) {
        self.change(color: color, with: internalOperator)
    }

    public func change(width: CGFloat) {
        self.change(width: width, with: internalOperator)
    }

    public func undo() {
        self.undo(with: internalOperator)
    }

    public func emptyDrawingBoard() {
        originLines.removeAll()
        emptyDrawingBoard(with: internalOperator)
    }

    public func draw(drawTool: JYXBDrawingBoardDrawTool, scale: CGFloat = 1) {
        var tool = drawTool
        if let value = drawTool.bold {
            tool.bold = value * scale
        }
        if let value = drawTool.font {
            tool.font = value * scale
        }
        internalOperator.add(drawTool: tool)
    }
}

// 通用的操作方法，子类应将其包装成子类自己的方法，然后子类的实例调用包装后的方法，而不是用子类的实例直接调用这些方法。
extension JYXBDrawingBoard {

    public func add(point: JYXBDrawingBoardElement, with optor: JYXBDrawingBoardOperator) {
        optor.add(point: point)
    }

    public func changeToWriteStatus(with optor: JYXBDrawingBoardOperator) {
        optor.status = .write
        if optor === internalOperator, let closure = commandClosure {
            closure(.changeToWrite)
        }
    }

    public func changeToEraserStatus(with optor: JYXBDrawingBoardOperator) {
        optor.status = .eraser
        if optor === internalOperator, let closure = commandClosure {
            closure(.changeToEraser)
        }
    }

    public func change(color: UIColor, with optor: JYXBDrawingBoardOperator) {
        optor.color = color
        if optor === internalOperator, let closure = commandClosure {
            closure(.changeToColor(color))
        }
    }

    public func change(width: CGFloat, with optor: JYXBDrawingBoardOperator) {
        optor.width = width
    }

    public func undo(with optor: JYXBDrawingBoardOperator) {
        guard let context = context else {
            return
        }
        guard isDataManageBySelf else {
            layer.contents = nil
            context.clear(bounds)
            if optor === internalOperator, let closure = commandClosure {
                closure(.undo)
            }
            return
        }
        // 线判断optor是否有线条可以撤销，如果没有，就直接返回了
        guard optor.undo() else {
            return
        }
        layer.contents = nil
        context.clear(bounds)
        // 因为把context清空了，当前optor要undo,画板的其它optor要刷新
        if optor === internalOperator {
            for externalOptor in externalOperators {
                externalOptor.refresh()
            }
            if let closure = commandClosure {
                closure(.undo)
            }
        } else {
            internalOperator.refresh()
            for externalOptor in externalOperators where externalOptor !== optor {
                externalOptor.refresh()
            }
        }
    }

    public func emptyDrawingBoard(with optor: JYXBDrawingBoardOperator) {
        guard let context = context else {
            return
        }
        layer.contents = nil
        context.clear(bounds)
        internalOperator.empty()
        for optor in externalOperators {
            optor.empty()
        }
        if optor === internalOperator, let closure = commandClosure {
            closure(.empty)
        }
    }
}

extension JYXBDrawingBoard {

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isEnable else {
            return
        }
        var point = touches.first!.location(in: self)
        point.x += 50
        point.y += 50
        let isPencil = touches.first!.type == .pencil
        let boardPoint = JYXBDrawingBoardElement(point: point, action: .begin, type: .internalPoint, isPencil: isPencil)

        if let closure = pointActionClosure {
            let externalPoint = JYXBDrawingBoardElement(point: bounds.scalePoint(point: point), action: .begin, type: .externalPoint, isPencil: isPencil)
            closure(externalPoint)
        }

        guard isDirectRenderInternal else {
            return
        }
        self.add(point: boardPoint)
    }

    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isEnable else {
            return
        }
        var point = touches.first!.location(in: self)
        let isPencil = touches.first!.type == .pencil
        JPrint("000 point \(point)")
        point.x += 50
        point.y += 50
        let boardPoint = JYXBDrawingBoardElement(point: point, action: .move, type: .internalPoint, isPencil: isPencil)
        JPrint("000 boardPoint \(boardPoint)")
        JPrint("----------------")
        
        if let closure = pointActionClosure {
            let externalPoint = JYXBDrawingBoardElement(point: bounds.scalePoint(point: point), action: .move, type: .externalPoint, isPencil: isPencil)
            closure(externalPoint)
        }

        guard isDirectRenderInternal else {
            return
        }
        self.add(point: boardPoint)
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isEnable else {
            return
        }
        var point = touches.first!.location(in: self)
        point.x += 50
        point.y += 50
        let isPencil = touches.first!.type == .pencil
        let boardPoint = JYXBDrawingBoardElement(point: point, action: .end, type: .internalPoint, isPencil: isPencil)

        if let closure = pointActionClosure {
            let externalPoint = JYXBDrawingBoardElement(point: bounds.scalePoint(point: point), action: .end, type: .externalPoint, isPencil: isPencil)
            closure(externalPoint)
        }

        guard isDirectRenderInternal else {
            return
        }
        self.add(point: boardPoint)
    }

}

class TimerDeinitHelper: NSObject {
    var displayLink: CADisplayLink!

    weak var weakObj: JYXBDrawingBoard?

    @objc func render() {
        weakObj?.render()
    }

    override init() {
        super.init()
        displayLink = CADisplayLink(target: self, selector: #selector(render))
        displayLink.add(to: RunLoop.main, forMode: .common)
    }
}
