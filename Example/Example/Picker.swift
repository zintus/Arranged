//
//  Picker.swift
//  Example
//
//  Created by Alexander Grebenyuk on 02/03/16.
//  Copyright © 2016 Alexander Grebenyuk. All rights reserved.
//

import UIKit
import ObjectiveC

// MARK: Picker

extension UIViewController {
    func showPicker(title: String?, items: [String], selected: Int?, handler: (index: Int) -> Void) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .ActionSheet)
        for (index, item) in items.enumerate() {
            let checkmark = index == selected ? " ✓" : ""
            alert.addAction(UIAlertAction(title: "\(item)\(checkmark)", style: .Default) { _ in
                handler(index: index)
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

// MARK: Value Pickers

private struct AssociatedKeys {
    static var Controller = "Arranged.Controller"
}

class ValuePicker<Value> {
    weak var presenter: UIViewController!
    var value: Value {
        didSet {
            self.update()
            self.observer(value: value)
        }
    }
    let button = UIButton(type: .System)
    let observer: (value: Value) -> Void
    var view: UIView

    init(value: Value, presenter: UIViewController, observer: (value: Value) -> Void) {
        self.value = value
        self.presenter = presenter
        self.observer = observer
        self.view = button
        self.update()
        objc_setAssociatedObject(button, &AssociatedKeys.Controller, self, .OBJC_ASSOCIATION_RETAIN)
        button.addTarget(self, action: "buttonTapped:", forControlEvents: .TouchUpInside)
    }

    func update() {
        fatalError("update() has not been implemented")
    }

    @objc func buttonTapped(sender: UIButton) {
        self.tapped()
    }

    func tapped() {

    }
}

class AxisPicker : ValuePicker<UILayoutConstraintAxis> {
    let values: [UILayoutConstraintAxis] = [.Vertical, .Horizontal]
    let items = [".Vertical", ".Horizontal"]

    override init(value: UILayoutConstraintAxis, presenter: UIViewController, observer: (value: UILayoutConstraintAxis) -> Void) {
        super.init(value: value, presenter: presenter, observer: observer)
    }

    override func update() {
        button.setTitle("axis:", value: "\(items[values.indexOf(value)!])")
    }

    override func tapped() {
        presenter.showPicker("Constraint Axis (UILayoutConstraintAxis)", items: items, selected: values.indexOf(self.value)) { index in
            self.value = self.values[index]
        }
    }
}

class SpacingPicker : ValuePicker<CGFloat> {
    let values: [CGFloat] = [0.0, 10.0, 20.0]
    let items = ["0.0", "10.0", "20.0"]

    override init(value: CGFloat, presenter: UIViewController, observer: (value: CGFloat) -> Void) {
        super.init(value: value, presenter: presenter, observer: observer)
    }

    override func update() {
        button.setTitle("spacing:", value: "\(values[values.indexOf(value)!])")
    }

    override func tapped() {
        presenter.showPicker("Spacing", items: items, selected: values.indexOf(self.value)) { index in
            self.value = self.values[index]
        }
    }
}

class DistrubituonPicker : ValuePicker<UIStackViewDistribution> {
    let values: [UIStackViewDistribution] = [.Fill, .FillEqually, .FillProportionally, .EqualSpacing, .EqualCentering]
    let items = [".Fill", ".FillEqually", ".FillProportionally", ".EqualSpacing", ".EqualCentering"]

    override init(value: UIStackViewDistribution, presenter: UIViewController, observer: (value: UIStackViewDistribution) -> Void) {
        super.init(value: value, presenter: presenter, observer: observer)
    }

    override func update() {
        button.setTitle("distribution:", value: "\(items[values.indexOf(value)!])")
    }

    override func tapped() {
        presenter.showPicker("Distribution", items: items, selected: values.indexOf(self.value)) { index in
            self.value = self.values[index]
        }
    }
}

class AlignmentPicker : ValuePicker<UIStackViewAlignment> {
    let values: [UIStackViewAlignment] = [.Fill, .Leading, .FirstBaseline, .Center, .Trailing, .LastBaseline]
    let items = [".Fill", ".Leading", ".FirstBaseline", ".Center", ".Trailing", ".LastBaseline"]

    override init(value: UIStackViewAlignment, presenter: UIViewController, observer: (value: UIStackViewAlignment) -> Void) {
        super.init(value: value, presenter: presenter, observer: observer)
    }

    override func update() {
        button.setTitle("alignment:", value: "\(items[values.indexOf(value)!])")
    }

    override func tapped() {
        presenter.showPicker("Alignment", items: items, selected: values.indexOf(self.value)) { index in
            self.value = self.values[index]
        }
    }
}

class MarginsPicker : ValuePicker<UIEdgeInsets> {
    let values: [UIEdgeInsets] = [UIEdgeInsetsMake(8, 8, 8, 8) , UIEdgeInsetsMake(10, 20, 30, 40), UIEdgeInsetsZero]
    let items = ["(8, 8, 8, 8)", "(10, 20, 30, 40)", "(0, 0, 0, 0)"]

    override init(value: UIEdgeInsets, presenter: UIViewController, observer: (value: UIEdgeInsets) -> Void) {
        super.init(value: value, presenter: presenter, observer: observer)
    }

    override func update() {
        button.setTitle("margins:", value: "\(items[values.indexOf(value)!])")
    }

    override func tapped() {
        presenter.showPicker("Margins", items: items, selected: values.indexOf(self.value)) { index in
            self.value = self.values[index]
        }
    }
}

class BaselineRelativeArrangementPicker : ValuePicker<Bool> {
    override init(value: Bool, presenter: UIViewController, observer: (value: Bool) -> Void) {
        super.init(value: value, presenter: presenter, observer: observer)
    }

    override func update() {
        button.setTitle("baselineRelative:", value: "\(value)")
    }

    override func tapped() {
        value = !value
    }
}

class LayoutMarginsRelativeArrangementPicker : ValuePicker<Bool> {
    override init(value: Bool, presenter: UIViewController, observer: (value: Bool) -> Void) {
        super.init(value: value, presenter: presenter, observer: observer)
    }

    override func update() {
        button.setTitle("marginsRelative:", value: "\(value)")
    }

    override func tapped() {
        value = !value
    }
}

class AnimatedPicker : ValuePicker<Bool> {
    override init(value: Bool, presenter: UIViewController, observer: (value: Bool) -> Void) {
        super.init(value: value, presenter: presenter, observer: observer)
    }
    
    override func update() {
        button.setTitle("animated:", value: "\(value)")
    }
    
    override func tapped() {
        value = !value
    }
}

class ContentTypePicker : ValuePicker<ContentType> {
    let values: [ContentType] = [.View, .Label]
    let items = [".View", ".Label"]

    override init(value: ContentType, presenter: UIViewController, observer: (value: ContentType) -> Void) {
        super.init(value: value, presenter: presenter, observer: observer)
    }

    override func update() {
        button.setTitle("content type:", value: "\(items[values.indexOf(value)!])")
    }

    override func tapped() {
        presenter.showPicker("Content Type", items: items, selected: values.indexOf(self.value)) { index in
            self.value = self.values[index]
        }
    }
}

enum SizeType {
    case Width, Height
}

class SizePicker: ValuePicker<(Bool, CGFloat)> {
    let type: SizeType
    init(value: (Bool, CGFloat), type: SizeType, presenter: UIViewController, observer: (value: (Bool, CGFloat)) -> Void) {
        self.type = type
        super.init(value: value, presenter: presenter, observer: observer)
        
        let prefix = type == .Width ? "H:" : "V:"
        button.setTitle("\(prefix) pin", forState: .Normal)
        button.setTitle("\(prefix) unpin", forState: .Selected)
        
        let slider = UISlider()
        slider.autoSetDimension(.Width, toSize: 100)
        slider.value = Float(value.1)
        slider.addTarget(self, action: "sliderValueChanged:", forControlEvents: .ValueChanged)
        
        let container = UIStackView(arrangedSubviews: [button, slider])
        container.spacing = 8
        view = container
    }
    
    override func update() {
        button.selected = value.0
    }
    
    override func tapped() {
        var value = self.value
        value.0 = !value.0
        self.value = value
    }
    
    @objc func sliderValueChanged(sender: UISlider) {
        var value = self.value
        value.1 = CGFloat(sender.value)
        self.value = value
    }
}

extension UIButton {
    func setTitle(title: String, value: String) {
        let string = NSMutableAttributedString()
        string.appendAttributedString(NSAttributedString(string: title.stringByAppendingString(" "), attributes: [ NSFontAttributeName: UIFont.systemFontOfSize(14) ]))
        string.appendAttributedString(NSAttributedString(string: value, attributes: [ NSFontAttributeName: UIFont.boldSystemFontOfSize(14) ]))
        self.setAttributedTitle(string, forState: .Normal)
    }
}
