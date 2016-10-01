//
//  Environment.swift
//  Epic Selfie
//
//  Created by Bastian Clausdorff on 01.10.16.
//  Copyright © 2016 Epic Selfie. All rights reserved.
//

import Foundation

class Environment {
    static let sharedInstance = Environment()

    private lazy var dict: NSDictionary? = {
        guard let filePath = Bundle.main.path(forResource: "Environment", ofType: "plist") else {
            assertionFailure("Error: Environment.plist not found")
            return nil
        }
        guard let dict = NSDictionary(contentsOfFile:filePath) else {
            assertionFailure("Error: Couldn't read Environment.plist")
            return nil
        }
        return dict
    }()

    var googleCloudApiKey: String {
        return dict?.object(forKey: "GOOGLE_CLOUD_API_KEY") as? String ?? ""
    }

}
