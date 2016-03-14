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
    var marginsEnabled: Bool = false

    private var constraints = [NSLayoutConstraint]()

    init(canvas: StackView) {
        self.canvas = canvas
    }

    func updateConstraints() {
        visibleItems = items.filter { return !isHidden($0) }
        NSLayoutConstraint.deactivateConstraints(constraints.filter { return $0.active })
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
        constraints.append(constraint)
        return constraint
    }
    
    // MARK: Helpers
    
    func isHidden(item: UIView) -> Bool {
        return hiddenItems.contains(item)
    }
    
    func addCanvasFitConstraint(attribute attribute: NSLayoutAttribute) {
        constraint(item: canvas, attribute: attribute, constant: 0, priority: 49, identifier: "ASV-canvas-fit")
    }
    
    func connectToCanvas(item: UIView, attribute attr: NSLayoutAttribute, weak: Bool = false) {
        let relation = connectionRelation(attr, weak: weak)
        constraint(item: canvas, attribute: (marginsEnabled ? attr.toMargin : attr), toItem: item, attribute: attr, relation: relation, identifier: "ASV-canvas-connection")
    }
    
    func connectionRelation(attr: NSLayoutAttribute, weak: Bool) -> NSLayoutRelation {
        if !weak { return .Equal }
        return (attr == .Top || attr == .Left || attr == .Leading) ? .LessThanOrEqual : .GreaterThanOrEqual
    }
}
