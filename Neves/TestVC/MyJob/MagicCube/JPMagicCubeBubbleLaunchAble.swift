//
//  JPMagicCubeBubbleLaunchAble.swift
//  Neves
//
//  Created by aa on 2021/7/21.
//

protocol JPMagicCubeBubbleLaunchAble: UIView {
    var bubbleView: JPMagicCubeBubbleView? { set get }
    var isCacheBubble: Bool { get }
    var horBubbleSpace: CGFloat { get }
    var verBubbleSpace: CGFloat { get }
    var bubbleSafeFrame: CGRect { get }
}

extension JPMagicCubeBubbleLaunchAble {
    var bubbleSafeFrame: CGRect { superview.map { $0.bounds } ?? .zero }
    
    func launchMagicCubeBubble(awardInfo: JPMagicGiftInfo) {
        if let gestureRecognizers = self.gestureRecognizers {
            for gr in gestureRecognizers where gr is UIPanGestureRecognizer && gr.state == .changed {
                return
            }
        }
        
        let isToLeft = frame.midX < bubbleSafeFrame.width * 0.5
        
        var isToTop = true
        let minY = frame.origin.y - JPMagicCubeBubbleView.bubbleH - verBubbleSpace
        if minY < bubbleSafeFrame.origin.y {
            isToTop = false
        }
        
        let site: JPMagicCubeBubbleView.Site
        let launchPoint: CGPoint
        
        switch (isToLeft, isToTop) {
        case (true, true):
            site = .topLeft
            launchPoint = [-horBubbleSpace, -verBubbleSpace]
            
        case (false, true):
            site = .topRight
            launchPoint = [frame.width + horBubbleSpace, -verBubbleSpace]
            
        case (false, false):
            site = .bottomRight
            launchPoint = [frame.width + horBubbleSpace, frame.height + verBubbleSpace]
            
        case (true, false):
            site = .bottomLeft
            launchPoint = [-horBubbleSpace, frame.height + verBubbleSpace]
        }
        
        if isCacheBubble {
            if let bubbleView = self.bubbleView, !bubbleView.isAnimating {
                bubbleView.launch(awardInfo: awardInfo, site: site, launchPoint: launchPoint)
            } else {
                bubbleView?.stop(andRemove: true)
                bubbleView = JPMagicCubeBubbleView.launch(on: self, awardInfo: awardInfo, site: site, launchPoint: launchPoint)
            }
            return
        }
        
        bubbleView?.stop(andRemove: true)
        bubbleView = JPMagicCubeBubbleView.launch(on: self, awardInfo: awardInfo, site: site, launchPoint: launchPoint) { bubble in
            bubble.removeFromSuperview()
        }
    }
}
