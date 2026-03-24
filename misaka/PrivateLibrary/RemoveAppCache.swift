//
//  RemoveAppCache.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/08/10.
//

import Foundation
import UIKit

func RemoveAppCache(alert: Bool) {
    let cacheURL =  FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    let fileManager = FileManager.default
    do {
        let directoryContents = try FileManager.default.contentsOfDirectory( at: cacheURL, includingPropertiesForKeys: nil, options: [])
        var isSuccess = [Bool]()
        for file in directoryContents {
            do {
                try fileManager.removeItem(at: file)
                isSuccess.append(true)
            }
            catch let error as NSError {
                UIApplication.shared.alert(title: MILocalizedString("Error"), body: "\(MILocalizedString("Couldn’t clear cache"))\n \(error)")
                isSuccess.append(false)
            }
        }
        if isSuccess.allSatisfy({ $0 == true }) && alert {
            UIApplication.shared.alert(title: MILocalizedString("Succeed"), body: MILocalizedString("All Caches are deleted"))
        }
    } catch let error as NSError {
        print(error.localizedDescription)
    }
}
