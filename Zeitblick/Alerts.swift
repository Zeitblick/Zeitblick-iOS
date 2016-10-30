//
//  AppDelegate.swift
//  Zeitblick
//
//  Created by Bastian Clausdorff on 27.09.16.
//  Copyright © 2016 Zeitblick. All rights reserved.
//

import UIKit
import Rswift

class Alerts {
    typealias Action = () -> Void

    static func photo(viewController: UIViewController, takePhotoAction: @escaping Action, choosePhotoAction: @escaping Action) {

        let isCameraAvailable = UIImagePickerController.isSourceTypeAvailable(.camera)
        let isLibraryAvailable = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)

        if isCameraAvailable {
            let alert = UIAlertController()
            alert.addAction(UIAlertAction(title: R.string.localizable.imagePicker_takePhoto(), style: .default, handler:  { action in
                takePhotoAction()
            }))
            alert.addAction(UIAlertAction(title: R.string.localizable.imagePicker_pickPhoto(), style: .default, handler: { action in
                choosePhotoAction()
            }))
            alert.addAction(UIAlertAction(title: R.string.localizable.imagePicker_cancel(), style: .cancel, handler: nil))

            viewController.present(alert, animated: true, completion: nil)
        } else if isLibraryAvailable {
            choosePhotoAction()
        }
    }
}
