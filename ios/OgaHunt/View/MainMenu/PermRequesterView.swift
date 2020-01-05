//
//  PermRequesterView.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 9/13/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import SnapKit
import UIKit

protocol PermRequesterViewDelegate: class {
    func didAcceptPermissionRequest(accepted: Bool, missingPerm: AppPerm)
}

class PermRequesterView: UIView {
    var msgImage: UIImage!
    var msgTitle: String!
    var msgDescription: String!
    var msgButtonTitle: String!
    var msgSecondaryButtonTitle: String!

    var missingPerm: AppPerm!

    var iconImage: UIImageView!
    var titleLabel: UILabel!
    var descriptionTextView: UITextView!
    var actionButton: UIButton!
    var secondaryActionButton: UIButton!

    weak var delegate: PermRequesterViewDelegate?

    convenience init(missingPerm: AppPerm, title: String, subtitle: String, imageName: String, actionTitle: String) {
        self.init(frame: CGRect.zero)
        self.missingPerm = missingPerm
        msgImage = UIImage(named: imageName)
        msgTitle = title
        msgDescription = subtitle
        msgButtonTitle = actionTitle
        msgSecondaryButtonTitle = "Don't allow"
        render()
    }

    func render() {
        buildElements()
        buildLayout()
    }

    func buildElements() {
        // build
        iconImage = UIImageView(image: msgImage)
        titleLabel = UILabel()
        descriptionTextView = UITextView()
        actionButton = UIButton(type: .system)

        secondaryActionButton = UIButton(type: .system)

        // values
        titleLabel.text = msgTitle
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)

        actionButton.addTarget(self, action: #selector(actionButtonTapped(_:)), for: .touchUpInside)
        secondaryActionButton.addTarget(self, action: #selector(secondaryActionButtonTapped(_:)), for: .touchUpInside)

        // style
        backgroundColor = .white

        descriptionTextView.textAlignment = .left
        descriptionTextView.text = msgDescription
        descriptionTextView.textContainer.lineBreakMode = .byWordWrapping
        descriptionTextView.font = UIFont.systemFont(ofSize: 18)
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.textAlignment = .center

        titleLabel.textAlignment = .center

        actionButton.setTitle(msgButtonTitle, for: UIControl.State())
        actionButton.titleLabel?.font = UIFont(name: actionButton.titleLabel!.font.fontName, size: 22)

        secondaryActionButton.setTitle(msgSecondaryButtonTitle, for: UIControl.State())
        secondaryActionButton.titleLabel?.font = UIFont(name: secondaryActionButton.titleLabel!.font.fontName, size: 16)
    }

    func buildLayout() {
        // Layout
        addSubview(iconImage)
        addSubview(titleLabel)
        addSubview(descriptionTextView)
        addSubview(actionButton)
        addSubview(secondaryActionButton)

        iconImage.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY).offset(-50)
            make.width.equalTo(80)
            make.height.equalTo(80)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImage.snp.bottom).offset(10)
            make.centerX.equalTo(iconImage.snp.centerX)
            make.width.equalTo(self.snp.width)
            make.height.equalTo(30)
        }

        descriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            //            make.centerX.equalTo(titleLabel.snp.centerX)
            make.left.equalTo(self.snp.left).offset(10)
            make.right.equalTo(self.snp.right).offset(-10)
            make.height.equalTo(90)
        }

        actionButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionTextView.snp.bottom).offset(10)
            make.centerX.equalTo(descriptionTextView.snp.centerX)
            make.width.equalTo(self.snp.width)
            make.height.equalTo(40)
        }

        secondaryActionButton.snp.makeConstraints { make in
            make.top.equalTo(actionButton.snp.bottom).offset(10)
            make.centerX.equalTo(actionButton.snp.centerX)
            make.width.equalTo(self.snp.width)
            make.height.equalTo(30)
        }
    }

    func setup(view: UIView, delegate: PermRequesterViewDelegate? = nil) {
        view.addSubview(self)

        snp.makeConstraints { make in
            make.size.equalTo(view.snp.size)
            make.center.equalTo(view.snp.center)
        }

        self.delegate = delegate
    }

    func hide() {
        isHidden = true
    }

    func show() {
        isHidden = false
    }

    func enableRefresh(enable: Bool) {
        actionButton.isEnabled = enable
    }

    @objc
    func actionButtonTapped(_: Any) {
        actionButton.isEnabled = false
        secondaryActionButton.isEnabled = false
        delegate?.didAcceptPermissionRequest(accepted: true, missingPerm: missingPerm)
    }

    @objc
    func secondaryActionButtonTapped(_: Any) {
        secondaryActionButton.isEnabled = false
        secondaryActionButton.isEnabled = false
        delegate?.didAcceptPermissionRequest(accepted: false, missingPerm: missingPerm)
    }
}
