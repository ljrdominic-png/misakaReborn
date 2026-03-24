//
//  AccessController.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/14.
//

import Foundation
import UIKit

func DataPath(_ Type: String) -> String {
    var Type_ = Type
    
    var library = URLwithEncode(string: "/var/mobile/Documents/.misaka")!
    #if targetEnvironment(simulator)
        library = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
    #endif
    
    if SettingsManager.shared.ExploitInfo[SettingsManager.shared.Exploit] == "Sandboxed" || SettingsManager.shared.NoVar {
        library = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
        if Type_ == "Packages" {
            Type_ = "Packages_Varless"
        }
    }
    
    if Type_ == "Settings" {
        library = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
    }
    
    let Path = library.appendingPathComponent(Type_)
    try? FileManager.default.createDirectory(atPath: Path.path, withIntermediateDirectories: true, attributes: nil)
    return Path.path
}

func checkSubdirectoryExistence(in directory: String, subdirectory: String) -> Bool {
    if directory == "" {
        return true
    }
    guard let contents = try? FileManager.default.contentsOfDirectory(atPath: directory) else {
        return false
    }
    return contents.contains(subdirectory)
}
func checkPathExistence(path: String) -> Bool {
    let paths = generatePaths(from: path)
    for (index, currentPath) in paths.enumerated() {
        if index > 0 {
            let parentPath = paths[index - 1]
            let lastComponent = currentPath.components(separatedBy: "/").last ?? ""
            let containsSubdirectory = checkSubdirectoryExistence(in: parentPath, subdirectory: lastComponent)
            if !containsSubdirectory {
                return false
            }
        }
    }
    return true
}

func generatePaths(from path: String) -> [String] {
    var generatedPaths: [String] = []
    let components = path.components(separatedBy: "/")
    for (index, _) in components.enumerated() {
        let partialPath = components[0...index].joined(separator: "/")
        generatedPaths.append(partialPath)
    }
    return generatedPaths
}
func createAndManageFolder(directoryPath: String, fileName: String) throws -> Void {
    try FileManager.default.createDirectory(atPath: "\(directoryPath)/\(fileName)", withIntermediateDirectories: true, attributes: nil)
}
func checkPathExistenceOrCreate(path: String) throws -> Void {
    let paths = generatePaths(from: path)
    for (index, currentPath) in paths.enumerated() {
        if index > 0 {
            let parentPath = paths[index - 1]
            let lastComponent = currentPath.components(separatedBy: "/").last ?? ""
            let containsSubdirectory = checkSubdirectoryExistence(in: parentPath, subdirectory: lastComponent)
            if !containsSubdirectory {
                try createAndManageFolder(directoryPath: parentPath, fileName: lastComponent)
            }
        }
    }
}

extension FileManager {
    func contentsOfDirectoryExploit(atPath path: String) throws -> [String] {
        var result = [String]()
        if FileManager.default.isAppdir(atPath: path) {
            result = try FileManager.default.contentsOfDirectory(atPath: path)
        } else {
            result = try FileManager.default.contentsOfDirectory(atPath: path)
        }
        return result
    }
    func createFileExploit(atPath path: String) -> Void {
        FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
    }
    func moveItemExploit(atPath: String, toPath: String) throws -> Void {
        try FileManager.default.moveItem(atPath: atPath, toPath: toPath)
    }
    func copyItemExploit(atPath: String, toPath: String) throws -> Void {
        try FileManager.default.copyItem(atPath: atPath, toPath: toPath)
    }
    func contentsExploit(atPath path: String) -> Data? {
        FileManager.default.contents(atPath: path)
    }
    func removeItemExploit(atPath path: String) throws {
        try FileManager.default.removeItem(atPath: path)
    }
    func writeFileExploit(atPath path: String, _ data: Data) throws -> Void {
        let url = URL(fileURLWithPath: path)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? FileManager.default.removeItem(atPath: path)
        try data.write(to: url)
    }
//    func fileExistsExploit(atPath path: String) -> Bool {
//        if KFDFileManager(atPath: path) {
//            return checkPathExistence(path: path)
//        }else{
//            return FileManager.default.fileExists(atPath: path)
//        }
//    }
    func createDirectoryExploit(atPath path: String) throws -> Void {
        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
    }
    func writeItemExploit(atPath path: String, data: Data) throws -> Void {
        try data.write(to: URL(fileURLWithPath: path))
    }
    func fileExistsExploit(atPath path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
}

extension FileManager {
//    func contentsOfDirectoryExploit(atPath path: String) throws -> [String] {
//        if KFDFileManager(atPath: path) {
//            if fileExistsExploit(atPath: path) {
//                let mntPath = "\(NSHomeDirectory())/Documents/\(UUID().uuidString)"
//                let origToVData = createFolderAndRedirect(getVnodeAtPathByChdir(path.cString()), mntPath)
//                defer {
//                    UnRedirectAndRemoveFolder(origToVData, mntPath)
//                }
//                return try FileManager.default.contentsOfDirectory(atPath: mntPath)
//            }else{
//                throw NSLocalizedString("folder not found", comment: "")
//            }
//        }else{
//            return try FileManager.default.contentsOfDirectory(atPath: path)
//        }
//    }
//    func createFileExploit(atPath path: String) throws -> Void {
//        if KFDFileManager(atPath: path) {
//            if fileExistsExploit(atPath: FileManager.default.extractDirectoryPath(path)!) {
//                try FileManager.default.writeFileExploit(atPath: path, Data([]))
//            }else{
//                throw NSLocalizedString("folder not found", comment: "")
//            }
//        }else{
//            FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
//        }
//    }
//    func contentsExploit(atPath path: String) -> Data? {
//        if KFDFileManager(atPath: path) {
//            if FileManager.default.fileExistsExploit(atPath: path) {
//                return dataFromFileCopy_AI(FileManager.default.extractDirectoryPath(path)!, FileManager.default.Basename(path)!)
//            }else{
//                return nil
//            }
//        }else{
//            return FileManager.default.contents(atPath: path)
//        }
//    }
    func writeFileExploitS(atPath path: String, _ data: Data) throws -> Void {
        let url = URL(fileURLWithPath: path)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: url)
    }
//    func createDirectoryExploit(atPath path: String) throws -> Void {
//        if KFDFileManager(atPath: path) {
//            let mntPath = "\(NSHomeDirectory())/Documents/\(UUID().uuidString)"
//            let origToVData = createFolderAndRedirect(getVnodeAtPathByChdir(FileManager.default.extractDirectoryPath(path)!.cString()), mntPath)
//            defer {
//                UnRedirectAndRemoveFolder(origToVData, mntPath)
//            }
//            try FileManager.default.createDirectory(atPath: "\(mntPath)/\(FileManager.default.Basename(path)!)", withIntermediateDirectories: true, attributes: nil)
//        }else{
//            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
//        }
//    }
}



extension FileManager {
    func isAppdir(atPath: String) -> Bool {
        let appDataDir = NSHomeDirectory().replacingOccurrences(of: "file://", with: "")
        let appBundleDir = Bundle.main.bundleURL.path.replacingOccurrences(of: "file://", with: "")
        return (atPath.prefix(appDataDir.count) == appDataDir || atPath.prefix(appBundleDir.count) == appBundleDir || atPath.contains("/.misaka/"))
    }
    func isDirectory(_ dirName: String) -> Bool {
        let fileManager = FileManager.default
        var isDir: ObjCBool = false
        if fileManager.fileExists(atPath: dirName, isDirectory: &isDir) {
            if isDir.boolValue {
                return true
            }
        }
        return false
    }
    func getTopLevelDirectoryName(atPath path: String) -> String? {
        guard let enumerator = FileManager.default.enumerator(atPath: path) else { return nil }
        var topLevelDirectory: String? = nil
        while let element = enumerator.nextObject() as? String {
            let elementPath = (path as NSString).appendingPathComponent(element)
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: elementPath, isDirectory: &isDirectory) && isDirectory.boolValue {
                topLevelDirectory = element
                enumerator.skipDescendants()
                break
            }
        }
        return topLevelDirectory
    }
    func checkFilePermissions(atPath path: String) -> Bool {
        if let range = path.range(of: "/", options: .backwards) {
            let folderPath = String(path.prefix(upTo: range.lowerBound))
            let filePath = folderPath + "/" + UUID().uuidString
            do {
                if !FileManager.default.fileExists(atPath: folderPath) {
                    try FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
                }
                FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
                try FileManager.default.removeItem(atPath: filePath)
                return true
            } catch {
                return false
            }
        }
        return false
    }
    func extractDirectoryPath(_ url: String) -> String? {
        let url = URL(fileURLWithPath: url)
        let directoryURL = url.deletingLastPathComponent()
        return directoryURL.path
    }
    func isDirectoryCountOver50(_ path: String) -> Bool{
        var directoryCount: Int = 0
        func countDirectory(path: String) {
            do {
                guard let escaped_path = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else { return }
                let files = try FileManager.default.contentsOfDirectoryExploit(atPath: escaped_path)
                files.forEach { item in
                    let itemPath = path+"/"+item
                    if (isDirectory(itemPath)) {
                        directoryCount += 1
                        if directoryCount >= 50 {
                            return
                        }
                        countDirectory(path: itemPath)
                    }
                }
            } catch {}
        }
        countDirectory(path: path)
        if directoryCount >= 50 {
            return false
        }
        return true
    }
    func AllfilesInFolder(_ path: String) -> [String] {
        var allfiles = [String]()
        func loopDirectory(path: String) {
            do{
                let files = try FileManager.default.contentsOfDirectoryExploit(atPath: path)
                files.forEach { item in
                    if isDirectory(path+"/"+item) {
                        loopDirectory(path: path+"/"+item)
                    }else{
                        allfiles.append(path+"/"+item)
                    }
                }
            }catch{}
        }
        loopDirectory(path: path)
        return allfiles
    }
    func Basename(_ urlString: String) -> String? {
        if let escapedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
           let url = URL(string: escapedString) {
            let basename = url.lastPathComponent
            return basename
        }
        return nil
    }
    func pathExtension(_ urlString: String) -> String? {
        let url = NSString(string: urlString)
        return url.pathExtension
    }
}


func ClearFolder(_ Path: String){
    try? FileManager.default.removeItem(atPath: Path)
    try? FileManager.default.createDirectory(atPath: Path, withIntermediateDirectories: true, attributes: nil)
}


var semaphoreExploit = DispatchSemaphore(value: 1)

/// When KRW + KFS is ready and the target is a real filesystem path (not `DataPath("Emu_Var")` mirror), use `kfs_overwrite_file` via `KRWKFSManager`. Otherwise fall back to `FileManager`.
func ExploitOverwrite(tn: String, on: String?, od: Data?) -> String {
    semaphoreExploit.wait()
    defer {
        semaphoreExploit.signal()
    }

    let emuRoot = DataPath("Emu_Var")
    let useKFS = SettingsManager.shared.Exploit == "DarkSword"
        && KRWKFSManager.shared.isReady
        && tn.hasPrefix(emuRoot) == false

    if useKFS {
        if let od = od {
            if KRWKFSManager.shared.overwriteFileWithData(target: tn, data: od) {
                return "Success"
            }
            return "Failure"
        }
        if let on = on, !on.isEmpty {
            if KRWKFSManager.shared.overwriteFileFromLocalPath(target: tn, sourcePath: on) {
                return "Success"
            }
            return "Failure"
        }
        return "Failure"
    }

    do {
        let url = URL(fileURLWithPath: tn)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        if let od = od {
            try od.write(to: url)
            return "Success"
        }
        if let on = on, let od = FileManager.default.contents(atPath: on) {
            try od.write(to: url)
            return "Success"
        }
    } catch {
        return error.localizedDescription
    }
    return "Failure"
}
