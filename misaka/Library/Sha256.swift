//
//  Hash.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/10/06.
//

import Foundation
import CommonCrypto

func sha256(data: Data) -> String {
    var digestData = Data(count: Int(CC_SHA256_DIGEST_LENGTH))

    _ = digestData.withUnsafeMutableBytes {digestBytes in
        data.withUnsafeBytes {messageBytes in
            CC_SHA256(messageBytes, CC_LONG(data.count), digestBytes)
        }
    }
    return digestData.map { String(format: "%02hhx", $0) }.joined()
}
