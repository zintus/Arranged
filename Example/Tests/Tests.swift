// The MIT License (MIT)
//
// Copyright (c) 2016 Alexander Grebenyuk (github.com/kean).

import XCTest
import Arranged
import UIKit


struct StackTestConfiguraton {
    // StackView Parameters
    var axis: UILayoutConstraintAxis = .Horizontal
    var alignment: UIStackViewAlignment = .Fill
    var distribution: UIStackViewDistribution = .Fill
    var baselineRelativeArrangement: Bool = false
    var layoutMarginsRelativeArrangement: Bool = false
    var spacing: CGFloat = 0
}

extension StackTestConfiguraton: CustomStringConvertible {
    var description: String {
        var desc = String()
        desc.appendContentsOf("alignment: \(alignment.toString)\n")
        desc.appendContentsOf("distribution: \(distribution.toString)\n")
        desc.appendContentsOf("baselineRelativeArrangement: \(baselineRelativeArrangement)\n")
        desc.appendContentsOf("layoutMarginsRelativeArrangement: \(layoutMarginsRelativeArrangement)\n")
        desc.appendContentsOf("spacing: \(spacing)\n")
        return desc
    }
}



class Tests: XCTestCase {
    func test0() {
        printTestTitle("Test: 0 views")
        _test{ return [] }
    }
    
    func test1() {
        printTestTitle("Test: 3 content views with defined content size")
        _test{ return [ContentView(), ContentView(), ContentView()] }
    }
    
    func test2() {
        printTestTitle("Test: 3 content views, 1 without intrinsic")
        _test{
            return [ContentView(),
                ContentView(contentSize: CGSize(width: UIViewNoIntrinsicMetric, height: UIViewNoIntrinsicMetric)),
                ContentView()]
        }
        
        printTestTitle("Test: 3 content views, 2 without intrinsic")
        _test {
            return [ContentView(contentSize: CGSize(width: UIViewNoIntrinsicMetric, height: UIViewNoIntrinsicMetric)),
                ContentView(),
                ContentView(contentSize: CGSize(width: UIViewNoIntrinsicMetric, height: UIViewNoIntrinsicMetric))]
        }
        
        printTestTitle("Test: 3 content views, 3 without intrinsic")
        _test {
            return [ContentView(contentSize: CGSize(width: UIViewNoIntrinsicMetric, height: UIViewNoIntrinsicMetric)),
            ContentView(contentSize: CGSize(width: UIViewNoIntrinsicMetric, height: UIViewNoIntrinsicMetric)),
            ContentView(contentSize: CGSize(width: UIViewNoIntrinsicMetric, height: UIViewNoIntrinsicMetric))]
        }
    }
    
    // MARK: Impl
    
    func _test(views: (Void -> [UIView])) {
        print("Testing views: \(views)")
        var failedCount = 0
        let combinations = _generateConfigurations()
        combinations.forEach {
            if !_test(views, conf: $0) {
                failedCount += 1
                print("Failed combination:\n\n \($0)")
                print("\n================================================\n")
            }
        }
        print("Passed: \(combinations.count - failedCount)/\(combinations.count) combinations")
    }
    
    func _test(viewsClosure: (Void -> [UIView]), conf: StackTestConfiguraton) -> Bool {
        let stack1 = UIStackView()
        let stack2 = StackView()
        
        func constraints<T where T: UIView, T: StackViewAdapter>(view: T) -> [NSLayoutConstraint] {
            let views = viewsClosure()
            views.enumerate().forEach {
                // This is important, tag is requried to match constraints later
                view.tag = $0
                $1.test_isContentView = true
                $1.accessibilityIdentifier = "content-view-\($0)"
                view.addArrangedSubview($1)
            }
            view.ar_alignment = conf.alignment
            view.ar_distribution = conf.distribution
            view.baselineRelativeArrangement = conf.baselineRelativeArrangement
            view.layoutMarginsRelativeArrangement = conf.layoutMarginsRelativeArrangement
            
            view.translatesAutoresizingMaskIntoConstraints = false
            view.updateConstraints()
            return constraintsFor(view)
        }
        return assertEqualConstraints(constraints(stack1), constraints(stack2))
    }
    
    // MARK: Helpers
    
    func _generateConfigurations() -> [StackTestConfiguraton] {
        let alignments: [UIStackViewAlignment] = [.Fill, .Leading, .FirstBaseline, .Center, .Trailing, .LastBaseline]
        let distributions: [UIStackViewDistribution] = [.Fill, .FillEqually, .FillProportionally, .EqualSpacing, .EqualCentering]
        let spacing: [CGFloat] = [0.0]
        
        var combinations = [StackTestConfiguraton]()
        
        for axis in [UILayoutConstraintAxis.Horizontal, UILayoutConstraintAxis.Vertical] {
            for alignment in alignments {
                for distribution in distributions {
                    for marginsRelative in [true, false] {
                        for baselineRelative in [true, false] {
                            var conf = StackTestConfiguraton()
                            conf.axis = axis
                            conf.alignment = alignment
                            conf.distribution = distribution
                            conf.baselineRelativeArrangement = baselineRelative
                            conf.layoutMarginsRelativeArrangement = marginsRelative
                            combinations.append(conf)
                        }
                    }
                }
            }
        }
        return combinations
    }
    
    func printTestTitle(string: String) {
        print("\n=======================================")
        print(string)
        print("=======================================\n")
    }
}

class ContentView: UIView {
    var contentSize: CGSize = CGSize(width: 44, height: 44)
    convenience init(contentSize: CGSize) {
        self.init(frame: CGRectZero)
        self.contentSize = contentSize
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func intrinsicContentSize() -> CGSize {
        return self.contentSize
    }
}
