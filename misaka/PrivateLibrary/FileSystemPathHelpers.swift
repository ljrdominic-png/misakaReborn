//
//  FileSystemPathHelpers.swift
//  misaka
//
//  Helpers previously in FileExplorer (chown/chmod/stat + bundle id from container UUID).
//

import Foundation

func UuidToAppIdentifier(_ path: String) -> String? {
    if let data = FileManager.default.contentsExploit(atPath: "\(path)/.com.apple.mobile_container_manager.metadata.plist"),
       let MCMMetadataIdentifier = getPropertyListValue(fromData: data, forKey: "MCMMetadataIdentifier") as? String {
        return MCMMetadataIdentifier
    }
    do {
        let appFiles = try FileManager.default.contentsOfDirectoryExploit(atPath: path).filter { $0.suffix(4) == ".app" }
        if let first = appFiles.first,
           let data = FileManager.default.contentsExploit(atPath: "\(path)/\(first)/Info.plist"),
           let CFBundleIdentifier = getPropertyListValue(fromData: data, forKey: "CFBundleIdentifier") as? String {
            return CFBundleIdentifier
        }
    } catch {}
    return nil
}

func changeFilePermissions(atPath filePath: String, permissions: String) -> Bool {
    let fileManager = FileManager.default
    if let permissionsValue = Int(permissions, radix: 8) {
        do {
            let attributes = try fileManager.attributesOfItem(atPath: filePath)
            var currentPermissions = (attributes[.posixPermissions] as? NSNumber)?.intValue ?? 0
            currentPermissions = permissionsValue
            try fileManager.setAttributes([.posixPermissions: NSNumber(value: currentPermissions)], ofItemAtPath: filePath)
            return true
        } catch {
            return false
        }
    }
    return false
}

func getFilePermissions(atPath filePath: String) -> String? {
    let fileManager = FileManager.default

    do {
        let attributes = try fileManager.attributesOfItem(atPath: filePath)
        if let permissions = attributes[.posixPermissions] as? NSNumber {
            let octalPermissions = String(permissions.intValue, radix: 8)
            return octalPermissions
        } else {
            return nil
        }
    } catch {
        print("エラー: \(error)")
        return nil
    }
}

func getLastModificationTime(atPath path: String) -> Date? {
    do {
        let attributes = try FileManager.default.attributesOfItem(atPath: path)
        if let modificationDate = attributes[.modificationDate] as? Date {
            return modificationDate
        } else {
            print("Failed to retrieve modification date.")
            return nil
        }
    } catch {
        print("Error: \(error)")
        return nil
    }
}

func getFileOwnerAndGroup(atPath filePath: String) -> (owner: String?, group: String?) {
    let fileManager = FileManager.default
    var owner: String?
    var group: String?

    do {
        let fileAttributes = try fileManager.attributesOfItem(atPath: filePath)
        if let fileOwner = fileAttributes[FileAttributeKey.ownerAccountName] as? String {
            owner = fileOwner
        }

        if let fileGroup = fileAttributes[FileAttributeKey.groupOwnerAccountName] as? String {
            group = fileGroup
        }
    } catch {
        print("Error: \(error.localizedDescription)")
    }

    return (owner, group)
}

func setFileOwnerAndGroup(atPath filePath: String, owner: String, group: String) -> Bool {
    let fileManager = FileManager.default
    do {
        try fileManager.setAttributes([.ownerAccountName: owner, .groupOwnerAccountName: group], ofItemAtPath: filePath)
        return true
    } catch {
        print("Error: \(error.localizedDescription)")
        return false
    }
}
