//
//  ACAnimations.swift
//  ACNotificationsDemo
//
//  Created by Yury on 10/07/16.
//  Copyright © 2016 Avtolic. All rights reserved.
//

import Foundation
import UIKit

class ACAnimationSlideDown: ACAnimationSimple {
    
    var duration: NSTimeInterval = 0.5
    let hasInOutAnimation: Bool = false
    
    func preAnimation(view: UIView) {
        view.transform = CGAffineTransformMakeTranslation(0, view.bounds.size.height)
    }
    
    func inAnimation(view: UIView) {
        view.transform = CGAffineTransformMakeTranslation(0, 0)
    }
    
    func outAnimation(view: UIView) {
        view.transform = CGAffineTransformMakeTranslation(0, view.bounds.size.height)
    }
}

class ACAnimationLog: ACAnimationSimple {
    var duration: NSTimeInterval = 3
    let hasInOutAnimation: Bool = true
    
    func preAnimation(view: UIView) { view.alpha = 0; print(NSDate(), "ACAnimation : preAnimation") }
    func inAnimation(view: UIView) { view.alpha = 1; print(NSDate(), "ACAnimation : inAnimation") }
    func outAnimation(view: UIView) { view.alpha = 0; print(NSDate(), "ACAnimation : outAnimation") }
}