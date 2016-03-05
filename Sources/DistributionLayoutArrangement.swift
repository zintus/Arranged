// The MIT License (MIT)
//
// Copyright (c) 2016 Alexander Grebenyuk (github.com/kean).

import UIKit

class DistributionLayoutArrangement: LayoutArrangement {
    var type: StackViewDistribution = .Fill
    var spacing: CGFloat = 0

    override func updateConstraints() {
        super.updateConstraints()

        updateCanvasConnectingCostraints()
        updateSpacingConstraints()
        updateDistributionConstraints()
    }

    private func updateSpacingConstraints() {
        // FIXME: Don't remove all spacers
        canvas.subviews.filter{ $0 is LayoutSpacer }.forEach{ $0.removeFromSuperview() }

        switch type {
        case .EqualSpacing, .EqualCentering:
            updateLayoutSpacers()
        case .Fill, .FillEqually:
            // Set spacing without creating spacers
            items.forPair {  previous, current in
                addSpacing(current: current, previous: previous)
            }
        case .FillProportionally:
            print(".FillProportionally not implemented")
        }
    }

    private func updateLayoutSpacers() {
        // Join views using spacer
        var spacers = [LayoutSpacer]()
        items.forPair { previous, current in
            let spacer = LayoutSpacer()
            spacer.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(spacer)
            spacers.append(spacer)

            addSpacing(current: current, previous: previous, relation: .GreaterThanOrEqual)

            // Join views using spacer
            let leadingAttr: NSLayoutAttribute = horizontal ? .Leading : .Top
            let trailingAttr: NSLayoutAttribute = horizontal ? .Trailing : .Bottom
            let centerAttr: NSLayoutAttribute = horizontal ? .CenterX : .CenterY
            if type == .EqualCentering {
                // Spacers are joined to the centers of the views
                connectItem(spacer, attribute: leadingAttr, toItem: previous, attribute: centerAttr)
                connectItem(spacer, attribute: trailingAttr, toItem: current, attribute: centerAttr)
            } else {
                connectItem(spacer, attribute: leadingAttr, toItem: previous, attribute: trailingAttr)
                connectItem(spacer, attribute: trailingAttr, toItem: current, attribute: leadingAttr)
            }
        }

        // Match spacers size
        spacers.forPair { previous, current in
            addConstraint(item: previous, attribute: (horizontal ? .Width : .Height), toItem: current).identifier = "ASV-equal-spacers"
        }
    }

    private func addSpacing(current current: UIView, previous: UIView, relation: NSLayoutRelation = .Equal) {
        addConstraint(item: current, attribute: (horizontal ? .Leading : .Top), toItem: previous, attribute: (horizontal ? .Trailing : .Bottom), relation: relation, constant: spacing).identifier = "ASV-spacing"
    }

    private func connectItem(item1: UIView, attribute attr1: NSLayoutAttribute, toItem item2: UIView, attribute attr2: NSLayoutAttribute) {
        addConstraint(item: item1, attribute: attr1, toItem: item2, attribute: attr2).identifier = "AVS-spacer-connection"
    }

    private func updateCanvasConnectingCostraints() {
        if let first = items.first, last = items.last {
            connectToCanvas(first, attribute: horizontal ? .Leading : .Top)
            connectToCanvas(last, attribute: horizontal ? .Trailing : .Bottom)
        }
    }

    private func updateDistributionConstraints() {
        // FIXME: Cleanup
        guard type == .FillEqually else {
            return
        }
        items.forPair { previous, current in
            addConstraint(item: previous, attribute: (horizontal ? .Width : .Height), toItem: current)
        }
    }
}
