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
        didSet { if axis != oldValue { invalidateLayout() } }
    }
    public var distribution: StackViewDistribution = .Fill {
        didSet { if distribution != oldValue { invalidateLayout() } }
    }
    public var alignment: StackViewAlignment = .Fill {
        didSet { if alignment != oldValue { invalidateLayout() } }
    }
    public var spacing: CGFloat = 0.0 {
        didSet { if spacing != oldValue { invalidateLayout() } }
    }
    // FIXME: Implement
    public var baselineRelativeArrangement = false {
        didSet { if baselineRelativeArrangement != oldValue { invalidateLayout() } }
    }

    public var layoutMarginsRelativeArrangement = false {
        didSet { if layoutMarginsRelativeArrangement != oldValue { invalidateLayout() } }
    }
    
    private var alignmentArrangement: AlignedLayoutArrangement!
    private var distributionArrangement: DistributionLayoutArrangement!
    
    private var invalidated = false
        
    public private(set) var arrangedSubviews: [UIView]
    
    public init(arrangedSubviews views: [UIView]) {
        arrangedSubviews = views
        super.init(frame: CGRectZero)
        commonInit()
    }

    public convenience init() {
        self.init(arrangedSubviews: [])
    }
    
    public required init?(coder aDecoder: NSCoder) {
        arrangedSubviews = []
        super.init(coder: aDecoder)
        commonInit()
        
        // FIXME:
        arrangedSubviews.appendContentsOf(subviews)
        invalidateLayout()
    }
    
    private func commonInit() {
        layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        alignmentArrangement = AlignedLayoutArrangement(canvas: self)
        distributionArrangement = DistributionLayoutArrangement(canvas: self)
    }

    // MARK: Managing Arranged Views
    
    public func addArrangedSubview(view: UIView) {
        if view.superview != view && !arrangedSubviews.contains(view) {
            arrangedSubviews.append(view)
            addSubview(view)
            invalidateLayout()
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
        if !invalidated {
            invalidated = true
            setNeedsUpdateConstraints()
        }
    }
    
    public override func updateConstraints() {
        if invalidated {
            invalidated = false
            
            alignmentArrangement.views = arrangedSubviews
            alignmentArrangement.axis = axis
            alignmentArrangement.marginsEnabled = layoutMarginsRelativeArrangement
            
            alignmentArrangement.type = alignment
            
            distributionArrangement.views = arrangedSubviews
            distributionArrangement.axis = axis
            distributionArrangement.marginsEnabled = layoutMarginsRelativeArrangement
            
            distributionArrangement.type = distribution
            distributionArrangement.spacing = spacing
            
            // FIXME: Refresh only invalidated constraints (at least in most and perforamce-intensive common cases)
            alignmentArrangement.updateConstraints()
            distributionArrangement.updateConstraints()
        }
        super.updateConstraints()
    }
}

private class LayoutArrangement {
    weak var canvas: UIView!
    var views = [UIView]() // Arranged views
    
    var axis: UILayoutConstraintAxis = .Horizontal
    var horizontal: Bool { return axis == .Horizontal }
    var marginsEnabled: Bool = false
    
    var constraints = [NSLayoutConstraint]()
    
    init(canvas: StackView) {
        self.canvas = canvas
    }
    
    func updateConstraints() {
        canvas.removeConstraints(constraints)
        constraints.removeAll()
    }
}

private class AlignedLayoutArrangement: LayoutArrangement {
    var type: StackViewAlignment = .Fill
    
    override func updateConstraints() {
        super.updateConstraints()
        let _ = views.reduce(nil as UIView?) { previous, current in
            // Pin edges leading and trailing edges (either with .Equal : .GreaterThanOrEqual relation)
            if marginsEnabled {
                constraints.append(current.autoPinEdgeToSuperviewMargin(leadingEdge, relation: leadingRelation))
                constraints.append(current.autoPinEdgeToSuperviewMargin(trailingEdge, relation: trailingRelation))
            } else {
                constraints.append(current.autoPinEdgeToSuperviewEdge(leadingEdge, withInset: 0, relation: leadingRelation))
                constraints.append(current.autoPinEdgeToSuperviewEdge(trailingEdge, withInset: 0, relation: trailingRelation))
            }
            if type == .Center {
                constraints.append(current.autoConstrainAttribute(centeringAttribute, toAttribute: centeringAttribute, ofView: canvas))
            }
            if let previous = previous where type == .FirstBaseline || type == .LastBaseline {
                assert(!horizontal, "baseline alignment not supported for vertical layout axis")
                constraints.append(current.autoAlignAxis((type == .FirstBaseline ? .FirstBaseline : .LastBaseline), toSameAxisOfView: previous))
            }
            return current
        }
    }
    
    var leadingEdge: ALEdge {
        return horizontal ? .Top : .Leading
    }
    
    var trailingEdge: ALEdge {
        return horizontal ? .Bottom : .Trailing
    }
    
    var leadingRelation: NSLayoutRelation {
        return (type == .Fill || type == .Leading ? .Equal : .GreaterThanOrEqual)
    }
    
    var trailingRelation: NSLayoutRelation {
        return (type == .Fill || type == .Trailing ? .Equal : .GreaterThanOrEqual)
    }
    
    var centeringAttribute: ALAttribute {
        return marginsEnabled ? (horizontal ? .MarginAxisHorizontal : .MarginAxisVertical) : (horizontal ? .Horizontal : .Vertical)
    }
}

private class DistributionLayoutArrangement: LayoutArrangement {
    var type: StackViewDistribution = .Fill
    var spacing: CGFloat = 0
    
    override func updateConstraints() {
        super.updateConstraints()

        updateSpacingConstraints()
        updateCanvasConnectingCostraints()
        updateDistributionConstraints()
    }
    
    func updateSpacingConstraints() {
        canvas.subviews.filter{ $0 is Spacer }.forEach{ $0.removeFromSuperview() }
        
        let fromEdge: ALEdge = horizontal ? .Leading : .Top
        let toEdge: ALEdge = horizontal ? .Trailing : .Bottom
        
        guard spacersEnabled else {
            // Set spacing without creating spacers
            let _ = views.reduce(nil as UIView?) { previous, current in
                if let previous = previous {
                    let constraint = current.autoPinEdge(fromEdge, toEdge: toEdge, ofView: previous, withOffset: spacing)
                    constraint.identifier = "ASV-spacing"
                    constraints.append(constraint)
                }
                return current
            }
            return
        }
        
        // Join views using spacers
        var spacers = [Spacer]()
        let _ = views.reduce(nil as UIView?) { previous, current in
            if let previous = previous {
                let spacer = Spacer()
                canvas.addSubview(spacer)
                spacers.append(spacer)
                constraints.append(spacer.autoPinEdge(fromEdge, toEdge: toEdge, ofView: previous))
                constraints.append(current.autoPinEdge(fromEdge, toEdge: toEdge, ofView: spacer))
            }
            return current
        }
        // Configure spacers
        let _ = spacers.reduce(nil as Spacer?) { previous, current in
            let dimension: ALDimension = horizontal ? .Width : .Height
            constraints.append(current.autoSetDimension(dimension, toSize: spacing, relation: (type == .EqualSpacing ? .Equal : .GreaterThanOrEqual)))
            if let previous = previous {
                constraints.append(current.autoMatchDimension(dimension, toDimension: dimension, ofView: previous))
            }
            return current
        }
    }
    
    var spacersEnabled: Bool {
        return type == .EqualSpacing
    }
    
    func updateCanvasConnectingCostraints() {
        guard let first = views.first, last = views.last else {
            return
        }
        let leadingEdge: ALEdge = horizontal ? .Leading : .Top
        let trailingEdge: ALEdge = horizontal ? .Trailing : .Bottom
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
        guard type == .FillEqually else {
            return
        }
        let _ = views.reduce(nil as UIView?) { previous, current in
            let dimension: ALDimension = horizontal ? .Width : .Height
            if let previous = previous {
                constraints.append(previous.autoMatchDimension(dimension, toDimension: dimension, ofView: current))
            }
            return current
        }
    }
}

private class Spacer: UIView {
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: 0, height: 0)
    }
}
