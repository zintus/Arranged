// The MIT License (MIT)
//
// Copyright (c) 2016 Alexander Grebenyuk (github.com/kean).

import Arranged
import UIKit
import XCTest

func assertEqualConstraints(_ constraints1: [NSLayoutConstraint], _ constraints2: [NSLayoutConstraint]) -> Bool {
    func filterOutMarginContraints(_ constraints: [NSLayoutConstraint]) -> [NSLayoutConstraint] {
        return constraints.filter {
            return $0.identifier?.hasSuffix("Margin-guide-constraint") == false
        }
    }
    // We fitler out margin-guide constraints because Arranged.StackView doesn't use those
    return _assertEqualConstraints(filterOutMarginContraints(constraints1), filterOutMarginContraints(constraints2))
}

func _assertEqualConstraints(_ constraints1: [NSLayoutConstraint], _ constraints2: [NSLayoutConstraint]) -> Bool {
    guard constraints1.count == constraints2.count else {
        XCTFail("Constraints count doesn't match")
        return false
    }
    
    var array1 = constraints1
    var array2 = constraints2
    
    while let c1 = array1.popLast() {
        let idx2 = array2.index { c2 in
            return isEqual(c1, c2)
        }
        guard let unpackedIdx2 = idx2 else {
            XCTFail("Couldn't find matching constraint for \(c1)")
            return false
        }
        array2.remove(at: unpackedIdx2)
    }
    
    guard array1.count == 0 && array2.count == 0 else {
        XCTFail("Failed to match all constraints")
        return false
    }
    
    return true
}

// MARK: Constrain Comparison

func isEqual(_ lhs: NSLayoutConstraint, _ rhs: NSLayoutConstraint) -> Bool {
    func identifier(_ constraint: NSLayoutConstraint) -> String? {
        return constraint.identifier?.replacingOccurrences(of: "ASV-", with: "UISV-")
    }
    
    guard identifier(lhs) == identifier(rhs) else {
        return false
    }
        
    func isEqual(_ item1: AnyObject?, _ item2: AnyObject?) -> Bool {
        // True if both nil
        if item1 == nil && item2 == nil {
            return true
        }
        // True if both items are stack views
        if ((item1 is UIStackView && item2 is Arranged.StackView) ||
            (item1 is Arranged.StackView && item2 is UIStackView)) {
            return true
        }
        // True if both are for content views with the same indexes
        if let view1 = item1 as? UIView, let view2 = item2 as? UIView {
            return view1.test_isContentView && view2.test_isContentView && view1.tag == view2.tag
        }
        // FIXME: Find a better way to test layout guides
        // Assume that the remaining items are spacers, we can't check really
        return item1 != nil && item2 != nil
    }
    guard isEqual(lhs.firstItem, rhs.firstItem) &&
        isEqual(lhs.secondItem, rhs.secondItem) else {
            return false
    }    
    return lhs.firstAttribute == rhs.firstAttribute &&
        lhs.secondAttribute == rhs.secondAttribute &&
        lhs.relation == rhs.relation &&
        lhs.constant == rhs.constant &&
        lhs.multiplier == rhs.multiplier &&
        lhs.priority == rhs.priority
}


// MARK: Misc

func constraintsFor(_ view: UIView) -> [NSLayoutConstraint] {
    var constraints = [NSLayoutConstraint]()
    constraints.append(contentsOf: view.constraints)
    for subview in view.subviews {
        constraints.append(contentsOf: subview.constraints)
    }
    return constraints
}

extension UIStackViewAlignment {
    var toString: String {
        switch self {
        case .fill: return ".Fill"
        case .leading: return ".Leading"
        case .firstBaseline: return ".FirstBaseline"
        case .center: return ".Center"
        case .lastBaseline: return ".LastBaseline"
        case .trailing: return ".Trailing"
        }
    }
}

extension UIStackViewDistribution {
    var toString: String {
        switch self {
        case .fill: return ".Fill"
        case .fillEqually: return ".FillEqually"
        case .fillProportionally: return ".FillProportionally"
        case .equalSpacing: return ".EqualSpacing"
        case .equalCentering: return ".EqualCentering"
        }
    }
}


private struct AssociatedKeys {
    static var IsContentView = "Arranged.Test.IsContentView"
}

extension UIView {
    var test_isContentView: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.IsContentView) != nil
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.IsContentView, true, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
