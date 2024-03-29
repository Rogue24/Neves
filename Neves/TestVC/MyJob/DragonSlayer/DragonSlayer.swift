//
//  DragonSlayer.swift
//  Neves
//
//  Created by aa on 2021/11/4.
//

enum DragonSlayer {
    
    enum Task {
        case enterRoom
        case stayRoom
        case giveGift
        case inspire
        case allDone
    }
    
    enum CountingDown: Equatable {
        case prepare(_ second: TimeInterval)
        case fight(_ second: TimeInterval)
    }
    
}
