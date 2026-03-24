//
//  BinaryEdit.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/19.
//

import Foundation

func updateBinaryData(od: Data, td: Data) -> Data {
    var result = td
    if let jsonObject = try? JSONSerialization.jsonObject(with: od, options: []) as? [String: Any],
      let Overwrite = jsonObject["Overwrite"] as? [String: String] {
        for (key, value) in Overwrite {
            let index = Int(key)!
            var bytes: [UInt8] = []

            // 2桁ずつ分割して16進数文字列をバイト配列に変換
            var startIndex = value.startIndex
            while startIndex < value.endIndex {
                let endIndex = value.index(startIndex, offsetBy: 2, limitedBy: value.endIndex) ?? value.endIndex
                if let byte = UInt8(value[startIndex..<endIndex], radix: 16) {
                    bytes.append(byte)
                }
                startIndex = endIndex
            }

            if index + bytes.count <= td.count {
                for (i, byte) in bytes.enumerated() {
                    result[index + i] = byte
                }
            }
        }
    }
    return result
}
