//
//  ZeitblickBackend.swift
//  Zeitblick
//
//  Created by Bastian Clausdorff on 30.10.16.
//  Copyright © 2016 Zeitblick. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import SwiftyJSON

enum ZeitblickBackendError: Error {
    case invalidJsonResponse
    case jsonToParams
    case noMatch
}

class ZeitblickBackend {

    func findSimilarEmotion(json: JSON) throws -> Promise<ImageMetadata> {
        let q = DispatchQueue.global()

        guard let parameters = json.dictionaryObject else {
            throw ZeitblickBackendError.jsonToParams
        }

        return firstly {
            Alamofire.request("https://projekt-lisa.appspot.com/SimilarEmotion",
                              method: .post,
                              parameters: parameters,
                              encoding: JSONEncoding.default).responseData()
        }.then(on: q) { data in
            let json = JSON(data: data)

            // Check for errors
            guard json["error"].dictionaryValue == [:] else {
                throw ZeitblickBackendError.invalidJsonResponse
            }

            let metadata = ImageMetadata(fromJson: json)
            return Promise(value: metadata)
        }
    }

    func findSimilarRotation(face: Face) throws -> Promise<ImageMetadata> {
        let q = DispatchQueue.global()

        let parameters: Parameters = [
            "pan": face.panAngle,
            "tilt": face.tiltAngle,
            "roll": face.rollAngle
        ]

        return firstly {
            Alamofire.request("https://projekt-lisa.appspot.com/SimilarHeadRotation",
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default).responseData()
        }.then(on: q) { data in
            let json = JSON(data: data)
            let errorObj: JSON = json["error"]

            // Check for errors
            guard errorObj.dictionaryValue == [:] else {
                print("Error code \(errorObj["code"]): \(errorObj["message"])")
                throw ZeitblickBackendError.invalidJsonResponse
            }

            let metadata = ImageMetadata(fromJson: json)

            return Promise(value: metadata)
        }
    }
}
