// The MIT License (MIT)
//
// Copyright (c) 2016 Alexander Grebenyuk (github.com/kean).

import UIKit

class AlignedLayoutArrangement: LayoutArrangement {
    var type: StackViewAlignment = .Fill
    private var spacer: LayoutSpacer?
    
    override func updateConstraints() {
        super.updateConstraints()

        spacer?.removeFromSuperview()
        spacer = nil
        createSpacerIfNecessary()
        
        updateCanvasConnectingConstraints()
        updateAlignmentConstraints()

        if type != .Fill {
            addItemsAmbiguitySuppressors(items)
        }
        
        if items.count > 0 && ((spacer == nil && isAnyCanvasConnectionWeak) || (horizontal && (type == .FirstBaseline || type == .LastBaseline))) {
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
    
    private func updateCanvasConnectingConstraints() {
        guard visibleItems.count > 0 else { return }
        
        let firstItem = visibleItems.first!
        let spacerItem = spacer != nil ? spacer! : firstItem
        
        let topItem = typeIn([.Fill, .Leading, .FirstBaseline]) ? firstItem : spacerItem
        let bottomItem = typeIn([.Leading, .FirstBaseline]) ? spacerItem : firstItem
        
        connectToCanvas(topItem, attribute: (horizontal ? .Top : .Leading), weak: isTopCanvasConnectionWeak)
        connectToCanvas(bottomItem, attribute: (horizontal ? .Bottom : .Trailing), weak: isBottomCanvasConnectionWeak)
        
        if type == .Center {
            connectToCanvas(firstItem, attribute: (horizontal ? .CenterY : .CenterX))
        }

    }
    
    private var isAnyCanvasConnectionWeak: Bool {
        return isTopCanvasConnectionWeak || isBottomCanvasConnectionWeak
    }
    
    private var isTopCanvasConnectionWeak: Bool {
        switch type {
        case .Fill: return false
        case .Leading: return false
        case .Trailing: return spacer == nil
        case .Center: return spacer == nil
        case .FirstBaseline: return spacer == nil || horizontal // Not supported for vertical axis
        case .LastBaseline: return spacer == nil
        }
    }
    
    private var isBottomCanvasConnectionWeak: Bool {
        switch type {
        case .Fill: return false
        case .Leading: return spacer == nil
        case .Trailing: return false
        case .Center: return spacer == nil
        case .FirstBaseline: return spacer == nil
        case .LastBaseline: return spacer == nil || horizontal  // Not supported for vertical axis
        }
    }
    
    private func createSpacerIfNecessary() {
        guard visibleItems.count > 1 && type != .Fill else { return }
        
        let spacer = LayoutSpacer()
        self.spacer = spacer
        spacer.translatesAutoresizingMaskIntoConstraints = false
        canvas.addSubview(spacer)
        add(constraint(item: spacer, attribute: (horizontal ? .Height : .Width), constant: 0, priority: 51, identifier: "ASV-spanning-fit"))
        
        connectItemsToSpacer(spacer, items: visibleItems, topWeak: type != .Leading, bottomWeak: type != .Trailing)
    }
    
    // MARK: Helpers
    
    private func alignItems(items: [UIView], attribute: NSLayoutAttribute) {
        guard items.count > 0 else { return }
        let firstItem = items.first!
        items.dropFirst().forEach {
            add(constraint(item: firstItem, attribute: attribute, toItem: $0, attribute: nil, identifier: "ASV-alignment"))
        }
    }
    
    private func connectItemsToSpacer(spacer: LayoutSpacer, items: [UIView], topWeak: Bool, bottomWeak: Bool) {
        func connectToSpacer(item: UIView, attribute attr: NSLayoutAttribute, weak: Bool) {
            let relation = connectionRelation(attr, weak: weak)
            let priority: UILayoutPriority? = weak ? nil : 999.5
            add(constraint(item: spacer, attribute: attr, toItem: item, relation: relation, priority: priority, identifier: "ASV-spanning-boundary"))
        }
        let top: NSLayoutAttribute = horizontal ? .Top : .Leading
        let bottom: NSLayoutAttribute = horizontal ? .Bottom : .Trailing
        items.forEach {
            connectToSpacer($0, attribute: top, weak: topWeak)
            connectToSpacer($0, attribute: bottom, weak: bottomWeak)
        }
    }
    
    private func addItemsAmbiguitySuppressors(items: [UIView]) {
        items.forEach {
            add(constraint(item: $0, attribute: (horizontal ? .Height : .Width), constant: 0, priority: 25, identifier: "ASV-ambiguity-suppression"))
        }
    }
    
    private func typeIn(types: [StackViewAlignment]) -> Bool {
        return types.contains(type)
    }
}
