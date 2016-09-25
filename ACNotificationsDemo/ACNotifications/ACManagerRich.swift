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
    case waiting
    case presenting
    case active
    case dismissing
    case finished
}

protocol ACStateChangedProtocol {
    func stateChanged(_ state: ACNotificationState)
}

protocol ACDismissProtocol : class {
    var dismissCallback: (() -> Void) { get set }
}

// MARK: - ACTaskDismissProtocol

protocol ACTaskDismissProtocol : class {
    func dismissTask(_ task: ACTask)
}

// MARK: - ACTaskRich

// ACTaskRich has dismiss delay value. Supports ACNotifications with ACStateChangedProtocol and ACDismissProtocol
class ACTaskRich : ACTask {

    let notification: ACNotification
    let animation: ACAnimation
    let presenter: ACPresenter
    let delay: TimeInterval?
    weak var delegate: ACTaskDismissProtocol?
    
    var state: ACTaskState = .waiting {
        didSet {
            if let notification = notification as? ACStateChangedProtocol {
                
                let notificationState: ACNotificationState
                switch state {
                case .waiting: notificationState = .waiting
                case .presenting: notificationState = .presenting
                case .active: notificationState = .active
                case .dismissing: notificationState = .dismissing
                case .finished: notificationState = .finished
                }
                notification.stateChanged(notificationState)
            }
            if state == .active, let delay = delay {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC))
                { [weak self] in self?.dismissSelf() }
            }
        }
    }

    func dismissSelf() {
        delegate?.dismissTask(self)
    }
    
    init(notification: ACNotification, presenter: ACPresenter, animation: ACAnimation, delay: TimeInterval? = nil) {
        self.notification = notification
        self.presenter = presenter
        self.animation = animation
        self.delay = delay
        if let notification = notification as? ACDismissProtocol {
            notification.dismissCallback = { [weak self] in
                DispatchQueue.main.async
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
    var defaultDelay: TimeInterval?

    init(defaultPresenter: ACPresenter = ACPresenterStatusBar(), defaultAnimation: ACAnimation = ACAnimationSlideDown()) {
        self.defaultPresenter = defaultPresenter
        self.defaultAnimation = defaultAnimation
    }
    
    func addTask(_ task: ACTaskRich) {
        task.delegate = self
        super.addTask(task)
    }
    
    // Adds ACTaskRich with specified or default parameters.
    func addNotification(_ notification: ACNotification,
                         delay: TimeInterval? = nil,
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
