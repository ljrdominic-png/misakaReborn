//
//  ApplyVariable.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/17.
//

import Foundation
import UIKit

func applyPathVariable(_ path: String) -> String{
    var _path = path
    let devicetype = UIDevice.current.userInterfaceIdiom == .phone ? "iphone" : "ipad"
    _path = _path.replacingOccurrences(of: "%Misaka_Path{'DeviceType'}%", with: devicetype)
    let ostype = UIDevice.current.userInterfaceIdiom == .phone ? "iOS" : "iPadOS"
    _path = _path.replacingOccurrences(of: "%Misaka_Path{'OSType'}%", with: ostype)
    _path = _path.replacingOccurrences(of: "%Misaka_Path{'SpringLang'}%", with: SettingsManager.shared.SpringLang)
    _path = Regex_BundleID_To_UUID_UserAppBundle(_path)
    _path = Regex_BundleID_To_UUID_UserAppData(_path)
    _path = Regex_BundleID_To_UUID_UserAppGroup(_path)
    return _path
}


func processFileMode(_ fileName: inout String) -> [String] {
    var modes: [String] = []
    if fileName.contains("%Optional%") {
        modes.append("%Optional%")
        fileName = fileName.replacingOccurrences(of: "%Optional%", with: "")
    }
    if fileName.contains("%Misaka_Resize%") {
        modes.append("%Misaka_Resize%")
        fileName = fileName.replacingOccurrences(of: "%Misaka_Resize%", with: "")
    }
    if fileName.contains("%Misaka_Compression%") {
        modes.append("%Misaka_Compression%")
        fileName = fileName.replacingOccurrences(of: "%Misaka_Compression%", with: "")
    }
    if fileName.contains("%Misaka_Binary%") {
        modes.append("%Misaka_Binary%")
        fileName = fileName.replacingOccurrences(of: "%Misaka_Binary%", with: "")
    }
    if fileName.contains("%Misaka_Regex%") {
        modes.append("%Misaka_Regex%")
        fileName = fileName.replacingOccurrences(of: "%Misaka_Regex%", with: "")
    }
    return modes
}

func parsePlist(_ data: Data) -> [[String: Any]] {
    var result: [[String: Any]] = []
    result.append(["Identifier": "iOSver", "Value": iOSVersion()])
    result.append(["Identifier": "Notched", "Value": UIDevice.current.hasNotch ? "YES" : "NO"])
    result.append(["Identifier": "hasDynamicIsland", "Value": UIDevice.current.hasDynamicIsland ? "YES" : "NO"])
    result.append(["Identifier": "DeviceType", "Value": UIDevice.current.isiPhone ? "iPhone" : "iPad"])
    guard let categories = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [[String: Any]] else { return result }
    func updatevalue(_ categories: [[String: Any]]) {
        for category in categories {
            if let items = category["Tweaks"] as? [[String: Any]] {
                for item in items {
                    if let identifier = item["Identifier"] as? String, let value = item["Value"] {
                        var Disabled = false
                        if item["Disabled"] as? Bool == true { Disabled = true }
                        if value as? String == "%Misaka_Original%" { Disabled = true }
                        result.append(["Identifier": identifier, "Value": value, "Disabled": Disabled])
                    }
                    else if let categories = item["Categories"] as? [[String: Any]] {
                        updatevalue(categories)
                    }
                }
            }
        }
    }
    updatevalue(categories)
    return result
}

func Misaka_Segment(path: String) -> [String: Any] {
    // 正規表現で文字列をマッチング
    let pattern = "%Misaka_Segment\\{Name[:;] '(.+)', \\[(.+)\\]\\}%"
    let regex = try! NSRegularExpression(pattern: pattern, options: [])
    let range = NSRange(path.startIndex..<path.endIndex, in: path)
    guard let match = regex.firstMatch(in: path, options: [], range: range) else {
        return [:]
    }

    // マッチした部分文字列を取得
    let nameRange = Range(match.range(at: 1), in: path)!
    let valuesRange = Range(match.range(at: 2), in: path)!

    let name = String(path[nameRange])
    let valuesString = String(path[valuesRange])

    // パースして辞書オブジェクトを作成
    let pattern2 = #"\((Identifier|Value)[:;] '([^']+)'(?:, (Identifier|Value)[:;] '([^']+)'|)\)"#
    let regex2 = try! NSRegularExpression(pattern: pattern2, options: [])
    let valuesMatches = regex2.matches(in: valuesString, options: [], range: NSRange(valuesString.startIndex..<valuesString.endIndex, in: valuesString))

    let values = valuesMatches.map { match -> [String: String] in
        let identifierRange = Range(match.range(at: 2), in: valuesString)!
        let valueRange = Range(match.range(at: 4), in: valuesString)!
        let identifier = String(valuesString[identifierRange])
        let value = String(valuesString[valueRange])
        return ["Identifier": identifier, "Value": value]
    }

    return ["Name": name, "Params": values]
}
