//
//  BaseStackViewController.swift
//  Example
//
//  Created by Alexander Grebenyuk on 02/03/16.
//  Copyright © 2016 Alexander Grebenyuk. All rights reserved.
//

import UIKit
import Arranged

let loggingEnabled = false
let logAffectingViewsConstraints = false


// MARK: BaseStackViewController

enum ContentType {
    case View
    case Label
}

class BaseStackViewController<T where T: UIView, T: StackViewAdapter>: UIViewController {
    var stackView: T!
    var views = [UIView]()
    var widthConstraint: NSLayoutConstraint!
    var heightConstraint: NSLayoutConstraint!

    // Options
    var animated = true
    var contentType: ContentType = .View {
        didSet {
            if oldValue != self.contentType {
                refreshContent()
            }
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
        self.widthConstraint = self.stackView.autoSetDimension(.Width, toSize: 100)
        self.widthConstraint.active = false
        self.heightConstraint = self.stackView.autoSetDimension(.Height, toSize: 100)
        self.heightConstraint.active = false
        
        // Create background for stack view

        let background = UIView()
        background.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        self.view.insertSubview(background, belowSubview: self.stackView)
        background.autoMatchDimension(.Width, toDimension: .Width, ofView: self.stackView)
        background.autoMatchDimension(.Height, toDimension: .Height, ofView: self.stackView)
        background.autoAlignAxis(.Horizontal, toSameAxisOfView: self.stackView)
        background.autoAlignAxis(.Vertical, toSameAxisOfView: self.stackView)


        // Create controls

        let controls = UIStackView()
        controls.spacing = 2
        controls.axis = .Vertical
        controls.layoutMarginsRelativeArrangement = true
        controls.alignment = .Leading

        controls.addArrangedSubview(AxisPicker(value: self.stackView.axis, presenter: self) { axis in
            self.perform {
                self.stackView.axis = axis
            }
        }.view)
        controls.addArrangedSubview(SpacingPicker(value: self.stackView.spacing, presenter: self) { value in
            self.perform {
                self.stackView.spacing = value
            }
        }.view)
        controls.addArrangedSubview(DistrubituonPicker(value: self.stackView.ar_distribution, presenter: self) { value in
            self.perform {
                self.stackView.ar_distribution = value
            }
        }.view)
        controls.addArrangedSubview(AlignmentPicker(value: self.stackView.ar_alignment, presenter: self) { value in
            self.perform {
                self.stackView.ar_alignment = value
            }
        }.view)
        controls.addArrangedSubview(MarginsPicker(value: self.stackView.layoutMargins, presenter: self) { value in
            self.perform {
                self.stackView.layoutMargins = value
            }
        }.view)
        controls.addArrangedSubview(BaselineRelativeArrangementPicker(value: self.stackView.baselineRelativeArrangement
            , presenter: self) { value in
            self.perform {
                self.stackView.baselineRelativeArrangement = value
            }
        }.view)
        controls.addArrangedSubview(LayoutMarginsRelativeArrangementPicker(value: self.stackView.layoutMarginsRelativeArrangement
            , presenter: self) { value in
            self.perform {
                self.stackView.layoutMarginsRelativeArrangement = value
            }
        }.view)

        let controls2 = UIStackView()
        controls2.spacing = 2
        controls2.axis = .Vertical
        controls2.layoutMarginsRelativeArrangement = true
        controls2.alignment = .Trailing
        controls2.addArrangedSubview(UIButton(type: .System).then {
            $0.setTitle("show all subviews", forState: .Normal)
            $0.addTarget(self, action: "buttonShowAllTapped:", forControlEvents: .TouchUpInside)
        })
        controls2.addArrangedSubview(AnimatedPicker(value: self.animated, presenter: self) {
            self.animated = $0
        }.view)
        controls2.addArrangedSubview(ContentTypePicker(value: self.contentType, presenter: self) {
            self.contentType = $0
        }.view)
        controls2.addArrangedSubview(SizePicker(value: (false, 0.5), type: .Width, presenter: self) { active, ratio in
            self.widthConstraint.active = active
            let bound = self.view.bounds.size.width
            self.widthConstraint.constant = ratio * bound
        }.view)
        controls2.addArrangedSubview(SizePicker(value: (false, 0.5), type: .Height, presenter: self) { active, ratio in
            self.heightConstraint.active = active
            let bound = self.view.bounds.size.width
            self.heightConstraint.constant = ratio * bound
        }.view)

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
            $0.removeFromSuperview()
        }
        self.views.removeAll()

        switch self.contentType {
        case .View:
            self.views.append(ContentView().then {
                $0.contentSize = CGSize(width: 40, height: 40)
                $0.backgroundColor = UIColor.redColor()
            })

            self.views.append(ContentView().then {
                $0.contentSize = CGSize(width: 20, height: 100)
                $0.backgroundColor = UIColor.blueColor()
            })

            self.views.append(ContentView().then {
                $0.contentSize = CGSize(width: 80, height: 60)
                $0.backgroundColor = UIColor.greenColor()
            })

        case .Label:
            self.views.append(UILabel().then {
                $0.text = "Sed ut perspiciatis unde omnis iste natus"
                $0.font = UIFont.systemFontOfSize(26)
                $0.numberOfLines = 0
                $0.backgroundColor = UIColor.redColor()
            })

            self.views.append(UILabel().then {
                $0.text = "Neque porro quisquam est, qui dolorem ipsum"
                $0.font = UIFont.systemFontOfSize(20)
                $0.numberOfLines = 0
                $0.backgroundColor = UIColor.blueColor()
            })

            self.views.append(UILabel().then {
                $0.text = "Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt."
                $0.font = UIFont.systemFontOfSize(14)
                $0.numberOfLines = 0
                $0.backgroundColor = UIColor.greenColor()
            })
        }

        for (index, view) in self.views.enumerate() {
            view.accessibilityIdentifier = "content-view-\(index + 1)"
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "viewTapped:"))
            self.stackView.addArrangedSubview(view)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if loggingEnabled {
            print("\n\n")
            print("===========================")
            print("constraints:")
            printConstraints(constraintsForView(stackView))

            if logAffectingViewsConstraints {
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
    }
    
    @objc func buttonShowAllTapped(sender: UIButton) {
        self.perform {
            self.stackView.subviews.forEach{
                if let stack = self.stackView as? Arranged.StackView {
                    stack.setArrangedView($0, hidden: false)
                } else {
                    $0.hidden = false
                }
            }
        }
    }

    @objc func viewTapped(sender: UITapGestureRecognizer) {
        self.perform {
            if let stack = self.stackView as? Arranged.StackView {
                stack.setArrangedView(sender.view!, hidden: true)
            } else {
                sender.view?.hidden = true
            }
        }
    }
    
    func perform(closure: (Void) -> Void) {
        if (animated) {
            UIView.animateWithDuration(0.33) {
                closure()
                // Arranged.StackView requires call to layoutIfNeeded
                if !(self.stackView is UIStackView) {
                    self.view.layoutIfNeeded()
                }
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
    
    func constraintsForView(item: UIView) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        constraints.appendContentsOf(item.constraints)
        for subview in item.subviews {
                constraints.appendContentsOf(subview.constraints)
        }
        return constraints
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
