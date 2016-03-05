// The MIT License (MIT)
//
// Copyright (c) 2016 Alexander Grebenyuk (github.com/kean).

import UIKit

class LayoutArrangement {
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
    
    func addConstraint(item item1: UIView, attribute attr1: NSLayoutAttribute, toItem item2: UIView? = nil, attribute attr2: NSLayoutAttribute? = nil, relation: NSLayoutRelation = .Equal, multiplier: CGFloat = 1, constant c: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: item1, attribute: attr1, relatedBy: relation, toItem: item2, attribute: (attr2 != nil ? attr2! : attr1), multiplier: multiplier, constant: c)
        constraint.identifier = "AVS-constraint"
        constraints.append(constraint)
        canvas.addConstraint(constraint)
        return constraint
    }
    
    // MARK: Constraint Helpers
    
    func connectToCanvas(item: UIView, attribute attr: NSLayoutAttribute, equal: Bool = true) {
        let relation: NSLayoutRelation = equal ? .Equal : .LessThanOrEqual
        let canvasAttr = marginsEnabled ? marginForAttribute(attr) : attr
        if attr == .Top || attr == .Left || attr == .Leading {
            addConstraint(item: canvas, attribute: canvasAttr, toItem: item, attribute: attr, relation: relation).identifier = "AVS-canvas-connection"
        } else {
            addConstraint(item: item, attribute: attr, toItem: canvas, attribute: canvasAttr, relation: relation).identifier = "AVS-canvas-connection"
        }
    }
    
    private func marginForAttribute(attr: NSLayoutAttribute) -> NSLayoutAttribute {
        switch attr {
        case .Left: return .LeftMargin
        case .Right: return .RightMargin
        case .Top: return .TopMargin
        case .Bottom: return .BottomMargin
        case .Leading: return .LeadingMargin
        case .Trailing: return .TrailingMargin
        case .CenterX: return .CenterXWithinMargins
        case .CenterY: return .CenterYWithinMargins
        default: return attr
        }
    }
}
