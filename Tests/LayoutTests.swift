// The MIT License (MIT)
//
// Copyright (c) 2017 Alexander Grebenyuk (github.com/kean).

import Arranged
import UIKit
import XCTest

var testCasesCount = 0
var failedTestCasesCount = 0

var constraintsPrinted = 0
let maxConstraintsPrinted = 50


class LayoutTests: XCTestCase {
    func testWithoutItems() {
        printTestTitle("Test: 0 views")
        _test{ return [] }
    }
    
    func testWithItems() {
        printTestTitle("Test: 1 content view")
        _test{ return [ContentView()] }
        
        printTestTitle("Test: 3 content view")
        _test{ return [ContentView(), ContentView(), ContentView()] }
    }
    
    func testWithItemSomeOfWhichHaveNoIntrinsic() {
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
    
    func testWithHiddenItems() {
        printTestTitle("Test: 1 content view, hidden")
        _test(views: {
            return [ContentView()]
        }, update: { stack, views in
            stack.setArrangedView(views[0], hidden: true)
        })
        
        printTestTitle("Test: 2 content views, 1st hidden")
        _test(views: {
            return [ContentView(), ContentView()]
        }, update: { stack, views in
            stack.setArrangedView(views[0], hidden: true)
        })
        
        printTestTitle("Test: 2 content views, 2nd hidden")
        _test(views: {
            return [ContentView(), ContentView()]
        }, update: { stack, views in
            stack.setArrangedView(views[1], hidden: true)
        })
        
        printTestTitle("Test: 2 content views, both hidden")
        _test(views: {
            return [ContentView(), ContentView()]
        }, update: { stack, views in
            stack.setArrangedView(views[0], hidden: true)
            stack.setArrangedView(views[1], hidden: true)
        })
        
        printTestTitle("Test: 3 content views, all hidden")
        _test(views: {
            return [ContentView(), ContentView(), ContentView()]
        }, update: { stack, views in
            stack.setArrangedView(views[0], hidden: true)
            stack.setArrangedView(views[1], hidden: true)
            stack.setArrangedView(views[2], hidden: true)
        })

        printTestTitle("Test: 3 content views, 1st and 2nd hidden")
        _test(views: {
            return [ContentView(), ContentView(), ContentView()]
        }, update: { stack, views in
            stack.setArrangedView(views[0], hidden: true)
            stack.setArrangedView(views[1], hidden: true)
        })

        printTestTitle("Test: 3 content views, 2nd and 3rd hidden")
        _test(views: {
            return [ContentView(), ContentView(), ContentView()]
        }, update: { stack, views in
            stack.setArrangedView(views[1], hidden: true)
            stack.setArrangedView(views[2], hidden: true)
        })
    }
    
    func testRemovingItems() {
        printTestTitle("Test: 2 content views, 1st removed")
        _test(views: {
            return [ContentView(), ContentView()]
        }, update: { stack, views in
            stack.removeArrangedSubview(views[1])
        })
    }
    
    func testTextBasedViews() {
        printTestTitle("Test: 2 text based views (empty)")
        _test {
            return [UILabel(), UILabel()]
        }
        
        printTestTitle("Test: 2 text based views (one not empty)")
        _test {
            let label1 = UILabel()
            label1.text = "Test"
            let label2 = UILabel()
            label2.text = "Test"
            return [label1, label2, UILabel()]
        }
    }
    
    // MARK: Tests Implementation

    func _test(_ views: @escaping (() -> [UIView])) {
        _test(views: views, update: nil)
    }
    
    func _test(views: @escaping (() -> [UIView]), update: ((StackViewAdapter, [UIView]) -> Void)?) {
        var failedCount = 0
        let combinations = StackTestConfiguraton.generate()
        combinations.forEach {
            if !_test(views, update: update, conf: $0) {
                failedCount += 1
            }
        }
        print("Current pass: \(combinations.count - failedCount)/\(combinations.count) combinations")
        
        testCasesCount += combinations.count
        failedTestCasesCount += failedCount
        
        print("Total passes: \(testCasesCount - failedTestCasesCount)/\(testCasesCount) combinations")
    }
    
    func _test(_ viewsClosure: @escaping (() -> [UIView]), update: ((StackViewAdapter, [UIView]) -> Void)?, conf: StackTestConfiguraton) -> Bool {
        let stack1 = UIStackView()
        let stack2 = StackView()
        
        func constraints<T>(_ stack: T) -> [NSLayoutConstraint] where T: UIView, T: StackViewAdapter {
            let views = viewsClosure()
            views.enumerated().forEach {
                // This is important, tag is requried to match constraints later
                $1.tag = $0
                $1.test_isContentView = true
                $1.accessibilityIdentifier = "content-view-\($0)"
                stack.addArrangedSubview($1)
            }
            stack.axis = conf.axis
            stack.ar_alignment = conf.alignment
            stack.ar_distribution = conf.distribution
            stack.isBaselineRelativeArrangement = conf.isBaselineRelativeArrangement
            stack.isLayoutMarginsRelativeArrangement = conf.isLayoutMarginsRelativeArrangement
            stack.spacing = conf.spacing
            
            if let update = update {
                update(stack, views)
            }
            
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.updateConstraints()
            return constraintsFor(stack)
        }
        
        XCTAssertEqual(stack1.axis, stack2.axis)
        XCTAssertEqual(stack1.axis, stack2.axis)
        XCTAssertEqual(stack1.ar_alignment, stack2.ar_alignment)
        XCTAssertEqual(stack1.ar_distribution, stack2.ar_distribution)
        XCTAssertEqual(stack1.isLayoutMarginsRelativeArrangement, stack2.isLayoutMarginsRelativeArrangement)
        XCTAssertEqual(stack1.isBaselineRelativeArrangement, stack2.isBaselineRelativeArrangement)
        XCTAssertEqual(stack1.spacing, stack2.spacing)
        XCTAssertEqual(stack1.arrangedSubviews.count, stack2.arrangedSubviews.count)
        
        let constraints1 = constraints(stack1)
        let constraints2 = constraints(stack2)
        let success = assertEqualConstraints(constraints1, constraints2)
        if !success {
            print("\nFailed configuration:\n\n\(conf)")
            
            print("UIStackView constraints (count: \(constraints1.count)):\n")
            _print(constraints1)
            
            print("Arranged.StackView constraints (count: \(constraints2.count)):\n")
            _print(constraints2)
            
            print("\n===============================================")
        }
        return success
    }
    
    // MARK: Helpers
    
    func printTestTitle(_ string: String) {
        print("\n\n===============================================")
        print(string)
    }
    
    func _print(_ constraints: [NSLayoutConstraint]) {
        constraintsPrinted += 1
        guard constraintsPrinted < maxConstraintsPrinted else {
            return
        }
        print("Constraints (count: \(constraints.count)):")
        constraints.forEach {
            print($0)
        }
    }
}

class ContentView: UIView {
    var contentSize: CGSize = CGSize(width: 44, height: 44)
    convenience init(contentSize: CGSize) {
        self.init(frame: CGRect.zero)
        self.contentSize = contentSize
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return self.contentSize
    }
}
