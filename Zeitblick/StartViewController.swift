//
//  StartViewController.swift
//  Zeitblick
//
//  Created by Bastian Clausdorff on 29.10.16.
//  Copyright © 2016 Epic Selfie. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit

class StartViewController: UIViewController {

    @IBOutlet weak var photoButton: DesignableButton!
    @IBOutlet weak var selfieImageView: DesignableImageView!

    @IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var logoSubtitle: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        selfieImageView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
                strongSelf.present(imagePicker, animated: true, completion: {
                    UIApplication.shared.setStatusBarStyle(.lightContent, animated:true)
                })
            })
    }

}

extension StartViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        print("selected photo")

        dismiss(animated: false, completion: nil)

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selfieImageView.image = image
            selfieImageView.isHidden = false
            photoButton.isHidden = true

            logoTopConstraint.constant = 22.0
            logoSubtitle.isHidden = true

            firstly {
                return try GoogleVision().findOneFace(image: image)
            }.then { face -> Promise<String> in
                return try ZeitblickBackend().findSimilarRotation(face: face)
            }.then { inventoryNumber -> Promise<UIImage> in
                return try GoogleDatastore().getImage(inventoryNumber: inventoryNumber)
            }.then { image in
                print("got image")
            }.catch { error in
                print(error)
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
