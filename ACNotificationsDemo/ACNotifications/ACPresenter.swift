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
    func addView(_ view: UIView) {
        print(Date(), "ACPresenter : addView")
        UIApplication.shared.keyWindow?.addSubview(view)
    }
    func removeView(_ view: UIView) {
        print(Date(), "ACPresenter : removeView")
        view.removeFromSuperview()
    }
}

class ACPresenterView: ACPresenter {
    let presenterView: UIView
    
    init(view: UIView) {
        presenterView = view
    }
    
    func addView(_ view: UIView) {
        presenterView.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: presenterView, attribute: .leading, multiplier: 1, constant: 0).isActive = true

        NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: presenterView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: presenterView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        
        presenterView.layoutSubviews()
    }
    
    func removeView(_ view: UIView) {
        view.removeFromSuperview()
    }
}

class ACPresenterStatusBar: ACPresenter {
    func addView(_ view: UIView) { }
    func removeView(_ view: UIView) { }
}

class ACPresenterNavigationBar: ACPresenter {
    init(navigationBar: UINavigationBar) { }
    func addView(_ view: UIView) { }
    func removeView(_ view: UIView) { }
}

