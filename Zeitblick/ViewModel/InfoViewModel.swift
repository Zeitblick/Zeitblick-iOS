//
//  InfoViewModel.swift
//  Zeitblick
//
//  Created by Bastian Clausdorff on 01.11.16.
//  Copyright © 2016 Zeitblick. All rights reserved.
//

import Foundation

class InfoViewModel {

    let model: ImageMetadata

    var title: String {
        return model.title
    }

    init(model: ImageMetadata) {
        self.model = model
    }
}
