// The MIT License (MIT)
//
// Copyright (c) 2016 Alexander Grebenyuk (github.com/kean).

import Foundation
import UIKit
import PureLayout

public enum StackViewDistribution {
    case Fill
    case FillEqually
    // FIXME: Implement
    case FillProportionally
    case EqualSpacing
    // FIXME: Implement
    case EqualCentering
}

public enum StackViewAlignment {
    case Fill
    case Leading
    public static var Top: StackViewAlignment {
        return .Leading
    }
    case Center
    case Trailing
    public static var Bottom: StackViewAlignment {
        return .Trailing
    }
    case FirstBaseline
    case LastBaseline
}

public class StackView : UIView {
    public var axis: UILayoutConstraintAxis = .Horizontal {
        didSet { if axis != oldValue { self.invalidateLayout() } }
    }
    public var distribution: StackViewDistribution = .Fill {
        didSet { if distribution != oldValue { self.invalidateLayout() } }
    }
    public var alignment: StackViewAlignment = .Fill {
        didSet { if alignment != oldValue { self.invalidateLayout() } }
    }
    public var spacing: CGFloat = 0.0 {
        didSet { if spacing != oldValue { self.invalidateLayout() } }
    }
    // FIXME: Implement
    public var baselineRelativeArrangement = false {
        didSet { if baselineRelativeArrangement != oldValue { self.invalidateLayout() } }
    }
    // FIXME: Implement
    public var layoutMarginsRelativeArrangement = false {
        didSet { if layoutMarginsRelativeArrangement != oldValue { self.invalidateLayout() } }
    }
    
    private var alignmentArrangement: LayoutArrangement? = nil
    private var distrubitonArrangement: LayoutArrangement? = nil
    
    private var invalidated = false
        
    public private(set) var arrangedSubviews: [UIView]
    
    public init(arrangedSubviews views: [UIView]) {
        self.arrangedSubviews = views
        super.init(frame: CGRectZero)
        self.commonInit()
    }

    public convenience init() {
        self.init(arrangedSubviews: [])
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.arrangedSubviews = []
        super.init(coder: aDecoder)
        self.commonInit()
        
        // FIXME:
        self.arrangedSubviews.appendContentsOf(self.subviews)
        self.invalidateLayout()
    }
    
    private func commonInit() {
        self.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        self.alignmentArrangement = AlignedLayoutArrangement(canvas: self)
        self.distrubitonArrangement = DistributionLayoutArrangement(canvas: self)
    }

    // MARK: Managing Arranged Views
    
    public func addArrangedSubview(view: UIView) {
        if view.superview != view && !self.arrangedSubviews.contains(view) {
            self.arrangedSubviews.append(view)
            self.addSubview(view)
            self.invalidateLayout()
        }
    }

    public func removeArrangedSubview(view: UIView) {
        // FIXME:
    }
    
    public func insertArrangedSubview(view: UIView, atIndex stackIndex: Int) {
        // FIXME:
    }
    
    // MARK: Layout
    
    private func invalidateLayout() {
        if !self.invalidated {
            self.invalidated = true
            self.setNeedsUpdateConstraints()
        }
    }
    
    public override func updateConstraints() {
        if self.invalidated {
            self.invalidated = false
            // FIXME: Refresh only invalidated constraints (at least in most and perforamce-intensive common cases)
            self.alignmentArrangement?.updateConstraints()
            self.distrubitonArrangement?.updateConstraints()
        }
        super.updateConstraints()
    }
}

class LayoutArrangement {
    weak var canvas: StackView!
    var constraints = [NSLayoutConstraint]()
    
    // Convenience accessors
    var hor: Bool { return canvas.axis == .Horizontal }
    var align: StackViewAlignment { return canvas.alignment }
    var marginsEnabled: Bool { return canvas.layoutMarginsRelativeArrangement }
    
    
    init(canvas: StackView) {
        self.canvas = canvas
    }
    
    func updateConstraints() {
        canvas.removeConstraints(self.constraints)
        constraints.removeAll()
    }
}

class AlignedLayoutArrangement: LayoutArrangement {
    override func updateConstraints() {
        super.updateConstraints()
        let _ = canvas.arrangedSubviews.reduce(nil as UIView?) { previous, current in
            // Pin edges leading and trailing edges (either with .Equal : .GreaterThanOrEqual relation)
            if marginsEnabled {
                constraints.append(current.autoPinEdgeToSuperviewMargin(leadingEdge, relation: leadingRelation))
                constraints.append(current.autoPinEdgeToSuperviewMargin(trailingEdge, relation: trailingRelation))
            } else {
                constraints.append(current.autoPinEdgeToSuperviewEdge(leadingEdge, withInset: 0, relation: leadingRelation))
                constraints.append(current.autoPinEdgeToSuperviewEdge(trailingEdge, withInset: 0, relation: trailingRelation))
            }
            if align == .Center {
                constraints.append(current.autoConstrainAttribute(centeringAttribute, toAttribute: centeringAttribute, ofView: canvas))
            }
            if let previous = previous where align == .FirstBaseline || align == .LastBaseline {
                assert(!hor, "baseline alignment not supported for vertical layout axis")
                constraints.append(current.autoAlignAxis((align == .FirstBaseline ? .FirstBaseline : .LastBaseline), toSameAxisOfView: previous))
            }
            return current
        }
    }
    
    var leadingEdge: ALEdge {
        return hor ? .Top : .Leading
    }
    
    var trailingEdge: ALEdge {
        return hor ? .Bottom : .Trailing
    }
    
    var leadingRelation: NSLayoutRelation {
        return (align == .Fill || align == .Leading ? .Equal : .GreaterThanOrEqual)
    }
    
    var trailingRelation: NSLayoutRelation {
        return (align == .Fill || align == .Trailing ? .Equal : .GreaterThanOrEqual)
    }
    
    var centeringAttribute: ALAttribute {
        return marginsEnabled ? (hor ? .MarginAxisHorizontal : .MarginAxisVertical) : (hor ? .Horizontal : .Vertical)
    }
}

class DistributionLayoutArrangement: LayoutArrangement {
    override func updateConstraints() {
        super.updateConstraints()

        updateSpacingConstraints()
        updatePinningSidesCostraints()
        updateDistributionConstraints()
    }
    
    func updateSpacingConstraints() {
        // FIXME: Don't create spacers when not necessary
        /*
        var constraints2 = [NSLayoutConstraint]()
        let _ = self.arrangedSubviews.reduce(nil as UIView?) { previous, current in
        if let previous = previous {
        let hor = self.axis == .Horizontal
        constraints2.append(current.autoPinEdge((hor ? .Leading : .Bottom), toEdge: (hor ? .Trailing : .Top), ofView: previous, withOffset: self.spacing))
        }
        return current
        }
        return constraints2
        */
        canvas.subviews.filter{ $0 is Spacer }.forEach{ $0.removeFromSuperview() }
        let hor = canvas.axis == .Horizontal
        // Join views using spacers
        var spacers = [Spacer]()
        let _ = canvas.arrangedSubviews.reduce(nil as UIView?) { previous, current in
            if let previous = previous {
                let spacer = Spacer()
                canvas.addSubview(spacer)
                spacers.append(spacer)
                constraints.append(spacer.autoPinEdge((hor ? .Leading : .Bottom), toEdge: (hor ? .Trailing : .Top), ofView: previous))
                constraints.append(current.autoPinEdge((hor ? .Leading : .Bottom), toEdge: (hor ? .Trailing : .Top), ofView: spacer))
            }
            return current
        }
        // Configure spacers
        let _ = spacers.reduce(nil as Spacer?) { previous, current in
            constraints.append(current.autoSetDimension((hor ? .Height : .Width), toSize: 0))
            // FIXME: Support other distributions
            let dimension: ALDimension = hor ? .Width : .Height
            constraints.append(current.autoSetDimension(dimension, toSize: canvas.spacing, relation: (canvas.distribution == .EqualSpacing ? .Equal : .GreaterThanOrEqual)))
            if let previous = previous {
                constraints.append(current.autoMatchDimension(dimension, toDimension: dimension, ofView: previous))
            }
            return current
        }
    }
    
    func updatePinningSidesCostraints() {
        guard let first = canvas.arrangedSubviews.first, last = canvas.arrangedSubviews.last else {
            return
        }
        let leadingEdge: ALEdge = hor ? .Leading : .Top
        let trailingEdge: ALEdge = hor ? .Trailing : .Bottom
        if marginsEnabled {
            constraints.append(first.autoPinEdgeToSuperviewMargin(leadingEdge))
            constraints.append(last.autoPinEdgeToSuperviewMargin(trailingEdge))
        } else {
            constraints.append(first.autoPinEdgeToSuperviewEdge(leadingEdge))
            constraints.append(last.autoPinEdgeToSuperviewEdge(trailingEdge))
        }
    }

    func updateDistributionConstraints() {
        // FIXME: Add support for other distributions
        guard canvas.distribution == .FillEqually else {
            return
        }
        let _ = canvas.arrangedSubviews.reduce(nil as UIView?) { previous, current in
            let dimension: ALDimension = (canvas.axis == .Horizontal ? .Width : .Height)
            if let previous = previous {
                constraints.append(previous.autoMatchDimension(dimension, toDimension: dimension, ofView: current))
            }
            return current
        }
    }
}

private class Spacer: UIView {}
