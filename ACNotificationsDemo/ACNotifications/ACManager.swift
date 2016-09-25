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
    
    func add(task: ACTask){
        guard task.state == .waiting else { print("ACManager. Only .waiting ACTask could be added to queue."); return }
        queue.append(task)
        presentIfPossible(task: task)
    }
    
    func dismiss(task: ACTask) {
        dismissIfPossible(task: task)
    }
    
    func remove(task: ACTask) {
        guard task.state == .waiting || task.state == .finished else {
            print("ACManager. Only .waiting or .finished ACTask could be removed from queue.")
            return
        }
        if let index = queue.index(where: {$0 === task}) {
            queue.remove(at: index)
        }
    }
    
    // MARK: Queue methods
    
    fileprivate func activeTask(presenter: ACPresenter) -> ACTask? {
        return queue.first { $0.presenter === presenter && $0.state != .waiting }
    }
    
    fileprivate func waitingTask(presenter: ACPresenter) -> ACTask? {
        return queue.first { $0.presenter === presenter && $0.state == .waiting }
    }
    
    fileprivate func isUsed(presenter: ACPresenter) -> Bool {
        return activeTask(presenter: presenter) != nil
    }
    
    // MARK: Tasks manipulation
    
    fileprivate func presentIfPossible(task: ACTask) {
        guard task.state == .waiting else { print("ACManager: Only .waiting tasks could be presented."); return }
        guard !isUsed(presenter: task.presenter) else { return }
        
        task.state = .presenting
        present(task: task) {
            task.state = .active
        }
    }
    
    fileprivate func dismissIfPossible(task: ACTask) {
        guard task.state == .active else { print("ACManager. Only .Active ACTask could be dismissed."); return }
        
        task.state = .dismissing
        
        if let newTask = waitingTask(presenter: task.presenter) , newTask.animation.hasInOutAnimation
        {
            newTask.state = .presenting
            replace(oldTask: task, newTask: newTask, completion: {
                task.state = .finished
                self.remove(task: task)
                newTask.state = .active
            })
        }
        else {
            dismiss(task: task, completion: {
                task.state = .finished
                self.remove(task: task)
                
                if let newTask = self.waitingTask(presenter: task.presenter) {
                    self.presentIfPossible(task: newTask)
                }
            })
        }
    }
    
    // MARK: Animation methods
    
    fileprivate func present(task: ACTask, completion:@escaping () -> Void) {
        
        let presenter = task.presenter
        let animation = task.animation
        let view = task.notification.notificationView
        
        presenter.add(view: view)
        animation.animateIn(view: view, completion: { completion() })
    }
    
    fileprivate func replace(oldTask: ACTask, newTask: ACTask, completion:() -> Void) {
        
        precondition(oldTask.presenter === newTask.presenter, "ACManager: Presenters should be the same for replace animation.")
        precondition(newTask.animation.hasInOutAnimation, "ACManager: Animation does not support replacement.")
        
        let presenter = oldTask.presenter
        let oldView = oldTask.notification.notificationView
        let animation = newTask.animation
        let newView = newTask.notification.notificationView
        
        presenter.add(view: newView)
        animation.animateInOut(view: newView, previousView: oldView) {
            
            presenter.remove(view: oldView)
            completion()
        }
    }
    
    fileprivate func dismiss(task: ACTask, completion:@escaping () -> Void) {
        
        let presenter = task.presenter
        let animation = task.animation
        let view = task.notification.notificationView
        
        animation.animateOut(view: view, completion: {
            
            presenter.remove(view: view)
            completion()
        })
    }
}
