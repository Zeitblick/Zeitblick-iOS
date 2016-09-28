//
//  ViewController.swift
//  Epic Selfie
//
//  Created by Bastian Clausdorff on 27.09.16.
//  Copyright © 2016 Epic Selfie. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var photoButton: DesignableButton!

    private lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        return imagePicker
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        photoButton.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)

    }

    // mark: actions
    func takePhoto() {
        present(imagePicker, animated: true, completion: nil)
    }

}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print(#function)
        dismiss(animated: true, completion: nil)
    }
}
