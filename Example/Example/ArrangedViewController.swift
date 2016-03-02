//
//  ArrangedViewController.swift
//  Example
//
//  Created by Alexander Grebenyuk on 01/03/16.
//  Copyright © 2016 Alexander Grebenyuk. All rights reserved.
//

import UIKit
import Arranged
import PureLayout

class ArrangedViewController: BaseStackViewController<StackView> {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override init() {
        super.init(nibName: nil, bundle: nil)
    }

    override func createStackView() -> StackView {
        return StackView()
    }
}
