//
//  URL++.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/22.
//

import Foundation

func URLwithEncode(string: String) -> URL? {
    guard let encodedTarget = string.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
          let targetURL = URL(string: "file://" + encodedTarget) else { return nil }
    return targetURL
}
