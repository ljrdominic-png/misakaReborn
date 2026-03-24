//
//  DeviceInfo++.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/13.
//

import Foundation
import UIKit

extension UIDevice {
    var hasDynamicIsland: Bool {
        guard userInterfaceIdiom == .phone else {
            return false
        }
        guard let window = (UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.flatMap { $0.windows }.first { $0.isKeyWindow}) else {
            return false
        }
        return window.safeAreaInsets.top >= 51
    }
    
    var hasNotch: Bool {
        guard userInterfaceIdiom == .phone else {
            return false
        }
        guard let window = (UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.flatMap { $0.windows }.first { $0.isKeyWindow}) else {
            return false
        }
        return window.safeAreaInsets.bottom > 0
    }

    var isiPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    var isiPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var getModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }

}


extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

func iOSVersion() -> String {
    return String(UIDevice.current.systemVersion.split(separator: ".").first ?? "")
}

var iOSVer: String {
    return UIDevice.current.systemVersion
}

var ProductBuildVersion: String {
    if let bundleid = NSDictionary(contentsOfFile: "/System/Library/CoreServices/SystemVersion.plist")?.value(forKey: "ProductBuildVersion") as? String {
        return bundleid
    }
    return "Unknown"
}

func InstalledPackages() -> [String] {
    if let dirs = try? FileManager.default.contentsOfDirectoryExploit(atPath: DataPath("Packages")) {
        return dirs
    }
    return [String]()
}

func InstalledPackageVersion(_ PackageID: String) -> String {
    if let data = FileManager.default.contents(atPath: "\(DataPath("Packages"))/\(PackageID)/.system/Version.json") {
        return String(data: data, encoding: .utf8) ?? "100"
    }
    return "100"
}

extension UIDevice {
    func MBFormatter(_ bytes: Int64) -> Double {
        let megabytes = Double(bytes) / 1_000_000
        return megabytes
    }
    
    // MARK: Get Double Value
    var totalDiskSpaceInGB: Double {
        let gigabytes = Double(totalDiskSpaceInBytes) / 1_000_000_000
        return gigabytes
    }
    
    var freeDiskSpaceInGB: Double {
        let gigabytes = Double(freeDiskSpaceInBytes) / 1_000_000_000
        return gigabytes
    }
    
    var usedDiskSpaceInGB: Double {
        let gigabytes = Double(usedDiskSpaceInBytes) / 1_000_000_000
        return gigabytes
    }
    
    var totalDiskSpaceInMB: Double {
        return MBFormatter(totalDiskSpaceInBytes)
    }
    
    var freeDiskSpaceInMB: Double {
        return MBFormatter(freeDiskSpaceInBytes)
    }
    
    var usedDiskSpaceInMB: Double {
        return MBFormatter(usedDiskSpaceInBytes)
    }
    
    // MARK: Get raw value
    var totalDiskSpaceInBytes: Int64 {
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
              let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value else { return 0 }
        return space
    }
    
    var freeDiskSpaceInBytes: Int64 {
        if #available(iOS 11.0, *) {
            if let space = try? URL(fileURLWithPath: NSHomeDirectory() as String).resourceValues(forKeys: [URLResourceKey.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage {
                return space
            } else {
                return 0
            }
        } else {
            if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
                let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value {
                return freeSpace
            } else {
                return 0
            }
        }
    }
    
    var usedDiskSpaceInBytes: Int64 {
        return totalDiskSpaceInBytes - freeDiskSpaceInBytes
    }
}
