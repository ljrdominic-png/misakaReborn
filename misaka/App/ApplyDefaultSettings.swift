//
//  apply_default_settings.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/08/07.
//

import Foundation
import UIKit

func ApplyDefaultSettings() {
    // 設定の初期値
    if Memory.shared.FirstStartupA {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        if version.contains("M1") {
            Memory.shared.puaf_pages_index = 8
        }
        
        SettingsManager.shared.Exploit = "DarkSword"
        
        DispatchQueue.global().async {
            Requests(RequestsType(Method: "Get", URL: "https://github.com/shimajiron/Misaka_Network/raw/main/Server/DefaultRepositoriesDS.json")) { data in
                do {
                    if let data = data {
                        let decoder = JSONDecoder()
                        decoder.allowsJSON5 = true
                        let DRsS = try decoder.decode([DefaultRepositoriesType].self, from: data)
                        for DRs in DRsS {
                            for DR in DRs.Repositories {
                                DispatchQueue.main.async {
                                    Memory.shared.RepositoriesURL.append(DR)
                                }
                            }
                        }
                    }
                }catch{}
            }
        }
        Memory.shared.FirstStartupA = false
    }

    if SettingsManager.shared.ExploitInfo[SettingsManager.shared.Exploit] == nil {
        SettingsManager.shared.Exploit = "DarkSword"
    }
    
    localization_init()
    
    DeviceLockStatus().registerAppforDetectLockState()
    
    UIDevice.current.isBatteryMonitoringEnabled = true
    var lastBatteryLevel: Float = UIDevice.current.batteryLevel
    var lastUpdateTime: Date = Date()
    let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
        let batteryLevel = UIDevice.current.batteryLevel
        if lastBatteryLevel != batteryLevel {
            let currentTime = Date()
            let timeInterval = currentTime.timeIntervalSince(lastUpdateTime)
            Memory.shared.lastTimeInterval = timeInterval
            lastUpdateTime = currentTime
            lastBatteryLevel = batteryLevel
        }
    }
}
