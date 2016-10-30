//
//  GoogleDatastore.swift
//  Zeitblick
//
//  Created by Bastian Clausdorff on 30.10.16.
//  Copyright © 2016 Zeitblick. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit
import SwiftyJSON

enum GoogleDatastoreError: Error {
    case imageNotFound
    case invalidImage
}

class GoogleDatastore {

    func getImage(inventoryNumber: String) throws -> Promise<UIImage> {
        // "https://sammlungonline.mkg-hamburg.de/de/object/\(inventoryNumber)/image_download/0"
        let q = DispatchQueue.global()

        return firstly {
            // responseImage
            Alamofire.request("https://storage.googleapis.com/projektlisa_test/\(inventoryNumber).jpg", method: .get).responseData()
        }.then(on: q) { data in
            guard let image = UIImage(data: data) else {
                throw GoogleDatastoreError.invalidImage
            }

            return Promise(value: image)
        }
    }
}
