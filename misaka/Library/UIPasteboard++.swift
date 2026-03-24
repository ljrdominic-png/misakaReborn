//
//  UIPasteboard++.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/11/09.
//

import Foundation
import AlertToast
import UIKit

extension UIPasteboard {
    func setString(_ str: String) {
        UIPasteboard.general.string = str
        ToastController.shared.Toast_Hud = AlertToast(displayMode: .hud, type: .complete(.green), title: "Cliped")
        ToastController.shared.Show_Hud = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            ToastController.shared.Show_Hud = false
        }
    }
}
