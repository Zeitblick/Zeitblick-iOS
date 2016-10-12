//
//  ImageHelper.swift
//  Zeitblick
//
//  Created by Bastian Clausdorff on 01.10.16.
//  Copyright © 2016 Zeitblick. All rights reserved.
//

import Foundation
import UIKit

class ImageHelper {

    // Max single image size for Vision API: 4 MB
    static let googleVisionFilesizeLimitInBytes = 4 * 1024 * 1024
    // TODO: recommended face image size: 1600 x 1200
    // my face was not detected until I downsized it to 800 x 600
    // but label detection detected a face, so vision API is a bit picky
    // Google Cloud says: most important is the eye distance

    static func prepareForGoogleCloud(image: UIImage) -> String? {
        // resize for better detectability
        let oldSize = image.size
        let newSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
        guard let resized = resize(image: image, toSize: newSize) else {
            print("Error: Could not resize image")
            return nil
        }

        // jpeg for faster upload
        guard let jpeg = UIImageJPEGRepresentation(resized, 0.9) else {
            print("Error: Could not convert image to JPEG")
            return nil
        }

        return base64EncodeImage(imagedata: jpeg)
    }

    static func base64EncodeImage(imagedata: Data) -> String? {
        return imagedata.base64EncodedString(options: .endLineWithCarriageReturn)
    }

//    static func resizeImage(imageSize: CGSize, image: UIImage) -> Data? {
//        UIGraphicsBeginImageContext(imageSize)
//        let rect = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
//        image.draw(in: rect)
//        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
//            return nil
//        }
//        let resizedImage = UIImagePNGRepresentation(newImage)
//        UIGraphicsEndImageContext()
//        return resizedImage
//    }

    static func resize(image: UIImage, toSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(toSize, true, 0.0)
        let rect = CGRect(x: 0, y: 0, width: toSize.width, height: toSize.height)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

}
