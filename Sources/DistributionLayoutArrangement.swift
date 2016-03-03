// The MIT License (MIT)
//
// Copyright (c) 2016 Alexander Grebenyuk (github.com/kean).

import UIKit
import PureLayout

class DistributionLayoutArrangement: LayoutArrangement {
    var type: StackViewDistribution = .Fill
    var spacing: CGFloat = 0

    override func updateConstraints() {
        super.updateConstraints()

        updateSpacingConstraints()
        updateCanvasConnectingCostraints()
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
                save(addSpacing(current: current, previous: previous))
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
            canvas.addSubview(spacer)
            spacers.append(spacer)

            save(addSpacing(current: current, previous: previous, relation: .GreaterThanOrEqual))

            // Join views using spacer
            let leadingAttribute: ALAttribute = horizontal ? .Leading : .Top
            let trailingAttribute: ALAttribute = horizontal ? .Trailing : .Bottom
            let centerAttribute: ALAttribute = horizontal ? .Vertical : .Horizontal
            if type == .EqualCentering {
                // Spacers are joined to the centers of the views
                save(pinSpacer(spacer, attribute: leadingAttribute, toAttribute: centerAttribute, ofView: previous))
                save(pinSpacer(spacer, attribute: trailingAttribute, toAttribute: centerAttribute, ofView: current))
            } else {
                save(pinSpacer(spacer, attribute: leadingAttribute, toAttribute: trailingAttribute, ofView: previous))
                save(pinSpacer(spacer, attribute: trailingAttribute, toAttribute: leadingAttribute, ofView: current))
            }
        }

        // Match spacers size
        spacers.forPair { previous, current in
            let dimension: ALDimension = horizontal ? .Width : .Height
            let constraint = current.autoMatchDimension(dimension, toDimension: dimension, ofView: previous)
            constraint.identifier = "ASV-equal-spacers"
            save(constraint)
        }
    }

    private func addSpacing(current current: UIView, previous: UIView, relation: NSLayoutRelation = .Equal) -> NSLayoutConstraint {
        let fromEdge: ALEdge = horizontal ? .Leading : .Top
        let toEdge: ALEdge = horizontal ? .Trailing : .Bottom
        let constraint = current.autoPinEdge(fromEdge, toEdge: toEdge, ofView: previous, withOffset: spacing, relation: relation)
        constraint.identifier = "ASV-spacing"
        return constraint
    }

    private func pinSpacer(spacer: LayoutSpacer, attribute: ALAttribute, toAttribute: ALAttribute, ofView view: UIView) -> NSLayoutConstraint {
        let constraint = spacer.autoConstrainAttribute(attribute, toAttribute: toAttribute, ofView: view)
        constraint.identifier = "AVS-spacer-connection"
        return constraint
    }

    private func updateCanvasConnectingCostraints() {
        guard let first = items.first, last = items.last else {
            return
        }
        let leadingEdge: ALEdge = horizontal ? .Leading : .Top
        let trailingEdge: ALEdge = horizontal ? .Trailing : .Bottom
        if marginsEnabled {
            save(first.autoPinEdgeToSuperviewMargin(leadingEdge))
            save(last.autoPinEdgeToSuperviewMargin(trailingEdge))
        } else {
            save(first.autoPinEdgeToSuperviewEdge(leadingEdge))
            save(last.autoPinEdgeToSuperviewEdge(trailingEdge))
        }
    }

    private func updateDistributionConstraints() {
        // FIXME: Cleanup
        guard type == .FillEqually else {
            return
        }
        items.forPair { previous, current in
            let dimension: ALDimension = horizontal ? .Width : .Height
            save(previous.autoMatchDimension(dimension, toDimension: dimension, ofView: current))
        }
    }
}
