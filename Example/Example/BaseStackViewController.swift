//
//  BaseStackViewController.swift
//  Example
//
//  Created by Alexander Grebenyuk on 02/03/16.
//  Copyright © 2016 Alexander Grebenyuk. All rights reserved.
//

import UIKit

class BaseStackViewController<T where T: UIView, T: StackViewAdapter>: UIViewController {
    var stackView: T!
    var views = [UIView]()
    var pinStackViewConstraint: NSLayoutConstraint!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    func createStackView() -> T {
        fatalError("abstract method")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Creat stack view

        self.stackView = self.createStackView()

        views.append(ContentView(contentSize: CGSize(width: 44, height: 44), color: UIColor.redColor()))
        views.append(ContentView(contentSize: CGSize(width: 30, height: 100), color: UIColor.blueColor()))
        views.append(ContentView(contentSize: CGSize(width: 80, height: 40), color: UIColor.greenColor()))

        for view in views {
            self.stackView.addArrangedSubview(view)
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "viewTapped:"))
            self.stackView.addArrangedSubview(view)
        }

        self.stackView.layoutMargins = UIEdgeInsetsZero

        self.view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        self.view.addSubview(self.stackView)
        self.stackView.autoPinToTopLayoutGuideOfViewController(self, withInset: 16)
        self.stackView.autoPinEdgeToSuperviewMargin(.Leading)
        self.stackView.autoPinEdgeToSuperviewMargin(.Trailing, relation: .GreaterThanOrEqual)
        self.pinStackViewConstraint = self.stackView.autoPinEdgeToSuperviewMargin(.Trailing)
        self.pinStackViewConstraint.active = false


        // Create background for stack view

        let background = UIView()
        background.backgroundColor = UIColor.yellowColor()
        self.view.insertSubview(background, belowSubview: self.stackView)
        background.autoMatchDimension(.Width, toDimension: .Width, ofView: self.stackView)
        background.autoMatchDimension(.Height, toDimension: .Height, ofView: self.stackView)
        background.autoAlignAxis(.Horizontal, toSameAxisOfView: self.stackView)
        background.autoAlignAxis(.Vertical, toSameAxisOfView: self.stackView)


        // Create controls

        let controls = UIStackView()
        controls.spacing = 0
        controls.axis = .Vertical
        controls.layoutMarginsRelativeArrangement = true
        controls.alignment = .Leading

        controls.addArrangedSubview(AxisPicker(value: self.stackView.axis, presenter: self) {
            self.stackView.axis = $0
        }.button)
        controls.addArrangedSubview(SpacingPicker(value: self.stackView.spacing, presenter: self) {
            self.stackView.spacing = $0
        }.button)
        controls.addArrangedSubview(DistrubituonPicker(value: self.stackView.ar_distribution, presenter: self) {
            self.stackView.ar_distribution = $0
        }.button)
        controls.addArrangedSubview(AlignmentPicker(value: self.stackView.ar_alignment, presenter: self) {
            self.stackView.ar_alignment = $0
        }.button)
        controls.addArrangedSubview(MarginsPicker(value: self.stackView.layoutMargins, presenter: self) {
            self.stackView.layoutMargins = $0
        }.button)
        controls.addArrangedSubview(BaselineRelativeArrangementPicker(value: self.stackView.baselineRelativeArrangement
            , presenter: self) {
                self.stackView.baselineRelativeArrangement = $0
        }.button)
        controls.addArrangedSubview(LayoutMarginsRelativeArrangementPicker(value: self.stackView.layoutMarginsRelativeArrangement
            , presenter: self) {
            self.stackView.layoutMarginsRelativeArrangement = $0
        }.button)

        let controls2 = UIStackView()
        controls2.spacing = 0
        controls2.axis = .Vertical
        controls2.layoutMarginsRelativeArrangement = true
        controls2.alignment = .Trailing
        controls2.addArrangedSubview({
            let button = UIButton(type: .System)
            button.setTitle("show all subviews", forState: .Normal)
            button.addTarget(self, action: "buttonShowAllTapped:", forControlEvents: .TouchUpInside)
            return button
        }())
        controls2.addArrangedSubview({
            let button = UIButton(type: .System)
            button.setTitle("pin stack view", forState: .Normal)
            button.setTitle("unpin stack view", forState: .Selected)
            button.addTarget(self, action: "buttonPinTapped:", forControlEvents: .TouchUpInside)
            return button
        }())

        self.view.addSubview(controls)
        self.view.addSubview(controls2)
        controls.autoPinToBottomLayoutGuideOfViewController(self, withInset: 16)
        controls2.autoPinEdge(.Top, toEdge: .Top, ofView: controls)
        controls.autoPinEdgeToSuperviewMargin(.Leading)
        controls2.autoPinEdgeToSuperviewMargin(.Trailing)
        controls.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.stackView, withOffset: 16, relation: .GreaterThanOrEqual)
    }

    @objc func buttonShowAllTapped(sender: UIButton) {
        self.stackView.subviews.forEach{ $0.hidden = false }
    }

    @objc func buttonPinTapped(sender: UIButton ) {
        sender.selected = !sender.selected
        self.pinStackViewConstraint.active = sender.selected
    }

    @objc func viewTapped(sender: UIView) {
        sender.hidden = true
    }
}


class ContentView: UIView {
    var contentSize = CGSize(width: 44, height: 44)

    convenience init(contentSize: CGSize, color: UIColor) {
        self.init(frame: CGRectZero)
        self.contentSize = contentSize
        self.backgroundColor = color
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func intrinsicContentSize() -> CGSize {
        return self.contentSize
    }
}
