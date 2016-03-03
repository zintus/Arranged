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
        // FIXME: Make sure that behavior matches UIStackView
        if view.superview != view && !arrangedSubviews.contains(view) {
            arrangedSubviews.append(view)
            addSubview(view)
            invalidateLayout()
        }
    }

    public func removeArrangedSubview(view: UIView) {
        // FIXME: Make sure that behavior matches UIStackView
        if let index = arrangedSubviews.indexOf(view) {
            arrangedSubviews.removeAtIndex(index)
            invalidateLayout()
        }
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
            
            alignmentArrangement.items = arrangedSubviews
            alignmentArrangement.axis = axis
            alignmentArrangement.marginsEnabled = layoutMarginsRelativeArrangement
            
            alignmentArrangement.type = alignment
            
            distributionArrangement.items = arrangedSubviews
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
    var items = [UIView]() // Arranged views
    
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

    func save(constraint: NSLayoutConstraint) {
        constraints.append(constraint)
    }
}

private class AlignedLayoutArrangement: LayoutArrangement {
    var type: StackViewAlignment = .Fill
    
    override func updateConstraints() {
        super.updateConstraints()
        items.forEach { item in
            switch type {
            case .Fill:
                save(pinToLeadingEdge(item, relation: .Equal))
                save(pinToTrailingEdge(item, relation: .Equal))
            case .Leading, .Trailing:
                save(pinToLeadingEdge(item, relation: (type == .Leading ? .Equal : .GreaterThanOrEqual)))
                save(pinToTrailingEdge(item, relation: (type == .Leading ? .GreaterThanOrEqual : .Equal)))
            case .Center:
                save(pinToLeadingEdge(item, relation: .GreaterThanOrEqual))
                let attribute: ALAttribute = marginsEnabled ? (horizontal ? .MarginAxisHorizontal : .MarginAxisVertical) : (horizontal ? .Horizontal : .Vertical)
                save(item.autoConstrainAttribute(attribute, toAttribute: attribute, ofView: canvas))
            case .FirstBaseline, .LastBaseline: break
            }
        }
        if type == .FirstBaseline || type == .LastBaseline {
            items.forPair { previous, current in
                assert(!horizontal, "baseline alignment not supported for vertical layout axis")
                save(previous.autoAlignAxis((type == .FirstBaseline ? .FirstBaseline : .LastBaseline), toSameAxisOfView: current))
            }
        }
    }

    func pinToLeadingEdge(item: UIView, relation: NSLayoutRelation) -> NSLayoutConstraint {
        let edge: ALEdge = horizontal ? .Top : .Leading
        let constraint = marginsEnabled ? item.autoPinEdgeToSuperviewMargin(edge, relation: relation) : item.autoPinEdgeToSuperviewEdge(edge, withInset: 0, relation: relation)
        constraint.identifier = "ASV-canvas-connection"
        return constraint
    }

    func pinToTrailingEdge(item: UIView, relation: NSLayoutRelation) -> NSLayoutConstraint {
        let edge: ALEdge = horizontal ? .Bottom : .Trailing
        let constraint = marginsEnabled ? item.autoPinEdgeToSuperviewMargin(edge, relation: relation) : item.autoPinEdgeToSuperviewEdge(edge, withInset: 0, relation: relation)
        constraint.identifier = "ASV-canvas-connection"
        return constraint
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
        // FIXME: Don't remove all spacers
        canvas.subviews.filter{ $0 is Spacer }.forEach{ $0.removeFromSuperview() }

        guard type != .EqualSpacing else {
            self.updateFillEquallyConstraints()
            return
        }

        // Set spacing without creating spacers
        let fromEdge: ALEdge = horizontal ? .Leading : .Top
        let toEdge: ALEdge = horizontal ? .Trailing : .Bottom
        items.forPair {  previous, current in
            let constraint = current.autoPinEdge(fromEdge, toEdge: toEdge, ofView: previous, withOffset: spacing)
            constraint.identifier = "ASV-spacing"
            save(constraint)
        }
        return
    }

    func updateFillEquallyConstraints() {
        let fromEdge: ALEdge = horizontal ? .Leading : .Top
        let toEdge: ALEdge = horizontal ? .Trailing : .Bottom

        // Join views using spacer
        var spacers = [Spacer]()
        items.forPair { previous, current in
            let spacer = Spacer()
            canvas.addSubview(spacer)
            spacers.append(spacer)

            save(current.autoPinEdge(fromEdge, toEdge: toEdge, ofView: previous, withOffset: spacing, relation: .GreaterThanOrEqual))

            // Join views using spacer
            save(spacer.autoPinEdge(fromEdge, toEdge: toEdge, ofView: previous))
            save(current.autoPinEdge(fromEdge, toEdge: toEdge, ofView: spacer))
        }

        // Match spacers size
        spacers.forPair { previous, current in
            let dimension: ALDimension = horizontal ? .Width : .Height
            let constraint = current.autoMatchDimension(dimension, toDimension: dimension, ofView: previous)
            constraint.identifier = "ASV-fill-equally"
            save(constraint)
        }
    }

    func updateCanvasConnectingCostraints() {
        guard let first = items.first, last = items.last else {
            return
        }
        let leadingEdge: ALEdge = horizontal ? .Leading : .Top
        let trailingEdge: ALEdge = horizontal ? .Trailing : .Bottom
        if marginsEnabled {
            save(first.autoPinEdgeToSuperviewMargin(leadingEdge))
            save(last.autoPinEdgeToSuperviewMargin(trailingEdge))
        } else {
            save(first.autoPinEdgeToSuperviewEdge(leadingEdge))
            save(last.autoPinEdgeToSuperviewEdge(trailingEdge))
        }
    }

    func updateDistributionConstraints() {
        // FIXME: Cleanup
        guard type == .FillEqually else {
            return
        }
        items.forPair { previous, current in
            let dimension: ALDimension = horizontal ? .Width : .Height
            save(previous.autoMatchDimension(dimension, toDimension: dimension, ofView: current))
        }
    }
}

private class Spacer: UIView {
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: 0, height: 0)
    }
}

private extension SequenceType {
    // FIXME: Name might be misleading, it doesn't enumerate over all combinations
    func forPair(@noescape closure: (first: Self.Generator.Element, second: Self.Generator.Element) -> Void) {
        let _ = reduce(nil as Self.Generator.Element?) { previous, current in
            if let previous = previous {
                closure(first: previous, second: current)
            }
            return current
        }
    }
}
