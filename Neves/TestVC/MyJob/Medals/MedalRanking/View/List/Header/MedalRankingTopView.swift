//
//  MedalRankingTopView.swift
//  Neves
//
//  Created by aa on 2023/6/30.
//

import UIKit
import SnapKit

class MedalRankingTopView: UIView {
    static let size: CGSize = [Env.screenWidth, 230.px]
    
    private let dateView: UIStackView
    private let dateLabel: UILabel
    
    private let top1View: MedalRankingTopUserView
    private let top2View: MedalRankingTopUserView
    private let top3View: MedalRankingTopUserView
    
    init(_ showType: MedalRanking.ShowType) {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = showType == .fullScreen ? 8.px : 4.px
        stackView.alignment = .center
        
        let icon = UIImageView(image: UIImage(named: showType == .fullScreen ? "medal_ranking_time" : "moment_time"))
        stackView.addArrangedSubview(icon)
        icon.snp.makeConstraints { make in
            make.width.height.equalTo(12.px)
        }
        
        let label = UILabel()
        label.font = .systemFont(ofSize: 11.px)
        label.textColor = showType == .fullScreen ? .rgb(226, 222, 255) : .rgb(102, 102, 102)
        stackView.addArrangedSubview(label)
        
        self.dateView = stackView
        self.dateLabel = label
        
        self.top1View = MedalRankingTopUserView(showType, ranking: .top1)
        self.top2View = MedalRankingTopUserView(showType, ranking: .top2)
        self.top3View = MedalRankingTopUserView(showType, ranking: .top3)
        
        super.init(frame: CGRect(origin: .zero, size: MedalRankingTopView.size))
        clipsToBounds = false
        
        addSubview(dateView)
        dateView.alpha = 0
        dateView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(43.px)
            make.top.equalToSuperview().offset(-43.px)
        }
        
        addSubview(top1View)
        addSubview(top2View)
        addSubview(top3View)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MedalRankingTopView {
    func updateData(_ listVM: MedalRankingListViewModel?) {
        let topUserVMs = listVM?.topUserVMs ?? []
        let top1UserVM = topUserVMs.first(where: { $0.ranking == .top1 })
        let top2UserVM = topUserVMs.first(where: { $0.ranking == .top2 })
        let top3UserVM = topUserVMs.first(where: { $0.ranking == .top3 })
        
        top1View.willUpdateData(top1UserVM)
        top2View.willUpdateData(top2UserVM)
        top3View.willUpdateData(top3UserVM)
        
        Asyncs.mainDelay(0.1) {
            UIView.animate(withDuration: 0.45,
                           delay: 0,
                           usingSpringWithDamping: 0.9,
                           initialSpringVelocity: 0,
                           options: []) {
                
                if let dateStr = listVM?.dateStr, dateStr.count > 0 {
                    self.dateLabel.text = dateStr
                    self.dateView.alpha = 1
                } else {
                    self.dateView.alpha = 0
                }
                
                self.top1View.updateData(top1UserVM)
                self.top2View.updateData(top2UserVM)
                self.top3View.updateData(top3UserVM)
            }
        }
    }
}
