//
//  Apply.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/19.
//

import Foundation
import UIKit
import SwiftUI

struct ResultType: Codable, Hashable {
    var Log: String
    var FullLog: String
    var IsSuccess: Bool
    var Target: String
    var Overwrite: String
    var Target_Size: String?
    var Overwrite_Size: String?
}

func ApplyBackground(Addon: String) {
    let paths = FileManager.default.AllfilesInFolder("\(DataPath("BackgroundApply"))/\(Addon)")
    for path in paths {
        var FullLog = ""
        var Results = [ResultType]()
        if let od = FileManager.default.contents(atPath: path) {
            Flash(tn: path.replacingOccurrences(of: "\(DataPath("BackgroundApply"))/\(Addon)", with: ""), on: path, od: od, Mode: "Apply", isOptional: true, FullLog: &FullLog, randomStr: FullLog, Results: &Results)
        }
    }
}

func Apply(PackageID: String, Mode: String) -> [ResultType] {
    print("[* misaka] Apply")
//    print(PackageID+": semaphorek.wait()")
    var Results: [ResultType] = [ResultType]()
    
    ViewMemory.shared.semaphoreApply.wait()
    DispatchQueue.main.async {
        ViewMemory.shared.Applying_Addon = PackageID
    }
    defer {
//        print(PackageID+": semaphorek.signal()")
        DispatchQueue.main.async {
            ViewMemory.shared.Applying_Addon = ""
            ViewMemory.shared.semaphoreApply.signal()
        }
    }
    
    if FileManager.default.fileExists(atPath: "\(DataPath("Packages"))/\(PackageID)/Special") {
        if Mode == "Apply" {
            Results = SpecialApply(PackageID: PackageID, Mode: "Apply")
        }else{
            Results.append(ResultType(Log: "", FullLog: "", IsSuccess: false, Target: "", Overwrite: ""))
        }
        return Results
    }else if FileManager.default.fileExists(atPath: "\(DataPath("Packages"))/\(PackageID)/main.js") {
        Results.append(ResultType(Log: MILocalizedString("Unsupported"), FullLog: "main.js tweaks are not supported.", IsSuccess: false, Target: "", Overwrite: ""))
        return Results
    }
    
    if Mode == "BackgroundApply" {
        ApplyBackground(Addon: PackageID)
        return Results
    }
    var isPasscodeTheme = false
    
    do {
        var config_Array = parsePlist(FileManager.default.contents(atPath: "\(DataPath("Packages"))/\(PackageID)/config.plist") ?? Data())
        if SettingsManager.shared.ExploitInfo[SettingsManager.shared.Exploit] == "Sandboxed" || SettingsManager.shared.NoVar {
            config_Array.append(["Identifier": "/var", "Value": "\(DataPath("Emu_Var"))/var"])
        }
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
                    var FullLog = ""
                    let randomStr = String((0..<2).map{ _ in "0123456789".randomElement()! })
                    // 設定分岐
                    let Segments = Misaka_Segment(path: matched_target[i])
                    if let Segments_Params = Segments["Params"] as? [[String: String]],
                       let Segments_Name = Segments["Name"] as? String {
                        for Params in Segments_Params {
                            if let matchedElement = config_Array.first(where: { $0["Identifier"] as? String == Params["Identifier"] }) {
                                if Params["Value"] != AnyToString(matchedElement["Value"] as Any) {
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
                    
                    var tn = "\(tc)/\(matched_target[i])".replacingOccurrences(of: "//", with: "/")
                    let on = "\(oc)/\(file)".replacingOccurrences(of: "///", with: "/").replacingOccurrences(of: "//", with: "/")
                    print("[* misaka] tn: \(tn)")
                    print("[* misaka] on: \(on)")
                    if tn.contains("TelephonyUI-") {
                        isPasscodeTheme = true
                    }
                    
                    var isDir2: ObjCBool = false
                    if FileManager.default.fileExists(atPath: "\(on)", isDirectory: &isDir2) {
                        if isDir2.boolValue {
                            try AssetsLoop(tc: "\(tn)", oc: "\(on)", optional: isOptional)
                        }else{
                            FullLog += "[*] Optional: "+String(isOptional)+"\n"
                            
                            guard var od = FileManager.default.contents(atPath: on) else {
                                Results.append(ResultType(
                                    Log: "on load failed",
                                    FullLog: FullLog,
                                    IsSuccess: false,
                                    Target: tn,
                                    Overwrite: on
                                ))
                                continue
                            }
//                            var od: NSData = try NSData(contentsOf: URLwithEncode(string: on)! ,options: NSData.ReadingOptions.alwaysMapped)
                            
                            FullLog += "Size (Overwrite): "+String(od.count)+"\n"
                            if let bb = getFileSize(atPath: tn) {
                                FullLog += "Size (Target): "+String(bb)+"\n"
                            }
                            
                            if Mode == "Apply" || Mode == "IsSucceeded" {
                                // .json .caml
                                if NSString(string: matched_target[i]).pathExtension == "caml" ||
                                    NSString(string: matched_target[i]).pathExtension == "json" ||
                                    modes.contains("%Misaka_Binary%") {
                                    FullLog += "[*] File Type: json / caml\n"
                                    FullLog += "[*] Data to String\n"
                                    guard var str = String(data: od, encoding: .utf8) else {
                                        FullLog += "[*] Error\n"
                                        Results.append(ResultType(
                                            Log: "Data to String - Error",
                                            FullLog: FullLog,
                                            IsSuccess: false,
                                            Target: tn,
                                            Overwrite: on
                                        ))
                                        continue
                                    }
                                    if modes.contains("%Misaka_Compression%") {
                                        FullLog += "[*] Compression\n"
                                        FullLog += "Size (Before): "+String(od.count)+"\n"
                                        str = str.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\t", with: "")
                                        FullLog += "Size (After): "+String(od.count)+"\n"
                                    }
                                    FullLog += "[*] String to Data\n"
                                    let output = StrReplaceByArray(str, ArrayValueToString(config_Array))
                                    guard let outputcaml = output.data(using: .utf8) else {
                                        Results.append(ResultType(
                                            Log: "String to Data - Error",
                                            FullLog: FullLog,
                                            IsSuccess: false,
                                            Target: tn,
                                            Overwrite: on
                                        ))
                                        continue
                                    }
                                    od = outputcaml
                                    if NSString(string: matched_target[i]).pathExtension == "json" {
                                        if !FileManager.default.checkFilePermissions(atPath: tn) {
                                            if FileManager.default.fileExistsExploit(atPath: tn) {
                                                FullLog += "[*] Padding to fit target file size\n"
                                                FullLog += "Size (Before): "+String(od.count)+"\n"
                                                guard let td = FileManager.default.contentsExploit(atPath: tn) else {
                                                    FullLog += "[*] Error\n"
                                                    Results.append(ResultType(
                                                        Log: "Padding to fit target file size - Error",
                                                        FullLog: FullLog,
                                                        IsSuccess: false,
                                                        Target: tn,
                                                        Overwrite: on
                                                    ))
                                                    continue
                                                }
                                                while od.count < td.count {
                                                    od.append(Data([0x00]))
                                                }
                                                FullLog += "Size (After): "+String(od.count)+"\n"
                                            }
                                        }
                                    }
                                }
                                // .png
                                else if NSString(string: matched_target[i]).pathExtension == "png" && modes.contains("%Misaka_Resize%") {
                                    FullLog += "[*] File Type: png\n"
                                    if let td = FileManager.default.contentsExploit(atPath: tn) {
                                        FullLog += "[*] Adjust resolution to match target file size\n"
                                        guard let im = resizeImage(od: od, td: td) else {
                                            FullLog += "[*] Error\n"
                                            Results.append(ResultType(
                                                Log: "Adjust resolution to match target file size - Error",
                                                FullLog: FullLog,
                                                IsSuccess: false,
                                                Target: tn,
                                                Overwrite: on
                                            ))
                                            continue
                                        }
                                        od = im
                                    }
                                }
                                // .binary
                                if modes.contains("%Misaka_Binary%") {
                                    FullLog += "[*] Binary Edit\n"
                                    if let td = FileManager.default.contentsExploit(atPath: tn) {
                                        od = updateBinaryData(od: od, td: td)
                                    }
                                }
                                // .bplist
                                else if let bplist = try? PropertyListSerialization.propertyList(from: od, options: [], format: nil) {
                                    var isbplist = false
                                    if let _ = bplist as? [String: Any] {
                                        isbplist = true
                                        FullLog += "[*] File Type: bplist\n"
                                        if let _ = bplist as? [String: Any] {
                                            FullLog += "[*] Apply config settings\n"
                                            FullLog += "Size (Before): "+String(od.count)+"\n"
                                            guard let applyedData = PlistReplaceByArray(od, config_Array) else {
                                                Results.append(ResultType(
                                                    Log: "PlistReplaceByArray failed",
                                                    FullLog: FullLog,
                                                    IsSuccess: false,
                                                    Target: tn,
                                                    Overwrite: on
                                                ))
                                                continue
                                            }
                                            od = applyedData
                                            FullLog += "Size (After): "+String(od.count)+"\n"
                                            if (NSDictionary(contentsOfFile: on)?.value(forKey: "%Misaka_Overwrite%") != nil) {
                                                FullLog += "[*] Merge target file with this file\n"
                                                FullLog += "Size (Before): "+String(od.count)+"\n"
                                                guard let plist = mergePlistFiles(tn: tn, od: od) else {
                                                    Results.append(ResultType(
                                                        Log: "mergePlist failed",
                                                        FullLog: FullLog,
                                                        IsSuccess: false,
                                                        Target: tn,
                                                        Overwrite: on
                                                    ))
                                                    continue
                                                }
                                                od = plist
                                                FullLog += "Size (After): "+String(od.count)+"\n"
                                            }
                                        }
                                        if !FileManager.default.checkFilePermissions(atPath: tn) && FileManager.default.fileExistsExploit(atPath: tn) {
                                            FullLog += "[*] Padding to fit target file size\n"
                                            FullLog += "Size (Before): "+String(od.count)+"\n"
                                            guard let plist = plistPadding(tn: tn, od: od)?.0 else {
                                                FullLog += "[*] Error\n"
                                                Results.append(ResultType(
                                                    Log: "Padding to fit target file size - Error",
                                                    FullLog: FullLog,
                                                    IsSuccess: false,
                                                    Target: tn,
                                                    Overwrite: on
                                                ))
                                                continue
                                            }
                                            od = plist
                                            FullLog += "Size (After): "+String(od.count)+"\n"
                                        }
                                    }else if let _ = bplist as? [Any] {
                                        isbplist = true
                                        FullLog += "[*] File Type: bplist (array)\n"
                                        if !FileManager.default.checkFilePermissions(atPath: matched_target[i]) {
                                            if let bplist = try? PropertyListSerialization.propertyList(from: od, options: [], format: nil),
                                               let _ = bplist as? [Any] {
                                                if FileManager.default.fileExistsExploit(atPath: tn) {
                                                    FullLog += "[*] Padding to fit target file size\n"
                                                    FullLog += "Size (Before): "+String(od.count)+"\n"
                                                    guard let plist = plistPadding(tn: tn, od: od)?.0 else {
                                                        FullLog += "[*] Error\n"
                                                        Results.append(ResultType(
                                                            Log: "Padding to fit target file size - Error",
                                                            FullLog: FullLog,
                                                            IsSuccess: false,
                                                            Target: tn,
                                                            Overwrite: on
                                                        ))
                                                        continue
                                                    }
                                                    od = plist
                                                    FullLog += "Size (After): "+String(od.count)+"\n"
                                                }
                                            }
                                        }
                                    }
                                    
                                    if isbplist == true {
                                        if !FileManager.default.checkFilePermissions(atPath: tn) {
                                            if let td = FileManager.default.contentsExploit(atPath: tn) {
                                                if od.count != td.count {
                                                    Results.append(ResultType(
                                                        Log: "Padding to fit target file size - Error",
                                                        FullLog: FullLog,
                                                        IsSuccess: false,
                                                        Target: tn,
                                                        Overwrite: on
                                                    ))
                                                    continue
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                FullLog += "Final Size (Overwrite): "+String(od.count)+"\n"
                                if let bb = getFileSize(atPath: tn) {
                                    FullLog += "Final Size (Target): "+String(bb)+"\n"
                                }
                                
                                if SettingsManager.shared.ExploitInfo[SettingsManager.shared.Exploit] == "Sandboxed" || SettingsManager.shared.NoVar {
                                    // VirtualRoot Path
                                    if tn.prefix(22) == "/var/mobile/Documents/" || tn.prefix(38) == "/var/mobile/Library/Caches/TelephonyUI" {
                                        tn = tn.replacingOccurrences(of: "/var", with: "\(DataPath("Emu_Var"))/var")
                                    }
                                }
                                
                                if Mode == "Apply" {
                                    if !FileManager.default.checkFilePermissions(atPath: tn) && !optional && !isOptional {
                                        if FileBackup(tn) == false {
                                            Results.append(ResultType(
                                                Log: "target file does not exist.\n\(tn)",
                                                FullLog: FullLog,
                                                IsSuccess: false,
                                                Target: tn,
                                                Overwrite: on
                                            ))
                                            break
                                        }
                                    }
                                }
                            }else if Mode == "Restore" {
                                if SettingsManager.shared.ExploitInfo[SettingsManager.shared.Exploit] == "Sandboxed" || SettingsManager.shared.NoVar {
                                    // VirtualRoot Path
                                    if tn.prefix(22) == "/var/mobile/Documents/" || tn.prefix(38) == "/var/mobile/Library/Caches/TelephonyUI" {
                                        tn = tn.replacingOccurrences(of: "/var", with: "\(DataPath("Emu_Var"))/var")
                                    }
                                }
                                
                                if !FileManager.default.checkFilePermissions(atPath: tn) {
                                    if let od_ = FileManager.default.contentsExploit(atPath: "\(DataPath("Backup"))\(tn)") {
                                        od = od_
                                    }else {
                                        FullLog += "[*] Missing backup\n"
                                        if !isOptional {
                                            Results.append(ResultType(
                                                Log: "Missing backup - "+randomStr,
                                                FullLog: FullLog,
                                                IsSuccess: false,
                                                Target: tn,
                                                Overwrite: on
                                            ))
                                            continue
                                        }else{
                                            FullLog += "[*] Missing backup (Ignored because it is optional)\n"
                                            Results.append(ResultType(
                                                Log: "Optional Skip (Missing backup) - "+randomStr,
                                                FullLog: FullLog,
                                                IsSuccess: true,
                                                Target: tn,
                                                Overwrite: on
                                            ))
                                            continue
                                        }
                                    }
                                }
                            }
                            
                            if Mode == "Apply" {
                                let tn_b = "\(DataPath("BackgroundApply"))/\(PackageID)/\(tn)"
                                try? FileManager.default.createDirectory(atPath: tn_b, withIntermediateDirectories: true, attributes: nil)
                                try? FileManager.default.removeItem(atPath: tn_b)
                                try od.write(to: URLwithEncode(string: tn_b)!)
                            }
                            
                            Flash(tn: tn, on: on, od: od, Mode: Mode, isOptional: isOptional, FullLog: &FullLog, randomStr: randomStr, Results: &Results)
                        }
                    }
                }
            }
        }
        try AssetsLoop(tc: "/", oc: "\(DataPath("Packages"))/\(PackageID)/Overwrite")
        if Mode == "Apply", isPasscodeTheme {
            Passcode()
        }
    } catch {
//        UIApplication.shared.alert(body: "An error occurred: \(error)", withButton: true)
    }
    return Results
}


func Apply_F(PackageID: String, Mode: String) -> [ResultType] {
    print("[* misaka] Apply")
//    print(PackageID+": semaphorek.wait()")
    var Results: [ResultType] = [ResultType]()
    
    ViewMemory.shared.semaphoreApply.wait()
    DispatchQueue.main.async {
        ViewMemory.shared.Applying_Addon = PackageID
    }
    defer {
//        print(PackageID+": semaphorek.signal()")
        DispatchQueue.main.async {
            ViewMemory.shared.Applying_Addon = ""
            ViewMemory.shared.semaphoreApply.signal()
        }
    }
    
    if FileManager.default.fileExists(atPath: "\(DataPath("Packages"))/\(PackageID)/Special") {
        if Mode == "Apply" {
            Results = SpecialApply(PackageID: PackageID, Mode: "Apply")
        }else{
            Results.append(ResultType(Log: "", FullLog: "", IsSuccess: false, Target: "", Overwrite: ""))
        }
        return Results
    }else if FileManager.default.fileExists(atPath: "\(DataPath("Packages"))/\(PackageID)/main.js") {
        Results.append(ResultType(Log: MILocalizedString("Unsupported"), FullLog: "main.js tweaks are not supported.", IsSuccess: false, Target: "", Overwrite: ""))
        return Results
    }
    
    if Mode == "BackgroundApply" {
        ApplyBackground(Addon: PackageID)
        return Results
    }
    var isPasscodeTheme = false
    
    do {
        var config_Array = parsePlist(FileManager.default.contents(atPath: "\(DataPath("Packages"))/\(PackageID)/config.plist") ?? Data())
        if SettingsManager.shared.ExploitInfo[SettingsManager.shared.Exploit] == "Sandboxed" || SettingsManager.shared.NoVar {
            config_Array.append(["Identifier": "/var", "Value": "\(DataPath("Emu_Var"))/var"])
        }
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
                    var FullLog = ""
                    let randomStr = String((0..<2).map{ _ in "0123456789".randomElement()! })
                    // 設定分岐
                    let Segments = Misaka_Segment(path: matched_target[i])
                    if let Segments_Params = Segments["Params"] as? [[String: String]],
                       let Segments_Name = Segments["Name"] as? String {
                        for Params in Segments_Params {
                            if let matchedElement = config_Array.first(where: { $0["Identifier"] as? String == Params["Identifier"] }) {
                                if Params["Value"] != AnyToString(matchedElement["Value"] as Any) {
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
                    
                    var tn = "\(tc)/\(matched_target[i])".replacingOccurrences(of: "//", with: "/")
                    let on = "\(oc)/\(file)".replacingOccurrences(of: "///", with: "/").replacingOccurrences(of: "//", with: "/")
                    print("[* misaka] tn: \(tn)")
                    print("[* misaka] on: \(on)")
                    if tn.contains("TelephonyUI-") {
                        isPasscodeTheme = true
                    }
                    
                    var isDir2: ObjCBool = false
                    if FileManager.default.fileExists(atPath: "\(on)", isDirectory: &isDir2) {
                        if isDir2.boolValue {
                            try AssetsLoop(tc: "\(tn)", oc: "\(on)", optional: isOptional)
                        }else{
                            FullLog += "[*] Optional: "+String(isOptional)+"\n"
                            
                            guard var od = FileManager.default.contents(atPath: on) else {
                                Results.append(ResultType(
                                    Log: "on load failed",
                                    FullLog: FullLog,
                                    IsSuccess: false,
                                    Target: tn,
                                    Overwrite: on
                                ))
                                continue
                            }
//                            var od: NSData = try NSData(contentsOf: URLwithEncode(string: on)! ,options: NSData.ReadingOptions.alwaysMapped)
                            
                            FullLog += "Size (Overwrite): "+String(od.count)+"\n"
                            if let bb = getFileSize(atPath: tn) {
                                FullLog += "Size (Target): "+String(bb)+"\n"
                            }
                            
                            if Mode == "Apply" || Mode == "IsSucceeded" {
                                // .json .caml
                                if NSString(string: matched_target[i]).pathExtension == "caml" ||
                                    NSString(string: matched_target[i]).pathExtension == "json" ||
                                    modes.contains("%Misaka_Binary%") {
                                    FullLog += "[*] File Type: json / caml\n"
                                    FullLog += "[*] Data to String\n"
                                    guard var str = String(data: od, encoding: .utf8) else {
                                        FullLog += "[*] Error\n"
                                        Results.append(ResultType(
                                            Log: "Data to String - Error",
                                            FullLog: FullLog,
                                            IsSuccess: false,
                                            Target: tn,
                                            Overwrite: on
                                        ))
                                        continue
                                    }
                                    if modes.contains("%Misaka_Compression%") {
                                        FullLog += "[*] Compression\n"
                                        FullLog += "Size (Before): "+String(od.count)+"\n"
                                        str = str.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\t", with: "")
                                        FullLog += "Size (After): "+String(od.count)+"\n"
                                    }
                                    FullLog += "[*] String to Data\n"
                                    let output = StrReplaceByArray(str, ArrayValueToString(config_Array))
                                    guard let outputcaml = output.data(using: .utf8) else {
                                        Results.append(ResultType(
                                            Log: "String to Data - Error",
                                            FullLog: FullLog,
                                            IsSuccess: false,
                                            Target: tn,
                                            Overwrite: on
                                        ))
                                        continue
                                    }
                                    od = outputcaml
                                    if NSString(string: matched_target[i]).pathExtension == "json" {
                                        if !FileManager.default.checkFilePermissions(atPath: tn) {
                                            if FileManager.default.fileExistsExploit(atPath: tn) {
                                                FullLog += "[*] Padding to fit target file size\n"
                                                FullLog += "Size (Before): "+String(od.count)+"\n"
                                                guard let td = FileManager.default.contentsExploit(atPath: tn) else {
                                                    FullLog += "[*] Error\n"
                                                    Results.append(ResultType(
                                                        Log: "Padding to fit target file size - Error",
                                                        FullLog: FullLog,
                                                        IsSuccess: false,
                                                        Target: tn,
                                                        Overwrite: on
                                                    ))
                                                    continue
                                                }
                                                while od.count < td.count {
                                                    od.append(Data([0x00]))
                                                }
                                                FullLog += "Size (After): "+String(od.count)+"\n"
                                            }
                                        }
                                    }
                                }
                                // .png
                                else if NSString(string: matched_target[i]).pathExtension == "png" && modes.contains("%Misaka_Resize%") {
                                    FullLog += "[*] File Type: png\n"
                                    if let td = FileManager.default.contentsExploit(atPath: tn) {
                                        FullLog += "[*] Adjust resolution to match target file size\n"
                                        guard let im = resizeImage(od: od, td: td) else {
                                            FullLog += "[*] Error\n"
                                            Results.append(ResultType(
                                                Log: "Adjust resolution to match target file size - Error",
                                                FullLog: FullLog,
                                                IsSuccess: false,
                                                Target: tn,
                                                Overwrite: on
                                            ))
                                            continue
                                        }
                                        od = im
                                    }
                                }
                                // .binary
                                if modes.contains("%Misaka_Binary%") {
                                    FullLog += "[*] Binary Edit\n"
                                    if let td = FileManager.default.contentsExploit(atPath: tn) {
                                        od = updateBinaryData(od: od, td: td)
                                    }
                                }
                                // .bplist
                                else if let bplist = try? PropertyListSerialization.propertyList(from: od, options: [], format: nil) {
                                    var isbplist = false
                                    if let _ = bplist as? [String: Any] {
                                        isbplist = true
                                        FullLog += "[*] File Type: bplist\n"
                                        if let _ = bplist as? [String: Any] {
                                            FullLog += "[*] Apply config settings\n"
                                            FullLog += "Size (Before): "+String(od.count)+"\n"
                                            guard let applyedData = PlistReplaceByArray(od, config_Array) else {
                                                Results.append(ResultType(
                                                    Log: "PlistReplaceByArray failed",
                                                    FullLog: FullLog,
                                                    IsSuccess: false,
                                                    Target: tn,
                                                    Overwrite: on
                                                ))
                                                continue
                                            }
                                            od = applyedData
                                            FullLog += "Size (After): "+String(od.count)+"\n"
                                            if (NSDictionary(contentsOfFile: on)?.value(forKey: "%Misaka_Overwrite%") != nil) {
                                                FullLog += "[*] Merge target file with this file\n"
                                                FullLog += "Size (Before): "+String(od.count)+"\n"
                                                guard let plist = mergePlistFiles(tn: tn, od: od) else {
                                                    Results.append(ResultType(
                                                        Log: "mergePlist failed",
                                                        FullLog: FullLog,
                                                        IsSuccess: false,
                                                        Target: tn,
                                                        Overwrite: on
                                                    ))
                                                    continue
                                                }
                                                od = plist
                                                FullLog += "Size (After): "+String(od.count)+"\n"
                                            }
                                        }
                                        if !FileManager.default.checkFilePermissions(atPath: tn) && FileManager.default.fileExistsExploit(atPath: tn) {
                                            FullLog += "[*] Padding to fit target file size\n"
                                            FullLog += "Size (Before): "+String(od.count)+"\n"
                                            guard let plist = plistPadding(tn: tn, od: od)?.0 else {
                                                FullLog += "[*] Error\n"
                                                Results.append(ResultType(
                                                    Log: "Padding to fit target file size - Error",
                                                    FullLog: FullLog,
                                                    IsSuccess: false,
                                                    Target: tn,
                                                    Overwrite: on
                                                ))
                                                continue
                                            }
                                            od = plist
                                            FullLog += "Size (After): "+String(od.count)+"\n"
                                        }
                                    }else if let _ = bplist as? [Any] {
                                        isbplist = true
                                        FullLog += "[*] File Type: bplist (array)\n"
                                        if !FileManager.default.checkFilePermissions(atPath: matched_target[i]) {
                                            if let bplist = try? PropertyListSerialization.propertyList(from: od, options: [], format: nil),
                                               let _ = bplist as? [Any] {
                                                if FileManager.default.fileExistsExploit(atPath: tn) {
                                                    FullLog += "[*] Padding to fit target file size\n"
                                                    FullLog += "Size (Before): "+String(od.count)+"\n"
                                                    guard let plist = plistPadding(tn: tn, od: od)?.0 else {
                                                        FullLog += "[*] Error\n"
                                                        Results.append(ResultType(
                                                            Log: "Padding to fit target file size - Error",
                                                            FullLog: FullLog,
                                                            IsSuccess: false,
                                                            Target: tn,
                                                            Overwrite: on
                                                        ))
                                                        continue
                                                    }
                                                    od = plist
                                                    FullLog += "Size (After): "+String(od.count)+"\n"
                                                }
                                            }
                                        }
                                    }
                                    
                                    if isbplist == true {
                                        if !FileManager.default.checkFilePermissions(atPath: tn) {
                                            if let td = FileManager.default.contentsExploit(atPath: tn) {
                                                if od.count != td.count {
                                                    Results.append(ResultType(
                                                        Log: "Padding to fit target file size - Error",
                                                        FullLog: FullLog,
                                                        IsSuccess: false,
                                                        Target: tn,
                                                        Overwrite: on
                                                    ))
                                                    continue
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                FullLog += "Final Size (Overwrite): "+String(od.count)+"\n"
                                if let bb = getFileSize(atPath: tn) {
                                    FullLog += "Final Size (Target): "+String(bb)+"\n"
                                }
                                
                                if SettingsManager.shared.ExploitInfo[SettingsManager.shared.Exploit] == "Sandboxed" || SettingsManager.shared.NoVar {
                                    // VirtualRoot Path
                                    if tn.prefix(22) == "/var/mobile/Documents/" || tn.prefix(38) == "/var/mobile/Library/Caches/TelephonyUI" {
                                        tn = tn.replacingOccurrences(of: "/var", with: "\(DataPath("Emu_Var"))/var")
                                    }
                                }
                                
                                if Mode == "Apply" {
                                    if !FileManager.default.checkFilePermissions(atPath: tn) && !optional && !isOptional {
                                        if FileBackup(tn) == false {
                                            Results.append(ResultType(
                                                Log: "target file does not exist.\n\(tn)",
                                                FullLog: FullLog,
                                                IsSuccess: false,
                                                Target: tn,
                                                Overwrite: on
                                            ))
                                            break
                                        }
                                    }
                                }
                            }else if Mode == "Restore" {
                                if SettingsManager.shared.ExploitInfo[SettingsManager.shared.Exploit] == "Sandboxed" || SettingsManager.shared.NoVar {
                                    // VirtualRoot Path
                                    if tn.prefix(22) == "/var/mobile/Documents/" || tn.prefix(38) == "/var/mobile/Library/Caches/TelephonyUI" {
                                        tn = tn.replacingOccurrences(of: "/var", with: "\(DataPath("Emu_Var"))/var")
                                    }
                                }
                                
                                if !FileManager.default.checkFilePermissions(atPath: tn) {
                                    if let od_ = FileManager.default.contentsExploit(atPath: "\(DataPath("Backup"))\(tn)") {
                                        od = od_
                                    }else {
                                        FullLog += "[*] Missing backup\n"
                                        if !isOptional {
                                            Results.append(ResultType(
                                                Log: "Missing backup - "+randomStr,
                                                FullLog: FullLog,
                                                IsSuccess: false,
                                                Target: tn,
                                                Overwrite: on
                                            ))
                                            continue
                                        }else{
                                            FullLog += "[*] Missing backup (Ignored because it is optional)\n"
                                            Results.append(ResultType(
                                                Log: "Optional Skip (Missing backup) - "+randomStr,
                                                FullLog: FullLog,
                                                IsSuccess: true,
                                                Target: tn,
                                                Overwrite: on
                                            ))
                                            continue
                                        }
                                    }
                                }
                            }
                            
                            if Mode == "Apply" {
                                let tn_b = "\(DataPath("BackgroundApply"))/\(PackageID)/\(tn)"
                                try? FileManager.default.createDirectory(atPath: tn_b, withIntermediateDirectories: true, attributes: nil)
                                try? FileManager.default.removeItem(atPath: tn_b)
                                try od.write(to: URLwithEncode(string: tn_b)!)
                            }
                            
                            Flash(tn: tn, on: on, od: od, Mode: Mode, isOptional: isOptional, FullLog: &FullLog, randomStr: randomStr, Results: &Results)
                        }
                    }
                }
            }
        }
        try AssetsLoop(tc: "/", oc: "\(DataPath("Packages"))/\(PackageID)/Overwrite")
        if Mode == "Apply", isPasscodeTheme {
            Passcode()
        }
    } catch {
//        UIApplication.shared.alert(body: "An error occurred: \(error)", withButton: true)
    }
    return Results
}


func Passcode() {
    let TelephonyUI = "\(DataPath("Emu_Var"))/var/mobile/Library/Caches/\(SettingsManager.shared.TelephonyUI)"
    let selectedFiles: [String: String] = [
        "other-0---white.png": "0",
        "other-1---white.png": "1",
        "other-2-A B C--white.png": "2",
        "other-3-D E F--white.png": "3",
        "other-4-G H I--white.png": "4",
        "other-5-J K L--white.png": "5",
        "other-6-M N O--white.png": "6",
        "other-7-P Q R S--white.png": "7",
        "other-8-T U V--white.png": "8",
        "other-9-W X Y Z--white.png": "9"
    ]
    try? FileManager.default.removeItem(atPath: "\(DataPath("Settings"))/Passcode")
    try? FileManager.default.createDirectory(atPath: "\(DataPath("Settings"))/Passcode", withIntermediateDirectories: true, attributes: nil)
    if let fs = try? FileManager.default.contentsOfDirectory(atPath: TelephonyUI) {
        for f in fs {
            if let digit = selectedFiles[f] {
                try? FileManager.default.copyItem(atPath: "\(TelephonyUI)/\(f)", toPath: "\(DataPath("Settings"))/Passcode/\(digit).png")
            }
        }
        UIApplication.shared.alert(title: MILocalizedString("Passcode Theme"), body: MILocalizedString("Copied. To apply, go to Useful Tools > Passcode Theme"))
    }
}





func Flash(
    tn: String,
    on: String,
    od: Data,
    Mode: String,
    isOptional: Bool,
    FullLog: inout String,
    randomStr: String,
    Results: inout [ResultType]
) {
    if Mode == "Apply" || Mode == "Restore" {
        FullLog += "[*] Flash\n"
        if !FileManager.default.checkFilePermissions(atPath: tn) {
            if SettingsManager.shared.ExploitInfo[SettingsManager.shared.Exploit] == "Sandboxed" {
                FullLog += "[*] No write permission (Sandboxed)\n"
            }else{
                FullLog += "[*] No write permission (Unsandboxed)\n"
            }
            FullLog += "[*] Using \(SettingsManager.shared.Exploit)\n"
            FullLog += "[*] Flashing\n"
            let res = ExploitOverwrite(tn: tn, on: on, od: od)
            switch res {
            case "Success":
                FullLog += "[*] Success\n"
                Results.append(ResultType(
                    Log: "Success - "+randomStr,
                    FullLog: FullLog,
                    IsSuccess: true,
                    Target: tn,
                    Overwrite: on
                ))
            case "File too big":
                if !isOptional {
                    FullLog += "[*] File too big\n"
                    Results.append(ResultType(
                        Log: "File too big - "+randomStr,
                        FullLog: FullLog,
                        IsSuccess: false,
                        Target: tn,
                        Overwrite: on
                    ))
                }else{
                    FullLog += "[*] File too big (Ignored because it is optional)\n"
                    Results.append(ResultType(
                        Log: "Optional Skip - "+randomStr,
                        FullLog: FullLog,
                        IsSuccess: true,
                        Target: tn,
                        Overwrite: on
                    ))
                }
            case "Failure":
                FullLog += "[*] Failure\n"
                if !isOptional {
                    FullLog += "[*] Failure\n"
                    Results.append(ResultType(
                        Log: "Failure - "+randomStr,
                        FullLog: FullLog,
                        IsSuccess: false,
                        Target: tn,
                        Overwrite: on
                    ))
                }else{
                    FullLog += "[*] Failure (Ignored because it is optional)\n"
                    Results.append(ResultType(
                        Log: "Optional Skip - "+randomStr,
                        FullLog: FullLog,
                        IsSuccess: true,
                        Target: tn,
                        Overwrite: on
                    ))
                }
            default:
                FullLog += "[*] End\n"
                Results.append(ResultType(
                    Log: res+" - "+randomStr,
                    FullLog: FullLog,
                    IsSuccess: true,
                    Target: tn,
                    Overwrite: on
                ))
            }
        }else {
            if Mode == "Apply" {
                do {
                    try FileManager.default.writeFileExploit(atPath: tn, od)
                    FullLog += "[*] Success\n"
                    Results.append(ResultType(
                        Log: "Success - "+randomStr,
                        FullLog: FullLog,
                        IsSuccess: true,
                        Target: tn,
                        Overwrite: on
                    ))
                }catch {
                    FullLog += "[*] Failure\n"
                    Results.append(ResultType(
                        Log: "Failure - "+randomStr,
                        FullLog: FullLog,
                        IsSuccess: false,
                        Target: tn,
                        Overwrite: on
                    ))
                }
            }else if Mode == "Restore" {
                let bn =  "\(DataPath("Backup"))/\(tn)"
                if let bd = FileManager.default.contents(atPath: bn) {
                    do {
                        try FileManager.default.writeFileExploit(atPath: tn, bd)
                        FullLog += "[*] Success\n"
                        Results.append(ResultType(
                            Log: "Success - "+randomStr,
                            FullLog: FullLog,
                            IsSuccess: true,
                            Target: tn,
                            Overwrite: bn
                        ))
                    }catch {
                        FullLog += "[*] Failure\n"
                        Results.append(ResultType(
                            Log: "Failure - "+randomStr,
                            FullLog: FullLog,
                            IsSuccess: false,
                            Target: tn,
                            Overwrite: bn
                        ))
                    }
                }else {
                    try? FileManager.default.removeItem(atPath: tn)
                    FullLog += "[*] Target Removed\n"
                    Results.append(ResultType(
                        Log: "Success - "+randomStr,
                        FullLog: FullLog,
                        IsSuccess: true,
                        Target: tn,
                        Overwrite: bn
                    ))
                }
            }
        }
    }else if Mode == "IsSucceeded" {
        if let td = FileManager.default.contentsExploit(atPath: tn) {
            if let _ = try? PropertyListSerialization.propertyList(from: td, options: [], format: nil),
               let _ = try? PropertyListSerialization.propertyList(from: od, options: [], format: nil) {
                Results.append(ResultType(
                    Log: "Success - "+randomStr,
                    FullLog: FullLog,
                    IsSuccess: comparePlist(td: td, od: od),
                    Target: tn,
                    Overwrite: on
                ))
            }else if td.prefix(od.count) == od.prefix(od.count) {
                Results.append(ResultType(
                    Log: "Success - "+randomStr,
                    FullLog: FullLog,
                    IsSuccess: true,
                    Target: tn,
                    Overwrite: on
                ))
            }else{
                if isOptional == true {
                    Results.append(ResultType(
                        Log: "Optional Skip (Target Missing) - "+randomStr,
                        FullLog: FullLog,
                        IsSuccess: true,
                        Target: tn,
                        Overwrite: on
                    ))
                }else{
                    Results.append(ResultType(
                        Log: "Missing Target - "+randomStr,
                        FullLog: FullLog,
                        IsSuccess: false,
                        Target: tn,
                        Overwrite: on
                    ))
                }
            }
        }else{
            if isOptional == true {
                Results.append(ResultType(
                    Log: "Optional Skip (Target Missing) - "+randomStr,
                    FullLog: FullLog,
                    IsSuccess: true,
                    Target: tn,
                    Overwrite: on
                ))
            }else{
                Results.append(ResultType(
                    Log: "Missing Target - "+randomStr,
                    FullLog: FullLog,
                    IsSuccess: false,
                    Target: tn,
                    Overwrite: on
                ))
            }
        }
    }
}

func getFileSize(atPath path: String) -> Int64? {
    do {
        let attributes = try FileManager.default.attributesOfItem(atPath: path)
        if let fileSize = attributes[.size] as? Int64 {
            return fileSize
        }
    } catch {
        print("Error: \(error.localizedDescription)")
    }
    return nil
}

