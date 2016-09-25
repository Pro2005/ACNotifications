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
    
    var duration: TimeInterval = 5
    let hasInOutAnimation: Bool = false
    
    func preAnimation(_ view: UIView) {
        view.transform = CGAffineTransform(translationX: 0, y: -view.bounds.size.height)
    }
    
    func inAnimation(_ view: UIView) {
        view.transform = CGAffineTransform(translationX: 0, y: 0)
    }
    
    func outAnimation(_ view: UIView) {
        view.transform = CGAffineTransform(translationX: 0, y: -view.bounds.size.height)
    }
}

class ACAnimationLog: ACAnimationSimple {
    var duration: TimeInterval = 3
    let hasInOutAnimation: Bool = true
    
    func preAnimation(_ view: UIView) { view.alpha = 0; print(Date(), "ACAnimation : preAnimation") }
    func inAnimation(_ view: UIView) { view.alpha = 1; print(Date(), "ACAnimation : inAnimation") }
    func outAnimation(_ view: UIView) { view.alpha = 0; print(Date(), "ACAnimation : outAnimation") }
}
