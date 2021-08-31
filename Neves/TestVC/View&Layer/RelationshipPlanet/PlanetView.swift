//
//  PlanetPeopleView.swift
//  Neves
//
//  Created by aa on 2021/8/31.
//

let radian360 = CGFloat.pi * 2
let radian180 = CGFloat.pi
let radian90 = CGFloat.pi / 2.0
let radian30 = CGFloat.pi / 6.0

let peopleW: CGFloat = 30 + 10 + 100
let peopleH: CGFloat = 30
let planetRadius: CGFloat = 165 // 330
let planetWH: CGFloat = planetRadius * 2 + peopleH
let planetCircleXY: CGFloat = planetWH * 0.5

let minContentH = planetWH
let maxContentH = planetWH * 3
let maxOffsetY = maxContentH - minContentH

let onePeopleRadian: CGFloat = radian30
let onePeopleOffsetY: CGFloat = minContentH * (radian30 / radian180)

let topInset = onePeopleOffsetY

class PlanetView: UIView {
    
    let scrollView = UIScrollView()
    
    lazy var peoples: [PeopleView] = {
        (0 ..< 15).map { PeopleView(tag: $0) }
    }()
    var peopleCount: Int { peoples.count }
    
    
    init() {
        super.init(frame: [0, 0, planetWH, planetWH])
        clipsToBounds = false
        
        let planetImgView = UIImageView(image: UIImage(named: "gxq_rk_shitu"))
        planetImgView.frame = [HalfDiffValue(planetWH, 300), HalfDiffValue(planetWH, 300), 300, 300]
        addSubview(planetImgView)
        
        let planetRingImgView = UIImageView(image: UIImage(named: "gxq_rk_shitu_lottie"))
        planetRingImgView.frame = planetImgView.bounds//[14.4, 89, 285.6, 174]
        planetImgView.addSubview(planetRingImgView)
        
        scrollView.jp.contentInsetAdjustmentNever()
        scrollView.frame = bounds
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.clipsToBounds = false
        addSubview(scrollView)
        
        peoples.forEach { scrollView.addSubview($0) }
        
        var contentH = onePeopleOffsetY * CGFloat(peopleCount)
        if contentH < minContentH { contentH = minContentH }
        scrollView.contentSize = [0, contentH]
        scrollView.contentInset = .init(top: topInset, left: 0, bottom: 0, right: 0)
        scrollView.contentOffset = [0, -topInset]
        
        
        
//        let line = CALayer()
//        line.backgroundColor = UIColor.randomColor.cgColor
//        line.frame = [0, scrollView.y + HalfDiffValue(scrollView.height, 1), scrollView.width, 1]
//        layer.addSublayer(line)
//
//        let line2 = CALayer()
//        line2.backgroundColor = line.backgroundColor
//        line2.frame = [scrollView.x + HalfDiffValue(scrollView.width, 1), 0, 1, scrollView.height]
//        layer.addSublayer(line2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PlanetView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        
        let scale = offsetY / maxOffsetY
        JPrint("offsetY ---", offsetY, "scale ---", scale)
        
        for i in 0 ..< peopleCount {
            let people = peoples[i]
            people.updateAlpha(offsetY)
            people.center = center
            
            // 弧度
            var radian: CGFloat = onePeopleRadian * CGFloat(i) - radian90
            radian -= scale * radian360
            
            let centerX: CGFloat = planetCircleXY + planetRadius * cos(radian)
            let centerY: CGFloat = planetCircleXY + planetRadius * sin(radian)
            people.center = [centerX, offsetY + centerY]
            people.currentRradian = radian
        }
    }
}


extension PlanetView {
    
    func peopleCenteres(_ offsetY: CGFloat) -> [CGPoint] {
        var centeres: [CGPoint] = []
        
        let scale = offsetY / maxOffsetY
        
        for i in 0 ..< peopleCount {
            // 弧度
            var radian: CGFloat = onePeopleRadian * CGFloat(i) - radian90
            radian -= scale * radian360

            let centerX: CGFloat = planetCircleXY + planetRadius * cos(radian)
            let centerY: CGFloat = planetCircleXY + planetRadius * sin(radian)
            centeres.append([centerX, offsetY + centerY])
        }
        
        return centeres
    }
    
}
