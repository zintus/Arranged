// The MIT License (MIT)
//
// Copyright (c) 2016 Alexander Grebenyuk (github.com/kean).

import UIKit

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
    public var baselineRelativeArrangement = false {
        didSet { if baselineRelativeArrangement != oldValue { invalidateLayout() } }
    }
    public var layoutMarginsRelativeArrangement = false {
        didSet { if layoutMarginsRelativeArrangement != oldValue { invalidateLayout() } }
    }
    
    private var alignmentArrangement: AlignedLayoutArrangement!
    private var distributionArrangement: DistributionLayoutArrangement!

    private var invalidated = false

    public private(set) var arrangedSubviews = [UIView]()
    private var hiddenViews = Set<UIView>()
    
    public init(arrangedSubviews views: [UIView]) {
        super.init(frame: CGRectZero)
        commonInit(views: views)
    }

    public convenience init() {
        self.init(arrangedSubviews: [])
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(views: subviews)
    }
    
    private func commonInit(views views: [UIView]) {
        layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        alignmentArrangement = AlignedLayoutArrangement(canvas: self)
        distributionArrangement = DistributionLayoutArrangement(canvas: self)
        views.forEach {
            addArrangedSubview($0)
        }
    }

    // MARK: Managing Arranged Views
    
    public func addArrangedSubview(view: UIView) {
        insertArrangedSubview(view, atIndex: arrangedSubviews.count)
    }

    public func removeArrangedSubview(view: UIView) {
        if let index = arrangedSubviews.indexOf(view) {
            arrangedSubviews.removeAtIndex(index)
            hiddenViews.remove(view)
            invalidateLayout()
        }
    }
    
    public func insertArrangedSubview(view: UIView, atIndex stackIndex: Int) {
        if !arrangedSubviews.contains(view) {
            view.translatesAutoresizingMaskIntoConstraints = false
            arrangedSubviews.insert(view, atIndex: stackIndex)
            if view.superview != self {
                addSubview(view)
            }
            invalidateLayout()
        }
    }
    
    // MARK: Hiding Views
    
    public func setView(view: UIView, hidden: Bool) {
        if hidden {
            hiddenViews.insert(view)
        } else {
            hiddenViews.remove(view)
        }
        invalidateLayout()
    }
    
    // MARK: Layout
    
    public func invalidateLayout() {
        if !invalidated {
            invalidated = true
            setNeedsUpdateConstraints()
        }
    }
    
    public override func updateConstraints() {
        if invalidated {
            invalidated = false
            
            for arrangement in [alignmentArrangement, distributionArrangement] {
                arrangement.items = arrangedSubviews
                arrangement.axis = axis
                arrangement.marginsEnabled = layoutMarginsRelativeArrangement
                arrangement.hiddenItems = hiddenViews
            }
            
            alignmentArrangement.type = alignment
            
            distributionArrangement.type = distribution
            distributionArrangement.spacing = spacing
            
            alignmentArrangement.updateConstraints()
            distributionArrangement.updateConstraints()
        }
        super.updateConstraints()
    }
}
