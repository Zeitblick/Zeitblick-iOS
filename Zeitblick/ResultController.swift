//
//  ResultController.swift
//  Zeitblick
//
//  Created by Bastian Clausdorff on 30.10.16.
//  Copyright © 2016 Zeitblick. All rights reserved.
//

import UIKit
import SwiftyJSON

class ResultController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var selfieImageView: DesignableImageView!
    @IBOutlet weak var resultImageView: UIImageView!

    var selfieImage: UIImage?
    var resultImage: UIImage?
    var metadata: ImageMetadata?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        selfieImageView.image = selfieImage
        configureImageView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(#function)
    }

    override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        print("did call unwind")
    }

    func configureImageView() {
        resultImageView.image = resultImage
        resultImageView.sizeToFit()

        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
    }

    @IBAction func tappedInfo(_ sender: AnyObject) {
        guard let image = resultImage, let metadata = metadata else {
            return
        }
        let controller = InfoController(image: image, metadata: metadata)
        present(controller, animated: true, completion: nil)
    }
}

extension ResultController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return resultImageView
    }
}
