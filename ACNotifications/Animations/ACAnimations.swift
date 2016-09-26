//
//  ACAnimations.swift
//  ACNotificationsDemo
//
//  Created by Yury on 10/07/16.
//  Copyright © 2016 Avtolic. All rights reserved.
//

import Foundation
import UIKit

open class ACAnimationSlideDown: ACAnimationSimple {
    
    open let duration: TimeInterval
    open let hasInOutAnimation: Bool = false
    
    public init(duration: TimeInterval = 0.25) {
        self.duration = duration
    }
    
    open func preAnimation(_ view: UIView) {
        view.transform = CGAffineTransform(translationX: 0, y: -view.bounds.size.height)
    }
    
    open func inAnimation(_ view: UIView) {
        view.transform = CGAffineTransform(translationX: 0, y: 0)
    }
    
    open func outAnimation(_ view: UIView) {
        view.transform = CGAffineTransform(translationX: 0, y: -view.bounds.size.height)
    }
}

open class ACAnimationLog: ACAnimationSimple {
    open var duration: TimeInterval = 3
    open let hasInOutAnimation: Bool = true
    
    open func preAnimation(_ view: UIView) { view.alpha = 0; print(Date(), "ACAnimation : preAnimation") }
    open func inAnimation(_ view: UIView) { view.alpha = 1; print(Date(), "ACAnimation : inAnimation") }
    open func outAnimation(_ view: UIView) { view.alpha = 0; print(Date(), "ACAnimation : outAnimation") }
}
