//
//  ACManager.swift
//
//  Created by Yury on 10/07/16.
//  Copyright © 2016 Avtolic. All rights reserved.
//

import Foundation
import UIKit

private func GCDAfter(delay:NSTimeInterval, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

private func GCDNow(closure:()->()) {
    dispatch_async(dispatch_get_main_queue(), closure)
}



public class ACNotificationTask {

    enum ACTaskState {
        case Waiting
        case Presenting
        case Active
        case Dismissing
        case Finished
    }

    let notification: ACNotification
    let animation: ACAnimation
    let presenter: ACPresenter?
    var state: ACTaskState = .Waiting {
        didSet {
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
    }

    init(notification: ACNotification, presenter: ACPresenter?, animation: ACAnimation) {
        self.notification = notification
        self.presenter = presenter
        self.animation = animation
    }
}


class ACManager {
    
    var defaultPresenter: ACPresenter?
    var defaultAnimation: ACAnimation
    
    private(set) var queue: [ACNotificationTask] = []
    
// MARK: Public methods
    
    init(defaultPresenter: ACPresenter? = ACPresenterStatusBar(), defaultAnimation: ACAnimation = ACAnimationSlideDown()) {
        self.defaultPresenter = defaultPresenter
        self.defaultAnimation = defaultAnimation
    }
    
    func addNotification(notification: ACNotification,
                         presenter: ACPresenter? = nil,
                         animation: ACAnimation? = nil) -> ACNotificationTask {
        
        let notificationTask = ACNotificationTask(notification: notification, presenter: presenter ?? defaultPresenter, animation: animation ?? defaultAnimation)
        queue.append(notificationTask)
        processNewState(notificationTask)
        return notificationTask
    }
    
// MARK: Queue methods
    
    private func activeTaskForPresenter(presenter: ACPresenter?) -> ACNotificationTask? {
        for task in queue where task.presenter === presenter && task.state != .Waiting{ return task }
        return nil
    }
    
    private func waitingTaskForPresenter(presenter: ACPresenter?) -> ACNotificationTask? {
        for task in queue where task.presenter === presenter && task.state == .Waiting { return task }
        return nil
    }
    
    private func isUsedPresenter(presenter: ACPresenter?) -> Bool {
        return activeTaskForPresenter(presenter) != nil
    }
    
    private func removeTask(task: ACNotificationTask) {
        if let index = queue.indexOf({$0 === task}) {
            queue.removeAtIndex(index)
        }
    }

// MARK: Tasks activation
    
    private func processNewState(task: ACNotificationTask) {
        let state = task.state
        
        if .Waiting == state {
            if !isUsedPresenter(task.presenter) {
                
                task.state = .Presenting
                
                present(task) {
                    task.state = .Active
                    self.processNewState(task)
                }
            }
        }
        if .Active == state {
            GCDAfter(task.notification.notificationDuration, closure: {
                
                task.state = .Dismissing
                
                if let newTask = self.waitingTaskForPresenter(task.presenter) where newTask.animation.hasInOutAnimation {
                    
                    newTask.state = .Presenting
                    
                    self.replace(task, newTask: newTask, completion: {
                        
                        task.state = .Finished
                        self.removeTask(task)
                        newTask.state = .Active
                        self.processNewState(newTask)
                    })
                }
                else {
                    self.dismiss(task, completion: {
                        task.state = .Finished
                        self.removeTask(task)
                        
                        if let newTask = self.waitingTaskForPresenter(task.presenter) {
                            self.processNewState(newTask)
                        }
                    })
                }
            })
        }
    }
    
// MARK: Animation methods
    private func present(task: ACNotificationTask, completion:() -> Void) {
        
        let presenter = task.presenter
        let animation = task.animation
        let view = task.notification.notificationView

        presenter?.addView(view)
        animation.animateIn(view: view, completion: { completion() })
    }
    
    private func replace(oldTask: ACNotificationTask, newTask: ACNotificationTask, completion:() -> Void) {

        precondition(oldTask.presenter === newTask.presenter, "ACNotifications: Presenters should be the same for replace animation.")
        precondition(newTask.animation.hasInOutAnimation, "ACNotifications: Animation does not support replacement.")
        
        let presenter = oldTask.presenter
        let oldView = oldTask.notification.notificationView
        let animation = newTask.animation
        let newView = newTask.notification.notificationView
        
        presenter?.addView(newView)
        animation.animateInOut(view: newView, previousView: oldView) {

            presenter?.removeView(oldView)
            completion()
        }
    }
    
    private func dismiss(task: ACNotificationTask, completion:() -> Void) {
        
        let presenter = task.presenter
        let animation = task.animation
        let view = task.notification.notificationView
        
        animation.animateOut(view: view, completion: {
            
            presenter?.removeView(view)
            completion()
        })
    }
}

//Поддержка принудительного закрытия (по нажатию кнопки)
//Пример: Анимация, требующая дополнительной инфы (наездающий на нотификешн статус бар)
//С приоритетом
//Presenter поддерживающий несколько нотификейшенов одновременно