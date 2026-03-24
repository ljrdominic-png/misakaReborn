//
//  Color++.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/22.
//

import Foundation
import SwiftUI

extension Color: RawRepresentable {
    public init?(rawValue: String) {
        guard let data = Data(base64Encoded: rawValue) else {
            self = .black
            return
        }
        do {
            let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor ?? .black
            self = Color(color)
        } catch {
            self = .black
        }
    }
    public var rawValue: String {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: UIColor(self), requiringSecureCoding: false) as Data
            return data.base64EncodedString()
        } catch {
            return ""
        }
    }
}


func HexToColor(_ Hex: String) -> Color {
    let RGBA = hexToRGBA(hex: Hex)
    let RGBA_normalized = normalizeRGB(RGBA)
    return Color(.sRGB, red: RGBA_normalized.red, green: RGBA_normalized.green, blue: RGBA_normalized.blue, opacity: RGBA_normalized.alpha)
}

extension Data {
    init(hex: String) {
        var hex = hex
        if hex.count % 2 != 0 {
            hex = "0" + hex
        }

        let scalars = hex.unicodeScalars
        var bytes = Array<UInt8>(repeating: 0, count: scalars.count / 2)
        for (index, scalar) in scalars.enumerated() {
            var nibble = scalar.hexNibble
            if index & 1 == 0 {
                nibble <<= 4
            }
            bytes[index >> 1] |= nibble
        }
        self = Data(bytes: bytes)
    }
}

extension UnicodeScalar {
    var hexNibble: UInt8 {
        let value = self.value
        if 48 <= value && value <= 57 {
            return UInt8(value - 48)
        } else if 65 <= value && value <= 70 {
            return UInt8(value - 55)
        } else if 97 <= value && value <= 102 {
            return UInt8(value - 87)
        }
        fatalError("\(self) is not a legal hex nibble")
    }
}

func getColorsFromPicker(pickerColor: Color) -> String {
    let colorString = "\(pickerColor)"
    let colorArray: [String] = colorString.components(separatedBy: " ")
    if colorArray.count == 1{
        return colorString
    }
    var r: CGFloat = CGFloat((Float(colorArray[1]) ?? 1))
    var g: CGFloat = CGFloat((Float(colorArray[2]) ?? 1))
    var b: CGFloat = CGFloat((Float(colorArray[3]) ?? 1))
    var a: CGFloat = CGFloat((Float(colorArray[4]) ?? 1))
    
    if (r < 0.0) {r = 0.0}
    if (g < 0.0) {g = 0.0}
    if (b < 0.0) {b = 0.0}
    if (a < 0.0) {a = 0.0}
    
    if (r > 1.0) {r = 1.0}
    if (g > 1.0) {g = 1.0}
    if (b > 1.0) {b = 1.0}
    if (a > 1.0) {a = 1.0}
    
    // Update hex
    let red = String(format: "%02X", Int(r * 255))
    let green = String(format: "%02X", Int(g * 255))
    let blue = String(format: "%02X", Int(b * 255))
    let alpha = String(format: "%02X", Int(a * 255))
    
    let hex = "#\(red)\(green)\(blue)\(alpha)"
    return hex
}

func hexToRGBA(hex: String) -> (red: Double, green: Double, blue: Double, alpha: Double) {
    var hexString = hex
    if hexString.hasPrefix("#") {
        hexString = String(hexString.dropFirst())
    }
    let scanner = Scanner(string: hexString)
    var hexNumber: UInt64 = 0
    scanner.scanHexInt64(&hexNumber)
    let red = Double((hexNumber & 0xff000000) >> 24)
    let green = Double((hexNumber & 0x00ff0000) >> 16)
    let blue = Double((hexNumber & 0x0000ff00) >> 8)
    let alpha = Double(hexNumber & 0x000000ff)
    return (red, green, blue, alpha)
}

func normalizeRGB(_ rgba: (red: Double, green: Double, blue: Double, alpha: Double)) -> (red: Double, green: Double, blue: Double, alpha: Double) {
    let red = round((rgba.red/255) * 100)/100
    let green = round((rgba.green/255) * 100)/100
    let blue = round((rgba.blue/255) * 100)/100
    let alpha = round((rgba.alpha/255) * 100)/100
    return (red, green, blue, alpha)
}

func makeEven(hexString: String) -> String {
    var result = hexString
    if result.count % 2 != 0 {
        result = "0" + result
    }
    return result
}

func swapHexBytes(_ hexString: String) -> String {
    var result = ""
    
    // Ensure the input string has even length
    let sanitizedHexString = hexString.count % 2 == 0 ? hexString : "0" + hexString
    
    // Loop through pairs of characters and swap them
    for i in stride(from: 0, to: sanitizedHexString.count, by: 2) {
        let start = sanitizedHexString.index(sanitizedHexString.startIndex, offsetBy: i)
        let end = sanitizedHexString.index(start, offsetBy: 2)
        let hexPair = String(sanitizedHexString[start..<end])
        result = hexPair + result
    }
    
    return result
}


func convertColorFormat(_ colorString: String) -> String {
    // 入力文字列が適切な長さでない場合はnilを返す
    guard colorString.count == 8 else {
        return "00000000"
    }
    
    // 文字列から各要素を切り出し、指定された順序で結合して返す
    let bb = colorString.prefix(2)
    let gg = colorString.dropFirst(2).prefix(2)
    let rr = colorString.dropFirst(4).prefix(2)
    let aa = colorString.dropFirst(6)
    
    return "\(rr)\(gg)\(bb)\(aa)"
}

func convertColorFormatReverse(_ colorString: String) -> String {
    // 入力文字列が適切な長さでない場合はnilを返す
    guard colorString.count == 8 else {
        return "00000000"
    }
    
    // 文字列から各要素を切り出し、指定された順序で結合して返す
    let rr = colorString.prefix(2)
    let gg = colorString.dropFirst(2).prefix(2)
    let bb = colorString.dropFirst(4).prefix(2)
    let aa = colorString.dropFirst(6)
    
    return "\(bb)\(gg)\(rr)\(aa)"
}

func convertHexToColorMatrix(hex: String) -> [Double] {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    // Convert hex to UIColor
    if hex.hasPrefix("#") {
        let start = hex.index(hex.startIndex, offsetBy: 1)
        let hexColor = String(hex[start...])
        
        if hexColor.count == 8 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0
            
            if scanner.scanHexInt64(&hexNumber) {
                red = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                green = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                blue = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                alpha = CGFloat(hexNumber & 0x000000ff) / 255
            }
        }
    }
    
    // Convert UIColor to color matrix
    let matrix: [Double] = [
        Double(red), Double(red), Double(red), Double(red), Double(red),
        Double(green), Double(green), Double(green), Double(green), Double(green),
        Double(blue), Double(blue), Double(blue), Double(blue), Double(blue),
        Double(alpha), Double(alpha), Double(alpha), Double(alpha), Double(alpha)
    ]
    
    return matrix
}
func convertColorMatrixToHex(matrix: [Double]) -> String? {
    guard matrix.count == 20 else { return nil } // make sure matrix has the correct length
    let red = Int(matrix[0]*255)
    let green = Int(matrix[6]*255)
    let blue = Int(matrix[12]*255)
    let alpha = Int(matrix[18]*255)
    
    let hexString = String(format: "#%02X%02X%02X%02X", red, green, blue, alpha)
    return hexString
}
