// The MIT License (MIT)
//
// Copyright (c) 2016 Alexander Grebenyuk (github.com/kean).

import UIKit

class DistributionLayoutArrangement: LayoutArrangement {
    var type: StackViewDistribution = .Fill
    var spacing: CGFloat = 0
    var baselineRelative = false
    var spacer: LayoutSpacer
    private var gaps = [GapLayoutGuide]()

    override init(canvas: StackView) {
        spacer = LayoutSpacer()
        spacer.accessibilityIdentifier = "ASV-alignment-spanner"
        spacer.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(canvas: canvas)
    }
    
    override func updateConstraints() {
        super.updateConstraints()

        spacer.removeFromSuperview()
        
        gaps.forEach { $0.removeFromSuperview() }
        gaps.removeAll()
        
        if items.count > 0 {
            updateCanvasConnectingConstraints()
            updateSpacingConstraints()
            updateDistributionConstraints()
        }
        if hiddenItems.count > 0 {
            updateHiddenItemsConstraints()
        }
        if items.count > 0 && (type == .EqualSpacing || type == .EqualCentering) {
            addCanvasFitConstraint(attribute: (horizontal ? .Width : .Height))
        }
    }

    private func updateCanvasConnectingConstraints() {
        if visibleItems.count == 0 {
            canvas.addSubview(spacer)
            connectToCanvas(spacer, attribute: horizontal ? .Leading : .Top)
            connectToCanvas(spacer, attribute: horizontal ? .Trailing : .Bottom)
        } else {
            connectToCanvas(visibleItems.first!, attribute: horizontal ? .Leading : .Top)
            connectToCanvas(visibleItems.last!, attribute: horizontal ? .Trailing : .Bottom)
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
        visibleItems.forPair { previous, current in
            let gap = GapLayoutGuide()
            gap.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(gap)
            gaps.append(gap)

            let leading: NSLayoutAttribute = baselineRelative ? .FirstBaseline : (horizontal ? .Leading : .Top)
            let trailing: NSLayoutAttribute = baselineRelative ? .LastBaseline : (horizontal ? .Trailing : .Bottom)
            let center: NSLayoutAttribute = horizontal ? .CenterX : .CenterY
            
            connectItem(gap, attribute: leading, item: previous, attribute: (type == .EqualCentering ? center : trailing))
            connectItem(gap, attribute: trailing, item: current, attribute: (type == .EqualCentering ? center : leading))
        }
        matchItemsSize(gaps, priority: type == .EqualCentering ? 149 : nil)
    }

    private func updateDistributionConstraints() {
        switch type {
        case .FillProportionally:
            fillItemsProportionally()
        case .FillEqually:
            matchItemsSize(visibleItems)
        default: break
        }
    }
        
    private func fillItemsProportionally() {
        func size(item: UIView) -> CGFloat {
            let intrinsic = item.intrinsicContentSize()
            return horizontal ? intrinsic.width : intrinsic.height
        }
        let itemsWithIntrinsic: [UIView] = visibleItems.filter {
            let size = size($0)
            return size != UIViewNoIntrinsicMetric && size > 0
        }
        guard itemsWithIntrinsic.count > 0 else {
            matchItemsSize(visibleItems)
            return
        }
        let totalSpacing = spacing * CGFloat(visibleItems.count - 1)
        let totalSize = itemsWithIntrinsic.reduce(totalSpacing) { total, item in
            return total + size(item)
        }
        var priority: UILayoutPriority? = (itemsWithIntrinsic.count == 1 && (visibleItems.count == 1 || spacing == 0.0)) ? nil : 999
        let dimension: NSLayoutAttribute = horizontal ? .Width : .Height
        visibleItems.forEach {
            let size = size($0)
            if size != UIViewNoIntrinsicMetric && size > 0 {
                add(constraint(item: $0, attribute: dimension, toItem: canvas, relation: .Equal, multiplier: (size / totalSize), priority: priority, identifier: "ASV-fill-proportionally"))
            } else {
                add(constraint(item: $0, attribute: dimension, constant: 0, identifier: "ASV-fill-proportionally"))
            }
            priority? -= 1
        }
    }
    
    private func updateHiddenItemsConstraints() {
        hiddenItems.forEach {
            add(constraint(item: $0, attribute: (horizontal ? .Width : .Height), constant: 0, identifier: "ASV-hiding"))
        }
    }
    
    // MARK: Helpers
    
    private func addSpacings(relation: NSLayoutRelation = .Equal) {
        func spacingFor(previous previous: UIView, current: UIView) -> CGFloat {
            if current === visibleItems.first || previous === visibleItems.last {
                return 0.0
            } else {
                return spacing - (spacing / 2.0) * CGFloat([previous, current].filter{ isHidden($0) }.count)
            }
        }
        items.forPair { previous, current in
            let spacing = spacingFor(previous: previous, current: current)
            let to: NSLayoutAttribute = baselineRelative ? .FirstBaseline : (horizontal ? .Leading : .Top)
            let from: NSLayoutAttribute = baselineRelative ? .LastBaseline : (horizontal ? .Trailing : .Bottom)
            add(constraint(item: current, attribute: to, toItem: previous, attribute: from, relation: relation, constant: spacing, identifier: "ASV-spacing"))
        }
    }
    
    private func connectItem(item1: UIView, attribute attr1: NSLayoutAttribute, item item2: UIView, attribute attr2: NSLayoutAttribute) {
        add(constraint(item: item1, attribute: attr1, toItem: item2, attribute: attr2, identifier: "ASV-distributing-edge"))
    }
    
    private func matchItemsSize(items: [UIView], priority: UILayoutPriority? = nil) {
        guard items.count > 0 else { return }
        let firstItem = items.first!
        items.dropFirst().forEach {
            add(constraint(item: $0, attribute: (horizontal ? .Width : .Height), toItem: firstItem, priority: priority, identifier: "ASV-fill-equally"))
        }
    }
}
