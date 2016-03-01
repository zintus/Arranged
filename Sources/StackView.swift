// The MIT License (MIT)
//
// Copyright (c) 2016 Alexander Grebenyuk (github.com/kean).

import Foundation
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
    public var axis: UILayoutConstraintAxis = .Horizontal
    public var distribution: StackViewDistribution = .Fill
    public var alignment: StackViewAlignment = .Fill
    public var spacing: CGFloat = 0.0
    
    // FIXME:
    public var baselineRelativeArrangement = false
    public var layoutMarginsRelativeArrangement = false
    
    private var invalidated = false
    
    public private(set) var arrangedSubviews: [UIView]
    
    public init(arrangedSubviews views: [UIView]) {
        self.arrangedSubviews = views
        super.init(frame: CGRectZero)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        
        self.arrangedSubviews = []
        super.init(coder: aDecoder)
        
        // FIXME:
        self.subviews.forEach{ $0.removeFromSuperview() }
        self.subviews.forEach{ self.addArrangedSubview($0) }
    }
    
    public func addArrangedSubview(view: UIView) {
        if view.superview != view {
            self.arrangedSubviews.append(view)
            self.addSubview(view)
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
        // FIXME: Add constraints
    }
}
