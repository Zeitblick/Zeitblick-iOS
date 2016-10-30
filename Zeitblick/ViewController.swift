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
import AlamofireImage


enum State {
    case noPhoto
    case hasPhoto
    case processing
    case result
    case error
}

class ViewController: UIViewController {

    @IBOutlet weak var photoButton: DesignableButton!
    @IBOutlet weak var submitButton: DesignableButton!
    @IBOutlet weak var submitButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var photoAgainButton: UIButton!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var selfieView: DesignableImageView!
    @IBOutlet weak var selfieViewLeadingConstraint: NSLayoutConstraint!

    private lazy var alertController: UIAlertController = {
        let alert = UIAlertController(title: "Error", message: "Message", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: { action in
            print("Tapped OK on error-message")
        })

        alert.addAction(okButton)
        return alert
    }()

    typealias Me = ViewController
    private let imageViewTopOffset: CGFloat = 80.0
    private let submitButtonBottomOffset: CGFloat = -31.0
    private let selfieViewLeadingOffset: CGFloat = -74.0

    var image: UIImage?
    var state: State = .noPhoto {
        willSet(newState) {
            switch state {
            case .noPhoto: switch newState {
                case .hasPhoto:
                    photoButton.alpha = 0.0
                    photoAgainButton.alpha = 1.0
                    submitButton.alpha = 1.0
                default: return
                }
            case .hasPhoto: switch newState {
                case .processing:
                    imageViewTopConstraint.constant = -imageView.frame.height - 100
                    submitButtonBottomConstraint.constant = -500
                    selfieView.image = imageView.image
                    UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseInOut, animations: {
                        self.view.layoutIfNeeded()
                    }, completion: { finished in
                        print("completed anim")
                    })
                    self.view.showLoading()
                    print("Processing")
                default: return
                }
            case .processing: switch newState {
                case .result:
                    self.view.hideLoading()
                    imageViewTopConstraint.constant = imageViewTopOffset
                    submitButtonBottomConstraint.constant = submitButtonBottomOffset
                    submitButton.isHidden = true
//                    submitButton.setTitle("Bildinformationen", for: .normal)
//                    submitButton.titleLabel!.font = UIFont.systemFont(ofSize: 17.0)
//                    photoAgainButton.isHidden = true
                    selfieViewLeadingConstraint.constant = selfieViewLeadingOffset
                    UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseInOut, animations: {
                        self.view.layoutIfNeeded()
                    }, completion: { finished in
                        print("completed anim")
                    })
                default: return
                }
            case .result: switch newState {
                case .hasPhoto:
                    photoButton.alpha = 0.0
                    photoAgainButton.alpha = 1.0
                    submitButton.isHidden = false
                    selfieViewLeadingConstraint.constant = 300
                default: return
                }
            case .error: switch newState {
                case .noPhoto:
                    imageViewTopConstraint.constant = imageViewTopOffset
                    submitButtonBottomConstraint.constant = submitButtonBottomOffset
                    selfieViewLeadingConstraint.constant = 300

                    photoButton.alpha = 1.0
                    submitButton.alpha = 0.0
                    photoAgainButton.alpha = 0.0
                default: return
                }
            }
        }
        didSet {
            if self.state == .error {
                self.view.hideLoading()
                self.present(alertController, animated: true, completion: {
                    self.state = .noPhoto
                })
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        photoButton.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        photoAgainButton.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(submitPhoto), for: .touchUpInside)

        submitButton.alpha = 0.0
        photoAgainButton.alpha = 0.0
        selfieViewLeadingConstraint.constant = 300
    }

    // mark: actions
    func takePhoto() {
//        present(imagePicker, animated: true, completion: nil)
    }

    func submitPhoto() {
        state = .processing
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


