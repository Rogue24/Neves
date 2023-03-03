//
//  JYXBDrawingBoardOperator.swift
//  JYXBDrawingBoard-swift
//
//  Created by xy_yanfa_imac on 2019/1/16.
//

import UIKit

// 画板点结构体
public struct JYXBDrawingBoardElement {
    //  画板点动作类型枚举
    public enum JYXBDrawingBoardPointAction {
        case begin
        case move
        case end
    }

    public enum JYXBDrawingBoardPointType {
        case internalPoint
        case externalPoint
    }

    public var point: CGPoint
    public var action: JYXBDrawingBoardPointAction
    public var type: JYXBDrawingBoardPointType
    public var toolElement: JYXBDrawingBoardDrawTool?
    public var isPencil: Bool

    public init(point: CGPoint, action: JYXBDrawingBoardPointAction,
                type: JYXBDrawingBoardPointType,
                element: JYXBDrawingBoardDrawTool? = nil,
                isPencil: Bool = false) {
        self.point = point
        self.action = action
        self.type = type
        toolElement = element
        self.isPencil = isPencil
    }
}

/// 可绘制的协议
public protocol XBDrawingBoardRender {
    /// 绘制
    /// - Parameters:
    ///   - ctx: 上下文
    ///   - bounds: 参考系
    func drawing(ctx: CGContext, bounds: CGRect)
}

public enum XBDrawToolType: Int {
    case normal = 0
    case line = 1
    case rect = 2
    case oval = 3
    case text = 4
}

/// 画图工具
public struct JYXBDrawingBoardDrawTool: XBDrawingBoardRender {
    public var color: UIColor = .black
    public var start: CGPoint = .zero
    public var end: CGPoint = .zero
    public var text: String?
    public var bold: CGFloat? = 1.5
    public var font: CGFloat? = 12
    public var type: XBDrawToolType = .normal

    public init(type: XBDrawToolType,
                color: UIColor,
                start: CGPoint,
                end: CGPoint,
                font: CGFloat? = nil,
                bold: CGFloat? = nil,
                text: String? = nil) {
        self.type = type
        self.color = color
        self.start = start
        self.end = end
        self.bold = bold
        self.font = font
        self.text = text
    }

    public func drawing(ctx: CGContext, bounds: CGRect) {
        let absoluteStart = bounds.absolutePoint(point: start)
        let absoluteEnd = bounds.absolutePoint(point: end)

        switch type {
        case .line:
            let path = UIBezierPath()
            path.move(to: absoluteStart)
            path.addLine(to: absoluteEnd)
            ctx.addPath(path.cgPath)

        case .rect:
            let path = UIBezierPath(rect: absoluteStart.getRect(to: absoluteEnd))
            ctx.addPath(path.cgPath)

        case .oval:
            let path = UIBezierPath.init(ovalIn: absoluteStart.getRect(to: absoluteEnd))
            ctx.addPath(path.cgPath)

        case .text:
            var rect = absoluteStart.getRect(to: absoluteEnd)
            let textWidth = text?.xb_stringWidth(font: UIFont.systemFont(ofSize: (font ?? 24)), maxHeight: rect.height) ?? 0
            if rect.width < textWidth {
                rect = CGRect(x: rect.origin.x, y: rect.origin.y, width: textWidth, height: rect.size.height)
            }
            text?.xb_toAttribute().xb_font(UIFont.systemFont(ofSize: (font ?? 24))).xb_color(color).draw(in: rect)
            return

        default:
            /// 正常模式不能画，理论上正常模式不应该进来
            return
        }

        ctx.setLineWidth(bold ?? 1)
        ctx.setLineJoin(.round)
        ctx.setLineCap(.round)
        ctx.setStrokeColor(color.cgColor)
        ctx.strokePath()
    }
}

// 画板线条结构体
public struct JYXBDrawingBoardLine: XBDrawingBoardRender {
    public var color: UIColor = .black
    public var width: CGFloat = 2
    private var points: [JYXBDrawingBoardElement] = [JYXBDrawingBoardElement]()

    public var pointCount: Int {
        get {
            points.count
        }
    }

    public var fisrtPoint: JYXBDrawingBoardElement? {
        get {
            points.first
        }
    }

    public var lastPoint: JYXBDrawingBoardElement? {
        get {
            points.last
        }
    }

    public var allPoint: [JYXBDrawingBoardElement] {
        get {
            points
        }
    }

    public func point(with index: Int) -> JYXBDrawingBoardElement {
        if index >= points.count {
            fatalError("array out of range")
        }
        return points[index]
    }

    public init(color: UIColor, width: CGFloat, point: [JYXBDrawingBoardElement] = [JYXBDrawingBoardElement]()) {
        self.color = color
        self.width = width
        points = point
    }

    mutating func add(_ point: JYXBDrawingBoardElement) {
        points.append(point)
    }

    public func drawing(ctx: CGContext, bounds: CGRect) {
        guard pointCount > 0 else {
            return
        }

        let path = UIBezierPath()
        if pointCount == 1 {
            move(to: fisrtPoint!, with: path, bounds: bounds)
        } else {
            move(to: fisrtPoint!, with: path, bounds: bounds)
            for index in 1...pointCount - 1 {
                addLine(to: point(with: index), with: path, bounds: bounds)
            }
        }
        ctx.addPath(path.cgPath)
        ctx.setLineJoin(.round)
        ctx.setLineCap(.round)
        ctx.setStrokeColor(color.cgColor)
        ctx.setLineWidth(width)
        ctx.strokePath()
    }
}

// 画板操作者类型枚举
enum JYXBDrawingBoardOperatorType {
    // 内部操作者 （直接操作画板  --  UI驱动）
    case internalOperator
    // 外部操作者 （通过命令操作画板  --  命令驱动）
    case externalOperator
}

// 画板操作者当前出的状态
public enum JYXBDrawingBoardOperatorStatus {
    // 书写
    case write
    // 擦除
    case eraser
}

public class JYXBDrawingBoardOperator {

    var type: JYXBDrawingBoardOperatorType = .internalOperator
    var status: JYXBDrawingBoardOperatorStatus = .write
    var color: UIColor = .black
    var width: CGFloat = 2.0
    var eraserWidth: CGFloat = 25

    // 用于记录当前操作者所画的自然线条数据（begin-move-move-move-end）
    // 之所以称之为自然线条，是因为pointsBuf由于displaylink的关系，生成的并不是完整的线条
    // 所以添加了natureLines这个私有属性，用于在 撤销 或者 刷新 时来减少计算量。
    // 见add(point）方法的逻辑
    private var natureLines = [XBDrawingBoardRender]()
    // 用于撤销时
    private var natureLinesBuf = [XBDrawingBoardRender]()
    private var pointsBuf = [JYXBDrawingBoardElement]()
    private var lastBufPoint: JYXBDrawingBoardElement?

    init(type: JYXBDrawingBoardOperatorType, color: UIColor, width: CGFloat, eraserWidth: CGFloat) {
        self.type = type
        self.color = color
        self.width = width
        self.eraserWidth = eraserWidth
    }

    static func internalOperator(eraserWidth: CGFloat, color: UIColor = UIColor.black) -> JYXBDrawingBoardOperator {
        let internalOperator = JYXBDrawingBoardOperator(type: .internalOperator, color: color, width: 2.0, eraserWidth: eraserWidth)
        return internalOperator
    }

    func popLines() -> [XBDrawingBoardRender] {

        var lines = [XBDrawingBoardRender]()
        guard !pointsBuf.isEmpty else {
            return lines
        }

        var bufPoints = [JYXBDrawingBoardElement]()
        if !pointsBuf.isEmpty {
            if let point = lastBufPoint {
                bufPoints.append(point)
            }
            bufPoints.append(contentsOf: pointsBuf)
            pointsBuf.removeAll()
        } else {
            return lines
        }

        var line: JYXBDrawingBoardLine?
        for point in bufPoints {
            /// 画图工具
            if let toolElement = point.toolElement {
                lines.append(toolElement)
                continue
            }
            switch point.action {
            case .begin:
                let width = status == .write ? width : eraserWidth
                let color = status == .write ? color : UIColor.clear
                var lineElement = JYXBDrawingBoardLine(color: color, width: width)
                lineElement.add(point)
                line = lineElement
            case .move:
                if var lineElement = line {
                    lineElement.add(point)
                    line = lineElement
                } else {
                    let width = status == .write ? width : eraserWidth
                    let color = status == .write ? color : UIColor.clear
                    var lineElement = JYXBDrawingBoardLine(color: color, width: width)
                    lineElement.add(point)
                    line = lineElement
                }
            case .end:
                if var lineElement = line {
                    lineElement.add(point)
                    if isVaild(for: lineElement) {
                        lines.append(lineElement)
                    }
                }
                line = nil
                lastBufPoint = nil
            }
        }

        if let lastPoint = bufPoints.last, lastPoint.toolElement == nil && lastPoint.action != .end {
            lastBufPoint = lastPoint
        }
        if let lineElement = line, isVaild(for: lineElement) {
            lines.append(lineElement)
        }
        return lines
    }

    func isVaild(for line: JYXBDrawingBoardLine) -> Bool {
        if let first = line.fisrtPoint, let last = line.lastPoint {
            let isValid = !(first.point.x == last.point.x && first.point.y == last.point.y)
            return isValid
        } else {
            return false
        }
    }
}

extension JYXBDrawingBoardOperator {

    func add(drawTool: JYXBDrawingBoardDrawTool) {

        let element = JYXBDrawingBoardElement(point: .zero, action: .move, type: .internalPoint, element: drawTool)
        pointsBuf.append(element)
        natureLines.append(drawTool)
    }

    func add(point: JYXBDrawingBoardElement) {
        pointsBuf.append(point)
    }

    func empty() {
        natureLines.removeAll()
        pointsBuf.removeAll()
    }

    func refresh() {
        guard !natureLines.isEmpty else {
            return
        }
        natureLinesBuf = natureLines
    }

    func undo() -> Bool {
        guard !natureLines.isEmpty else {
            return false
        }
        natureLines.removeLast()
        natureLinesBuf = natureLines
        return true
    }

    func changeColor(color: UIColor) {
        self.color = color
    }

    func change(width: CGFloat) {
        self.width = width
    }
}

func move(to point: JYXBDrawingBoardElement, with path: UIBezierPath, bounds: CGRect) {
    switch point.type {
    case .internalPoint:
        path.move(to: point.point)
    case .externalPoint:
        path.move(to: bounds.absolutePoint(point: point.point))
    }
}

func addLine(to point: JYXBDrawingBoardElement, with path: UIBezierPath, bounds: CGRect) {
    switch point.type {
    case .internalPoint:
        path.addLine(to: point.point)
    case .externalPoint:
        path.addLine(to: bounds.absolutePoint(point: point.point))
    }
}

public extension CGRect {
    func scalePoint(point: CGPoint) -> CGPoint {
        CGPoint(x: point.x / size.width, y: point.y / size.height)
    }

    func absolutePoint(point: CGPoint) -> CGPoint {
        CGPoint(x: point.x * size.width, y: point.y * size.height)
    }
}
