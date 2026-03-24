//
//  UnZip.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/14.
//

import Foundation
import Zip

func Unzip(from: URL, to: URL) -> (success: Bool, errorMessage: String) {
    var from = from
    if let fileExtension = FileManager.default.pathExtension(from.path), fileExtension != "zip", fileExtension != "misaka" {
        if let lastDotIndex = from.path.lastIndex(of: ".") {
            let newPath = from.path.prefix(upTo: lastDotIndex) + ".zip"
            try? FileManager.default.copyItem(atPath: from.path, toPath: String(newPath))
            from = URLwithEncode(string: String(newPath))!
            print("." + fileExtension)
            print(newPath)
            print(from)
        }
    }
    guard FileManager.default.fileExists(atPath: from.path),
          let data = FileManager.default.contents(atPath: from.path),
          !data.isEmpty else {
        return (false, "Archive is missing, empty, or unreadable at \(from.lastPathComponent).")
    }
    do {
        try? FileManager.default.removeItem(at: to)
        try Zip.unzipFile(from, destination: to, overwrite: true, password: nil, progress: { progress in
            print(progress)
        })
        return (true, "")
    } catch {
        return (false, (error as NSError).localizedDescription)
    }
}

func Zip(in inputFile: String, out outputFile: String) throws {
    let zipURL = "\(DataPath("ShareZip"))/Share.zip"
    try FileManager.default.createDirectory(atPath: DataPath("ShareZip"), withIntermediateDirectories: true, attributes: nil)
    try Zip.zipFiles(paths: [URL(fileURLWithPath: inputFile)], zipFilePath: URL(fileURLWithPath: zipURL), password: nil, progress: { progress in
        print(progress)
    })
    try? FileManager.default.removeItem(at: URL(fileURLWithPath: outputFile))
    try FileManager.default.copyItem(atPath: zipURL, toPath: outputFile)
}
