//
//  GoogleVision.swift
//  Zeitblick
//
//  Created by Bastian Clausdorff on 30.10.16.
//  Copyright © 2016 Zeitblick. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit
import SwiftyJSON

enum GoogleVisionError: Error {
    case invalidJsonResponse
    case noFaceFound
}

class GoogleVision {

    func analyse(image: UIImage) throws -> Promise<JSON> {
        let q = DispatchQueue.global()

        return firstly {
            Alamofire.request(GoogleVisionRouter.detectFaces(image: image)).responseData()
        }.then(on: q) { data in
            return JSON(data: data)
        }
    }

    func findOneFace(image: UIImage) throws -> Promise<Face> {
        let q = DispatchQueue.global()

        return firstly {
            Alamofire.request(GoogleVisionRouter.detectFaces(image: image)).responseData()
        }.then(on: q) { data in
            let json = JSON(data: data)
            let errorObj: JSON = json["error"]

            // Check for errors
            guard errorObj.dictionaryValue == [:] else {
                print("Error code \(errorObj["code"]): \(errorObj["message"])")
                throw GoogleVisionError.invalidJsonResponse
            }

            // Parse the response
            let response: JSON = json["responses"][0]

            // Get first face annotation
            let faceAnnotations = response["faceAnnotations"]
            let numPeopleDetected = faceAnnotations.count
            guard numPeopleDetected > 0 else {
                print("No faces found")
                throw GoogleVisionError.noFaceFound
            }

            let faceJson = faceAnnotations[0]
            let face = Face(fromJSON: faceJson)
            return Promise(value: face)
        }
    }
}
