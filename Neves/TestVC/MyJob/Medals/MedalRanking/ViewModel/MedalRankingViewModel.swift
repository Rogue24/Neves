//
//  MedalRankingViewModel.swift
//  Neves
//
//  Created by aa on 2023/7/4.
//

class MedalRankingViewModel {
    let type: MedalRanking.ListType
    let range: MedalRanking.RegionRange
    
    var listVM: MedalRankingListViewModel? = nil
    
//    weak var request: URLSessionTask? = nil
    var request: DispatchWorkItem? = nil
    var isRequesting = false
    var isRequested = false
    
    init(type: MedalRanking.ListType, range: MedalRanking.RegionRange) {
        self.type = type
        self.range = range
    }
    
    // 特殊处理：代替原来网络请求的取消行为
    var cancelHandler: ((_ vm: MedalRankingViewModel) -> Void)? = nil
}
