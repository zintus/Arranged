// The MIT License (MIT)
//
// Copyright (c) 2017 Alexander Grebenyuk (github.com/kean).

import UIKit

struct StackTestConfiguraton {
    var axis: UILayoutConstraintAxis = .horizontal
    var alignment: UIStackViewAlignment = .fill
    var distribution: UIStackViewDistribution = .fill
    var isBaselineRelativeArrangement: Bool = false
    var isLayoutMarginsRelativeArrangement: Bool = false
    var spacing: CGFloat = 0
    
    static func generate() -> [StackTestConfiguraton] {
        let alignments: [UIStackViewAlignment] = [.fill, .leading, .firstBaseline, .center, .trailing, .lastBaseline]
        let distributions: [UIStackViewDistribution] = [.fill, .fillEqually, .fillProportionally, .equalSpacing, .equalCentering]
        let spacings: [CGFloat] = [0.0, 20.0]
        
        var combinations = [StackTestConfiguraton]()
        // FIXME: Is there a better way to write this?
        for axis in [UILayoutConstraintAxis.horizontal, UILayoutConstraintAxis.vertical] {
        for alignment in alignments {
        for distribution in distributions {
        for baselineRelative in [true, false] {
        for spacing in spacings {
            var conf = StackTestConfiguraton()
            conf.axis = axis
            conf.alignment = alignment
            conf.distribution = distribution
            conf.isBaselineRelativeArrangement = baselineRelative
            // We don't test marginsRelative because UIStackView
            // pins to UIViewLayoutMarginsGuide (iOS 9+)
            conf.isLayoutMarginsRelativeArrangement = false
            conf.spacing = spacing
            combinations.append(conf)
        }}}}}
        return combinations
    }
}

extension StackTestConfiguraton: CustomStringConvertible {
    var description: String {
        var desc = String()
        let axis = self.axis == .horizontal ? ".Horizontal" : ".Vertical"
        desc.append("axis: \(axis)\n")
        desc.append("alignment: \(alignment.toString)\n")
        desc.append("distribution: \(distribution.toString)\n")
        desc.append("baselineRelativeArrangement: \(isBaselineRelativeArrangement)\n")
        desc.append("layoutMarginsRelativeArrangement: \(isLayoutMarginsRelativeArrangement)\n")
        desc.append("spacing: \(spacing)\n")
        return desc
    }
}
