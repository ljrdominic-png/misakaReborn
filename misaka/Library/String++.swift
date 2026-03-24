//
//  String++.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/10/01.
//

import Foundation
import CryptoKit

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

extension String {
    func cString() -> UnsafeMutablePointer<CChar>? {
        strdup(self)
    }
}

extension String {
    var sha256: String {
        let inputData = Data(self.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}
