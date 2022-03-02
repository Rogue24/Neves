//
//  FloatWindowContainer.swift
//  Neves
//
//  Created by aa on 2021/11/2.
//

class FloatWindowContainer: FloatContainer {
    
    static let shared = FloatWindowContainer()
    
    func setup() {
        guard let window = GetKeyWindow(), superview != window else {
            superview?.bringSubviewToFront(self)
            return
        }
        frame = window.bounds
        window.addSubview(self)
    }
    
}


