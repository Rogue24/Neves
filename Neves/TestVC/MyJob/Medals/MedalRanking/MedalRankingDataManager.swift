//
//  MedalRankingDataManager.swift
//  Neves
//
//  Created by aa on 2023/7/10.
//

import Foundation
import SVGAPlayer_Optimized

protocol MedalRankingDataResponder: AnyObject {
    func updateDefaultRange(_ range: MedalRanking.RegionRange, isCanSwitch: Bool, nationalFlag: String)
    func updateData(_ result: Result<MedalRankingViewModel, MedalRanking.Error>)
}

class MedalRankingDataManager {
    weak var responder: MedalRankingDataResponder?
    
    private var defaultRange: MedalRanking.RegionRange? = nil
//    private weak var defaultRequest: URLSessionTask? = nil
    private var defaultRequest: DispatchWorkItem? = nil
    
    private let viewModels: [MedalRankingViewModel] = MedalRanking.ListType.allCases.flatMap { type in
        MedalRanking.RegionRange.allCases.map { range in
            MedalRankingViewModel(type: type, range: range)
        }
    }
    
    private var topOnLineEntity: SVGAVideoEntity? = nil
    private var userOnLineEntity: SVGAVideoEntity? = nil
    
    init(isNeedShowOnLine: Bool) {
        // 特殊处理：代替原来网络请求的取消行为
        viewModels.forEach {
            $0.cancelHandler = { [weak self] vm in
                guard let self else { return }
                vm.isRequesting = false
                self.responder?.updateData(.failure(.userCancel(vm.type, vm.range)))
            }
        }
        
        guard isNeedShowOnLine else { return }
        SVGAParser().parse(withNamed: "ranking_top_online", in: nil) { [weak self] entity in
            guard let self = self else { return }
            self.topOnLineEntity = entity
        }
        SVGAParser().parse(withNamed: "time_line_online", in: nil) { [weak self] entity in
            guard let self = self else { return }
            self.userOnLineEntity = entity
        }
    }
    
    func getViewModel(for type: MedalRanking.ListType, _ range: MedalRanking.RegionRange) -> MedalRankingViewModel {
        viewModels.first { $0.type == type && $0.range == range } ?? viewModels[0]
    }
    
    deinit {
        defaultRequest?.cancel()
        viewModels.forEach { $0.request?.cancel() }
    }
}

extension MedalRankingDataManager {
    // MARK: - 请求默认榜单数据
    private func _fetchDefaultData(for type: MedalRanking.ListType) {
        defaultRequest?.cancel()
        
        var range: MedalRanking.RegionRange = .global
        
//        let url = "api/user/medals/point/rank"
//        
//        var params: [String: Any] = [:]
//        params["cycle"] = type.cycle
//        params["useDefault"] = true
//        // JP_Test
////        params["useDefault"] = nil
//        defaultRequest = JKRNetWorkManager.share().jkr_sendApi(withUrl: url, params: params) { [weak self] returnValue in
//            guard let self, self.defaultRange == nil else { return }
//            
//            guard let returnValue else {
//                self.responder?.updateData(.failure(.nullData(type, range)))
//                return
//            }
//            
//            var model: EMLRankingUsersModel?
//            var listVM: MedalRankingListViewModel?
//            Asyncs.async {
//                guard let usersModel = EMLRankingUsersModel.mj_object(withKeyValues: returnValue) else { return }
//                model = usersModel
//                listVM = MedalRankingListViewModel(
//                    type: type,
//                    range: range,
//                    usersModel: usersModel,
//                    getTopOnLineEntity: { [weak self] in self?.topOnLineEntity },
//                    getUserOnLineEntity: { [weak self] in self?.userOnLineEntity }
//                )
//                
//            } mainTask: { [weak self] in
//                guard let self, self.defaultRange == nil else { return }
//                guard let model, let listVM else {
//                    self.responder?.updateData(.failure(.nullData(type, range)))
//                    return
//                }
//                
//                range = MedalRanking.RegionRange(rawValue: model.rangeType) ?? .global
//                
//                // JP_Test
////                model.chooseData = true
//                
//                self.defaultRange = range
//                self.responder?.updateDefaultRange(range, isCanSwitch: model.chooseData, nationalFlag: model.nationalFlag)
//                
//                let vm = self.getViewModel(for: type, range)
//                vm.isRequesting = false
//                vm.isRequested = true
//                vm.listVM = listVM
//                self.responder?.updateData(.success(vm))
//            }
//            
//        } failure: { [weak self] error in
//            guard let self, self.defaultRange == nil else { return }
//            self.responder?.updateData(.failure(.networkFailed(type, range, error)))
//        } cancel: {}
        
        // 读取本地测试数据
        let delay = TimeInterval(Int.random(in: 5...10)) / 10.0
        defaultRequest = Asyncs.asyncDelay(delay) { [weak self] in
            var fileName = "medals_rank_"
            switch type {
            case .quarterly:
                fileName += "quarterly"
            case .overall:
                fileName += "overall"
            }
            fileName += "_default_data"
            guard let url = Bundle.main.url(forResource: fileName, withExtension: "txt"),
                  let data = try? Data(contentsOf: url),
                  let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            else {
                Asyncs.main { [weak self] in
                    guard let self else { return }
                    self.defaultRequest = nil
                    guard self.defaultRange == nil else { return }
                    self.responder?.updateData(.failure(.nullData(type, range)))
                }
                return
            }
            
            var model: EMLRankingUsersModel?
            var listVM: MedalRankingListViewModel?
            if let usersModel = EMLRankingUsersModel.mj_object(withKeyValues: dict) {
                model = usersModel
                listVM = MedalRankingListViewModel(
                    type: type,
                    range: range,
                    usersModel: usersModel,
                    getTopOnLineEntity: { [weak self] in self?.topOnLineEntity },
                    getUserOnLineEntity: { [weak self] in self?.userOnLineEntity }
                )
            }
            
            Asyncs.main { [weak self] in
                guard let self else { return }
                self.defaultRequest = nil
                
                guard self.defaultRange == nil else { return }
                guard let model, let listVM else {
                    self.responder?.updateData(.failure(.nullData(type, range)))
                    return
                }
                
                range = MedalRanking.RegionRange(rawValue: model.rangeType) ?? .global
                
                // JP_Test
//                model.chooseData = true
                
                self.defaultRange = range
                self.responder?.updateDefaultRange(range, isCanSwitch: model.chooseData, nationalFlag: model.nationalFlag)
                
                let vm = self.getViewModel(for: type, range)
                vm.isRequesting = false
                vm.isRequested = true
                vm.listVM = listVM
                self.responder?.updateData(.success(vm))
            }
        }
    }
    
    // MARK: - 请求榜单数据
    @discardableResult
    func fetchData(for type: MedalRanking.ListType, _ range: MedalRanking.RegionRange, isReload: Bool) -> Bool {
        if defaultRange == nil {
            _fetchDefaultData(for: type)
            return true
        }
        
        let vm = getViewModel(for: type, range)
        
        guard !vm.isRequested || isReload else {
            responder?.updateData(.success(vm))
            return false
        }
        
        guard !vm.isRequesting else { return true }
        vm.isRequesting = true
        
//        let url = "api/user/medals/point/rank"
//        
//        var params: [String: Any] = [:]
//        params["cycle"] = type.cycle
//        params["rangeType"] = range.rawValue
//        // JP_Test
////        params["rangeType"] = nil
//        vm.request = JKRNetWorkManager.share().jkr_sendApi(withUrl: url, params: params) { [weak self] returnValue in
//            guard let self else { return }
//            
//            guard let returnValue else {
//                let vm = self.getViewModel(for: type, range)
//                vm.isRequesting = false
//                vm.isRequested = true
//                self.responder?.updateData(.failure(.nullData(type, range)))
//                return
//            }
//            
//            var listVM: MedalRankingListViewModel?
//            Asyncs.async {
//                guard let usersModel = EMLRankingUsersModel.mj_object(withKeyValues: returnValue) else { return }
//                listVM = MedalRankingListViewModel(
//                    type: type,
//                    range: range,
//                    usersModel: usersModel,
//                    getTopOnLineEntity: { [weak self] in self?.topOnLineEntity },
//                    getUserOnLineEntity: { [weak self] in self?.userOnLineEntity }
//                )
//                
//            } mainTask: { [weak self] in
//                guard let self else { return }
//                
//                let vm = self.getViewModel(for: type, range)
//                vm.isRequesting = false
//                vm.isRequested = true
//                vm.listVM = listVM
//                
//                if listVM == nil {
//                    self.responder?.updateData(.failure(.nullData(type, range)))
//                } else {
//                    self.responder?.updateData(.success(vm))
//                }
//            }
//            
//        } failure: { [weak self] error in
//            guard let self else { return }
//            let vm = self.getViewModel(for: type, range)
//            vm.isRequesting = false
//            self.responder?.updateData(.failure(.networkFailed(type, range, error)))
//            
//        } cancel: { [weak self] in
//            guard let self else { return }
//            let vm = self.getViewModel(for: type, range)
//            vm.isRequesting = false
//            self.responder?.updateData(.failure(.userCancel(type, range)))
//        }
        
        // 读取本地测试数据
        let delay = TimeInterval(Int.random(in: 5...10)) / 10.0
        vm.request = Asyncs.asyncDelay(delay) { [weak self] in
            var fileName = "medals_rank_"
            switch type {
            case .quarterly:
                fileName += "quarterly"
            case .overall:
                fileName += "overall"
            }
            fileName += "_"
            switch range {
            case .country:
                fileName += "country"
            case .global:
                fileName += "global"
            }
            fileName += "_data"
            guard let url = Bundle.main.url(forResource: fileName, withExtension: "txt"),
                  let data = try? Data(contentsOf: url),
                  let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            else {
                Asyncs.main { [weak self] in
                    guard let self else { return }
                    let vm = self.getViewModel(for: type, range)
                    vm.request = nil
                    vm.isRequesting = false
                    vm.isRequested = true
                    self.responder?.updateData(.failure(.nullData(type, range)))
                }
                return
            }
            
            var listVM: MedalRankingListViewModel?
            if let usersModel = EMLRankingUsersModel.mj_object(withKeyValues: dict) {
                listVM = MedalRankingListViewModel(
                    type: type,
                    range: range,
                    usersModel: usersModel,
                    getTopOnLineEntity: { [weak self] in self?.topOnLineEntity },
                    getUserOnLineEntity: { [weak self] in self?.userOnLineEntity }
                )
            }
            
            Asyncs.main { [weak self] in
                guard let self else { return }
                
                let vm = self.getViewModel(for: type, range)
                vm.isRequesting = false
                vm.isRequested = true
                vm.listVM = listVM
                
                if listVM == nil {
                    self.responder?.updateData(.failure(.nullData(type, range)))
                } else {
                    self.responder?.updateData(.success(vm))
                }
            }
        }
        
        return true
    }
}
