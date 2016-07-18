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

public enum ACTaskState {
    case Waiting
    case Presenting
    case Active
    case Dismissing
    case Finished
}

public protocol ACTask : class {
    var notification: ACNotification { get }
    var animation: ACAnimation { get }
    var presenter: ACPresenter { get }
    var state: ACTaskState { get set }
}

public class ACNotificationTask : ACTask {

    public let notification: ACNotification
    public let animation: ACAnimation
    public let presenter: ACPresenter
    public var state: ACTaskState = .Waiting {
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

    init(notification: ACNotification, presenter: ACPresenter, animation: ACAnimation) {
        self.notification = notification
        self.presenter = presenter
        self.animation = animation
    }
}

//class ACManager<T: ACTask> {
class ACManager {
    
//    var defaultPresenter: ACPresenter?
//    var defaultAnimation: ACAnimation
    
    private(set) var queue: [ACTask] = []
    
    
//    init(defaultPresenter: ACPresenter? = ACPresenterStatusBar(), defaultAnimation: ACAnimation = ACAnimationSlideDown()) {
//        self.defaultPresenter = defaultPresenter
//        self.defaultAnimation = defaultAnimation
//    }
    
//    func addNotification(notification: ACNotification,
//                         presenter: ACPresenter? = nil,
//                         animation: ACAnimation? = nil) -> ACNotificationTask {
//        
//        let notificationTask = ACNotificationTask(notification: notification, presenter: presenter ?? defaultPresenter, animation: animation ?? defaultAnimation)
//        queue.append(notificationTask)
//        processNewState(notificationTask)
//        return notificationTask
//    }
    //MARK: Public methods
    
    func addTask(task: ACTask){
        guard task.state == .Waiting else { print("ACManager. Only .Waiting ACTask could be added to queue."); return }
        queue.append(task)
        presentTaskIfPossible(task)
    }
    
    func dismissTask(task: ACTask) {
        dismissTaskIfPossible(task)
    }

    func removeTask(task: ACTask) {
        
        guard task.state == .Waiting || task.state == .Finished else {
            print("ACManager. Only .Waiting or .Finished ACTask could be removed from queue.")
            return
        }
        
        if let index = queue.indexOf({$0 === task}) {
            queue.removeAtIndex(index)
        }
    }
    
// MARK: Queue methods
    
    private func activeTaskForPresenter(presenter: ACPresenter) -> ACTask? {
        for task in queue where task.presenter === presenter && task.state != .Waiting{ return task }
        return nil
    }
    
    private func waitingTaskForPresenter(presenter: ACPresenter) -> ACTask? {
        for task in queue where task.presenter === presenter && task.state == .Waiting { return task }
        return nil
    }
    
    private func isUsedPresenter(presenter: ACPresenter) -> Bool {
        return activeTaskForPresenter(presenter) != nil
    }
    
// MARK: Tasks manipulation
    
    private func presentTaskIfPossible(task: ACTask) {
        guard task.state == .Waiting else { print("ACManager: Only .Waiting tasks could be presented."); return }
        guard !isUsedPresenter(task.presenter) else { return }

        task.state = .Presenting
        present(task) {
            task.state = .Active
        }
    }
    
    private func dismissTaskIfPossible(task: ACTask) {
        guard task.state == .Active else { print("ACManager. Only .Active ACTask could be dismissed."); return }
        
        task.state = .Dismissing
        
        if let newTask = waitingTaskForPresenter(task.presenter) where newTask.animation.hasInOutAnimation
        {
            newTask.state = .Presenting
            replace(task, newTask: newTask, completion: {
                task.state = .Finished
                self.removeTask(task)
                newTask.state = .Active
            })
        }
        else {
            dismiss(task, completion: {
                task.state = .Finished
                self.removeTask(task)
                
                if let newTask = self.waitingTaskForPresenter(task.presenter) {
                    self.presentTaskIfPossible(newTask)
                }
            })
        }
    }
    
// MARK: Animation methods
    private func present(task: ACTask, completion:() -> Void) {
        
        let presenter = task.presenter
        let animation = task.animation
        let view = task.notification.notificationView

        presenter.addView(view)
        animation.animateIn(view: view, completion: { completion() })
    }
    
    private func replace(oldTask: ACTask, newTask: ACTask, completion:() -> Void) {

        precondition(oldTask.presenter === newTask.presenter, "ACManager: Presenters should be the same for replace animation.")
        precondition(newTask.animation.hasInOutAnimation, "ACManager: Animation does not support replacement.")
        
        let presenter = oldTask.presenter
        let oldView = oldTask.notification.notificationView
        let animation = newTask.animation
        let newView = newTask.notification.notificationView
        
        presenter.addView(newView)
        animation.animateInOut(view: newView, previousView: oldView) {

            presenter.removeView(oldView)
            completion()
        }
    }
    
    private func dismiss(task: ACTask, completion:() -> Void) {
        
        let presenter = task.presenter
        let animation = task.animation
        let view = task.notification.notificationView
        
        animation.animateOut(view: view, completion: {
            
            presenter.removeView(view)
            completion()
        })
    }
}

//Поддержка принудительного закрытия (по нажатию кнопки)
//Пример: Анимация, требующая дополнительной инфы (наездающий на нотификешн статус бар)
//С приоритетом
//Presenter поддерживающий несколько нотификейшенов одновременно
//Можно ли требование наследования от class заменить на требование Equitable без необходимости дополнительного кода в presenters и tasks?