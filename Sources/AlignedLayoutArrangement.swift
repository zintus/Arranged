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
        
        if items.count > 0 {
            updateCanvasConnectingCostraints()
            updateAlignmentConstraints()
        }
    }
    
    private func updateAlignmentConstraints() {
        let top: NSLayoutAttribute = horizontal ? .Top : .Leading
        let bottom: NSLayoutAttribute = horizontal ? .Bottom : .Trailing
        let center: NSLayoutAttribute = horizontal ? .CenterY : .CenterX
        
        let firstItem = items.first!
        
        switch type {
        case .Fill:
            for attribute in [top, bottom] {
                connectToCanvas(firstItem, attribute: attribute)
                alignItems(attribute: attribute)
            }
        case .Leading, .Trailing:
            connectToCanvas((type == .Leading ? firstItem : spacer), attribute: top)
            connectToCanvas((type == .Leading ? spacer : firstItem), attribute: bottom)
            alignItems(attribute: (type == .Leading ? top : bottom))
            connectItemsToSpacer(topEqual: type == .Leading, bottomEqual: type == .Trailing)
        case .Center:
            connectToCanvas(firstItem, attribute: center)
            connectToCanvas(spacer, attribute: top)
            connectToCanvas(spacer, attribute: bottom)
            alignItems(attribute: center)
            connectItemsToSpacer(topEqual: false, bottomEqual: false)
        case .FirstBaseline, .LastBaseline:
            connectToCanvas((type == .FirstBaseline ? firstItem : spacer), attribute: top, equal: type == .LastBaseline)
            connectToCanvas((type == .FirstBaseline ? spacer : firstItem), attribute: bottom, equal: type == .FirstBaseline)
            alignItems(attribute: (type == .FirstBaseline ? .FirstBaseline : .LastBaseline))
            add(constraint(item: canvas, attribute: (horizontal ? .Height : .Width), constant: 0, priority: 49, identifier: "ASV-canvas-fit"))
            connectItemsToSpacer(topEqual: false, bottomEqual: false)
        }
        
        if type != .Fill {
            addItemsAmbiguitySuppressors()
        }
    }
    
    private func updateCanvasConnectingCostraints() {
        if let first = items.first, last = items.last {
            connectToCanvas(first, attribute: horizontal ? .Leading : .Top)
            connectToCanvas(last, attribute: horizontal ? .Trailing : .Bottom)
        }
    }
    
    // MARK: Helpers
    
    private func alignItems(attribute attribute: NSLayoutAttribute) {
        let firstItem = items.first!
        items.dropFirst().forEach {
            add(constraint(item: firstItem, attribute: attribute, toItem: $0, attribute: nil, identifier: "ASV-alignment"))
        }
    }
    
    private func addItemsAmbiguitySuppressors() {
        items.forEach {
            add(constraint(item: $0, attribute: (horizontal ? .Height : .Width), constant: 0, priority: 25, identifier: "ASV-ambiguity-suppression"))
        }
    }
    
    private func connectItemsToSpacer(topEqual topEqual: Bool, bottomEqual: Bool) {
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
        let canvasAttr = marginsEnabled ? marginForAttribute(attr) : attr
        add(constraint(item: canvas, attribute: canvasAttr, toItem: item, attribute: attr, relation: relation, identifier: "ASV-canvas-connection"))
    }
    
    private func connectionRelation(attr: NSLayoutAttribute, equal: Bool) -> NSLayoutRelation {
        if equal { return .Equal }
        return (attr == .Top || attr == .Left || attr == .Leading) ? .LessThanOrEqual : .GreaterThanOrEqual
    }
    
    private func marginForAttribute(attr: NSLayoutAttribute) -> NSLayoutAttribute {
        switch attr {
        case .Left: return .LeftMargin
        case .Right: return .RightMargin
        case .Top: return .TopMargin
        case .Bottom: return .BottomMargin
        case .Leading: return .LeadingMargin
        case .Trailing: return .TrailingMargin
        case .CenterX: return .CenterXWithinMargins
        case .CenterY: return .CenterYWithinMargins
        default: return attr
        }
    }
}
