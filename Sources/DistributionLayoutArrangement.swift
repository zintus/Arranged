// The MIT License (MIT)
//
// Copyright (c) 2016 Alexander Grebenyuk (github.com/kean).

import UIKit

class DistributionLayoutArrangement: LayoutArrangement {
    var type: StackViewDistribution = .Fill
    var spacing: CGFloat = 0
    private var gaps = [GapLayoutGuide]()

    override func updateConstraints() {
        super.updateConstraints()

        gaps.forEach { $0.removeFromSuperview() }
        gaps.removeAll()
        
        if items.count > 0 {
            updateSpacingConstraints()
            updateDistributionConstraints()
        }
        if hiddenItems.count > 0 {
            updateHiddenItemsConstraints()
        }
    }

    private func updateSpacingConstraints() {
        switch type {
        case .Fill, .FillEqually, .FillProportionally:
            addSpacings()
        case .EqualSpacing, .EqualCentering:
            addSpacings(.GreaterThanOrEqual)
            updateGapLayoutGuides()
        }
    }

    private func updateGapLayoutGuides() {
        items.forPair { previous, current in
            let gap = GapLayoutGuide()
            gap.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(gap)
            gaps.append(gap)

            let leading: NSLayoutAttribute = horizontal ? .Leading : .Top
            let trailing: NSLayoutAttribute = horizontal ? .Trailing : .Bottom
            let center: NSLayoutAttribute = horizontal ? .CenterX : .CenterY
            let centering = type == .EqualCentering
            connectItem(previous, attribute: (centering ? center : trailing), item: gap, attribute: leading)
            connectItem(gap, attribute: trailing, item: current, attribute: (centering ? center : leading))
        }

        matchItemsSize(gaps)
    }

    private func updateDistributionConstraints() {
        switch type {
        case .FillProportionally:
            func size(item: UIView) -> CGFloat {
                let intrinsic = item.intrinsicContentSize()
                return horizontal ? intrinsic.width : intrinsic.height
            }
            let totalSize = items.reduce(CGFloat(0)) { total, item in
                return total + size(item)
            }
            var priority: UILayoutPriority = 999
            items.forEach { item in
                add(constraint(item: item, attribute: (horizontal ? .Width : .Height), toItem: canvas, relation: .Equal, multiplier: (size(item) / totalSize), priority: priority, identifier: "ASV-fill-proportionally"))
                priority -= 1
            }
        case .FillEqually:
            matchItemsSize(items)
        default: break
        }
    }
    
    private func updateHiddenItemsConstraints() {
        hiddenItems.forEach {
            add(constraint(item: $0, attribute: (horizontal ? .Width : .Height), constant: 0, identifier: "ASV-hiding"))
        }
    }
    
    // MARK: Helpers
    
    private func addSpacings(relation: NSLayoutRelation = .Equal) {
        func spacing(previous previous: UIView, current: UIView) -> CGFloat {
            if current === visibleItems.first || previous === visibleItems.last {
                return 0.0
            } else {
                var spacing = self.spacing
                [previous, current].forEach {
                    if isHidden($0) {
                        spacing -= self.spacing / 2.0
                    }
                }
                return spacing
            }
        }
        items.forPair { previous, current in
            let spacing = spacing(previous: previous, current: current)
            add(constraint(item: current, attribute: (horizontal ? .Leading : .Top), toItem: previous, attribute: (horizontal ? .Trailing : .Bottom), relation: relation, constant: spacing, identifier: "ASV-spacing"))
        }
    }
    
    private func connectItem(item1: UIView, attribute attr1: NSLayoutAttribute, item item2: UIView, attribute attr2: NSLayoutAttribute) {
        add(constraint(item: item1, attribute: attr1, toItem: item2, attribute: attr2, identifier: "ASV-distributing-edge"))
    }
    
    private func matchItemsSize(items: [UIView]) {
        items.forPair { previous, current in
            add(constraint(item: previous, attribute: (horizontal ? .Width : .Height), toItem: current, identifier: "ASV-fill-equally"))
        }
    }
}
