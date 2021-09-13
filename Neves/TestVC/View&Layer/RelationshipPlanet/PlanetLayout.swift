//
//  PlanetLayout.swift
//  Neves
//
//  Created by aa on 2021/8/30.
//

class PlanetLayout: UICollectionViewLayout {
    
    var attriArray: [UICollectionViewLayoutAttributes] = []
    
    let radian360 = CGFloat.pi * 2
    let radian180 = CGFloat.pi
    let radian90 = CGFloat.pi * 0.5
    
    let cellSize: CGSize = [50, 50]
    var cellCount: CGFloat = 0
    var radius: CGFloat = 0
    
    // 圆心
    var baseCircleX: CGFloat = 0
    var baseCircleY: CGFloat = 0
    
    var contentH: CGFloat = 0
    
    override func prepare() {
        super.prepare()
        
        attriArray.removeAll()
        
        guard let collectionView = collectionView else { return }
        
        if radius == 0 {
            // 圆心
            baseCircleX = collectionView.frame.width * 0.5
            baseCircleY = collectionView.frame.height * 0.5
            // 半径
            radius = (collectionView.frame.width - cellSize.width) * 0.5
            
//            contentH = collectionView.frame.height// + CGFloat.pi * 2 * radius / 15
            contentH = collectionView.frame.height * 2
        }
        
        let count = collectionView.numberOfItems(inSection: 0)
        cellCount = CGFloat(count)
        
        for i in 0 ..< count {
            
            let indexPath = IndexPath(item: i, section: 0)
            
            guard let attri = layoutAttributesForItem(at: indexPath) else { continue }
            attriArray.append(attri)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        attriArray
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView else { return nil }
        let offsetY = collectionView.contentOffset.y
        
        // 获取cell的布局属性
        let attri = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attri.size = cellSize
        
        // 弧度
        var angle: CGFloat = (radian360 / cellCount) * CGFloat(indexPath.item) - radian90
//        JPrint(indexPath.item, "---", JPRadian2Angle(angle))
        
        // 根据滚动比例（暂时以一屏高为一圈）刷新角度
        if contentH > 0 {
            let scale = offsetY / contentH
            angle -= scale * radian360
        }
        
        let centerX: CGFloat = baseCircleX + radius * cos(angle)
        let centerY: CGFloat = baseCircleY + radius * sin(angle)
        attri.center = [centerX, offsetY + centerY]
        
//        if indexPath.item == 4 {
//            JPrint("offsetY", offsetY)
//            JPrint("centerY", centerY)
//            JPrint("------------------")
//        }
        
        return attri
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        true
    }
    
    override var collectionViewContentSize: CGSize {
        return [0, contentH]
    }
    
    
//    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
//
//        let cCenter: CGPoint = [baseCircleX, baseCircleY + proposedContentOffset.y]
//        let tCenter: CGPoint = [baseCircleX + radius, baseCircleY + proposedContentOffset.y]
//
//
//        var tAttri: UICollectionViewLayoutAttributes? = nil
//
//        var minDelta: Float = MAXFLOAT
//
//        for attri in attriArray {
//            guard attri.center.x > cCenter.x else {
//                continue
//            }
//
//            let diffY = Float(attri.center.y - cCenter.y)
//
//            if fabsf(minDelta) > fabsf(diffY) {
//                minDelta = diffY
//                tAttri = attri
//            }
//        }
//
//        guard let tAttri = tAttri else {
//            JPrint("!!!!!targetContentOffset000!!!!")
//            return proposedContentOffset
//        }
//
//        JPrint("!!!!!targetContentOffset111!!!!")
//
////        let offsetY = collectionView.contentOffset.y
////
////        // 获取cell的布局属性
////        let attri = UICollectionViewLayoutAttributes(forCellWith: indexPath)
////        attri.size = cellSize
////
////        // 弧度
////        var angle: CGFloat = (radian360 / cellCount) * CGFloat(indexPath.item) - radian90
////        let scale = offsetY / contentH
////        angle -= scale * radian360
////
////        let centerX: CGFloat = baseCircleX + radius * cos(angle)
////        let centerY: CGFloat = baseCircleY + radius * sin(angle)
////        attri.center = [centerX, offsetY + centerY]
//       // attri.center = [centerX, offsetY + (baseCircleY + radius * sin((radian360 / cellCount) * CGFloat(indexPath.item) - radian90 - (offsetY / contentH) * radian360))]
//
//        var sideX = tAttri.center.x - baseCircleX
//        var sideY = tCenter.y - tAttri.center.y
//        var angle = atan(sideY / sideX)
//        let scale = angle / radian360
//
//        var offset = proposedContentOffset
//        offset.y -= contentH * scale
//        return offset
//
//    }
    
//    func afterRotationPoint(withStartPoint startPoint: CGPoint, centerPoint: CGPoint, angle: CGFloat) -> CGPoint {
//
//        CGFloat startX = startPoint.x;
//        CGFloat startY = startPoint.y;
//
//        CGFloat centerX = centerPoint.x;
//        CGFloat centerY = centerPoint.y;
//
//        CGFloat radian = angle / 180.0 * M_PI;
//
//        CGFloat x = (startX - centerX) * cos(radian) - (startY - centerY) * sin(radian) + centerX;
//        CGFloat y = (startX - centerX) * sin(radian) + (startY - centerY) * cos(radian) + centerY;
//
//        return CGPointMake(x, y);
//
//    }
}




