// The MIT License (MIT)
//
// Copyright (c) 2016 Alexander Grebenyuk (github.com/kean).

import UIKit

class AlignedLayoutArrangement: LayoutArrangement {
    var type: StackViewAlignment = .Fill

    override func updateConstraints() {
        super.updateConstraints()
        
        let leadingAttr: NSLayoutAttribute = horizontal ? .Top : .Leading
        let trailingAttr: NSLayoutAttribute = horizontal ? .Bottom : .Trailing
        let centerAttr: NSLayoutAttribute = horizontal ? .CenterY : .CenterX
        
        items.forEach { item in
            switch type {
            case .Fill:
                connectToCanvas(item, attribute: leadingAttr)
                connectToCanvas(item, attribute: trailingAttr)
            case .Leading, .Trailing:
                connectToCanvas(item, attribute: leadingAttr, equal: type == .Leading)
                connectToCanvas(item, attribute: trailingAttr, equal: type == .Trailing)
            case .Center:
                connectToCanvas(item, attribute: leadingAttr, equal: false)
                connectToCanvas(item, attribute: centerAttr)
            case .FirstBaseline, .LastBaseline:
                connectToCanvas(item, attribute: leadingAttr, equal: false)
                connectToCanvas(item, attribute: trailingAttr, equal: false)
            }
        }
        if type == .FirstBaseline || type == .LastBaseline {
            let attr: NSLayoutAttribute = type == .FirstBaseline ? .FirstBaseline : .LastBaseline
            items.forPair { previous, current in
                addConstraint(item: previous, attribute: attr, toItem: current, attribute: attr)
            }
        }
    }
}
