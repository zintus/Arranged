// The MIT License (MIT)
//
// Copyright (c) 2016 Alexander Grebenyuk (github.com/kean).

import UIKit


class LayoutGuide: UIView {}

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
