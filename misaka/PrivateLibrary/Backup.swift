//
//  Backup.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/19.
//

import Foundation

func FileBackup(_ tn: String) -> Bool {
    let backup = "\(DataPath("Backup"))/\(tn)"
    if FileManager.default.fileExists(atPath: backup) { return true }
    do {
        if let data = FileManager.default.contentsExploit(atPath: tn) {
            try? FileManager.default.createDirectory(atPath: backup, withIntermediateDirectories: true, attributes: nil)
            try? FileManager.default.removeItem(atPath: backup)
            try data.write(to: URLwithEncode(string: backup)!)
            return true
        }else{
            return false
        }
    } catch {
        if !FileManager.default.checkFilePermissions(atPath: tn) {
            return false
        }
    }
    return true
}


