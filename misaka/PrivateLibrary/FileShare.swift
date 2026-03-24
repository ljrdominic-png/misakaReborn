//
//  FileShare.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/08/22.
//

import Foundation
import UIKit

func FileShare(path: URL, presened: Bool) {
    do {
        if let data = FileManager.default.contentsExploit(atPath: path.path) {
            try data.write(to: URLwithEncode(string: DataPath("FM")+"/"+FileManager.default.Basename(path.path)!)!)
            UIApplication.shared.fileShare(path: URLwithEncode(string: DataPath("FM")+"/"+FileManager.default.Basename(path.path)!)!)
        }
    }catch{
        UIApplication.shared.alert(body: "File NotExists")
    }
}
