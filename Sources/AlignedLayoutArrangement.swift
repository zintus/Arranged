// The MIT License (MIT)
//
// Copyright (c) 2016 Alexander Grebenyuk (github.com/kean).

import UIKit

/** Manages alignment: constraints perpendicular to the axis.
 */
class AlignedLayoutArrangement: LayoutArrangement {
    var type: StackViewAlignment = .Fill
    private var spacer: LayoutSpacer
    
    override init(canvas: StackView) {
        spacer = LayoutSpacer()
        spacer.accessibilityIdentifier = "ASV-alignment-spanner"
        spacer.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(canvas: canvas)
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        spacer.removeFromSuperview()
        
        updateCanvasConnectingConstraints()
        updateAlignmentConstraints()
        
        if isAnyItemConnectionWeak {
            addItemsAmbiguitySuppressors(items)
        }
        
        if items.count > 0 && visibleItems.count > 0 && isAnyCanvasConnectionWeak {
            addCanvasFitConstraint(attribute: height)
        }
    }
    
    private func updateCanvasConnectingConstraints() {
        guard items.count > 0 else { return }
        
        let noVisibleItems = visibleItems.count == 0
        
        if shouldPackItemsIntoSpacer || noVisibleItems {
            canvas.addSubview(spacer)
            if isAnyItemConnectionWeak {
                add(constraint(item: spacer, attribute: height, constant: 0, priority: 51, identifier: "ASV-spanning-fit"))
            }
            connectItemsToSpacer(spacer, items: visibleItems, topWeak: isTopItemConnectionWeak, bottomWeak: isBottomItemConnectionWeak)
        }
        
        // FIXME: Not readable
        let firstItem = noVisibleItems ? spacer : items.first!
        var topItem = firstItem
        var bottomItem = shouldPackItemsIntoSpacer ? spacer : firstItem
        if typeIn([.Center, .Trailing, .LastBaseline]) {
            swap(&topItem, &bottomItem)
        }
        
        connectToCanvas(topItem, attribute: top, weak: (noVisibleItems ? false : isTopCanvasConnectionWeak))
        connectToCanvas(bottomItem, attribute: bottom, weak: (noVisibleItems ? false : isBottomCanvasConnectionWeak))
        
        if type == .Center {
            connectToCanvas(firstItem, attribute: center)
        }
    }
    
    private var isAnyCanvasConnectionWeak: Bool {
        return isTopCanvasConnectionWeak || isBottomCanvasConnectionWeak
    }
    
    private var isTopCanvasConnectionWeak: Bool {
        if shouldPackItemsIntoSpacer {
            return type == .FirstBaseline && axis == .Horizontal // FIXME: Why? Not supported for vertical axis? Just implementation detail?
        }
        return isTopItemConnectionWeak
    }
    
    private var isBottomCanvasConnectionWeak: Bool {
        if shouldPackItemsIntoSpacer {
            return type == .LastBaseline && axis == .Horizontal // FIXME: Why? Not supported for vertical axis? Just implementation detail?
        }
        return isBottomItemConnectionWeak
    }
    
    private var shouldPackItemsIntoSpacer: Bool {
        return items.count > 1 && isAnyItemConnectionWeak
    }
    
    private var isAnyItemConnectionWeak: Bool {
        return isTopItemConnectionWeak || isBottomItemConnectionWeak
    }
    
    private var isTopItemConnectionWeak: Bool {
        return typeIn([.Trailing, .Center, .FirstBaseline, .LastBaseline])
    }
    
    private var isBottomItemConnectionWeak: Bool {
        return typeIn([.Leading, .Center, .FirstBaseline, .LastBaseline])
    }
    
    private func updateAlignmentConstraints() {
        func attributes() -> [NSLayoutAttribute] {
            switch type {
            case .Fill: return [bottom, top]
            case .Leading: return [top]
            case .Trailing: return [bottom]
            case .Center: return [center]
            case .FirstBaseline: return axis == .Horizontal ? [.FirstBaseline] : []
            case .LastBaseline: return axis == .Horizontal ? [.LastBaseline] : []
            }
        }
        for attribute in attributes() {
            alignItems(items, attribute: attribute)
        }
    }

    // MARK: Managed Attributes

    private var height: NSLayoutAttribute {
        return axis == .Horizontal ? .Height : .Width
    }

    private var top: NSLayoutAttribute {
        return axis == .Horizontal ? .Top : .Leading
    }

    private var bottom: NSLayoutAttribute {
        return axis == .Horizontal ? .Bottom : .Trailing
    }

    private var center: NSLayoutAttribute {
        return axis == .Horizontal ? .CenterY : .CenterX
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
        items.forEach {
            connectToSpacer($0, attribute: top, weak: topWeak)
            connectToSpacer($0, attribute: bottom, weak: bottomWeak)
        }
    }
    
    private func addItemsAmbiguitySuppressors(items: [UIView]) {
        items.forEach {
            add(constraint(item: $0, attribute: height, constant: 0, priority: 25, identifier: "ASV-ambiguity-suppression"))
        }
    }
    
    private func typeIn(types: [StackViewAlignment]) -> Bool {
        return types.contains(type)
    }
}
