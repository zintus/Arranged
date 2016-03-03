// The MIT License (MIT)
//
// Copyright (c) 2016 Alexander Grebenyuk (github.com/kean).

import UIKit
import PureLayout

class AlignedLayoutArrangement: LayoutArrangement {
    var type: StackViewAlignment = .Fill

    override func updateConstraints() {
        super.updateConstraints()
        items.forEach { item in
            switch type {
            case .Fill:
                save(pinToLeadingEdge(item, relation: .Equal))
                save(pinToTrailingEdge(item, relation: .Equal))
            case .Leading, .Trailing:
                save(pinToLeadingEdge(item, relation: (type == .Leading ? .Equal : .GreaterThanOrEqual)))
                save(pinToTrailingEdge(item, relation: (type == .Leading ? .GreaterThanOrEqual : .Equal)))
            case .Center:
                save(pinToLeadingEdge(item, relation: .GreaterThanOrEqual))
                let attribute: ALAttribute = marginsEnabled ? (horizontal ? .MarginAxisHorizontal : .MarginAxisVertical) : (horizontal ? .Horizontal : .Vertical)
                save(item.autoConstrainAttribute(attribute, toAttribute: attribute, ofView: canvas))
            case .FirstBaseline, .LastBaseline: break
            }
        }
        if type == .FirstBaseline || type == .LastBaseline {
            items.forPair { previous, current in
                assert(!horizontal, "baseline alignment not supported for vertical layout axis")
                save(previous.autoAlignAxis((type == .FirstBaseline ? .FirstBaseline : .LastBaseline), toSameAxisOfView: current))
            }
        }
    }

    private func pinToLeadingEdge(item: UIView, relation: NSLayoutRelation) -> NSLayoutConstraint {
        let edge: ALEdge = horizontal ? .Top : .Leading
        let constraint = marginsEnabled ? item.autoPinEdgeToSuperviewMargin(edge, relation: relation) : item.autoPinEdgeToSuperviewEdge(edge, withInset: 0, relation: relation)
        constraint.identifier = "ASV-canvas-connection"
        return constraint
    }

    private func pinToTrailingEdge(item: UIView, relation: NSLayoutRelation) -> NSLayoutConstraint {
        let edge: ALEdge = horizontal ? .Bottom : .Trailing
        let constraint = marginsEnabled ? item.autoPinEdgeToSuperviewMargin(edge, relation: relation) : item.autoPinEdgeToSuperviewEdge(edge, withInset: 0, relation: relation)
        constraint.identifier = "ASV-canvas-connection"
        return constraint
    }
}
