//
//  ViewController.swift
//  Zeitblick
//
//  Created by Bastian Clausdorff on 27.09.16.
//  Copyright © 2016 Zeitblick. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

/// pan: left/right, tilt: up/down, roll:sideways
typealias HeadRotation = (pan: Double, tilt: Double, roll: Double)

class ViewController: UIViewController {

    @IBOutlet weak var photoButton: DesignableButton!
    @IBOutlet weak var submitButton: DesignableButton!

    @IBOutlet weak var imageView: UIImageView!

    var image: UIImage?

    private lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.cameraDevice = .front
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
        self.view.showLoading()
        guard let image = self.image ?? nil else {
            print("no image")
            return
        }

        guard let imageBase64 = ImageHelper.prepareForGoogleCloud(image: image) else {
            print("couldn't prepare image")
            return
        }

        createRequest(imageData: imageBase64)
    }

    func createRequest(imageData: String) {
        // Create our request URL
        let API_KEY = Environment.sharedInstance.googleCloudApiKey
        let url = URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(API_KEY)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")

        // Build our API request
        let jsonRequest: [String: Any] = [
            "requests": [
                "image": [
                    "content": imageData
                ],
                "features": [
                    [
                        "type": "LABEL_DETECTION",
                        "maxResults": 10
                    ],
                    [
                        "type": "FACE_DETECTION",
                        "maxResults": 1
                    ]
                ]
            ]
        ]

        // Serialize the JSON
        request.httpBody = try! JSONSerialization.data(withJSONObject: jsonRequest, options: [])

        // Run the request on a background thread
        DispatchQueue.global(qos: .background).async {
            self.runRequestOnBackgroundThread(request)
        }
    }


    func runRequestOnBackgroundThread(_ request: URLRequest) {
        let session = URLSession.shared

        // run the request
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            print(response)
            print(data)
            DispatchQueue.main.sync {
                self.view.hideLoading()
//                self.analyzeResults(data!)

                guard let data = data, let rotation = self.getAngles(data) else {
                    print("Couldn't get head rotation from selfie")
                    return
                }

                let parameters: Parameters = [
                    "pan": rotation.pan,
                    "tilt": rotation.tilt,
                    "roll": rotation.roll
                ]

                Alamofire.request("https://projekt-lisa.appspot.com/SimilarHeadRotation", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                    if let json = response.result.value {
                        print("JSON: \(json)")
                    }
                    // get image
                }
            }
        })
        print("fire")
        task.resume()
    }

    /// of first face
    func getAngles(_ dataToParse: Data) -> HeadRotation? {
        let json = JSON(data: dataToParse)
        let errorObj: JSON = json["error"]

        // Check for errors
        guard errorObj.dictionaryValue == [:] else {
            print("Error code \(errorObj["code"]): \(errorObj["message"])")
            return nil
        }

        // Parse the response
        let responses: JSON = json["responses"][0]

        // Get face annotations
        let faceAnnotations = responses["faceAnnotations"]
        let numPeopleDetected = faceAnnotations.count
        guard numPeopleDetected > 0 else {
            print("No faces found")
            return nil
        }

        print("People detected: \(numPeopleDetected)")
        print("Pick first person")

        let person: JSON = faceAnnotations[0]
        return HeadRotation(pan: person["panAngle"].doubleValue, tilt: person["tiltAngle"].doubleValue, roll: person["rollAngle"].doubleValue)
    }

    func analyzeResults(_ dataToParse: Data) {
            // Use SwiftyJSON to parse results
            let json = JSON(data: dataToParse)
            let errorObj: JSON = json["error"]

//            self.spinner.stopAnimating()
//            self.imageView.hidden = true
//            self.labelResults.hidden = false
//            self.faceResults.hidden = false
//            self.faceResults.text = ""

            // Check for errors
            if (errorObj.dictionaryValue != [:]) {
//                self.labelResults.text = "Error code \(errorObj["code"]): \(errorObj["message"])"
                print("Error code \(errorObj["code"]): \(errorObj["message"])")
            } else {
                // Parse the response
                print(json)
                let responses: JSON = json["responses"][0]

                // Get face annotations
                let faceAnnotations: JSON = responses["faceAnnotations"]
                if faceAnnotations != nil {
                    let emotions: Array<String> = ["joy", "sorrow", "surprise", "anger"]

                    let numPeopleDetected:Int = faceAnnotations.count

//                    self.faceResults.text = "People detected: \(numPeopleDetected)\n\nEmotions detected:\n"
                    print("People detected: \(numPeopleDetected)\n\nEmotions detected:\n")

                    var emotionTotals: [String: Double] = ["sorrow": 0, "joy": 0, "surprise": 0, "anger": 0]
                    var emotionLikelihoods: [String: Double] = ["VERY_LIKELY": 0.9, "LIKELY": 0.75, "POSSIBLE": 0.5, "UNLIKELY":0.25, "VERY_UNLIKELY": 0.0]

                    for index in 0..<numPeopleDetected {
                        let personData:JSON = faceAnnotations[index]

                        // Sum all the detected emotions
                        for emotion in emotions {
                            let lookup = emotion + "Likelihood"
                            let result:String = personData[lookup].stringValue
                            emotionTotals[emotion]! += emotionLikelihoods[result]!
                        }
                    }
                    // Get emotion likelihood as a % and display in UI
                    for (emotion, total) in emotionTotals {
                        let likelihood:Double = total / Double(numPeopleDetected)
                        let percent: Int = Int(round(likelihood * 100))
//                        self.faceResults.text! += "\(emotion): \(percent)%\n"
                        print("\(emotion): \(percent)%\n")
                    }
                } else {
//                    self.faceResults.text = "No faces found"
                    print("No faces found")
                }

                // Get label annotations
                let labelAnnotations: JSON = responses["labelAnnotations"]
                let numLabels: Int = labelAnnotations.count
                var labels: Array<String> = []
                if numLabels > 0 {
                    var labelResultsText:String = "Labels found: "
                    for index in 0..<numLabels {
                        let label = labelAnnotations[index]["description"].stringValue
                        labels.append(label)
                    }
                    for label in labels {
                        // if it's not the last item add a comma
                        if labels[labels.count - 1] != label {
                            labelResultsText += "\(label), "
                        } else {
                            labelResultsText += "\(label)"
                        }
                    }
//                    self.labelResults.text = labelResultsText
                        print(labelResultsText)
                } else {
//                    self.labelResults.text = "No labels found"
                    print("No labels found")
                }
            }
//        }

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
