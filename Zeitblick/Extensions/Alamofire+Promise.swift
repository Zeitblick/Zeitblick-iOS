//
//  Alamofire+Promise.swift
//  Zeitblick
//
//  Created by Bastian Clausdorff on 30.10.16.
//  Copyright © 2016 Zeitblick. All rights reserved.
//

import PromiseKit
import Alamofire
import SwiftyJSON

/// extracted from https://github.com/PromiseKit/Alamofire/blob/master/Sources/Alamofire%2BPromise.swift
extension Alamofire.DataRequest {

    /// Adds a handler to be called once the request has finished.
    public func responseData() -> Promise<Data> {
        return Promise { fulfill, reject in
            responseData(queue: nil) { response in
                switch response.result {
                case .success(let value):
                    fulfill(value)
                case .failure(let error):
                    reject(error)
                }
            }
        }
    }

    /// Adds a handler to be called once the request has finished.
    public func responseJSON(options: JSONSerialization.ReadingOptions = .allowFragments) -> Promise<Any> {
        return Promise { fulfill, reject in
            responseJSON(queue: nil, options: options, completionHandler: { response in
                switch response.result {
                case .success(let value):
                    fulfill(value)
                case .failure(let error):
                    reject(error)
                }
            })
        }
    }
}

