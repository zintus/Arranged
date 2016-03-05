// The MIT License (MIT)
//
// Copyright (c) 2016 Alexander Grebenyuk (github.com/kean).

import UIKit

class DistributionLayoutArrangement: LayoutArrangement {
    var type: StackViewDistribution = .Fill
    var spacing: CGFloat = 0

    override func updateConstraints() {
        super.updateConstraints()

        updateSpacingConstraints()
        updateDistributionConstraints()
    }

    private func updateSpacingConstraints() {
        // FIXME: Don't remove all gaps
        canvas.subviews.filter{ $0 is GapLayoutGuide }.forEach{ $0.removeFromSuperview() }

        switch type {
        case .EqualSpacing, .EqualCentering:
            updateGapLayoutGuides()
        case .Fill, .FillEqually:
            // Set spacing without creating spacers
            items.forPair {  previous, current in
                addSpacing(current: current, previous: previous)
            }
        case .FillProportionally:
            print(".FillProportionally not implemented")
        }
    }

    private func updateGapLayoutGuides() {
        // Join views using gaps
        var gaps = [GapLayoutGuide]()
        items.forPair { previous, current in
            let gap = GapLayoutGuide()
            gap.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(gap)
            gaps.append(gap)

            addSpacing(current: current, previous: previous, relation: .GreaterThanOrEqual)

            // Join views using spacer
            let leadingAttr: NSLayoutAttribute = horizontal ? .Leading : .Top
            let trailingAttr: NSLayoutAttribute = horizontal ? .Trailing : .Bottom
            let centerAttr: NSLayoutAttribute = horizontal ? .CenterX : .CenterY
            if type == .EqualCentering {
                // Spacers are joined to the centers of the views
                connectItem(gap, attribute: leadingAttr, toItem: previous, attribute: centerAttr)
                connectItem(gap, attribute: trailingAttr, toItem: current, attribute: centerAttr)
            } else {
                connectItem(gap, attribute: leadingAttr, toItem: previous, attribute: trailingAttr)
                connectItem(gap, attribute: trailingAttr, toItem: current, attribute: leadingAttr)
            }
        }

        // Match spacers size
        gaps.forPair { previous, current in
            add(constraint(item: previous, attribute: (horizontal ? .Width : .Height), toItem: current, identifier: "ASV-equal-spacers"))
        }
    }

    private func addSpacing(current current: UIView, previous: UIView, relation: NSLayoutRelation = .Equal) {
        add(constraint(item: current, attribute: (horizontal ? .Leading : .Top), toItem: previous, attribute: (horizontal ? .Trailing : .Bottom), relation: relation, constant: spacing, identifier: "ASV-spacing"))
    }

    private func connectItem(item1: UIView, attribute attr1: NSLayoutAttribute, toItem item2: UIView, attribute attr2: NSLayoutAttribute) {
        add(constraint(item: item1, attribute: attr1, toItem: item2, attribute: attr2, identifier: "AVS-spacer-connection"))
    }

    private func updateDistributionConstraints() {
        // FIXME: Cleanup
        guard type == .FillEqually else {
            return
        }
        items.forPair { previous, current in
            add(constraint(item: previous, attribute: (horizontal ? .Width : .Height), toItem: current, identifier: "AVS-fill-equally"))
        }
    }
}
