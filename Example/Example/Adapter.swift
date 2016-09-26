//
//  Adapter.swift
//  Example
//
//  Created by Alexander Grebenyuk on 02/03/16.
//  Copyright © 2016 Alexander Grebenyuk. All rights reserved.
//

import Foundation
import UIKit
import Arranged

protocol StackViewAdapter: class {
    // Those members are the same for both classes
    func addArrangedSubview(_ view: UIView)
    func removeArrangedSubview(_ view: UIView)
    var axis: UILayoutConstraintAxis { get set }
    var spacing: CGFloat { get set }
    var isBaselineRelativeArrangement: Bool { get set }
    var isLayoutMarginsRelativeArrangement: Bool { get set }

    var ar_distribution: UIStackViewDistribution { get set }
    var ar_alignment: UIStackViewAlignment { get set }
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
}

extension StackViewDistribution {
    func toStackViewDistrubition() -> UIStackViewDistribution {
        switch self {
        case .fill: return .fill
        case .fillEqually: return .fillEqually
        case .fillProportionally: return .fillProportionally
        case .equalSpacing: return .equalSpacing
        case .equalCentering: return .equalCentering
        }
    }

    static func fromStackViewDistrubition(_ distribution: UIStackViewDistribution) -> StackViewDistribution {
        switch distribution {
        case .fill: return .fill
        case .fillEqually: return .fillEqually
        case .fillProportionally: return .fillProportionally
        case .equalSpacing: return .equalSpacing
        case .equalCentering: return .equalCentering
        }
    }
}

extension StackViewAlignment {
    func toStackViewAlignment() -> UIStackViewAlignment {
        switch self {
        case .fill: return .fill
        case .leading: return .leading
        case .firstBaseline: return .firstBaseline
        case .center: return .center
        case .trailing: return .trailing
        case .lastBaseline: return .lastBaseline
        }
    }

    static func fromStackViewAlignment(_ alignment: UIStackViewAlignment) -> StackViewAlignment {
        switch alignment {
        case .fill: return .fill
        case .leading: return .leading
        case .firstBaseline: return .firstBaseline
        case .center: return .center
        case .trailing: return .trailing
        case .lastBaseline: return .lastBaseline
        }
    }
}
