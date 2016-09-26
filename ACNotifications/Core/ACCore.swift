//
//  ACBase.swift
//  ACNotificationsDemo
//
//  Created by Yury on 18/07/16.
//  Copyright © 2016 Avtolic. All rights reserved.
//

import UIKit


// MARK: - ACNotification
public protocol ACNotification {
    var notificationView: UIView { get }
}

// MARK: - ACPresenter
public protocol ACPresenter: class {
    func add(view: UIView)
    func remove(view: UIView)
}

// MARK: - ACAnimation
public protocol ACAnimation {
    func animateIn (view: UIView, completion:@escaping () -> Void)
    func animateOut(view: UIView, completion:@escaping () -> Void)
    
    var hasInOutAnimation: Bool { get } // Default is false (see extension below)
    func animateInOut(view: UIView, previousView: UIView, completion:() -> Void) // Does nothing by default (see extension below)
}

// MARK: extension
extension ACAnimation {
    public var hasInOutAnimation: Bool { return false }
    public func animateInOut(view: UIView, previousView: UIView, completion:() -> Void) {
        precondition(hasInOutAnimation, "ACNotifications: This method should never be called if hasInOutAnimation is false.")
    }
}

// MARK: - ACAnimationSimple
public protocol ACAnimationSimple: ACAnimation {
    
    var duration: TimeInterval { get }
    var hasInOutAnimation: Bool { get }
    func preAnimation(_ view: UIView) -> Void
    func inAnimation (_ view: UIView) -> Void
    func outAnimation(_ view: UIView) -> Void
}

extension ACAnimationSimple {
    
    public func animateIn(view: UIView, completion:@escaping () -> Void) {
        
        preAnimation(view)
        UIView.animate( withDuration: duration,
                                    animations: { self.inAnimation(view) },
                                    completion: { _ in completion() })
    }
    
    public func animateOut(view: UIView, completion:@escaping () -> Void) {
        
        UIView.animate( withDuration: duration,
                                    animations: { self.outAnimation(view) },
                                    completion: { _ in completion() })
    }
    
    func animateInOut(view: UIView, previousView: UIView, completion:@escaping () -> Void) {
        
        preAnimation(view)
        UIView.animate( withDuration: duration,
                                    animations: {
                                        self.outAnimation(previousView)
                                        self.inAnimation(view) },
                                    completion: { _ in completion() })
    }
}
