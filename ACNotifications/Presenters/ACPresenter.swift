//
//  ACPresenter.swift
//  ACNotificationsDemo
//
//  Created by Yury on 11/07/16.
//  Copyright © 2016 Avtolic. All rights reserved.
//

import Foundation
import UIKit


public class ACPresenterLog: ACPresenter {
    open func add(view: UIView) {
        print(Date(), "ACPresenter : addView")
        UIApplication.shared.keyWindow?.addSubview(view)
    }
    open func remove(view: UIView) {
        print(Date(), "ACPresenter : removeView")
        view.removeFromSuperview()
    }
    
    public init() {
        // do nothing
    }
}

public class ACPresenterView: ACPresenter {
    public let presenterView: UIView
    
    public init(view: UIView) {
        presenterView = view
    }
    
    public func add(view: UIView) {
        presenterView.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: presenterView, attribute: .leading, multiplier: 1, constant: 0).isActive = true

        NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: presenterView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: presenterView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        
        presenterView.layoutSubviews()
    }
    
    public func remove(view: UIView) {
        view.removeFromSuperview()
    }
}

open class ACViewControllerWithStatusBar: UIViewController {
    override open var prefersStatusBarHidden: Bool {
        return false
    }
}

open class ACPresenterStatusBar: ACPresenter {
    
    fileprivate let window: UIWindow
    fileprivate let viewController = ACViewControllerWithStatusBar()
    fileprivate let presenterView: UIView
    
    public init(aboveNativeStatusBar: Bool = true) {
        // About status bar size
        //http://stackoverflow.com/questions/31581526/ios9-covering-status-bar-with-custom-uiwindow-wrong-position?rq=1
        var rect = UIScreen.main.bounds
        rect.size.height = 20
        window = UIWindow(frame: rect)
        window.backgroundColor = UIColor.clear
        window.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window.windowLevel = UIWindowLevelStatusBar + (aboveNativeStatusBar ? 1 : -1)
        window.rootViewController = viewController
        window.isHidden = false
        window.isUserInteractionEnabled = false
        presenterView = viewController.view
        
    }
    
    open func add(view: UIView) {
        presenterView.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: presenterView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: presenterView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: presenterView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        
        presenterView.layoutSubviews()
    }
    
    open func remove(view: UIView) {
        view.removeFromSuperview()
    }
}

open class ACPresenterNavigationBar: ACPresenter {
    public init(navigationBar: UINavigationBar) { }
    open func add(view: UIView) { }
    open func remove(view: UIView) { }
}

