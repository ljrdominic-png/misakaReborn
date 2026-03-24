//
//  ArrayValueToString.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/19.
//

import Foundation

func StrReplaceByArray(_ string: String, _ mapping: [[String: String]]) -> String {
    var result = string
    for dict in mapping {
        if let identifier = dict["Identifier"], let value = dict["Value"] {
            result = result.replacingOccurrences(of: identifier, with: value)
        }
    }
    return result
}

func ArrayValueToString(_ array: [[String: Any]]) -> [[String: String]] {
    var result = [[String: String]]()
    for dict in array {
        var newDict = [String: String]()
        for (key, value) in dict {
            let stringValue: String
            switch value {
            case let value as String:
                stringValue = value
            case let value as Double:
                stringValue = String(value)
            case let value as Int:
                stringValue = String(value)
            case let value as Bool:
                stringValue = String(value)
            default:
                stringValue = "\(value)"
            }
            newDict[key] = stringValue
        }
        result.append(newDict)
    }
    return result
}

func PlistReplaceByArray(_ plist: Data, _ mapping: [[String: Any]]) -> Data? {
    do {
        let plist = try PropertyListSerialization.propertyList(from: plist, options: [], format: nil)
        let replacedPlist = PlistReplaceByArray(plist: plist, mapping: mapping)
        let data = try PropertyListSerialization.data(fromPropertyList: replacedPlist, format: .binary, options: 0)
        return data
    } catch {
        print("Error: \(error)")
        return nil
    }
}
func PlistReplaceByArray(plist: Any, mapping: [[String: Any]]) -> Any {
    if let plistArray = plist as? [Any] {
        return plistArray.map { PlistReplaceByArray(plist: $0, mapping: mapping) }
    } else if let plistDictionary = plist as? [String: Any] {
        var result = plistDictionary
        for (key, value) in result {
            if let _ = value as? [Any] {
                result[key] = PlistReplaceByArray(plist: value, mapping: mapping)
            }
            else if let _ = value as? [String: Any] {
                result[key] = PlistReplaceByArray(plist: value, mapping: mapping)
            }
            for mappingDict in mapping {
                if let mappingKey = mappingDict["Identifier"] as? String, let mappingValue = mappingDict["Value"], let stringValue = value as? String, stringValue == mappingKey {
                    if let Disabled = mappingDict["Disabled"] as? Bool, Disabled == true {
                        result.removeValue(forKey: key)
                        continue
                    }
                    result[key] = mappingValue
                }
            }
        }
        return result
    } else {
        return plist
    }
}

func AnyToString(_ value: Any) -> String {
    let stringValue: String
    switch value {
    case let value as String:
        stringValue = value
    case let value as Bool:
        if String(value) == "true" || String(value) == "false"  {
            stringValue = String(value == true ? "YES" : "NO")
        }else{
            stringValue = "\(value)"
        }
    default:
        stringValue = "\(value)"
    }
    return stringValue
}
