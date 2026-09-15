//
//  MedalDetailCellModel.swift
//  Falla
//
//  Created by aa on 2023/7/7.
//

import UIKit
import SVGAPlayer_Optimized

class MedalDetailCellModel: MBindable {
    enum IconSource {
        case svga(_ entity: SVGAVideoEntity?)
        case image(_ url: String)
    }
    
    /// =========`MBindable`=========
    var identifier: Int { medalID }
    weak var bindView: MedalDetailCell? = nil {
        didSet {
            if bindView != nil {
                loadSvgaIfNeeded()
            }
        }
    }
    
    let medalID: Int
    let medalUrl: String
    let title: String
    private(set) var iconSource: IconSource
    let subTitle: String?
    let score: String?
    let levelIconName: String?
    
    private var isLoading = false
    
    init(_ medal: JKRUserMedalsList, _ dateFormatter: DateFormatter) {
        self.medalID = medal.id
        self.medalUrl = medal.svga
        self.title = medal.desc
        
        if medal.svga.hasSuffix(".svga") {
            self.iconSource = .svga(nil)
        } else {
            self.iconSource = .image(medal.svga)
        }
        
        if medal.createTs > 0 {
            let date = Date(timeIntervalSince1970: TimeInterval(medal.createTs))
            let dateStr = dateFormatter.string(from: date)
            self.subTitle = "获得时间：\(dateStr)"
        } else {
            self.subTitle = nil
        }
        
        self.levelIconName = MedalLevel(rawValue: medal.lv)?.iconName
        
        self.score = medal.point > 0 ? medal.point.friendlyString() : nil
    }
    
    init(_ medal: JKRChatRoomMedalModel) {
        self.medalID = medal.id
        self.medalUrl = medal.icon
        self.title = medal.desc
        
        if medal.icon.hasSuffix(".svga") {
            self.iconSource = .svga(nil)
        } else {
            self.iconSource = .image(medal.icon)
        }
        
        self.subTitle = nil
        self.score = nil
        self.levelIconName = nil
    }
    
    func loadSvgaIfNeeded() {
        switch iconSource {
        case let .svga(entity):
            guard !isLoading, entity == nil else { return }
            guard let url = URL(string: medalUrl) else { return }
            isLoading = true
            SVGAParser().parse(with: url) { [weak self] e in
                guard let self else { return }
                self.isLoading = false
                guard let e else { return }
                self.iconSource = .svga(e)
                self.bindView?.showSVGA(e)
            } failureBlock: { [weak self] _ in
                self?.isLoading = false
            }
        case .image:
            break
        }
    }
}
