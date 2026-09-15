//
//  MedalRankingIconListView.swift
//  Neves
//
//  Created by aa on 2023/7/3.
//

import UIKit

enum MedalRankingIconListAlignment {
    case leading
    case center
    case trailing
}

class MedalRankingIconListView: UIView {
    var iconMaxCount: Int = 0
    var iconCacheCount: Int = 6
    var alignment: MedalRankingIconListAlignment = .center
    
    private var iconViews: [UIView] = []
    private var tapActions: [UIView: () -> Void] = [:]
    
    func willReloadIcons(_ iconVMs: [MedalRankingIconViewModel]) {
        tapActions.removeAll()
        
        let newCount = iconMaxCount > 0 ? min(iconVMs.count, iconMaxCount) : iconVMs.count
        if iconViews.count > newCount, iconCacheCount > 0, iconViews.count > iconCacheCount {
            var kIconViews: [UIView] = []
            for i in 0 ..< iconViews.count {
                let iconView = iconViews[i]
                if i < iconCacheCount {
                    kIconViews.append(iconView)
                } else {
                    setIcon(nil, for: iconView)
                    iconView.removeFromSuperview()
                }
            }
            iconViews = kIconViews
            return
        }
        
        guard iconViews.count < newCount else { return }
        for i in iconViews.count ..< newCount {
            let iconVM = iconVMs[i]
            
            let iconView: UIView
            switch iconVM.iconModel.iconSource {
            case .image, .asset, .remote:
                iconView = UIImageView()
            case .label:
                iconView = JKRShimmeringLabel()
            }
            
            iconView.rtl_refWidth = bounds.width
            iconView.rtl_frame = iconVM.iconFrame
            iconView.alpha = 0
            
            iconView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapIconView(_:))))
            iconView.isUserInteractionEnabled = false
            
            addSubview(iconView)
            iconViews.append(iconView)
        }
    }
    
    func reloadIcons(_ iconVMs: [MedalRankingIconViewModel]) {
        tapActions.removeAll()
        guard iconViews.count > 0 else { return }
        for (i, iconView) in iconViews.enumerated() {
            if i >= iconVMs.count {
                setIcon(nil, for: iconView)
                iconView.alpha = 0
            } else {
                let iconVM = iconVMs[i]
                iconView.rtl_frame = iconVM.iconFrame
                setIcon(iconVM.iconModel, for: iconView)
                iconView.alpha = 1
            }
        }
    }
}

private extension MedalRankingIconListView {
    @objc func tapIconView(_ tapGR: UITapGestureRecognizer) {
        guard let view = tapGR.view, let tapAction = tapActions[view] else { return }
        tapAction()
    }
    
    func setIcon(_ model: MedalRankingIconModel?, for view: UIView) {
        MedalRanking.IconSource.setup(model?.iconSource, for: view)
        
        if let tapAction = model?.tapAction {
            view.isUserInteractionEnabled = true
            tapActions[view] = tapAction
        } else {
            view.isUserInteractionEnabled = false
        }
    }
}
