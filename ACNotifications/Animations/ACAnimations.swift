//
//  ACAnimations.swift
//  ACNotificationsDemo
//
//  Created by Yury on 10/07/16.
//  Copyright © 2016 Avtolic. All rights reserved.
//

import Foundation
import UIKit

public class ACAnimationSlideDown: ACAnimationSimple {
    
    public let duration: TimeInterval
    public let hasInOutAnimation: Bool = false
    
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

public class ACAnimationLog: ACAnimationSimple {
    public var duration: TimeInterval = 3
    public let hasInOutAnimation: Bool = true
    
    public func preAnimation(_ view: UIView) { view.alpha = 0; print(Date(), "ACAnimation : preAnimation") }
    public func inAnimation(_ view: UIView) { view.alpha = 1; print(Date(), "ACAnimation : inAnimation") }
    public func outAnimation(_ view: UIView) { view.alpha = 0; print(Date(), "ACAnimation : outAnimation") }
}
