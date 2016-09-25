//
//  ACManager.swift
//
//  Created by Yury on 10/07/16.
//  Copyright © 2016 Avtolic. All rights reserved.
//

import Foundation
import UIKit


enum ACNotificationState {
    case waiting
    case presenting
    // dismissBlock - a block that could be called if notification wants to dismiss itself. Is valid only if state is .active.
    // Notification could decide itself when it should be dismissed. Example: the same notification with short or long text could
    // prefer to show itself with different durability depending on the text length
    case active(dismissBlock: () -> Void)
    case dismissing
    case finished
}

// MARK: - Protocols

protocol ACStateListenProtocol {
    // newState - a new state of notification
    func stateChanged(newState: ACNotificationState)
}

protocol ACTaskDismissProtocol : class {
    func dismiss(task: ACTask)
}

// MARK: -

// ACTaskRich supports ACNotifications with ACStateListenProtocol
class ACTaskRich: ACTaskBase {
    
    weak var delegate: ACTaskDismissProtocol?
    var delay: TimeInterval?
    
    fileprivate func notificationState() -> ACNotificationState {
        switch state {
        case .waiting: return .waiting
        case .presenting: return .presenting
        case .active:
            let dismissBlock: () -> Void = { [weak self] in
                guard let this = self else { return }
                DispatchQueue.main.async {
                    this.delegate?.dismiss(task: this)
                }
            }
            return .active(dismissBlock: dismissBlock)
        case .dismissing: return .dismissing
        case .finished: return .finished
        }
    }
    
    override var state: ACTaskState {
        didSet {
            if let notification = notification as? ACStateListenProtocol {
                let newNotificationState = notificationState()
                DispatchQueue.main.async {
                    notification.stateChanged(newState: newNotificationState)
                }
            }
            if state == .active, let delay = delay {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) { [weak self] in
                    guard let this = self else { return }
                    this.delegate?.dismiss(task: this)
                }
            }
        }
    }
    
    init(notification: ACNotification, presenter: ACPresenter, animation: ACAnimation, delay: TimeInterval? = nil) {
        self.delay = delay
        super.init(notification: notification, presenter: presenter, animation: animation)
    }
}

// MARK: -

// Supports any ACTasks. Has default ACPresenter, ACAnimation and delay time. Supports ACTaskRich's dismiss functionality.
class ACManager : ACManagerBase, ACTaskDismissProtocol {

    var defaultPresenter: ACPresenter
    var defaultAnimation: ACAnimation
    var defaultDelay: TimeInterval?

    init(defaultPresenter: ACPresenter = ACPresenterLog(), defaultAnimation: ACAnimation = ACAnimationSlideDown()) {
        self.defaultPresenter = defaultPresenter
        self.defaultAnimation = defaultAnimation
    }
    
    func add(task: ACTaskRich) {
        task.delegate = self
        super.add(task: task)
    }
    
    // Adds ACTaskRich with specified or default parameters.
    func add(notification: ACNotification,
             delay: TimeInterval? = nil,
             presenter: ACPresenter? = nil,
             animation: ACAnimation? = nil) -> ACTaskRich {

        let task = ACTaskRich(notification: notification,
                              presenter: presenter ?? defaultPresenter,
                              animation: animation ?? defaultAnimation,
                              delay: delay ?? defaultDelay)
        add(task: task)
        return task
    }
}

//Пример: Анимация, требующая дополнительной инфы (наезжающий на нотификешн статус бар)
//С приоритетом
//Presenter поддерживающий несколько нотификейшенов одновременно
//Можно ли требование наследования от class заменить на требование Equitable без необходимости дополнительного кода в presenters и tasks?
