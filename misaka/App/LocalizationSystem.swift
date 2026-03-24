//
//  Languages.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/08/31.
//

import Foundation

var localization: [String: String] = [:]

func MILocalizedString(_ text: String) -> String {
    return localization[text] ?? text
}

func localization_init() {
   if SettingsManager.shared.AppLang != "en (Bundle)" {
       if let d = FileManager.default.contents(atPath: "\(DataPath("Settings"))/Localization/\(SettingsManager.shared.AppLang)"),
          let j = try? JSONSerialization.jsonObject(with: d, options: .mutableContainers) as? [String: String] {
           localization = j
       }
   }
}
