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
    
    private var alignmentArrangement: _LayoutArrangement? = nil
    private var distrubitonArrangement: _LayoutArrangement? = nil
    
    private var invalidated = false
    
//    private
    
    public private(set) var arrangedSubviews: [UIView]
    
    public init(arrangedSubviews views: [UIView]) {
        self.arrangedSubviews = views
        super.init(frame: CGRectZero)
        self.commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.arrangedSubviews = []
        super.init(coder: aDecoder)
        self.commonInit()
        // FIXME: KVO warning
        
        // FIXME:
        self.arrangedSubviews.appendContentsOf(self.subviews)
        self.invalidateLayout()
    }
    
    private func commonInit() {
        self.alignmentArrangement = _AlignedLayoutArrangement(canvas: self)
        self.distrubitonArrangement = _DistributionLayoutArrangement(canvas: self)
    }
    
    public func addArrangedSubview(view: UIView) {
        if view.superview != view {
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

private class _LayoutArrangement {
    private weak var canvas: StackView!
    private var constraints = [NSLayoutConstraint]()

    private init(canvas: StackView) {
        self.canvas = canvas
    }
    private func updateConstraints() {
        canvas.removeConstraints(self.constraints)
        constraints.removeAll()
    }
}

private class _AlignedLayoutArrangement: _LayoutArrangement {
    private override func updateConstraints() {
        super.updateConstraints()
        let hor = canvas.axis == .Horizontal
        let align = canvas.alignment
        let _ = canvas.arrangedSubviews.reduce(nil as UIView?) { previous, current in
            constraints.append(current.autoPinEdgeToSuperviewMargin((hor ? .Top : .Leading), relation: (align == .Fill || align == .Leading ? .Equal : .GreaterThanOrEqual)))
            constraints.append(current.autoPinEdgeToSuperviewMargin((hor ? .Bottom : .Trailing), relation: (align == .Fill || align == .Trailing ? .Equal : .GreaterThanOrEqual)))
            if align == .Center {
                constraints.append(current.autoAlignAxisToSuperviewMarginAxis(hor ? .Horizontal : .Vertical))
            }
            if let previous = previous where align == .FirstBaseline || align == .LastBaseline {
                constraints.append(current.autoAlignAxis((align == .FirstBaseline ? .FirstBaseline : .LastBaseline), toSameAxisOfView: previous))
            }
            return current
        }
    }
}

private class _DistributionLayoutArrangement: _LayoutArrangement {
    private override func updateConstraints() {
        super.updateConstraints()
        
        self.addSpacingConstraints()
        self.addPinningSidesCostraints()
        self.addDistributionConstraints()
    }
    
    private func addSpacingConstraints() {
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
    
    private func addPinningSidesCostraints() {
        var constraints = [NSLayoutConstraint]()
        let hor = canvas.axis == .Horizontal
        if let constraint = canvas.arrangedSubviews.first?.autoPinEdgeToSuperviewMargin(hor ? .Leading : .Top) {
            constraints.append(constraint)
        }
        // FIXME: Make sure that matches UIStackView
        if let constraint = canvas.arrangedSubviews.last?.autoPinEdgeToSuperviewMargin(hor ? .Trailing : .Bottom) {
            constraints.append(constraint)
        }
    }
    
    private func addDistributionConstraints() {
        // FIXME: Add support for other distributions
        guard canvas.distribution == .FillEqually else {
            return
        }
        var constraints = [NSLayoutConstraint]()
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
