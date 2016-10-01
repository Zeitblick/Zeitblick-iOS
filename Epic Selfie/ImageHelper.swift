//
//  ImageHelper.swift
//  Epic Selfie
//
//  Created by Bastian Clausdorff on 01.10.16.
//  Copyright © 2016 Epic Selfie. All rights reserved.
//

import Foundation
import UIKit

class ImageHelper {

    static let googleVisionFilesizeLimitInBytes = 4 * 1024 * 1024

    static func base64EncodeImage(image: UIImage) -> String? {
        guard var imagedata = UIImagePNGRepresentation(image) else {
            print("Error: Could not create PNGRepresentation for image")
            return nil
        }

        // Resize the image if it exceeds the 4MB image API limit
        if (imagedata.count > googleVisionFilesizeLimitInBytes) {
            print("File too big for google vision -> Resizing it")
            let oldSize = image.size
            let newSize = CGSize(width: 1200, height: oldSize.height / oldSize.width * 1200)

            guard let resized = resizeImage(imageSize: newSize, image: image) else {
                print("Error: Could not resize image")
                return nil
            }
            imagedata = resized
        }

        return imagedata.base64EncodedString(options: .endLineWithCarriageReturn)
    }

    static func resizeImage(imageSize: CGSize, image: UIImage) -> Data? {
        UIGraphicsBeginImageContext(imageSize)
        let rect = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
        image.draw(in: rect)
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        let resizedImage = UIImagePNGRepresentation(newImage)
        UIGraphicsEndImageContext()
        return resizedImage
    }

}
