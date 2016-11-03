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

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let typedInfo = R.segue.startViewController.result(segue: segue) {
            //typedInfo.destination.startProcessing(image: image)
            typedInfo.destination.selfieImage = selfieImageView.image
            typedInfo.destination.resultImage = resultImage
            typedInfo.destination.metadata = metadata
        }
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
                strongSelf.present(imagePicker, animated: true, completion: nil)
            },
            choosePhotoAction: { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                imagePicker.sourceType = .photoLibrary
                strongSelf.present(imagePicker, animated: true, completion: nil)
            })
    }

    @IBAction func unwindToStart(segue: UIStoryboardSegue) {
        print(#function)
        resetController()
    }

    private func resetController() {
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

        dismiss(animated: true, completion: nil)

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
            return try GoogleVision().findOneFace(image: image)
        }.then { face -> Promise<ImageMetadata> in
            return try ZeitblickBackend().findSimilarRotation(face: face)
        }.then { [weak self] metadata -> Promise<UIImage> in
            self?.metadata = metadata
            return try GoogleDatastore().getImage(inventoryNumber: metadata.inventoryNumber)
        }.then { [weak self] image -> Void in
            print("got image")
            self?.resultImage = image
            self?.performSegue(withIdentifier: R.segue.startViewController.result, sender: self)
        }.always(on: q) { [weak self] in
            self?.view.hideLoading()
        }.catch { error in
            print(error)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
