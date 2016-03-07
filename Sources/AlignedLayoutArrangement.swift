// The MIT License (MIT)
//
// Copyright (c) 2016 Alexander Grebenyuk (github.com/kean).

import UIKit

class AlignedLayoutArrangement: LayoutArrangement {
    var type: StackViewAlignment = .Fill
    private var _spacer: LayoutSpacer?
    private var spacer: LayoutSpacer {
        if _spacer == nil {
            let spacer = LayoutSpacer()
            _spacer = spacer
            spacer.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(spacer)
            add(constraint(item: spacer, attribute: (horizontal ? .Height : .Width), constant: 0, priority: 51, identifier: "ASV-spanning-fit"))
        }
        return _spacer!
    }
    
    override func updateConstraints() {
        super.updateConstraints()

        _spacer?.removeFromSuperview()
        _spacer = nil
        
        updateCanvasConnectingCostraints()
        updateConnectingItemsToSpacerConstraints()
        updateAlignmentConstraints()

        if type != .Fill {
            addItemsAmbiguitySuppressors(items)
        }
        if items.count > 0 && (type == .FirstBaseline || type == .LastBaseline) {
            addCanvasFitConstraint(attribute: (horizontal ? .Height : .Width))
        }
    }
    
    private func updateAlignmentConstraints() {
        let top: NSLayoutAttribute = horizontal ? .Top : .Leading
        let bottom: NSLayoutAttribute = horizontal ? .Bottom : .Trailing
        func attributes() -> [NSLayoutAttribute] {
            switch type {
            case .Fill: return [top, bottom]
            case .Leading: return [top]
            case .Trailing: return [bottom]
            case .Center: return [horizontal ? .CenterY : .CenterX]
            case .FirstBaseline: return horizontal ? [.FirstBaseline] : []
            case .LastBaseline: return horizontal ? [.LastBaseline] : []
            }
        }
        for attribute in attributes() {
            alignItems(items, attribute: attribute)
        }
    }
    
    private func updateCanvasConnectingCostraints() {
        guard visibleItems.count > 0 else { return }
        
        let firstItem = visibleItems.first!
        let lastItem = visibleItems.last!
        
        // Along the axis
        // FIXME: Should probably be part of DistributionLayoutArrangement
        connectToCanvas(firstItem, attribute: horizontal ? .Leading : .Top)
        connectToCanvas(lastItem, attribute: horizontal ? .Trailing : .Bottom)
        
        // Perpendicular to the axis
        let top: NSLayoutAttribute = horizontal ? .Top : .Leading
        let bottom: NSLayoutAttribute = horizontal ? .Bottom : .Trailing
        let center: NSLayoutAttribute = horizontal ? .CenterY : .CenterX
        
        switch type {
        case .Fill:
            for attribute in [top, bottom] {
                connectToCanvas(firstItem, attribute: attribute)
            }
        case .Leading, .Trailing:
            connectToCanvas((type == .Leading ? firstItem : spacer), attribute: top)
            connectToCanvas((type == .Leading ? spacer : firstItem), attribute: bottom)
        case .Center:
            connectToCanvas(firstItem, attribute: center)
            connectToCanvas(spacer, attribute: top)
            connectToCanvas(spacer, attribute: bottom)
        case .FirstBaseline, .LastBaseline:
            connectToCanvas((type == .FirstBaseline ? firstItem : spacer), attribute: top, equal: type == .LastBaseline)
            connectToCanvas((type == .FirstBaseline ? spacer : firstItem), attribute: bottom, equal: type == .FirstBaseline)
        }
    }
    
    private func updateConnectingItemsToSpacerConstraints() {
        if type != .Fill {
            connectItemsToSpacer(visibleItems, topEqual: type == .Leading, bottomEqual: type == .Trailing)
        }
    }
    
    // MARK: Helpers
    
    private func alignItems(items: [UIView], attribute: NSLayoutAttribute) {
        guard items.count > 0 else { return }
        let firstItem = items.first!
        items.dropFirst().forEach {
            add(constraint(item: firstItem, attribute: attribute, toItem: $0, attribute: nil, identifier: "ASV-alignment"))
        }
    }
    
    private func connectItemsToSpacer(items: [UIView], topEqual: Bool, bottomEqual: Bool) {
        func connectToSpacer(item: UIView, attribute attr: NSLayoutAttribute, equal: Bool) {
            let relation = connectionRelation(attr, equal: equal)
            let priority: UILayoutPriority? = equal ? 999.5 : nil
            add(constraint(item: spacer, attribute: attr, toItem: item, relation: relation, priority: priority, identifier: "ASV-spanning-boundary"))
        }
        let top: NSLayoutAttribute = horizontal ? .Top : .Leading
        let bottom: NSLayoutAttribute = horizontal ? .Bottom : .Trailing
        items.forEach {
            connectToSpacer($0, attribute: top, equal: topEqual)
            connectToSpacer($0, attribute: bottom, equal: bottomEqual)
        }
    }
    
    private func connectToCanvas(item: UIView, attribute attr: NSLayoutAttribute, equal: Bool = true) {
        let relation = connectionRelation(attr, equal: equal)
        add(constraint(item: canvas, attribute: (marginsEnabled ? attr.toMargin : attr), toItem: item, attribute: attr, relation: relation, identifier: "ASV-canvas-connection"))
    }
    
    private func connectionRelation(attr: NSLayoutAttribute, equal: Bool) -> NSLayoutRelation {
        if equal { return .Equal }
        return (attr == .Top || attr == .Left || attr == .Leading) ? .LessThanOrEqual : .GreaterThanOrEqual
    }
        
    private func addItemsAmbiguitySuppressors(items: [UIView]) {
        items.forEach {
            add(constraint(item: $0, attribute: (horizontal ? .Height : .Width), constant: 0, priority: 25, identifier: "ASV-ambiguity-suppression"))
        }
    }
}
