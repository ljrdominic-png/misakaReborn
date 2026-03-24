//
//  PlistEdit.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/19.
//

import Foundation

func mergePlistFiles(tn leftFilePath: String, od rightData: Data) -> Data? {
    guard let leftData = FileManager.default.contents(atPath: leftFilePath) else { return nil }
    let isLoctable = NSString(string: leftFilePath).pathExtension == "loctable"
    do {
        var leftDictionary = try PropertyListSerialization.propertyList(from: leftData, options: [], format: nil) as! [String: Any]
        var rightDictionary = try PropertyListSerialization.propertyList(from: rightData, options: [], format: nil) as! [String: Any]
        rightDictionary.removeValue(forKey: "%Misaka_Overwrite%")
        func merge(dictionary1: [String: Any], dictionary2: [String: Any]) -> [String: Any] {
            var result = dictionary1
            for (key, value) in dictionary2 {
                if value as? String == "%Misaka_Remove%" {
                    result.removeValue(forKey: key)
                    continue
                }
                result.removeValue(forKey: key)
                result[applyPathVariable(key)] = value
                if let valueFromDict2 = value as? [String: Any],
                   let valueFromDict1 = dictionary1[applyPathVariable(key)] as? [String: Any] {
                    result[applyPathVariable(key)] = merge(dictionary1: valueFromDict1, dictionary2: valueFromDict2)
                } else {
                    result[applyPathVariable(key)] = value
                }
            }
            return result
        }
        let springLang = rightDictionary["%Misaka_Path{'SpringLang'}%"] != nil
        if springLang && isLoctable {
            var tmp = rightDictionary["%Misaka_Path{'SpringLang'}%"] ?? [:]
            rightDictionary.removeValue(forKey: "%Misaka_Path{'SpringLang'}%")
            rightDictionary.updateValue(tmp, forKey: SettingsManager.shared.SpringLang)
            var mergedDictionary = merge(dictionary1: leftDictionary, dictionary2: rightDictionary)
            tmp = rightDictionary[SettingsManager.shared.SpringLang] ?? [:]
            mergedDictionary = [:]
            mergedDictionary.updateValue(tmp, forKey: SettingsManager.shared.SpringLang)
            let newData = try PropertyListSerialization.data(fromPropertyList: mergedDictionary, format: .xml, options: 0)
            return newData
        }else{
            let mergedDictionary = merge(dictionary1: leftDictionary, dictionary2: rightDictionary)
            let newData = try PropertyListSerialization.data(fromPropertyList: mergedDictionary, format: .binary, options: 0)
            return newData
        }
    } catch {
        print(error)
        return nil
    }
}

func plistPadding(tn targetPath: String, od overwriteData: Data) -> (newData: Data, log: String)? {
    let isLoctable = NSString(string: targetPath).pathExtension == "loctable"
    return isLoctable ? plistPadding_xml(tn: targetPath, od: overwriteData) : plistPadding_bplist(tn: targetPath, od: overwriteData)
}

func plistPadding_xml(tn targetPath: String, od overwriteData: Data) -> (newData: Data, log: String)? {
    guard let targetURL = URLwithEncode(string: "file://"+targetPath) else { return nil }
    guard let targetData = FileManager.default.contentsExploit(atPath: targetURL.path) else { return nil }
    if targetData.count == overwriteData.count {
        return (overwriteData, "Same size")
    }
    var newData = overwriteData
    newData = newData + Data(repeating: 0x00, count: targetData.count - overwriteData.count)
    return (newData, "Auto plist padding")
}
func plistPadding_bplist(tn targetPath: String, od overwriteData: Data) -> (newData: Data, log: String)? {
    guard let targetURL = URLwithEncode(string: "file://"+targetPath) else { return nil }
    guard let targetData = FileManager.default.contentsExploit(atPath: targetURL.path) else { return nil }
    guard let newPlist = try? PropertyListSerialization.propertyList(from: overwriteData, format: nil) else { return nil }
    guard let newData = try? PropertyListSerialization.data(fromPropertyList: newPlist, format: .binary, options: 0) else { return nil }
    if targetData.count == newData.count {
        return (newData, "Same size")
    }
    do {
        guard var plistDict = try? PropertyListSerialization.propertyList(from: overwriteData, format: nil) else { return nil }
        if var editedDict = plistDict as? [String: Any] {
            var count = 0
            while true {
                let newOverwriteData = try PropertyListSerialization.data(fromPropertyList: editedDict, format: .binary, options: 0)
                if newOverwriteData.count >= targetData.count { break }
                count += 1
                editedDict.updateValue(String(repeating: "0", count: count), forKey: "0")
            }
            return (try PropertyListSerialization.data(fromPropertyList: editedDict, format: .binary, options: 0), "Auto plist padding")
        } else if var editedDict = plistDict as? [Any] {
            var count = 0
            editedDict.append("0")
            while true {
                let newOverwriteData = try PropertyListSerialization.data(fromPropertyList: editedDict, format: .binary, options: 0)
                if newOverwriteData.count >= targetData.count { break }
                count += 1
                editedDict[editedDict.count - 1] = String(repeating: "0", count: count)
            }
            return (try PropertyListSerialization.data(fromPropertyList: editedDict, format: .binary, options: 0), "Auto plist padding")
        }
    } catch {
        return (overwriteData, "Unknown error")
    }
    return (newData, "Auto plist padding")
}

func comparePlist(td: Data, od: Data) -> Bool {
    do {
        let plistDict1 = try PropertyListSerialization.propertyList(from: td, options: [], format: nil)
        let plistDict2 = try PropertyListSerialization.propertyList(from: od, options: [], format: nil)
        let xmlDict1 = try PropertyListSerialization.data(fromPropertyList: plistDict1, format: .xml, options: 0)
        let xmlDict2 = try PropertyListSerialization.data(fromPropertyList: plistDict2, format: .xml, options: 0)
        let xmlStr1 = String(data: xmlDict1, encoding: .utf8)
        let xmlStr2 = String(data: xmlDict2, encoding: .utf8)
        return xmlStr1 == xmlStr2
    } catch _ {
        return false
    }
}

func getPropertyListValue(fromData data: Data, forKey key: String) -> Any? {
    // Convert the provided data to a property list
    let propertyList = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)
    
    // Recursive function to search for the value of the specified key in arrays or dictionaries
    func searchValue(_ object: Any, _ key: String) -> Any? {
        if let dictionary = object as? [String: Any] {
            for (k, v) in dictionary {
                if k == key {
                    return v
                } else if let subObject = searchValue(v, key) {
                    return subObject
                }
            }
        } else if let array = object as? [Any] {
            for element in array {
                if let subObject = searchValue(element, key) {
                    return subObject
                }
            }
        }
        return nil
    }
    
    // Search for the value of the specified key in the property list
    return searchValue(propertyList, key)
}
