// The MIT License (MIT)
//
// Copyright (c) 2016 Alexander Grebenyuk (github.com/kean).

import Arranged
import UIKit
import XCTest

func assertEqualConstraints(constraints1: [NSLayoutConstraint], _ constraints2: [NSLayoutConstraint]) -> Bool {
    func filterOutMarginContraints(constraints: [NSLayoutConstraint]) -> [NSLayoutConstraint] {
        return constraints.filter {
            return $0.identifier?.hasSuffix("Margin-guide-constraint") == false
        }
    }
    // We fitler out margin-guide constraints because Arranged.StackView doesn't use those
    return _assertEqualConstraints(filterOutMarginContraints(constraints1), filterOutMarginContraints(constraints2))
}

func _assertEqualConstraints(constraints1: [NSLayoutConstraint], _ constraints2: [NSLayoutConstraint]) -> Bool {
    guard constraints1.count == constraints2.count else {
        XCTFail("Constraints count doesnt match: \(toString(constraints1, constraints2))")
        return false
    }
    
    var array1 = constraints1
    var array2 = constraints2
    
    while let c1 = array1.popLast() {
        let idx2 = array2.indexOf { c2 in
            return isEqual(c1, c2)
        }
        guard let unpackedIdx2 = idx2 else {
            XCTFail("Couldn't find matching constraint for \(c1) \(toString(constraints1, constraints2))")
            return false
        }
        array2.removeAtIndex(unpackedIdx2)
    }
    
    guard array1.count == 0 && array2.count == 0 else {
        XCTFail("Failed to match all constraints: \(toString(constraints1, constraints2))")
        return false
    }
    
    return true
}

// MARK: Constrain Comparison

func isEqual(lhs: NSLayoutConstraint, _ rhs: NSLayoutConstraint) -> Bool {
    func identifier(constraint: NSLayoutConstraint) -> String? {
        return constraint.identifier?.stringByReplacingOccurrencesOfString("ASV-", withString: "UISV-")
    }
    
    guard identifier(lhs) == identifier(rhs) else {
        return false
    }
    
    // For now we just make sure that we create the equivalent number of constraints with the same type
    return true
    
    // FIXME: Fix comparison
    func isEqual(item1: AnyObject?, _ item2: AnyObject?) -> Bool {
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
        if let view1 = item1 as? UIView, view2 = item2 as? UIView {
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
    return lhs.relation == rhs.relation &&
        lhs.constant == rhs.constant &&
        lhs.multiplier == rhs.multiplier &&
        lhs.priority == rhs.priority
}


// MARK: Misc

func constraintsFor(view: UIView) -> [NSLayoutConstraint] {
    var constraints = [NSLayoutConstraint]()
    constraints.appendContentsOf(view.constraints)
    for subview in view.subviews {
        constraints.appendContentsOf(subview.constraints)
    }
    return constraints
}

var constraintsPrinted = 0
let maxConstraintsPrinted = 50

func toString(constraints1: [NSLayoutConstraint], _ constraints2: [NSLayoutConstraint]) -> String {
    constraintsPrinted++
    guard constraintsPrinted < maxConstraintsPrinted else {
        return ""
    }
    func toString(constraints: [NSLayoutConstraint]) -> String {
        var string = String()
        constraints.forEach {
            string.appendContentsOf("\n\($0)")
        }
        return string
    }
    var string = String()
    [constraints1, constraints2].enumerate().forEach {
        string.appendContentsOf("\n\nConstraints \($0+1) (count: \($1.count)):\n")
        string.appendContentsOf(toString($1))
    }
    string.appendContentsOf("\n")
    return string
}

extension UIStackViewAlignment {
    var toString: String {
        switch self {
        case .Fill: return ".Fill"
        case .Leading: return ".Leading"
        case .FirstBaseline: return ".FirstBaseline"
        case .Center: return ".Center"
        case .LastBaseline: return ".LastBaseline"
        case .Trailing: return ".Trailing"
        }
    }
}

extension UIStackViewDistribution {
    var toString: String {
        switch self {
        case .Fill: return ".Fill"
        case .FillEqually: return ".FillEqually"
        case .FillProportionally: return ".FillProportionally"
        case .EqualSpacing: return ".EqualSpacing"
        case .EqualCentering: return ".EqualCentering"
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
