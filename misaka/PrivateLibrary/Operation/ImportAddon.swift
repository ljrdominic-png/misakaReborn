//
//  Import.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/18.
//

import Foundation
import UIKit

fileprivate func presentAddonInstallFailure(_ detail: String) {
    UIApplication.shared.alert(title: MILocalizedString("Installation failed"), body: detail, withButton: true)
}

func AddonImport(_ zip: URL, _ Queue: QueueType?) -> String {
    ClearFolder(DataPath("Extract"))
    
    let RepositoryURL = Queue?.RepositoryContentPack.RepositoryURL ?? ""
    let Repository = Queue?.RepositoryContentPack.Repository ?? RepositoryType()
    var RepositoryContent = Queue?.RepositoryContentPack.RepositoryContent ?? RepositoryContentType()
    var PackageID = Queue == nil ? UUID().uuidString : RepositoryContent.PackageID
    
    // Main
    if PackageID == "" {
        presentAddonInstallFailure("Package ID is empty. Repository metadata may be wrong or the queued item is invalid.")
        return "Incomplete file (Extract Error)"
    }
    let ExtractFrom = "\(DataPath("Extract"))/\(PackageID)"
    // Unzip
    let unzipResult = Unzip(from: zip, to: URLwithEncode(string: ExtractFrom)!)
    if !unzipResult.success {
        presentAddonInstallFailure("Could not unzip the package.\n\n\(unzipResult.errorMessage)")
        return "Incomplete file"
    }
//    deleteAllDSStoreFiles(in: ExtractFrom)
    
    guard let addons = try? FileManager.default.contentsOfDirectoryExploit(atPath: ExtractFrom) else {
        presentAddonInstallFailure("Could not read the extract folder after unzip.\n\(ExtractFrom)")
        return "A0"
    }
    addons_for:
    for addon in addons {
        do {
            if FileManager.default.fileExists(atPath: "\(ExtractFrom)/\(addon)/main.js") {
                presentAddonInstallFailure("JavaScript (main.js) tweaks are not supported.")
                return "Unsupported"
            }
            let config_Array = parsePlist(Data())
            func AssetsLoop(tc: String, oc: String, optional: Bool = false) throws {
                if tc.contains("/private/preboot") {
                    UIApplication.shared.alert(body: MILocalizedString("Editing /private/preboot may cause a boot loop"), withButton: true)
                    return
                }
                
                let files = try FileManager.default.contentsOfDirectoryExploit(atPath: oc)
                for_i:
                for file in files {
                    var _file = applyPathVariable(file)
                    let modes = processFileMode(&_file)
                    let isOptional = modes.contains("%Optional%") || optional
                    
                    var matched_target: [String] = [String]()
                    if !modes.contains("%Misaka_Regex%") {
                        matched_target.append(_file)
                    }else{
                        let files = try FileManager.default.contentsOfDirectoryExploit(atPath: tc)
                        for file in files {
                            if file.range(of: _file, options: .regularExpression) != nil {
                                matched_target.append(file)
                            }
                        }
                    }
                    
                    for i in matched_target.indices {
                        var AllLogs = ""
                        _ = String((0..<2).map{ _ in "0123456789".randomElement()! })
                        // 設定分岐
                        let Segments = Misaka_Segment(path: matched_target[i])
                        if let Segments_Params = Segments["Params"] as? [[String: String]],
                           let Segments_Name = Segments["Name"] as? String {
                            for Params in Segments_Params {
                                if let matchedElement = config_Array.first(where: { $0["Identifier"] as? String == Params["Identifier"] }) {
                                    if Params["Value"] != matchedElement["Value"] as? String {
                                        continue for_i
                                    }
                                }
                                let pattern = "%Misaka_Segment\\{Name[:;] '(.+)', \\[(.+)\\]\\}%"
                                if let range = matched_target[i].range(of: pattern, options: .regularExpression) {
                                    let substring = matched_target[i][range]
                                    matched_target[i] = matched_target[i].replacingOccurrences(of: substring, with: Segments_Name)
                                }
                            }
                        }
                        
                        let tn = "\(tc)/\(matched_target[i])".replacingOccurrences(of: "//", with: "/")
                        let on = "\(oc)/\(file)".replacingOccurrences(of: "///", with: "/").replacingOccurrences(of: "//", with: "/")
                        print("[* misaka] tn: \(tn)")
                        print("[* misaka] on: \(on)")
                        
                        var isDir2: ObjCBool = false
                        if FileManager.default.fileExists(atPath: "\(on)", isDirectory: &isDir2) {
                            if isDir2.boolValue {
                                try AssetsLoop(tc: "\(tn)", oc: "\(on)", optional: isOptional)
                            }else{
                                AllLogs += "[*] Optional: "+String(isOptional)+"\n"
                                if SettingsManager.shared.ExploitInfo[SettingsManager.shared.Exploit] == "Sandboxed" || SettingsManager.shared.NoVar {
                                    // VirtualRoot Path
                                    if tn.prefix(12) == "/var/mobile/" {
                                        continue
                                    }
                                }
                                
                                if FileBackup(tn) == false {
                                    if !FileManager.default.checkFilePermissions(atPath: tn) && !isOptional {
                                        presentAddonInstallFailure("Backup/write failed and target is not writable (required file).\n\(tn)")
                                        return
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Overwriteフォルダがあるか
            if !FileManager.default.fileExists(atPath: "\(ExtractFrom)/\(addon)/tweak.json") {
                let OverwriteF = "\(ExtractFrom)/\(addon)/Overwrite"
                print(OverwriteF)
                if !FileManager.default.fileExists(atPath: OverwriteF) {
                    let detail = "\(MILocalizedString("Incomplete file (Missing OverwriteFolder)"))\n\n\(addon)\n\(OverwriteF)"
                    UIApplication.shared.alert(title: MILocalizedString("Installation failed"), body: detail, withButton: true)
                    return "Incomplete file"
                }
                // Sandbox化されている場合、varへの変更を含むAddonをブロック
                if SettingsManager.shared.ExploitInfo[SettingsManager.shared.Exploit] == "Sandboxed" || SettingsManager.shared.NoVar {
                    guard let F = try? FileManager.default.contentsOfDirectoryExploit(atPath: OverwriteF) else {
                        presentAddonInstallFailure("Could not list Overwrite folder contents [A1].\n\(OverwriteF)")
                        return "A1"
                    }
                    if F.contains("var") && RepositoryContent.EmuVar == false && SettingsManager.shared.Exploit != "DarkSword" {
                        guard let Fv = try? FileManager.default.contentsOfDirectoryExploit(atPath: OverwriteF+"/var") else {
                            presentAddonInstallFailure("Could not read Overwrite/var [A2].\n\(OverwriteF)/var")
                            return "A2"
                        }
                        if Fv.contains("mobile") && Fv.count == 1 {
                            guard let Fvm = try? FileManager.default.contentsOfDirectoryExploit(atPath: OverwriteF+"/var/mobile") else {
                                presentAddonInstallFailure("Could not read Overwrite/var/mobile [A3].\n\(OverwriteF)/var/mobile")
                                return "A3"
                            }
                            if Fv.contains("Documents") && Fv.count == 1 {
                                UIApplication.shared.alert(body: MILocalizedString("Installation failed. This tweak requires access to /var/, which kfd doesn’t support yet"), withButton: true)
                                return "Unsupported"
                            }
                        }
                    }
                }
                if !FileManager.default.fileExists(atPath: "\(ExtractFrom)/\(addon)/Special") {
                    try AssetsLoop(tc: "/", oc: OverwriteF)
                }
            }
            
            try? FileManager.default.removeItem(atPath: "\(ExtractFrom)/\(addon)/config_default.plist")
            if FileManager.default.fileExists(atPath: "\(ExtractFrom)/\(addon)/config.plist") {
                try? FileManager.default.copyItem(atPath: "\(ExtractFrom)/\(addon)/config.plist", toPath: "\(ExtractFrom)/\(addon)/config_default.plist")
            }
            FileManager.default.createFile(atPath: "\(ExtractFrom)/\(addon)/.system/.OFF", contents: nil, attributes: nil)
            if Queue != nil {
                try? FileManager.default.createDirectory(atPath: "\(ExtractFrom)/\(addon)/.system", withIntermediateDirectories: true, attributes: nil)
                let encoder = JSONEncoder()
                do {
                    RepositoryContent.RepositoryURL = RepositoryURL
                    let jsonData = try encoder.encode(RepositoryContent)
                    let jsonString = String(data: jsonData, encoding: .utf8)
                    try jsonString?.write(to: URLwithEncode(string: "file://\(ExtractFrom)/\(addon)/.system/info.json")!, atomically: true, encoding: .utf8)
                } catch {}
                do {
                    let text = Queue?.Releases.Version
                    try text?.write(to: URLwithEncode(string: "file://\(ExtractFrom)/\(addon)/.system/Version.json")!, atomically: true, encoding: .utf8)
                } catch {}
            }
            var ExtractTo = "\(DataPath("Packages"))/\(PackageID)"
            if PackageID == "UUID().uuidString" {
                ExtractTo = "\(DataPath("Packages"))/\(addon)"
            }
            
            if Queue == nil && FileManager.default.fileExists(atPath: ExtractTo) {
                UIApplication.shared.alert(body: MILocalizedString("Item with same name already exists."), withButton: true)
                return "Already Exists"
            }
            try? FileManager.default.createDirectory(atPath: ExtractTo, withIntermediateDirectories: true, attributes: nil)
            try? FileManager.default.removeItem(atPath: ExtractTo)
            try FileManager.default.copyItem(atPath: "\(ExtractFrom)/\(addon)", toPath: ExtractTo)
        } catch {
            UIApplication.shared.alert(body: "An error occurred: \(error)", withButton: true)
        }
    }
    AfterInstall()
    ViewMemory.shared.Reload()
    return "Installed"
}

func AfterInstall() {}
