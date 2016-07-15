//
//  ACNotification.swift
//
//  Created by Yury on 10/07/16.
//  Copyright © 2016 Avtolic. All rights reserved.
//

import Foundation
import UIKit

public enum ACNotificationState {
    case Waiting
    case Presenting
    case Active
    case Dismissing
    case Finished
}

// MARK: ACNotification
public protocol ACNotification {
    
    var notificationView: UIView { get }
    var notificationDuration: NSTimeInterval { get }
    func stateChanged(state: ACNotificationState)
}
// MARK: extension
public extension ACNotification {
    func stateChanged(state: ACNotificationState) { }
}

// MARK: - ACAnimation
public protocol ACAnimation {
    func animateIn (view view: UIView, completion:() -> Void)
    func animateOut(view view: UIView, completion:() -> Void)
    
    var hasInOutAnimation: Bool { get } // Default is false (see extension below)
    func animateInOut(view view: UIView, previousView: UIView, completion:() -> Void) // Does nothing by default (see extension below)
}

// MARK: extension
public extension ACAnimation {
    
    var hasInOutAnimation: Bool { return false }
    func animateInOut(view view: UIView, previousView: UIView, completion:() -> Void) {
        precondition(hasInOutAnimation, "ACNotifications: This method should never be called if hasInOutAnimation is false.")
    }
}

// MARK: - ACAnimationSimple
public protocol ACAnimationSimple: ACAnimation {
    
    var duration: NSTimeInterval { get }
    var hasInOutAnimation: Bool { get }
    func preAnimation(view: UIView) -> Void
    func inAnimation (view: UIView) -> Void
    func outAnimation(view: UIView) -> Void
}

// MARK: extension
public extension ACAnimationSimple {
    
    func animateIn(view view: UIView, completion:() -> Void) {
        
        preAnimation(view)
        UIView.animateWithDuration( duration,
                                    animations: { self.inAnimation(view) },
                                    completion: { _ in completion() })
    }
    
    func animateOut(view view: UIView, completion:() -> Void) {
        
        UIView.animateWithDuration( duration,
                                    animations: { self.outAnimation(view) },
                                    completion: { _ in completion() })
    }
    
    func animateInOut(view view: UIView, previousView: UIView, completion:() -> Void) {
        
        preAnimation(view)
        UIView.animateWithDuration( duration,
                                    animations: {
                                        self.outAnimation(previousView)
                                        self.inAnimation(view) },
                                    completion: { _ in completion() })
    }
}
