//
//  ACManager.swift
//
//  Created by Yury on 10/07/16.
//  Copyright © 2016 Avtolic. All rights reserved.
//

import Foundation
import UIKit

// MARK: - ACTask

enum ACTaskState {
    case waiting
    case presenting
    case active
    case dismissing
    case finished
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
    var state: ACTaskState = .waiting
    
    init(notification: ACNotification, presenter: ACPresenter, animation: ACAnimation) {
        self.notification = notification
        self.presenter = presenter
        self.animation = animation
    }
}

// MARK: - ACManager
class ACManager {
    
    fileprivate(set) var queue: [ACTask] = []
    
    // MARK: Public methods
    
    func addTask(_ task: ACTask){
        guard task.state == .waiting else { print("ACManager. Only .Waiting ACTask could be added to queue."); return }
        queue.append(task)
        presentTaskIfPossible(task)
    }
    
    func dismissTask(_ task: ACTask) {
        dismissTaskIfPossible(task)
    }
    
    func removeTask(_ task: ACTask) {
        guard task.state == .waiting || task.state == .finished else {
            print("ACManager. Only .Waiting or .Finished ACTask could be removed from queue.")
            return
        }
        if let index = queue.index(where: {$0 === task}) {
            queue.remove(at: index)
        }
    }
    
    // MARK: Queue methods
    
    fileprivate func activeTaskForPresenter(_ presenter: ACPresenter) -> ACTask? {
        for task in queue where task.presenter === presenter && task.state != .waiting{ return task }
        return nil
    }
    
    fileprivate func waitingTaskForPresenter(_ presenter: ACPresenter) -> ACTask? {
        for task in queue where task.presenter === presenter && task.state == .waiting { return task }
        return nil
    }
    
    fileprivate func isUsedPresenter(_ presenter: ACPresenter) -> Bool {
        return activeTaskForPresenter(presenter) != nil
    }
    
    // MARK: Tasks manipulation
    
    fileprivate func presentTaskIfPossible(_ task: ACTask) {
        guard task.state == .waiting else { print("ACManager: Only .Waiting tasks could be presented."); return }
        guard !isUsedPresenter(task.presenter) else { return }
        
        task.state = .presenting
        present(task) {
            task.state = .active
        }
    }
    
    fileprivate func dismissTaskIfPossible(_ task: ACTask) {
        guard task.state == .active else { print("ACManager. Only .Active ACTask could be dismissed."); return }
        
        task.state = .dismissing
        
        if let newTask = waitingTaskForPresenter(task.presenter) , newTask.animation.hasInOutAnimation
        {
            newTask.state = .presenting
            replace(task, newTask: newTask, completion: {
                task.state = .finished
                self.removeTask(task)
                newTask.state = .active
            })
        }
        else {
            dismiss(task, completion: {
                task.state = .finished
                self.removeTask(task)
                
                if let newTask = self.waitingTaskForPresenter(task.presenter) {
                    self.presentTaskIfPossible(newTask)
                }
            })
        }
    }
    
    // MARK: Animation methods
    
    fileprivate func present(_ task: ACTask, completion:@escaping () -> Void) {
        
        let presenter = task.presenter
        let animation = task.animation
        let view = task.notification.notificationView
        
        presenter.addView(view)
        animation.animateIn(view: view, completion: { completion() })
    }
    
    fileprivate func replace(_ oldTask: ACTask, newTask: ACTask, completion:() -> Void) {
        
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
    
    fileprivate func dismiss(_ task: ACTask, completion:@escaping () -> Void) {
        
        let presenter = task.presenter
        let animation = task.animation
        let view = task.notification.notificationView
        
        animation.animateOut(view: view, completion: {
            
            presenter.removeView(view)
            completion()
        })
    }
}
