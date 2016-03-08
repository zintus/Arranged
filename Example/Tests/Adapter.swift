// The MIT License (MIT)
//
// Copyright (c) 2016 Alexander Grebenyuk (github.com/kean).

import Foundation
import UIKit
import Arranged

protocol StackViewAdapter: class {
    // Those members are the same for both classes
    func addArrangedSubview(view: UIView)
    func removeArrangedSubview(view: UIView)
    var axis: UILayoutConstraintAxis { get set }
    var spacing: CGFloat { get set }
    var baselineRelativeArrangement: Bool { get set }
    var layoutMarginsRelativeArrangement: Bool { get set }
    
    var ar_distribution: UIStackViewDistribution { get set }
    var ar_alignment: UIStackViewAlignment { get set }
    
    func setArrangedView(view: UIView, hidden: Bool)
}

extension StackView: StackViewAdapter {
    var ar_distribution: UIStackViewDistribution {
        get { return self.distribution.toStackViewDistrubition() }
        set { self.distribution = StackViewDistribution.fromStackViewDistrubition(newValue) }
    }
    var ar_alignment: UIStackViewAlignment {
        get { return self.alignment.toStackViewAlignment() }
        set { self.alignment = StackViewAlignment.fromStackViewAlignment(newValue) }
    }
}

extension UIStackView: StackViewAdapter {
    var ar_distribution: UIStackViewDistribution {
        get { return self.distribution }
        set { self.distribution = newValue }
    }
    var ar_alignment: UIStackViewAlignment {
        get { return self.alignment }
        set { self.alignment = newValue }
    }
    func setArrangedView(view: UIView, hidden: Bool) {
        view.hidden = hidden
    }
}

extension StackViewDistribution {
    func toStackViewDistrubition() -> UIStackViewDistribution {
        switch self {
        case .Fill: return .Fill
        case .FillEqually: return .FillEqually
        case .FillProportionally: return .FillProportionally
        case .EqualSpacing: return .EqualSpacing
        case .EqualCentering: return .EqualCentering
        }
    }
    
    static func fromStackViewDistrubition(distribution: UIStackViewDistribution) -> StackViewDistribution {
        switch distribution {
        case .Fill: return .Fill
        case .FillEqually: return .FillEqually
        case .FillProportionally: return .FillProportionally
        case .EqualSpacing: return .EqualSpacing
        case .EqualCentering: return .EqualCentering
        }
    }
}

extension StackViewAlignment {
    func toStackViewAlignment() -> UIStackViewAlignment {
        switch self {
        case .Fill: return .Fill
        case .Leading: return .Leading
        case .FirstBaseline: return .FirstBaseline
        case .Center: return .Center
        case .Trailing: return .Trailing
        case .LastBaseline: return .LastBaseline
        }
    }
    
    static func fromStackViewAlignment(alignment: UIStackViewAlignment) -> StackViewAlignment {
        switch alignment {
        case .Fill: return .Fill
        case .Leading: return .Leading
        case .FirstBaseline: return .FirstBaseline
        case .Center: return .Center
        case .Trailing: return .Trailing
        case .LastBaseline: return .LastBaseline
        }
    }
}