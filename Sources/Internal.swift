// The MIT License (MIT)
//
// Copyright (c) 2016 Alexander Grebenyuk (github.com/kean).

import UIKit


class LayoutGuide: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Make sure that layout guides don't interfere with touches
        self.hidden = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override class func layerClass() -> AnyClass {
        return CATransformLayer.self
    }
    
    override var backgroundColor: UIColor? {
        get { return nil }
        set { return }
    }
}

class GapLayoutGuide: LayoutGuide {}

class LayoutSpacer: LayoutGuide {}


extension SequenceType {
    // FIXME: Name might be misleading, it doesn't enumerate over all combinations
    func forPair(@noescape closure: (first: Self.Generator.Element, second: Self.Generator.Element) -> Void) {
        let _ = reduce(nil as Self.Generator.Element?) { previous, current in
            if let previous = previous {
                closure(first: previous, second: current)
            }
            return current
        }
    }
}


extension NSLayoutAttribute {
    var toMargin: NSLayoutAttribute {
        switch self {
        case .Left: return .LeftMargin
        case .Right: return .RightMargin
        case .Top: return .TopMargin
        case .Bottom: return .BottomMargin
        case .Leading: return .LeadingMargin
        case .Trailing: return .TrailingMargin
        case .CenterX: return .CenterXWithinMargins
        case .CenterY: return .CenterYWithinMargins
        default: return self
        }
    }
}
