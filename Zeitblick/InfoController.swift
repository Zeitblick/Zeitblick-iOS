//
//  InfoController.swift
//  Zeitblick
//
//  Created by Bastian Clausdorff on 31.10.16.
//  Copyright © 2016 Zeitblick. All rights reserved.
//

import UIKit
import SnapKit
import Rswift
import SwiftyJSON

class InfoController: UIViewController {
    typealias Me = InfoController

    lazy var header: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.zbMkgold
        return view
    }()

    lazy var logo: UIImageView = {
        let image = R.image.logo()
        let view = UIImageView(image: image)
        view.contentMode = .scaleAspectFit
        return view
    }()

    lazy var closeButton: UIButton = {
        let image = R.image.button_x()
        let button = UIButton(frame: .zero)
        button.setImage(image, for: .normal)
        return button
    }()

    lazy var scroller: UIScrollView = {
        let scroller = UIScrollView(frame: .zero)
        scroller.isScrollEnabled = true
        scroller.delegate = self
        return scroller
    }()

    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.zbInfoHeadline()
        label.textAlignment = .center
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    lazy var artistLabel: UILabel = {
        let text = R.string.localizable.infoController_artist()
        return Me.createLabel(text: text)
    }()

    lazy var artistText: UITextView = {
        return Me.createTextView()
    }()

    lazy var artistLine: UIImageView = {
        return Me.createDashedline()
    }()

    lazy var yearLocationLabel: UILabel = {
        let text = R.string.localizable.infoController_year()
        return Me.createLabel(text: text)
    }()

    lazy var yearLocationText: UITextView = {
        return Me.createTextView()
    }()

    lazy var yearLocationLine: UIImageView = {
        return Me.createDashedline()
    }()

    lazy var inventoryNumberLabel: UILabel = {
        let text = R.string.localizable.infoController_inventoryNumber()
        return Me.createLabel(text: text)
    }()

    lazy var inventoryNumberText: UITextView = {
        return Me.createTextView()
    }()

    lazy var inventoryNumberLine: UIImageView = {
        return Me.createDashedline()
    }()

    lazy var licenseLabel: UILabel = {
        let text = R.string.localizable.infoController_license()
        return Me.createLabel(text: text)
    }()

    lazy var licenseText: UITextView = {
        return Me.createTextView()
    }()

    lazy var linkButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.zbMkgold
        button.setTitle(R.string.localizable.infoController_linkButtonText(), for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.font = UIFont.zbInfoSubheadline()
        button.titleLabel?.textAlignment = .center
        return button
    }()

    var metadata: ImageMetadata!
    var image: UIImage!

    init(image: UIImage, metadata: ImageMetadata) {
        super.init(nibName: nil, bundle: nil)
        self.image = image
        self.metadata = metadata
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = image
        titleLabel.text = metadata?.title
        artistText.text = metadata?.artist
        yearLocationText.text = metadata?.yearLocation
        inventoryNumberText.text = metadata?.inventoryNumber
        licenseText.text = metadata?.license

        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        linkButton.addTarget(self, action: #selector(openLink), for: .touchUpInside)

        view.addSubview(header)
        header.addSubview(closeButton)

        view.addSubview(scroller)

        scroller.addSubview(imageView)
        scroller.addSubview(titleLabel)
        scroller.addSubview(artistLabel)
        scroller.addSubview(artistText)
        scroller.addSubview(artistLine)
        scroller.addSubview(yearLocationLabel)
        scroller.addSubview(yearLocationText)
        scroller.addSubview(yearLocationLine)
        scroller.addSubview(inventoryNumberLabel)
        scroller.addSubview(inventoryNumberText)
        scroller.addSubview(inventoryNumberLine)
        scroller.addSubview(licenseLabel)
        scroller.addSubview(licenseText)
        scroller.addSubview(linkButton)

        header.snp.makeConstraints { make in
            make.top.left.right.equalTo(view)
            make.height.equalTo(100).priority(1000)
        }

        closeButton.snp.makeConstraints { make in
            make.width.height.equalTo(44)
            make.right.centerY.equalTo(header)
        }

        scroller.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom)
            make.left.right.bottom.equalTo(view)
        }

        //imageView.snp.makeConstraints { make in
          //  make.top.equalTo(scroller)
            //make.left.right.equalTo(scroller)
            //make.height.equalTo(200)
        //}

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(scroller).offset(30)
            make.left.right.equalTo(scroller).offset(16)
            make.centerX.equalTo(scroller)
        }

        artistLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.left.right.equalTo(scroller).offset(16)
            make.centerX.equalTo(scroller)
        }

        artistText.snp.makeConstraints { make in
            make.top.equalTo(artistLabel.snp.bottom)
            make.left.right.equalTo(scroller).offset(16)
            make.centerX.equalTo(scroller)
        }

        artistLine.snp.makeConstraints { make in
            make.top.equalTo(artistText.snp.bottom).offset(20)
            make.left.right.equalTo(scroller).offset(16)
            make.height.equalTo(1)
        }

        yearLocationLabel.snp.makeConstraints { make in
            make.top.equalTo(artistLine.snp.bottom).offset(16)
            make.left.right.equalTo(scroller).offset(16)
            make.centerX.equalTo(scroller)
        }

        yearLocationText.snp.makeConstraints { make in
            make.top.equalTo(yearLocationLabel.snp.bottom)
            make.left.right.equalTo(scroller).offset(16)
            make.centerX.equalTo(scroller)
        }

        yearLocationLine.snp.makeConstraints { make in
            make.top.equalTo(yearLocationText.snp.bottom).offset(20)
            make.left.right.equalTo(scroller).offset(16)
            make.height.equalTo(1)
        }

        inventoryNumberLabel.snp.makeConstraints { make in
            make.top.equalTo(yearLocationLine.snp.bottom).offset(16)
            make.left.right.equalTo(scroller).offset(16)
            make.centerX.equalTo(scroller)
        }

        inventoryNumberText.snp.makeConstraints { make in
            make.top.equalTo(inventoryNumberLabel.snp.bottom)
            make.left.right.equalTo(scroller).offset(16)
            make.centerX.equalTo(scroller)
        }

        inventoryNumberLine.snp.makeConstraints { make in
            make.top.equalTo(inventoryNumberText.snp.bottom).offset(20)
            make.left.right.equalTo(scroller).offset(16)
            make.height.equalTo(1)
        }

        licenseLabel.snp.makeConstraints { make in
            make.top.equalTo(inventoryNumberLine.snp.bottom).offset(16)
            make.left.right.equalTo(scroller).offset(16)
            make.centerX.equalTo(scroller)
        }

        licenseText.snp.makeConstraints { make in
            make.top.equalTo(licenseLabel.snp.bottom)
            make.left.right.equalTo(scroller).offset(16)
            make.centerX.equalTo(scroller)
        }

        linkButton.snp.makeConstraints { make in
            make.top.equalTo(licenseText.snp.bottom).offset(40)
            make.left.right.equalTo(scroller).offset(16)
            make.height.equalTo(64).priority(1000)
            make.bottom.equalTo(scroller.snp.bottom).inset(16)
        }

    }

    // MARK: factories
    private static func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.zbInfoSubheadline()
        label.textAlignment = .center
        return label
    }

    private static func createTextView() -> UITextView {
        let text = UITextView()
        text.font = UIFont.zbInfoBody()
        text.textAlignment = .center
        text.isEditable = false
        text.textColor = UIColor.zbMkgold
        text.isScrollEnabled = false
        text.isUserInteractionEnabled = false
        return text
    }

    private static func createDashedline() -> UIImageView {
        let image = R.image.dashed_line()
        let view = UIImageView(image: image)
        view.clipsToBounds = true
        view.backgroundColor = UIColor.white
        return view
    }

    // MARK: actions
    func openLink() {
        UIApplication.shared.openURL(metadata.infoUrl)
    }

    func close() {
        dismiss(animated: true, completion: nil)
    }

}

extension InfoController: UIScrollViewDelegate {
    
}
