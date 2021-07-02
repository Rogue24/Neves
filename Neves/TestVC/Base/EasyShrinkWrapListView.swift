//
//  EasyShrinkWrapListView.swift
//  Neves
//
//  Created by aa on 2021/4/30.
//

protocol OneWayWrapListViewDataSource: NSObjectProtocol {
    var elementCount: Int { get }
    func listView(_ listView: OneWayWrapListView, elementAt index: Int) -> UIView
    
    
    func createElement<T: UIView>(_ elementClass: T.Type) -> T
    func updateElement<T: UIView>(_ element: T.Type)
    
}

class OneWayWrapListView: UIView {
    
    
    
    
    enum Direction {
        case horizontal
        case vertical
    }
    
    let direction: Direction
    var elementSpace: CGFloat = 0
    var contentInset: UIEdgeInsets = .zero
    
    weak var dataSource: OneWayWrapListViewDataSource? = nil
    
    init(direction: Direction, elementSpace: CGFloat = 0, contentInset: UIEdgeInsets = .zero) {
        self.direction = direction
        self.elementSpace = elementSpace
        self.contentInset = contentInset
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let elementOrder: [UIView.Type] = []
    
    private var showElements: [UIView] = []
    private var hideElements: [UIView] = []
    
//    func dequeueReusableElement<T: UIView>(withElementClass elementClass: T.Type) -> T? {
//
//    }
    
//    func reloadData() {
//        guard let dataSource = self.dataSource else { return }
//        
//        let elementCount = dataSource.elementCount
//        let showElements = self.showElements
//        let hideElements = self.hideElements
//        
//        
//        
//        
//        
//        if newCount == oldCount {
//            for i in 0..<newCount {
//                let label = featureLabels[i]
//                let model = models[i]
//                setupFeatureLabel(label, withModel: model)
//            }
//            return
//        }
//        
//        if oldCount >= newCount {
//            for i in 0..<oldCount {
//                let label = featureLabels[i]
//                if i >= newCount {
//                    setupFeatureLabel(label, withModel: nil)
//                } else {
//                    let model = models[i]
//                    setupFeatureLabel(label, withModel: model)
//                }
//            }
//        } else {
//            let labelCount = featureLabels.count
//            for i in 0..<newCount {
//                let model = models[i]
//                let label = i < labelCount ? featureLabels[i] : nil
//                setupFeatureLabel(label, withModel: model)
//            }
//        }
//    }
}
