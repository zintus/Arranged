// The MIT License (MIT)
//
// Copyright (c) 2016 Alexander Grebenyuk (github.com/kean).

import UIKit

class LayoutArrangement {
    weak var canvas: UIView!
    var items = [UIView]() // Arranged views
    var hiddenItems = Set<UIView>()
    var visibleItems = Array<UIView>()
    
    var axis: UILayoutConstraintAxis = .Horizontal
    var horizontal: Bool { return axis == .Horizontal }
    var marginsEnabled: Bool = false

    private var constraints = [NSLayoutConstraint]()

    init(canvas: StackView) {
        self.canvas = canvas
    }

    func updateConstraints() {
        visibleItems = items.filter { return !isHidden($0) }
        NSLayoutConstraint.deactivateConstraints(constraints)
        constraints.removeAll()
    }
    
    func constraint(item item1: UIView,
        attribute attr1: NSLayoutAttribute,
        toItem item2: UIView? = nil,
        attribute attr2: NSLayoutAttribute? = nil,
        relation: NSLayoutRelation = .Equal,
        multiplier: CGFloat = 1,
        constant c: CGFloat = 0,
        priority: UILayoutPriority? = nil,
        identifier: String) -> NSLayoutConstraint
    {
        let constraint = NSLayoutConstraint(item: item1, attribute: attr1, relatedBy: relation, toItem: item2, attribute: (attr2 != nil ? attr2! : attr1), multiplier: multiplier, constant: c)
        if let priority = priority {
            constraint.priority = priority
        }
        constraint.identifier = identifier
        (item2 != nil ? canvas : item1).addConstraint(constraint)
        return constraint
    }
    
    func add(constraint: NSLayoutConstraint) {
        constraints.append(constraint)
    }
    
    // MARK: Helpers
    
    func isHidden(item: UIView) -> Bool {
        return hiddenItems.contains(item)
    }
}
