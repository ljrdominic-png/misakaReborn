//
//  ResizeImage.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/19.
//

import Foundation
import UIKit

func resizeImage(od: Data, td: Data) -> Data? {
    guard let t_image = UIImage(data: td) else {
        return nil
    }
    guard let image = UIImage(data: od) else {
        return nil
    }
    if t_image.size == image.size {
        return od
    }
    let size = CGSize(width: t_image.size.width, height: t_image.size.height)
    guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
        return nil
    }
    guard let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
        return nil
    }
    context.interpolationQuality = .high
    let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    context.draw(image.cgImage!, in: rect)
    guard let scaledImage = context.makeImage() else {
        return nil
    }
    let resizedImage = UIImage(cgImage: scaledImage)
    return resizedImage.pngData()
}

