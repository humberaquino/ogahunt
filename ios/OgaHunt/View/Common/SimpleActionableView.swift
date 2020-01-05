//
//  EmptyListView.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 8/28/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import SnapKit
import UIKit

protocol SimpleActionableViewDelegate: class {
    func didTappedActionButton(view: SimpleActionableView)
}

class SimpleActionableView: UIView {
    var msgImage: UIImage!
    var msgTitle: String!
    var msgDescription: String!
    var msgButtonTitle: String!

    var iconImage: UIImageView!
    var titleLabel: UILabel!
    var descriptionTextView: UITextView!
    var actionButton: UIButton!

    weak var delegate: SimpleActionableViewDelegate?

    convenience init(image: UIImage, title: String, description: String, actionTitle: String) {
        self.init(frame: CGRect.zero)

        msgTitle = title
        msgDescription = description
        msgButtonTitle = actionTitle
        msgImage = image

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

        // values
        titleLabel.text = msgTitle
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)

        actionButton.addTarget(self, action: #selector(actionButtonTapped(_:)), for: .touchUpInside)

        // style
        backgroundColor = .white

        descriptionTextView.textAlignment = .left
        descriptionTextView.text = msgDescription
        descriptionTextView.textContainer.lineBreakMode = .byWordWrapping
        descriptionTextView.font = UIFont.systemFont(ofSize: 18)
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.textAlignment = .center
        descriptionTextView.isUserInteractionEnabled = false

        titleLabel.textAlignment = .center

        actionButton.setTitle(msgButtonTitle, for: UIControl.State())
        actionButton.titleLabel?.font = UIFont(name: actionButton.titleLabel!.font.fontName, size: 22)
    }

    func buildLayout() {
        // Layout
        addSubview(iconImage)
        addSubview(titleLabel)
        addSubview(descriptionTextView)
        addSubview(actionButton)

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
    }

    func setup(view: UIView, delegate: SimpleActionableViewDelegate? = nil) {
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
        delegate?.didTappedActionButton(view: self)
    }
}
