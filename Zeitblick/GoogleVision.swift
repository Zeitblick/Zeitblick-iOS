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

    func findOneFace(image: UIImage) -> Promise<Face> {
        let q = DispatchQueue.global()
        //UIApplication.shared.isNetworkActivityIndicatorVisible = true

        return firstly {
            Alamofire.request(GoogleVisionRouter.analyseImage(image: image)).responseData()
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
        }.always {
            //UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }.catch { error in
            print(error)
        }
    }
}
