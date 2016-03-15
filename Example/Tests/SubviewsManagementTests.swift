// The MIT License (MIT)
//
// Copyright (c) 2016 Alexander Grebenyuk (github.com/kean).

import Arranged
import UIKit
import XCTest

class SubviewsManagementTests: XCTestCase {
    func testInitialization() {
        let view = UIView()
        let stack = StackView(arrangedSubviews: [view])
        XCTAssertEqual(stack.arrangedSubviews.count, 1)
        XCTAssertTrue(stack.arrangedSubviews.contains(view))
        XCTAssertTrue(stack.subviews.contains(view))
    }
    
    func testThatArrangedViewAreAdded() {
        let stack = StackView()
        let view = UIView()
        stack.addArrangedSubview(view)
        XCTAssertEqual(stack.arrangedSubviews.count, 1)
        XCTAssertTrue(stack.arrangedSubviews.contains(view))
        XCTAssertTrue(stack.subviews.contains(view))
    }
    
    func testThatArrangedViewsAreRemoved() {
        let stack = StackView()
        let view = UIView()
        stack.addArrangedSubview(view)
        XCTAssertEqual(stack.arrangedSubviews.count, 1)
        XCTAssertTrue(stack.arrangedSubviews.contains(view))
        XCTAssertTrue(stack.subviews.contains(view))
        
        stack.removeArrangedSubview(view)
        XCTAssertEqual(stack.arrangedSubviews.count, 0)
        XCTAssertFalse(stack.arrangedSubviews.contains(view))
        XCTAssertTrue(stack.subviews.contains(view))
        
        view.removeFromSuperview()
        XCTAssertFalse(stack.subviews.contains(view))
    }
    
    func testThatArrangedViewIsRemovedWhenItIsRemovedFromSuperview() {
        let stack = StackView()
        let view = UIView()
        stack.addArrangedSubview(view)
        XCTAssertEqual(stack.arrangedSubviews.count, 1)
        XCTAssertTrue(stack.arrangedSubviews.contains(view))
        XCTAssertTrue(stack.subviews.contains(view))
        
        view.removeFromSuperview()
        XCTAssertEqual(stack.arrangedSubviews.count, 0)
        XCTAssertFalse(stack.arrangedSubviews.contains(view))
        XCTAssertFalse(stack.subviews.contains(view))
    }

    func testThatViewCanBeAddedAsSubviewWithoutBecomingManagedByStackView() {
        let view = UIView()
        let stack = StackView(arrangedSubviews: [view])
        view.removeFromSuperview()
        XCTAssertEqual(stack.arrangedSubviews.count, 0)
        XCTAssertFalse(stack.arrangedSubviews.contains(view))
        XCTAssertFalse(stack.subviews.contains(view))
    }
    
    func testThatItemCanBeAddedAsSubviewWithoutBecomingArranged() {
        let stack = StackView()
        let view = UIView()
        stack.addSubview(view)
        XCTAssertEqual(stack.arrangedSubviews.count, 0)
        XCTAssertFalse(stack.arrangedSubviews.contains(view))
        XCTAssertTrue(stack.subviews.contains(view))
    }

    func testThatInsertArrangedSubivewAtIndexMethodUpdatesIndexOfExistingSubview() {
        let stack = StackView()
        let view1 = UIView()
        let view2 = UIView()
        stack.addArrangedSubview(view1)
        stack.addArrangedSubview(view2)
        XCTAssertEqual(stack.arrangedSubviews.count, 2)
        XCTAssertTrue(stack.arrangedSubviews[0] === view1)
        XCTAssertTrue(stack.arrangedSubviews[1] === view2)

        stack.insertArrangedSubview(view2, atIndex: 0)
        XCTAssertEqual(stack.arrangedSubviews.count, 2)
        XCTAssertTrue(stack.arrangedSubviews[0] === view2)
        XCTAssertTrue(stack.arrangedSubviews[1] === view1)
    }
}