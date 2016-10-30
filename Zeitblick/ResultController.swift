//
//  ResultController.swift
//  Zeitblick
//
//  Created by Bastian Clausdorff on 30.10.16.
//  Copyright © 2016 Zeitblick. All rights reserved.
//

import UIKit

class ResultController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var selfieImageView: DesignableImageView!
    @IBOutlet weak var resultImageView: UIImageView!

    var selfieImage: UIImage?
    var resultImage: UIImage?

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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func configureImageView() {
        resultImageView.image = resultImage
        resultImageView.sizeToFit()

        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
    }
}

extension ResultController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return resultImageView
    }
}
