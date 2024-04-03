//
//  View.Extension.swift
//  Neves
//
//  Created by aa on 2022/6/20.
//

import SwiftUI

extension View {
    func intoUIVC() -> UIHostingController<Self> {
        UIHostingController(rootView: self)
    }
}
