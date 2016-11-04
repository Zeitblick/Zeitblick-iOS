//
//  ResultController.swift
//  Zeitblick
//
//  Created by Bastian Clausdorff on 30.10.16.
//  Copyright © 2016 Zeitblick. All rights reserved.
//

import UIKit
import SwiftyJSON
import SnapKit

class ResultController: UIViewController {

    private lazy var scroller: UIScrollView = {
        let scroller = UIScrollView(frame: .zero)
        scroller.delegate = self
        return scroller
    }()

    lazy var resultView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.sizeToFit()
        view.contentMode = .scaleAspectFill
        return view
    }()

    private lazy var selfieView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 49
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()

    private lazy var infoButton: UIButton = {
        let button = UIButton(frame: .zero)
        let image = R.image.button_info()
        button.setImage(image, for: .normal)
        return button
    }()

    private lazy var againButton: UIButton = {
        let button = UIButton(frame: .zero)
        let image = R.image.button_plus()
        button.setImage(image, for: .normal)
        return button
    }()

    var selfieImage: UIImage!
    var resultImage: UIImage!
    var metadata: ImageMetadata!
    var errorHappened: Bool!

    init(resultImage: UIImage, metadata: ImageMetadata, selfieImage: UIImage, errorHappened: Bool = false) {
        super.init(nibName: nil, bundle: nil)

        self.resultImage = resultImage
        self.metadata = metadata
        self.selfieImage = selfieImage
        self.errorHappened = errorHappened
    }

    convenience init(resultImage: UIImage, errorHappened: Bool) {
        self.init(resultImage: resultImage, metadata: ImageMetadata(), selfieImage: UIImage(), errorHappened: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        infoButton.addTarget(self, action: #selector(tappedInfo), for: .touchUpInside)
        againButton.addTarget(self, action: #selector(tappedAgain), for: .touchUpInside)

        resultView.image = resultImage
        selfieView.image = selfieImage

        scroller.delegate = self
        scroller.minimumZoomScale = 1.0
        scroller.maximumZoomScale = 3.0

        view.addSubview(scroller)
        scroller.addSubview(resultView)

        scroller.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }

        view.addSubview(selfieView)

        resultView.snp.makeConstraints { make in
            make.edges.equalTo(scroller)
            make.width.height.equalTo(view)
        }

        selfieView.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.centerX.equalTo(view)
            make.bottom.equalTo(view).inset(30)
        }

        view.addSubview(infoButton)

        infoButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.left.bottom.equalTo(view).inset(32)
        }

        view.addSubview(againButton)

        againButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.right.bottom.equalTo(view).inset(32)
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        UIApplication.shared.setStatusBarHidden(true, with: .fade)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if errorHappened == true {
            self.infoButton.isHidden = true
            self.selfieView.isHidden = true
            self.againButton.isHidden = true
            Alerts.error(viewController: self) { [weak self] in
                self?.tappedAgain()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        UIApplication.shared.setStatusBarHidden(false, with: .fade)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Actions
    func tappedInfo() {
        let controller = InfoController(metadata: metadata)
        present(controller, animated: true, completion: nil)
    }

    func tappedAgain() {
        dismiss(animated: true, completion: nil)
    }
}

extension ResultController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return resultView
    }
}
