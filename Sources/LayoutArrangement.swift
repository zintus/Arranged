// The MIT License (MIT)
//
// Copyright (c) 2016 Alexander Grebenyuk (github.com/kean).

import UIKit
import PureLayout

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
}
