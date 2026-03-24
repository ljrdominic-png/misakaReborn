//
//  BackgroundApply.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/10/05.
//

import Foundation
import AlertToast

func BackgroundApply() {
    if Memory.shared.FirstBoot == true {
        func timer_start() {
            _ = Timer.scheduledTimer(withTimeInterval: SettingsManager.shared.RuninBackground_Interval, repeats: true) { timer in
                timer.invalidate()
                if SettingsManager.shared.RuninBackground && SettingsManager.shared.Background_Apply && !Memory.shared.AdvancedSettings_isActive && !SmoothSheetController.shared.ShowBar {
                    Memory.shared.BGRun_Applying = true
                    ToastController.shared.Toast_Hud = AlertToast(displayMode: .hud, type: .loading, title: "Background Apply")
                    ToastController.shared.Show_Hud = true
                    DispatchQueue.global().async {
                        print("Background Apply")
                        if !ViewMemory.shared.DeviceLocked {
                            ApplyAll(Keep: true)
                        }
                        DispatchQueue.main.async {
                            Memory.shared.BGRun_Applying = false
                            ToastController.shared.Show_Hud = false
                            timer_start()
                        }
                    }
                }
            }
        }
        timer_start()
        Memory.shared.FirstBoot = false
    }
}
