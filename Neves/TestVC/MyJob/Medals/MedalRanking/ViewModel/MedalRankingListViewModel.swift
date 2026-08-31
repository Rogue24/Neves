//
//  MedalRankingListViewModel.swift
//  Falla
//
//  Created by aa on 2023/7/4.
//

class MedalRankingListViewModel {
    let type: MedalRanking.ListType
    let range: MedalRanking.RegionRange
    let usersModel: EMLRankingUsersModel
    
    var dateStr: String { usersModel.quarter }
    
    private(set) var topUserVMs: [MedalRankingTopUserViewModel] = []
    private(set) var userVMs: [MedalRankingUserViewModel] = []
    private(set) var myUserVM: MedalRankingUserViewModel?
    
    init(type: MedalRanking.ListType,
         range: MedalRanking.RegionRange,
         usersModel: EMLRankingUsersModel,
         getTopOnLineEntity: @escaping () -> SVGAVideoEntity?,
         getUserOnLineEntity: @escaping () -> SVGAVideoEntity?)
    {
        self.type = type
        self.range = range
        self.usersModel = usersModel
        
        let list = usersModel.list
        
        let maxRank = usersModel.maxRank
        let myRank = usersModel.myRank
        
//        let kList = list.sorted { $0.rank < $1.rank }
//        for user in kList {
//            switch user.rank {
//            case 1, 2, 3:
//                let topUserVM = MedalRankingTopUserViewModel(user: user)
//                topUserVM.getOnLineEntity = getTopOnLineEntity
//                topUserVMs.append(topUserVM)
//            default:
//                let userVM = MedalRankingUserViewModel(user: user, maxRank: maxRank)
//                userVM.getOnLineEntity = getUserOnLineEntity
//                userVMs.append(userVM)
//            }
//        }
        
        for (i, user) in list.enumerated() {
            let rank = i + 1
            switch rank {
            case 1, 2, 3:
                let topUserVM = MedalRankingTopUserViewModel(user: user, rank: rank)
                topUserVM.getOnLineEntity = getTopOnLineEntity
                topUserVMs.append(topUserVM)
            default:
                let userVM = MedalRankingUserViewModel(user: user, rank: rank, maxRank: maxRank)
                userVM.getOnLineEntity = getUserOnLineEntity
                userVMs.append(userVM)
            }
        }
        
        // JP_Test
//        if range == .country {
//            topUserVMs = topUserVMs.shuffled()
//            userVMs = userVMs.shuffled()
//        }
        
        myUserVM = MedalRankingUserViewModel(user: myRank, rank: myRank.rank, maxRank: maxRank)
        myUserVM?.getOnLineEntity = getUserOnLineEntity
    }
}
