//
//  ACPresenter.swift
//  ACNotificationsDemo
//
//  Created by Yury on 11/07/16.
//  Copyright © 2016 Avtolic. All rights reserved.
//

import Foundation
import UIKit


class ACPresenterLog: ACPresenter {
    func add(view: UIView) {
        print(Date(), "ACPresenter : addView")
        UIApplication.shared.keyWindow?.addSubview(view)
    }
    func remove(view: UIView) {
        print(Date(), "ACPresenter : removeView")
        view.removeFromSuperview()
    }
}

class ACPresenterView: ACPresenter {
    let presenterView: UIView
    
    init(view: UIView) {
        presenterView = view
    }
    
    func add(view: UIView) {
        presenterView.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: presenterView, attribute: .leading, multiplier: 1, constant: 0).isActive = true

        NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: presenterView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: presenterView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        
        presenterView.layoutSubviews()
    }
    
    func remove(view: UIView) {
        view.removeFromSuperview()
    }
}

class ACViewControllerWithStatusBar: UIViewController {
    override var prefersStatusBarHidden: Bool {
        return false
    }
}

class ACPresenterStatusBar: ACPresenter {
    
    fileprivate let window: UIWindow
    fileprivate let viewController = ACViewControllerWithStatusBar()
    fileprivate let presenterView: UIView
    
    init() {
        // Abous status bar size
        //http://stackoverflow.com/questions/31581526/ios9-covering-status-bar-with-custom-uiwindow-wrong-position?rq=1
        var rect = UIScreen.main.bounds
        rect.size.height = 20
        window = UIWindow(frame: rect)
        window.backgroundColor = UIColor.clear
        window.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window.windowLevel = UIWindowLevelStatusBar
        window.rootViewController = viewController
        window.isHidden = false
        presenterView = viewController.view
        
    }
    
    func add(view: UIView) {
        presenterView.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: presenterView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: presenterView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: presenterView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        
        presenterView.layoutSubviews()
    }
    
    func remove(view: UIView) {
        view.removeFromSuperview()
    }
}

class ACPresenterNavigationBar: ACPresenter {
    init(navigationBar: UINavigationBar) { }
    func add(view: UIView) { }
    func remove(view: UIView) { }
}

