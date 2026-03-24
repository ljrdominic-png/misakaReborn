//
//  Identifier_to .swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/17.
//

import Foundation

func Regex_BundleID_To_UUID_UserAppBundle(_ input: String) -> String {
    let regex = try! NSRegularExpression(pattern: "%Misaka_AppUUID\\{'(.*?)', 'Bundle'\\}%")
    let range = NSRange(location: 0, length: input.utf16.count)
    var output = input
    regex.enumerateMatches(in: input, options: [], range: range) { match, _, _ in
        guard let match = match else { return }
        let bundleIdRange = Range(match.range(at: 1), in: input)!
        let bundleId = String(input[bundleIdRange])
        guard let uuid = BundleID_To_UUID_UserAppBundle(bundleId) else { return }
        output = (output as NSString).replacingCharacters(in: match.range, with: uuid)
    }
    return output
}
func BundleID_To_UUID_UserAppBundle(_ bundleid: String) -> String? {
    let searchDir = "/var/containers/Bundle/Application"
    guard let files = try? FileManager.default.contentsOfDirectoryExploit(atPath: searchDir) else { return nil }
    for file in files {
        let filePath = "\(searchDir)/\(file)"
        if let topdir = FileManager.default.getTopLevelDirectoryName(atPath: filePath),
           let bundleid2 = NSDictionary(contentsOfFile: "\(filePath)/\(topdir)/Info.plist")?.value(forKey: "CFBundleIdentifier") as? String {
           if bundleid2 == bundleid {
               return file
           }
        }
    }
    return nil
}

func Regex_BundleID_To_UUID_UserAppData(_ input: String) -> String {
    let regex = try! NSRegularExpression(pattern: "%Misaka_AppUUID\\{'(.*?)', 'Data'\\}%")
    let range = NSRange(location: 0, length: input.utf16.count)
    var output = input
    regex.enumerateMatches(in: input, options: [], range: range) { match, _, _ in
        guard let match = match else { return }
        let bundleIdRange = Range(match.range(at: 1), in: input)!
        let bundleId = String(input[bundleIdRange])
        guard let uuid = BundleID_To_UUID_UserAppData(bundleId) else { return }
        output = (output as NSString).replacingCharacters(in: match.range, with: uuid)
    }
    return output
}
func BundleID_To_UUID_UserAppData(_ bundleid: String) -> String? {
    let searchDir = "/var/mobile/Containers/Data/Application"
    guard let files = try? FileManager.default.contentsOfDirectoryExploit(atPath: searchDir) else { return nil }
    for file in files {
        let filePath = "\(searchDir)/\(file)"
        if let bundleid2 = NSDictionary(contentsOfFile: "\(filePath)/.com.apple.mobile_container_manager.metadata.plist")?.value(forKey: "MCMMetadataIdentifier") as? String {
            if bundleid2 == bundleid {
                return file
            }
        }
    }
    return nil
}

func Regex_BundleID_To_UUID_UserAppGroup(_ input: String) -> String {
    let regex = try! NSRegularExpression(pattern: "%Misaka_AppUUID\\{'(.*?)', 'AppGroup'\\}%")
    let range = NSRange(location: 0, length: input.utf16.count)
    var output = input
    regex.enumerateMatches(in: input, options: [], range: range) { match, _, _ in
        guard let match = match else { return }
        let bundleIdRange = Range(match.range(at: 1), in: input)!
        let bundleId = String(input[bundleIdRange])
        guard let uuid = BundleID_To_UUID_UserAppGroup(bundleId) else { return }
        output = (output as NSString).replacingCharacters(in: match.range, with: uuid)
    }
    return output
}
func BundleID_To_UUID_UserAppGroup(_ bundleid: String) -> String? {
    let searchDir = "/var/mobile/Containers/Shared/AppGroup"
    guard let files = try? FileManager.default.contentsOfDirectoryExploit(atPath: searchDir) else { return nil }
    for file in files {
        let filePath = "\(searchDir)/\(file)"
        if let bundleid2 = NSDictionary(contentsOfFile: "\(filePath)/.com.apple.mobile_container_manager.metadata.plist")?.value(forKey: "MCMMetadataIdentifier") as? String {
           if bundleid2 == bundleid {
               return file
           }
        }
    }
    return nil
}

