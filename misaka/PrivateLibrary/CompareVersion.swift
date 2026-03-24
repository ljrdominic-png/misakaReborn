//
//  compare_version.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/08/10.
//

import Foundation

func isVersionInRange(check: String, min: String, max: String) -> Bool {
    if check.compare(min, options: .numeric) == .orderedAscending {
        // iOSバージョンが最小値未満
        return false
    } else if check.compare(max, options: .numeric) == .orderedDescending {
        // iOSバージョンが最大値を超えている
        return false
    } else if check == max {
        // iOSバージョンが最大値と同じである
        return true
    } else {
        // iOSバージョンが範囲内にある
        return true
    }
}

func isVersionLessThan(check: String, min: String) -> Bool {
    if check.compare(min, options: .numeric) == .orderedAscending {
        // iOSバージョンが最小値以下
        return true
    } else {
        // iOSバージョンが最小値より大きい
        return false
    }
}
