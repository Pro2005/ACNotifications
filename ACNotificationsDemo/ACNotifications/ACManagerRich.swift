//
//  ACManagerRich.swift
//
//  Created by Yury on 10/07/16.
//  Copyright © 2016 Avtolic. All rights reserved.
//

import Foundation
import UIKit

// MARK: ACNotification's protocols

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

// MARK: - ACTaskDismissProtocol

protocol ACTaskDismissProtocol : class {
    func dismissTask(task: ACTask)
}

// MARK: - ACTaskRich

// ACTaskRich has dismiss delay value. Supports ACNotifications with ACStateChangedProtocol and ACDismissProtocol
class ACTaskRich : ACTask {

    let notification: ACNotification
    let animation: ACAnimation
    let presenter: ACPresenter
    let delay: NSTimeInterval?
    weak var delegate: ACTaskDismissProtocol?
    
    var state: ACTaskState = .Waiting {
        didSet {
            if let notification = notification as? ACStateChangedProtocol {
                
                let notificationState: ACNotificationState
                switch state {
                case .Waiting: notificationState = .Waiting
                case .Presenting: notificationState = .Presenting
                case .Active: notificationState = .Active
                case .Dismissing: notificationState = .Dismissing
                case .Finished: notificationState = .Finished
                }
                notification.stateChanged(notificationState)
            }
            if state == .Active, let delay = delay {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))),
                               dispatch_get_main_queue())
                { [weak self] in self?.dismissSelf() }
            }
        }
    }

    func dismissSelf() {
        delegate?.dismissTask(self)
    }
    
    init(notification: ACNotification, presenter: ACPresenter, animation: ACAnimation, delay: NSTimeInterval? = nil) {
        self.notification = notification
        self.presenter = presenter
        self.animation = animation
        self.delay = delay
        if let notification = notification as? ACDismissProtocol {
            notification.dismissCallback = { [weak self] in
                dispatch_async(dispatch_get_main_queue())
                { self?.dismissSelf() }
            }
        }
    }
}

// MARK: - ACManagerRich

// Supports any ACTasks. Has default ACPresenter, ACAnimation and delay time. Supports ACTaskRich's dismiss functionality.
class ACManagerRich : ACManager, ACTaskDismissProtocol {

    var defaultPresenter: ACPresenter
    var defaultAnimation: ACAnimation
    var defaultDelay: NSTimeInterval?

    init(defaultPresenter: ACPresenter = ACPresenterStatusBar(), defaultAnimation: ACAnimation = ACAnimationSlideDown()) {
        self.defaultPresenter = defaultPresenter
        self.defaultAnimation = defaultAnimation
    }
    
    func addTask(task: ACTaskRich) {
        task.delegate = self
        super.addTask(task)
    }
    
    // Adds ACTaskRich with specified or default parameters.
    func addNotification(notification: ACNotification,
                         delay: NSTimeInterval? = nil,
                         presenter: ACPresenter? = nil,
                         animation: ACAnimation? = nil) -> ACTaskRich {

        let task = ACTaskRich(notification: notification,
                              presenter: presenter ?? defaultPresenter,
                              animation: animation ?? defaultAnimation,
                              delay: delay ?? defaultDelay)
        addTask(task)
        return task
    }
}

//Пример: Анимация, требующая дополнительной инфы (наезжающий на нотификешн статус бар)
//С приоритетом
//Presenter поддерживающий несколько нотификейшенов одновременно
//Можно ли требование наследования от class заменить на требование Equitable без необходимости дополнительного кода в presenters и tasks?