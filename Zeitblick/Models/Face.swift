//
//  Face.swift
//  Zeitblick
//
//  Created by Bastian Clausdorff on 30.10.16.
//  Copyright © 2016 Zeitblick. All rights reserved.
//

import UIKit
import SwiftyJSON

class Face {

    /// head rotation: left/right
    let panAngle: Double
    /// head rotation: up/down
    let tiltAngle: Double
    /// head rotation: sideways
    let rollAngle: Double

    /// awaits one entry of the faceAnnotations array
    init(fromJSON json: JSON) {
        panAngle = json["panAngle"].doubleValue
        tiltAngle = json["tiltAngle"].doubleValue
        rollAngle = json["rollAngle"].doubleValue
    }
}
