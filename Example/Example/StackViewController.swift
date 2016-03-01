//
//  StackViewController.swift
//  Example
//
//  Created by Alexander Grebenyuk on 01/03/16.
//  Copyright © 2016 Alexander Grebenyuk. All rights reserved.
//

import UIKit

class StackViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var viewToRemove: UIView!
    
    @IBAction func oneTapped(sender: AnyObject) {
        (sender as! UIView).hidden = true
    }
    
    @IBAction func twoTapped(sender: AnyObject) {
        (sender as! UIView).hidden = true
    }
    
    @IBAction func threeTapped(sender: AnyObject) {
        (sender as! UIView).hidden = true
    }
    
    @IBAction func verticalTapped(sender: AnyObject) {
        self.stackView.axis = .Vertical
    }
    
    @IBAction func horizontalTapped(sender: AnyObject) {
        self.stackView.axis = .Horizontal
    }
    
    @IBAction func spacingTapped(sender: UIView) {
        self.stackView.spacing = CGFloat(sender.tag)
    }
    
    @IBAction func hideAll(sender: UIView) {
        self.stackView.subviews.forEach { $0.hidden = true }
    }
    
    @IBAction func showAll(sender: UIView) {
        self.stackView.subviews.forEach { $0.hidden = false }
    }
    
    @IBAction func alignmentFill(sender: UIView) {
        self.stackView.alignment = .Fill
    }
    
    @IBAction func alignmentCenter(sender: UIView) {
        self.stackView.alignment = .Center
    }
    
    @IBAction func alignmentTrailing(sender: UIView) {
        self.stackView.alignment = .Trailing
    }
    
    @IBAction func alignmentLeading(sender: UIView) {
        self.stackView.alignment = .Leading
    }
    
    @IBAction func distributionFill(sender: UIView) {
        self.stackView.distribution = .Fill
    }
    
    @IBAction func distributionFillEqually(sender: UIView) {
        self.stackView.distribution = .FillEqually
    }
    
    @IBAction func distributionFillProportionally(sender: UIView) {
        self.stackView.distribution = .FillProportionally
    }
    
    @IBAction func distributionEqualSpacing(sender: UIView) {
        self.stackView.distribution = .EqualSpacing
    }
    
    @IBAction func distributionEqualCentering(sender: UIView) {
        self.stackView.distribution = .EqualCentering
    }
    
    @IBAction func marginsTapped(sender: UIView) {
        switch sender.tag {
        case 100:
            self.stackView.layoutMarginsRelativeArrangement = true
            self.stackView.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        case 200:
            self.stackView.layoutMarginsRelativeArrangement = true
            self.stackView.layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40);
        default:
            self.stackView.layoutMarginsRelativeArrangement = false
            self.stackView.layoutMargins = UIEdgeInsetsZero
        }
    }
}