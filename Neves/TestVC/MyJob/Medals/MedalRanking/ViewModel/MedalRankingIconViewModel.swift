//
//  MedalRankingIconViewModel.swift
//  Neves
//
//  Created by aa on 2023/7/4.
//

class MedalRankingIconModel {
    let iconSource: MedalRanking.IconSource
    var iconFrame: CGRect
    var nextSpace: CGFloat
    var tapAction: (() -> Void)?
    
    init(iconSource: MedalRanking.IconSource,
         iconFrame: CGRect,
         nextSpace: CGFloat = 0,
         tapAction: (() -> Void)? = nil)
    {
        self.iconSource = iconSource
        self.iconFrame = iconFrame
        self.nextSpace = nextSpace
        self.tapAction = tapAction
    }
}

class MedalRankingIconViewModel {
    let iconModel: MedalRankingIconModel
    var iconFrame: CGRect {
        set { iconModel.iconFrame = newValue }
        get { iconModel.iconFrame }
    }
    
    init(iconModel: MedalRankingIconModel) {
        self.iconModel = iconModel
    }
    
    static func build(with models: [MedalRankingIconModel],
                      iconMaxCount: Int,
                      iconListSize: CGSize,
                      iconListAlignment: MedalRankingIconListAlignment) -> [MedalRankingIconViewModel] {
        let count = iconMaxCount > 0 ? min(iconMaxCount, models.count) : models.count
        guard count > 0 else {
            return []
        }
        
        var contentW: CGFloat = 0
        for i in 0 ..< count {
            let model = models[i]
            contentW += model.iconFrame.width
            if i < (count - 1) {
                contentW += model.nextSpace
            }
        }
        
        var x: CGFloat = 0
        switch iconListAlignment {
        case .leading:
            x = 0
        case .center:
            x = HalfDiffValue(iconListSize.width, contentW)
        case .trailing:
            x = iconListSize.width - contentW
        }
        
        var iconVMs: [MedalRankingIconViewModel] = []
        for i in 0 ..< count {
            let model = models[i]
            model.iconFrame.origin = [x, HalfDiffValue(iconListSize.height, model.iconFrame.height)]
            iconVMs.append(MedalRankingIconViewModel(iconModel: model))
            x += (model.iconFrame.width + model.nextSpace)
        }
        
        return iconVMs
    }
}
