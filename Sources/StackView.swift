// The MIT License (MIT)
//
// Copyright (c) 2016 Alexander Grebenyuk (github.com/kean).

import Foundation
import UIKit
import PureLayout

public enum StackViewDistribution {
    case Fill
    case FillEqually
    case FillProportionally
    case EqualSpacing
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
    public var axis: UILayoutConstraintAxis = .Horizontal
    public var distribution: StackViewDistribution = .Fill
    public var alignment: StackViewAlignment = .Fill
    public var spacing: CGFloat = 0.0
    
    // FIXME:
    public var baselineRelativeArrangement = false
    public var layoutMarginsRelativeArrangement = false
    
    private var stackConstraints = [NSLayoutConstraint]()
    private var invalidated = false
    
    public private(set) var arrangedSubviews: [UIView]
    
    public init(arrangedSubviews views: [UIView]) {
        self.arrangedSubviews = views
        super.init(frame: CGRectZero)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.arrangedSubviews = []
        super.init(coder: aDecoder)
        
        // FIXME: KVO warning
        
        // FIXME:
        self.arrangedSubviews.appendContentsOf(self.subviews)
        self.invalidateLayout()
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
            self.refreshConstraints()
        }
        super.updateConstraints()
    }
    
    private func refreshConstraints() {
        self.removeConstraints(self.stackConstraints)
        self.stackConstraints.removeAll()
        // FIXME: Maybe we could avoid collection constraints?
        self.stackConstraints.appendContentsOf(self.addSpacingConstraints())
        self.stackConstraints.appendContentsOf(self.addPinningSidesCostraints())
        self.stackConstraints.appendContentsOf(self.addDistributionConstraints())
        self.stackConstraints.appendContentsOf(self.addAlignmentConstraints())
    }
    
    private func addSpacingConstraints() -> [NSLayoutConstraint] {
        // TEMP:
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
        
        self.subviews.filter{ $0 is Spacer }.forEach{ $0.removeFromSuperview() }
        let hor = self.axis == .Horizontal
        var constraints = [NSLayoutConstraint]()
        // Join views using spacers
        var spacers = [Spacer]()
        let _ = self.arrangedSubviews.reduce(nil as UIView?) { previous, current in
            if let previous = previous {
                let spacer = Spacer()
                self.addSubview(spacer)
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
            constraints.append(current.autoSetDimension(dimension, toSize: self.spacing, relation: (self.distribution == .EqualSpacing ? .Equal : .GreaterThanOrEqual)))
            if let previous = previous {
                constraints.append(current.autoMatchDimension(dimension, toDimension: dimension, ofView: previous))
            }
            return current
        }
        return constraints
    }
    
    private func addPinningSidesCostraints() -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        let hor = self.axis == .Horizontal
        if let constraint = self.arrangedSubviews.first?.autoPinEdgeToSuperviewMargin(hor ? .Leading : .Top) {
            constraints.append(constraint)
        }
        // FIXME: Make sure that matches UIStackView
        if let constraint = self.arrangedSubviews.last?.autoPinEdgeToSuperviewMargin(hor ? .Trailing : .Bottom) {
            constraints.append(constraint)
        }
        return constraints
    }
    
    private func addDistributionConstraints() -> [NSLayoutConstraint] {
        // FIXME: Add support for other distributions
        guard self.distribution == .FillEqually else {
            return []
        }
        var constraints = [NSLayoutConstraint]()
        let _ = self.arrangedSubviews.reduce(nil as UIView?) { previous, current in
            let dimension: ALDimension = (self.axis == .Horizontal ? .Width : .Height)
            if let previous = previous {
                constraints.append(previous.autoMatchDimension(dimension, toDimension: dimension, ofView: current))
            }
            return current
        }
        return constraints
    }
    
    private func addAlignmentConstraints() -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        let hor = self.axis == .Horizontal
        let align = self.alignment
        let _ = self.arrangedSubviews.reduce(nil as UIView?) { previous, current in
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
        return constraints
    }
}

private class Spacer: UIView {}
