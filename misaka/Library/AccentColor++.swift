//
//  AccentColor++.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/30.
//

import Foundation
import SwiftUI

enum DarkModeSetting: Int {
    case followSystem = 0
    case darkMode = 1
    case lightMode = 2
}

extension View {
    @ViewBuilder
    func applyAppearenceSetting(_ setting: DarkModeSetting) -> some View {
        switch setting {
        case .followSystem:
            self
                .preferredColorScheme(.none)
        case .darkMode:
            self
                .preferredColorScheme(.dark)
        case .lightMode:
            self
                .preferredColorScheme(.light)
        }
    }
}
