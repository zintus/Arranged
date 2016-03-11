// The MIT License (MIT)
//
// Copyright (c) 2016 Alexander Grebenyuk (github.com/kean).

import UIKit

/** The layout that defines the size and position of the arranged views along the stack view’s axis.
*/
public enum StackViewDistribution {
    /** A layout where the stack view resizes its arranged views so that they fill the available space along the stack view’s axis.
     */
    case Fill
    
    /** A layout where the stack view resizes its arranged views so that they fill the available space along the stack view’s axis. The views are resized so that they are all the same size along the stack view’s axis.
     */
    case FillEqually
    
    /** A layout where the stack view resizes its arranged views so that they fill the available space along the stack view’s axis. Views are resized proportionally based on their intrinsic content size along the stack view’s axis.
     */
    case FillProportionally
    
    /** A layout where the stack view positions its arranged views so that they fill the available space along the stack view’s axis. When the arranged views do not fill the stack view, it pads the spacing between the views evenly.
     */
    case EqualSpacing
    
    /** A layout that attempts to position the arranged views so that they have an equal center-to-center spacing along the stack view’s axis, while maintaining the spacing property’s distance between views.
     */
    case EqualCentering
}


/** Alignment—the layout transverse to the stacking axis.
 */
public enum StackViewAlignment {
    /** A layout where the stack view resizes its arranged views so that they fill the available space perpendicular to the stack view’s axis.
     */
    case Fill
    
    /** A layout for vertical stacks where the stack view aligns the leading edge of its arranged views along its leading edge. This is equivalent to the `StackViewAlignment.Top` alignment for horizontal stacks.
     */
    case Leading
    
    /** A layout for horizontal stacks where the stack view aligns the top edge of its arranged views along its top edge. This is equivalent to the `StackViewAlignment.Leading` alignment for vertical stacks.
     */
    public static var Top: StackViewAlignment {
        return .Leading
    }
    
    /** A layout where the stack view aligns its arranged views based on their first baseline. This alignment is only valid for horizontal stacks.
     */
    case FirstBaseline
    
    /** A layout where the stack view aligns the center of its arranged views with its center along its axis.
     */
    case Center
    
    /** A layout for vertical stacks where the stack view aligns the trailing edge of its arranged views along its trailing edge. This is equivalent to the `StackViewAlignment.Bottom` alignment for horizontal stacks.
     */
    case Trailing
    
    /** A layout for horizontal stacks where the stack view aligns the bottom edge of its arranged views along its bottom edge. This is equivalent to the `StackViewAlignment.Trailing` alignment for vertical stacks.
     */
    public static var Bottom: StackViewAlignment {
        return .Trailing
    }
    
    /** A layout where the stack view aligns its arranged views based on their last baseline. This alignment is only valid for horizontal stacks.
     */
    case LastBaseline
}

/**
The StackView class provides a streamlined interface for laying out a collection of views in either a column or a row. Stack views let you leverage the power of Auto Layout, creating user interfaces that can dynamically adapt to the device’s orientation, screen size, and any changes in the available space. The stack view manages the layout of all the views in its `arrangedSubviews` property. These views are arranged along the stack view’s `axis`, based on their order in the `arrangedSubviews` array. The exact layout varies depending on the stack view’s `axis`, `distribution`, `alignment`, `spacing`, and other properties.
 
 See UIStackView documentation for more info.
*/
public class StackView : UIView {
    
    /// The axis along which the arranged views are laid out.
    public var axis: UILayoutConstraintAxis = .Horizontal {
        didSet { if axis != oldValue { invalidateLayout() } }
    }
    
    /// The distribution of the arranged views along the stack view’s axis.
    public var distribution: StackViewDistribution = .Fill {
        didSet { if distribution != oldValue { invalidateLayout() } }
    }
    
    /// The alignment of the arranged subviews perpendicular to the stack view’s axis.
    public var alignment: StackViewAlignment = .Fill {
        didSet { if alignment != oldValue { invalidateLayout() } }
    }
    
    /// The distance in points between the adjacent edges of the stack view’s arranged views.
    public var spacing: CGFloat = 0.0 {
        didSet { if spacing != oldValue { invalidateLayout() } }
    }
    
    /// A Boolean value that determines whether the vertical spacing between views is measured from their baselines.
    public var baselineRelativeArrangement = false {
        didSet { if baselineRelativeArrangement != oldValue { invalidateLayout() } }
    }
    
    /// A Boolean value that determines whether the stack view lays out its arranged views relative to its layout margins.
    public var layoutMarginsRelativeArrangement = false {
        didSet { if layoutMarginsRelativeArrangement != oldValue { invalidateLayout() } }
    }

    /// The list of views arranged by the stack view.
    public private(set) var arrangedSubviews = [UIView]()
    
    private var alignmentArrangement: AlignedLayoutArrangement!
    private var distributionArrangement: DistributionLayoutArrangement!
    private var invalidated = false
    private var hiddenViews = Set<UIView>()
    
    /// Returns a new stack view object that manages the provided views.
    public init(arrangedSubviews views: [UIView]) {
        super.init(frame: CGRectZero)
        commonInit(views: views)
    }

    /// Returns a new stack view object.
    public convenience init() {
        self.init(arrangedSubviews: [])
    }
    
    /// Returns a new stack view object.
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(views: [])
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
    
    /**
    Adds a view to the end of the arrangedSubviews array.
    
    The stack view ensures that the arrangedSubviews array is always a subset of its subviews array. This method automatically adds the provided view as a subview of the stack view, if it is not already. If the view is already a subview, this operation does not alter the subview ordering.
    */
    public func addArrangedSubview(view: UIView) {
        insertArrangedSubview(view, atIndex: arrangedSubviews.count)
    }
    
    /**
     Removes the provided view from the stack’s array of arranged subviews.
     
     This method removes the provided view from the stack’s arrangedSubviews array. The view’s position and size will no longer be managed by the stack view. However, this method does not remove the provided view from the stack’s subviews array; therefore, the view is still displayed as part of the view hierarchy.
     */
    public func removeArrangedSubview(view: UIView) {
        if let index = arrangedSubviews.indexOf(view) {
            arrangedSubviews.removeAtIndex(index)
            hiddenViews.remove(view)
            invalidateLayout()
        }
    }
    
    /**
     Adds the provided view to the array of arranged subviews at the specified index.
     
     If index is already occupied, the stack view increases the size of the arrangedSubviews array and shifts all of its contents at the index and above to the next higher space in the array. Then the stack view stores the provided view at the index.
     
     The stack view also ensures that the arrangedSubviews array is always a subset of its subviews array. This method automatically adds the provided view as a subview of the stack view, if it is not already. When adding subviews, the stack view appends the view to the end of its subviews array. The index only affects the order of views in the arrangedSubviews array. It does not affect the ordering of views in the subviews array.
     */
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
    
    /// Removes subview from arranged subviews.
    public override func willRemoveSubview(subview: UIView) {
        removeArrangedSubview(subview)
    }
    
    // MARK: Hiding Views
    
    /// Updates stack view's layout to hide/show a given view. The view remains a subview of the stack view, but it's width (or height for vertical stack view) is reduced to 0. This method doesn't change view's `hidden` property.
    public func setArrangedView(view: UIView, hidden: Bool) {
        if hidden {
            hiddenViews.insert(view)
        } else {
            hiddenViews.remove(view)
        }
        invalidateLayout()
    }
    
    // MARK: Layout
    
    /**
    Invalidates stack view's layout.
    
    In general, you never need to call this method manually. The only reason to call it is when stack view's `distribution` is set to `.FillProportionally` and `intrinsicContentSize` of one of the arranged view changes.
    */
    public func invalidateLayout() {
        if !invalidated {
            invalidated = true
            setNeedsUpdateConstraints()
        }
    }

    /// Updates alignment and distribution constraints.
    public override func updateConstraints() {
        if invalidated {
            invalidated = false
            
            for arrangement in [alignmentArrangement, distributionArrangement] {
                arrangement.items = arrangedSubviews
                arrangement.axis = axis
                arrangement.marginsEnabled = layoutMarginsRelativeArrangement
                arrangement.hiddenItems = hiddenViews
            }
            
            distributionArrangement.type = distribution
            distributionArrangement.spacing = spacing
            distributionArrangement.baselineRelative = baselineRelativeArrangement && axis == .Vertical
            
            alignmentArrangement.type = alignment
            
            distributionArrangement.updateConstraints()
            alignmentArrangement.updateConstraints()
        }
        super.updateConstraints()
    }
    
    // MARK: Baseline Alignment
    
    // FIXME: Signal UIView when viewForFirst(Last)BaselineLayout changes.

    /// Returns first arranged view for vertical axis and self for horizontal axis.
    public override func viewForBaselineLayout() -> UIView {
        return _viewForFirstBaselineLayout
    }

    /// Returns first arranged view for vertical axis and self for horizontal axis.
    public override var viewForFirstBaselineLayout: UIView {
        return _viewForFirstBaselineLayout
    }
    
    private var _viewForFirstBaselineLayout: UIView {
        switch axis {
        case .Vertical:
            if let first = arrangedSubviews.first {
                if #available(iOS 9.0, *) {
                    return first.viewForFirstBaselineLayout
                } else {
                    return first.viewForBaselineLayout()
                }
            } else {
                return self
            }
            // FIXME: UIStackView: A horizontal stack view returns its tallest view (whatever that means)
        case .Horizontal: return self
        }
    }

    /// Returns last arranged view for vertical axis and self for horizontal axis.
    public override var viewForLastBaselineLayout: UIView {
        switch axis {
        case .Vertical:
            if let last = arrangedSubviews.last {
                if #available(iOS 9.0, *) {
                    return last.viewForLastBaselineLayout
                } else {
                    return last
                }
            } else {
                return self
            }
        case .Horizontal: return self
        }
    }
    
    // MARK: Misc

    /// Returns CATransformLayer class.
    public override class func layerClass() -> AnyClass {
        return CATransformLayer.self
    }

    /// Changing background color has no effect.
    public override var backgroundColor: UIColor? {
        get { return nil }
        set { return }
    }
}
