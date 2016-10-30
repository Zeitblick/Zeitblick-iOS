//
//  GoogleVisionRouter.swift
//  Zeitblick
//
//  Created by Bastian Clausdorff on 30.10.16.
//  Copyright © 2016 Zeitblick. All rights reserved.
//

import UIKit
import Alamofire

enum GoogleVisionRouterError: Error {
    case invalidImage
}

public enum GoogleVisionRouter {
    typealias Me = GoogleVisionRouter

    static let API_KEY = Environment.sharedInstance.googleCloudApiKey
    static let baseURLString = "https://vision.googleapis.com"
    //static let url = URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(API_KEY)")!

    case analyseImage(image: UIImage)
}

extension GoogleVisionRouter: URLRequestConvertible {

    public func asURLRequest() throws -> URLRequest {
        var urlRequest: URLRequest
        switch self {
        case .analyseImage(let image):
            guard let imageBase64 = ImageHelper.prepareForGoogleCloud(image: image) else {
                print("couldn't prepare image")
                throw GoogleVisionRouterError.invalidImage
            }

            urlRequest = request(relativePath: "/v1/images:annotate", params: ["key": Me.API_KEY])

            let jsonRequest: Parameters = [
                "requests": [
                    "image": [
                        "content": imageBase64
                    ],
                    "features": [
                        [
                            "type": "LABEL_DETECTION",
                            "maxResults": 10
                        ],
                        [
                            "type": "FACE_DETECTION",
                            "maxResults": 1
                        ]
                    ]
                ]
            ]

            urlRequest.httpMethod = Alamofire.HTTPMethod.post.rawValue
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: jsonRequest, options: [])
        }
        return urlRequest
    }

    private func request(relativePath: String, params: Parameters) -> URLRequest {
        let url = try! Me.baseURLString.asURL().appendingPathComponent(relativePath)
        let urlRequest = URLRequest(url: url)
        return try! URLEncoding.queryString.encode(urlRequest, with: params)
    }
}
