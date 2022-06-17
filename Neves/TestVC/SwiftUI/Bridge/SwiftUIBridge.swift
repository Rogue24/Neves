//
//  SwiftUIBridge.swift
//  Neves
//
//  Created by aa on 2022/6/13.
//

import SwiftUI

extension View {
    func intoVC() -> UIHostingController<Self> {
        UIHostingController(rootView: self)
    }
}
