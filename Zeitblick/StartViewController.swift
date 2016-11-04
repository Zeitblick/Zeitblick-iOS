//
//  StartViewController.swift
//  Zeitblick
//
//  Created by Bastian Clausdorff on 29.10.16.
//  Copyright © 2016 Epic Selfie. All rights reserved.
//

import UIKit
import Async
import Alamofire
import PromiseKit
import SwiftyJSON

enum StartError: Error {
    case invalidData
}

class StartViewController: UIViewController {
    typealias Me = StartViewController

    private static let hasSelfieTopConstant: CGFloat = 42

    @IBOutlet weak var photoButton: DesignableButton!
    @IBOutlet weak var selfieImageView: DesignableImageView!

    var logoHasSelfieConstraint: NSLayoutConstraint!
    @IBOutlet var logoNoSelfieConstraint: NSLayoutConstraint!

    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var logoSubtitle: UILabel!

    var resultImage: UIImage?
    var metadata: ImageMetadata?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        logoHasSelfieConstraint = logo.topAnchor.constraint(equalTo: view.topAnchor)
        logoHasSelfieConstraint.constant = Me.hasSelfieTopConstant
        resetController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pickPhoto(_ sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self

        Alerts.photo(viewController: self,
            takePhotoAction: { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                imagePicker.sourceType = .camera
                imagePicker.cameraDevice = .front
                strongSelf.present(imagePicker, animated: true) {
                    UIApplication.shared.setStatusBarHidden(true, with: .fade)
                }
            },
            choosePhotoAction: { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                imagePicker.sourceType = .photoLibrary
                strongSelf.present(imagePicker, animated: true, completion: nil)
            })
    }

    func resetController() {
        selfieImageView.image = nil
        selfieImageView.isHidden = true
        photoButton.isHidden = false

        logoHasSelfieConstraint.isActive = false
        logoNoSelfieConstraint.isActive = true
        logoSubtitle.isHidden = false
    }
}

extension StartViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        print("selected photo")

        dismiss(animated: true) {
            UIApplication.shared.setStatusBarHidden(false, with: .fade)
        }

        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }

        Async.main { [weak self] in
            self?.view.showLoading()
        }

        // Change UI
        selfieImageView.image = image
        selfieImageView.isHidden = false
        photoButton.isHidden = true

        logoNoSelfieConstraint.isActive = false
        logoHasSelfieConstraint.isActive = true
        logoSubtitle.isHidden = true

        let q = DispatchQueue.global()

        // Find match
        firstly {
            return try GoogleVision().analyse(image: image)
        }.then { visionResponseJson -> Promise<ImageMetadata> in
            dump(visionResponseJson)
            return try ZeitblickBackend().findSimilarEmotion(json: visionResponseJson)
        }.then { [weak self] metadata -> Promise<UIImage> in
            self?.metadata = metadata
            return try GoogleDatastore().getImage(inventoryNumber: metadata.inventoryNumber)
        }.then { [weak self] image -> Void in
            print("got image")
            self?.resultImage = image

            guard let result = self?.resultImage, let metadata = self?.metadata, let selfie = self?.selfieImageView.image else {
                throw StartError.invalidData
            }

            let controller = ResultController(resultImage: result , metadata: metadata, selfieImage: selfie, errorHappened: false)
            self?.present(controller, animated: false) {
                self?.resetController()
            }
        }.always(on: q) { [weak self] in
            self?.view.hideLoading()
        }.catch { [weak self] error in
            print(error)
            let errorImage = R.image.errorJpg()
            let controller = ResultController(resultImage: errorImage!, errorHappened: true)
            self?.present(controller, animated: false) {
                self?.resetController()
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true) {
            UIApplication.shared.setStatusBarHidden(false, with: .fade)
        }
    }
}
