//
//  ImageMetadata.swift
//  Zeitblick
//
//  Created by Bastian Clausdorff on 01.11.16.
//  Copyright © 2016 Zeitblick. All rights reserved.
//

import UIKit
import SwiftyJSON
import Rswift

class ImageMetadata {
    typealias Me = ImageMetadata

    var title: String
    var inventoryNumber: String
    var artist: String
    private var year: String
    private var location: String
    var yearLocation: String {
        get {
            if location == "" {
                return year
            } else {
                return "\(year), \(location)"
            }
        }
    }
    var license: String
    var infoUrl: URL
    // description

    init(fromJson json: JSON) {
        title           = Me.parseTitle(title: json["mkg_metadata"]["title"].stringValue)
        inventoryNumber = json["inventory_no"].stringValue
        artist          = Me.parseArtist(artist: json["mkg_metadata"]["event"]["eventActor"].stringValue)
        year            = Me.parseYear(eventJson: json["mkg_metadata"]["event"])
        location        = json["mkg_metadata"]["event"]["location"].stringValue
        license         = json["mkg_metadata"]["administrativeMetadata"]["license"].stringValue
        infoUrl         = Me.parseInfoUrl(url: json["mkg_metadata"]["administrativeMetadata"]["infoLink"].stringValue)
    }

    init() {
        title = "Title"
        inventoryNumber = "123"
        artist = "XYZ"
        year = "2016"
        location = "Hamburg"
        license = "CC0"
        infoUrl = URL(string: "http://sammlungonline.mkg-hamburg.de")!
    }

    private static func parseTitle(title: String) -> String {
        return title == "" ? R.string.localizable.unknown() : title
    }

    private static func parseArtist(artist: String) -> String {
        return artist == "" ? R.string.localizable.unknown() : artist
    }

    private static func parseYear(eventJson json: JSON) -> String {
        let displayDate = json["display_date"].stringValue
        guard displayDate == "" else {
            return displayDate
        }

        let earliestDate = json["earliest_date"].intValue
        let latestDate   = json["latest_date"].intValue

        guard earliestDate != 0 && latestDate != 0 else {
            let averageDate = (earliestDate + latestDate) / 2
            return "~ \(averageDate)"
        }

        return R.string.localizable.unknown()
    }

    private static func parseInfoUrl(url: String) -> URL {
        return URL(string: url) ?? URL(string: "http://sammlungonline.mkg-hamburg.de")!
    }

}
