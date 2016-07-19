//
//  ACBaseExtended.swift
//  ACNotificationsDemo
//
//  Created by Yury on 18/07/16.
//  Copyright © 2016 Avtolic. All rights reserved.
//

import UIKit

// MARK: ACNotification

enum ACNotificationState {
    case Waiting
    case Presenting
    case Active
    case Dismissing
    case Finished
}

protocol ACStateChangedProtocol {
    func stateChanged(state: ACNotificationState)
}

protocol ACDismissProtocol : class {
    var dismissCallback: (() -> Void) { get set }
}

// MARK: - ACAnimationSimple

protocol ACAnimationSimple: ACAnimation {
    
    var duration: NSTimeInterval { get }
    var hasInOutAnimation: Bool { get }
    func preAnimation(view: UIView) -> Void
    func inAnimation (view: UIView) -> Void
    func outAnimation(view: UIView) -> Void
}

extension ACAnimationSimple {
    
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