//
//  ApplySystem.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/08/03.
//

import Foundation
import UIKit

func ApplyAll(Keep: Bool) {
    let package_dir = DataPath("Packages")
    var dirs_sorted: [String] = [String]()
    
    do{
        dirs_sorted = try FileManager.default.contentsOfDirectoryExploit(atPath: package_dir)
    }catch{}
    
    do{
        var dirs_tmp = [(String, String)]()
        let dirs = try FileManager.default.contentsOfDirectoryExploit(atPath: package_dir)
        for i in 0..<dirs.count {
            let index_path = "\(package_dir)/\(dirs[i])/.system/.index"
            if let index_url = URLwithEncode(string: index_path) {
                if FileManager.default.fileExists(atPath: index_path) {
                    let index = try String(contentsOf: index_url, encoding: String.Encoding.utf8)
                    dirs_tmp.append((dirs[i], index))
                }else{
                    dirs_tmp.append((dirs[i], "0"))
                }
            }
        }
        let dirs_sorted_data = dirs_tmp.sorted { Int($0.1) ?? 0 < Int($1.1) ?? 0 }
        dirs_sorted = dirs_sorted_data.map { $0.0 }
    }catch{}
    
    dirs_sorted.forEach { dir in
        let package = "\(package_dir)/\(dir)"
        if FileManager.default.isDirectory(package) {
            let isOFF = FileManager.default.fileExists(atPath: "\(package)/.system/.OFF")
            if Keep {
                let isKeep = FileManager.default.fileExists(atPath: "\(package)/.system/.Keep")
                if !isOFF && isKeep {
                    let _ = Apply(PackageID: dir, Mode: "BackgroundApply")
                }
            }else{
                if !isOFF{
                    let _ = Apply(PackageID: dir, Mode: "Apply")
                }
            }
        }
    }
}

func RestoreAll() {
    do {
        let dirs = try FileManager.default.contentsOfDirectoryExploit(atPath: DataPath("Packages"))
        dirs.forEach { dir in
            let package = "\(DataPath("Packages"))/\(dir)"
            if FileManager.default.isDirectory(package) {
                let _ = Apply(PackageID: dir, Mode: "Restore")
            }
        }
    } catch {
        print(error.localizedDescription)
    }
}

