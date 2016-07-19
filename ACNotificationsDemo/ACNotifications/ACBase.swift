//
//  ACBase.swift
//  ACNotificationsDemo
//
//  Created by Yury on 18/07/16.
//  Copyright © 2016 Avtolic. All rights reserved.
//

import UIKit

// MARK: - ACNotification
protocol ACNotification {
    var notificationView: UIView { get }
}

// MARK: - ACAnimation
protocol ACAnimation {
    func animateIn (view view: UIView, completion:() -> Void)
    func animateOut(view view: UIView, completion:() -> Void)
    
    var hasInOutAnimation: Bool { get } // Default is false (see extension below)
    func animateInOut(view view: UIView, previousView: UIView, completion:() -> Void) // Does nothing by default (see extension below)
}

// MARK: extension
extension ACAnimation {
    var hasInOutAnimation: Bool { return false }
    func animateInOut(view view: UIView, previousView: UIView, completion:() -> Void) {
        precondition(hasInOutAnimation, "ACNotifications: This method should never be called if hasInOutAnimation is false.")
    }
}

// MARK: - ACPresenter
protocol ACPresenter: class {
    func addView(view: UIView)
    func removeView(view: UIView)
}

// MARK: - ACTask
enum ACTaskState {
    case Waiting
    case Presenting
    case Active
    case Dismissing
    case Finished
}

protocol ACTask : class {
    var notification: ACNotification { get }
    var animation: ACAnimation { get }
    var presenter: ACPresenter { get }
    var state: ACTaskState { get set }
}

class ACTaskBase : ACTask {
    
    let notification: ACNotification
    let animation: ACAnimation
    let presenter: ACPresenter
    var state: ACTaskState = .Waiting
    
    init(notification: ACNotification, presenter: ACPresenter, animation: ACAnimation) {
        self.notification = notification
        self.presenter = presenter
        self.animation = animation
    }
}

// MARK: - ACManager
class ACManagerBase {
    
    private(set) var queue: [ACTask] = []
    
    // MARK: Public methods
    
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

