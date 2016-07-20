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
    func addView(view: UIView) {
        print(NSDate(), "ACPresenter : addView")
        UIApplication.sharedApplication().keyWindow?.addSubview(view)
    }
    func removeView(view: UIView) {
        print(NSDate(), "ACPresenter : removeView")
        view.removeFromSuperview()
    }
}

class ACPresenterView: ACPresenter {
    let presenterView: UIView
    
    init(view: UIView) {
        presenterView = view
    }
    
    func addView(view: UIView) {
        presenterView.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: presenterView, attribute: .Leading, multiplier: 1, constant: 0).active = true

        NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: presenterView, attribute: .Trailing, multiplier: 1, constant: 0).active = true
        
        NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: presenterView, attribute: .Top, multiplier: 1, constant: 0).active = true
        
        presenterView.layoutSubviews()
    }
    
    func removeView(view: UIView) {
        view.removeFromSuperview()
    }
}

class ACPresenterStatusBar: ACPresenter {
    func addView(view: UIView) { }
    func removeView(view: UIView) { }
}

class ACPresenterNavigationBar: ACPresenter {
    init(navigationBar: UINavigationBar) { }
    func addView(view: UIView) { }
    func removeView(view: UIView) { }
}

