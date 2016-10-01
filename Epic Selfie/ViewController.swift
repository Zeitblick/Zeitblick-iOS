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
    @IBOutlet weak var submitButton: DesignableButton!

    @IBOutlet weak var imageView: UIImageView!

    var image: UIImage?

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
        submitButton.addTarget(self, action: #selector(submitPhoto), for: .touchUpInside)
    }

    // mark: actions
    func takePhoto() {
        present(imagePicker, animated: true, completion: nil)
    }

    func submitPhoto() {
        guard let image = self.image ?? nil else {
            print("no image")
            return
        }

        guard let imageBase64 = ImageHelper.base64EncodeImage(image: image) else {
            print("couldn't encode image")
            return
        }

        createRequest(imageData: imageBase64)

    }

    func createRequest(imageData: String) {
        // Create our request URL
        let API_KEY = Environment.sharedInstance.googleCloudApiKey
        let url = URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(API_KEY)")!
        let request = MutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")

        // Build our API request
        let jsonRequest: Parameters = [
            "requests": [
                "image": [
                    "content": imageData
                ],
                "features": [
//                    [
//                        "type": "LABEL_DETECTION",
//                        "maxResults": 10
//                    ],
                    [
                        "type": "FACE_DETECTION",
                        "maxResults": 10
                    ]
                ]
            ]
        ]

//        Alamofire.request("https://vision.googleapis.com/v1/images:annotate?key=\(API_KEY)", method: .post, parameters: parameters, encoding: JSONEncoding.default)

        // Serialize the JSON
        request.httpBody = try! JSONSerialization.data(withJSONObject: jsonRequest, options: [])

        // Run the request on a background thread

        self.view.showLoading()

        DispatchQueue.global(qos: .background).async {
            self.runRequestOnBackgroundThread(request as URLRequest)
        }
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {



    }


    func runRequestOnBackgroundThread(_ request: URLRequest) {
        let session = URLSession.shared

        // run the request
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
//            self.analyzeResults(data!)
            print(response)
            print(data)
            DispatchQueue.main.sync {
                self.view.hideLoading()
            }
        })
        print("fire")
        task.resume()
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print(#function)

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.image = image
            imageView.image = self.image
        }

        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
