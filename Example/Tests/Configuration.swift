// The MIT License (MIT)
//
// Copyright (c) 2016 Alexander Grebenyuk (github.com/kean).

import UIKit

struct StackTestConfiguraton {
    var axis: UILayoutConstraintAxis = .Horizontal
    var alignment: UIStackViewAlignment = .Fill
    var distribution: UIStackViewDistribution = .Fill
    var baselineRelativeArrangement: Bool = false
    var layoutMarginsRelativeArrangement: Bool = false
    var spacing: CGFloat = 0
    
    static func generate() -> [StackTestConfiguraton] {
        let alignments: [UIStackViewAlignment] = [.Fill, .Leading, .FirstBaseline, .Center, .Trailing, .LastBaseline]
        let distributions: [UIStackViewDistribution] = [.Fill, .FillEqually, .FillProportionally, .EqualSpacing, .EqualCentering]
        let spacings: [CGFloat] = [0.0, 20.0]
        
        var combinations = [StackTestConfiguraton]()
        // FIXME: Is there a better way to write this?
        for axis in [UILayoutConstraintAxis.Horizontal, UILayoutConstraintAxis.Vertical] {
        for alignment in alignments {
        for distribution in distributions {
        for baselineRelative in [true, false] {
        for spacing in spacings {
            var conf = StackTestConfiguraton()
            conf.axis = axis
            conf.alignment = alignment
            conf.distribution = distribution
            conf.baselineRelativeArrangement = baselineRelative
            // We don't test marginsRelative because UIStackView
            // pins to UIViewLayoutMarginsGuide (iOS 9+)
            conf.layoutMarginsRelativeArrangement = false
            conf.spacing = spacing
            combinations.append(conf)
        }}}}}
        return combinations
    }
}

extension StackTestConfiguraton: CustomStringConvertible {
    var description: String {
        var desc = String()
        let axis = self.axis == .Horizontal ? ".Horizontal" : ".Vertical"
        desc.appendContentsOf("axis: \(axis)\n")
        desc.appendContentsOf("alignment: \(alignment.toString)\n")
        desc.appendContentsOf("distribution: \(distribution.toString)\n")
        desc.appendContentsOf("baselineRelativeArrangement: \(baselineRelativeArrangement)\n")
        desc.appendContentsOf("layoutMarginsRelativeArrangement: \(layoutMarginsRelativeArrangement)\n")
        desc.appendContentsOf("spacing: \(spacing)\n")
        return desc
    }
}
