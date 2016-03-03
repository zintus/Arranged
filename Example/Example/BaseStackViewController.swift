//
//  BaseStackViewController.swift
//  Example
//
//  Created by Alexander Grebenyuk on 02/03/16.
//  Copyright © 2016 Alexander Grebenyuk. All rights reserved.
//

import UIKit

let loggingEnabled = true


// MARK: BaseStackViewController

enum ContentType {
    case View
    case Label
}

class BaseStackViewController<T where T: UIView, T: StackViewAdapter>: UIViewController {
    var stackView: T!
    var views = [UIView]()
    var pinStackViewConstraint: NSLayoutConstraint!

    // Options
    var animated = true
    var contentType: ContentType = .View {
        didSet {
            refreshContent()
        }
    }

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


        self.refreshContent()

        self.stackView.layoutMargins = UIEdgeInsetsMake(8, 8, 8, 8)

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

        controls.addArrangedSubview(AxisPicker(value: self.stackView.axis, presenter: self) { axis in
            self.perform {
                self.stackView.axis = axis
            }
        }.button)
        controls.addArrangedSubview(SpacingPicker(value: self.stackView.spacing, presenter: self) { value in
            self.perform {
                self.stackView.spacing = value
            }
        }.button)
        controls.addArrangedSubview(DistrubituonPicker(value: self.stackView.ar_distribution, presenter: self) { value in
            self.perform {
                self.stackView.ar_distribution = value
            }
        }.button)
        controls.addArrangedSubview(AlignmentPicker(value: self.stackView.ar_alignment, presenter: self) { value in
            self.perform {
                self.stackView.ar_alignment = value
            }
        }.button)
        controls.addArrangedSubview(MarginsPicker(value: self.stackView.layoutMargins, presenter: self) { value in
            self.perform {
                self.stackView.layoutMargins = value
            }
        }.button)
        controls.addArrangedSubview(BaselineRelativeArrangementPicker(value: self.stackView.baselineRelativeArrangement
            , presenter: self) { value in
            self.perform {
                self.stackView.baselineRelativeArrangement = value
            }
        }.button)
        controls.addArrangedSubview(LayoutMarginsRelativeArrangementPicker(value: self.stackView.layoutMarginsRelativeArrangement
            , presenter: self) { value in
            self.perform {
                self.stackView.layoutMarginsRelativeArrangement = value
            }
        }.button)

        let controls2 = UIStackView()
        controls2.spacing = 0
        controls2.axis = .Vertical
        controls2.layoutMarginsRelativeArrangement = true
        controls2.alignment = .Trailing
        controls2.addArrangedSubview(UIButton(type: .System).then {
            $0.setTitle("show all subviews", forState: .Normal)
            $0.addTarget(self, action: "buttonShowAllTapped:", forControlEvents: .TouchUpInside)
        })
        controls2.addArrangedSubview(UIButton(type: .System).then {
            $0.setTitle("pin stack view", forState: .Normal)
            $0.setTitle("unpin stack view", forState: .Selected)
            $0.addTarget(self, action: "buttonPinTapped:", forControlEvents: .TouchUpInside)
        })
        controls2.addArrangedSubview(AnimatedPicker(value: self.animated, presenter: self) {
            self.animated = $0
        }.button)
        controls2.addArrangedSubview(ContentTypePicker(value: self.contentType, presenter: self) {
            self.contentType = $0
        }.button)

        self.view.addSubview(controls)
        self.view.addSubview(controls2)
        controls.autoPinToBottomLayoutGuideOfViewController(self, withInset: 16)
        controls2.autoPinEdge(.Top, toEdge: .Top, ofView: controls)
        controls.autoPinEdgeToSuperviewMargin(.Leading)
        controls2.autoPinEdgeToSuperviewMargin(.Trailing)
        controls.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.stackView, withOffset: 16, relation: .GreaterThanOrEqual)
    }

    func refreshContent() {

        self.views.forEach {
            self.stackView.removeArrangedSubview($0)
        }
        self.views.removeAll()

        switch self.contentType {
        case .View:
            self.views.append(ContentView().then {
                $0.contentSize = CGSize(width: 44, height: 44)
                $0.backgroundColor = UIColor.redColor()
            })

            self.views.append(ContentView().then {
                $0.contentSize = CGSize(width: 30, height: 100)
                $0.backgroundColor = UIColor.blueColor()
            })

            self.views.append(ContentView().then {
                $0.contentSize = CGSize(width: 80, height: 40)
                $0.backgroundColor = UIColor.greenColor()
            })

        case .Label:
            self.views.append(UILabel().then {
                $0.text = "Sed ut perspiciatis unde omnis iste natus"
                $0.numberOfLines = 0
                $0.backgroundColor = UIColor.redColor()
            })

            self.views.append(UILabel().then {
                $0.text = "Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt."
                $0.numberOfLines = 0
                $0.backgroundColor = UIColor.blueColor()
            })

            self.views.append(UILabel().then {
                $0.text = "Neque porro quisquam est, qui dolorem ipsum"
                $0.numberOfLines = 0
                $0.backgroundColor = UIColor.greenColor()
            })
        }

        for (index, view) in views.enumerate() {
            view.accessibilityIdentifier = "content-view-\(index)"
            self.stackView.addArrangedSubview(view)
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "viewTapped:"))
            self.stackView.addArrangedSubview(view)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if loggingEnabled {
            print("")
            print("horizontal")
            print("==========")
            print("\naffecting stack view:")
            printConstraints(stackView.constraintsAffectingLayoutForAxis(.Horizontal))
            for view in views {
                print("\naffecting view \(view.accessibilityIdentifier):")
                printConstraints(view.constraintsAffectingLayoutForAxis(.Horizontal))
            }
            print("")
            print("vertical")
            print("==========")
            print("\naffecting stack view:")
            printConstraints(stackView.constraintsAffectingLayoutForAxis(.Vertical))
            for view in views {
                print("\naffecting view \(view.accessibilityIdentifier):")
                printConstraints(view.constraintsAffectingLayoutForAxis(.Vertical))
            }
        }
    }
    
    @objc func buttonShowAllTapped(sender: UIButton) {
        self.perform {
            self.stackView.subviews.forEach{ $0.hidden = false }
        }
    }

    @objc func buttonPinTapped(sender: UIButton ) {
        self.perform {
            sender.selected = !sender.selected
            self.pinStackViewConstraint.active = sender.selected
        }
    }

    @objc func viewTapped(sender: UITapGestureRecognizer) {
        self.perform {
            sender.view?.hidden = true
        }
    }
    
    func perform(closure: (Void) -> Void) {
        if (animated) {
            UIView.animateWithDuration(0.33) {
                closure()
                // Arranged.StackView requires call to layoutIfNeeded
                self.view.layoutIfNeeded()
            }
        } else {
            closure()
        }
    }
    
    func printConstraints(constraints: [NSLayoutConstraint]) {
        for constraint in constraints {
            print(constraint)
        }
    }
}


// MARK: ContentView

class ContentView: UIView {
    var contentSize = CGSize(width: 44, height: 44)

    convenience init() {
        self.init(frame: CGRectZero)
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


// MARK: Then

protocol Then {}

extension Then where Self: Any {
    func then(@noescape block: inout Self -> Void) -> Self {
        var copy = self
        block(&copy)
        return copy
    }
}

extension Then where Self: AnyObject {
    func then(@noescape block: Self -> Void) -> Self {
        block(self)
        return self
    }
}

extension NSObject: Then {}
