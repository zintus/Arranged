// The MIT License (MIT)
//
// Copyright (c) 2016 Alexander Grebenyuk (github.com/kean).

import UIKit

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
            view.translatesAutoresizingMaskIntoConstraints = false
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
