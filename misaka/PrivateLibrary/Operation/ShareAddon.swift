//
//  ShareAddon.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/10/02.
//

import Foundation
import Zip
import UIKit

func ShareAddon(Addon: String) {
    ViewMemory.shared.AppLoading = true
    ClearFolder(DataPath("Tmp"))
    ClearFolder(DataPath("Share"))
    ClearFolder(DataPath("ShareZip"))
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        let PackagesF = "\(DataPath("Packages"))/\(Addon)/"
        let ShareF = "\(DataPath("Share"))/\(Addon)/"
        let zipURL = "\(DataPath("ShareZip"))/Share.zip"
        let misakaURL = "\(DataPath("ShareZip"))/\(Addon).misaka"
        
        try? FileManager.default.copyItem(atPath: PackagesF, toPath: ShareF)
        FileManager.default.createFile(atPath: "\(DataPath("Share"))/\(Addon)/.system/.OFF", contents: nil, attributes: nil)
        try? FileManager.default.removeItem(atPath: zipURL)
        try? FileManager.default.removeItem(atPath: misakaURL)
        do {
            try Zip(in: ShareF, out: misakaURL)
            print("Zipping successful")
            try? FileManager.default.removeItem(atPath: zipURL)
            FileShare(path: URL(fileURLWithPath: misakaURL), presened: false)
        } catch {
            print("Zipping failed")
            return
        }
        DispatchQueue.main.async {
            ViewMemory.shared.AppLoading = false
        }
    }
}
