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

class StartViewController: UIViewController {

    @IBOutlet weak var photoButton: DesignableButton!
    @IBOutlet weak var selfieImageView: DesignableImageView!

    @IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var logoSubtitle: UILabel!

    var resultImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        selfieImageView.isHidden = true
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

        logoTopConstraint.constant = 22.0
        logoSubtitle.isHidden = true

        // Start processing animation
        // images durchrattern, bis result kommt 
        // dann zum Ende kommen und ResultViewController aufrufen

        // Find match
        firstly {
            return try GoogleVision().findOneFace(image: image)
        }.then { face -> Promise<String> in
            return try ZeitblickBackend().findSimilarRotation(face: face)
        }.then { inventoryNumber -> Promise<UIImage> in
            return try GoogleDatastore().getImage(inventoryNumber: inventoryNumber)
        }.then { [weak self] image -> Void in
            print("got image")
            self?.resultImage = image
            self?.performSegue(withIdentifier: R.segue.startViewController.result, sender: self)
        }.catch { error in
            print(error)
        }.always { [weak self] in
            self?.view.hideLoading()
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
