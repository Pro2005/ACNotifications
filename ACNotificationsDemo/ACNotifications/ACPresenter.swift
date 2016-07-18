//
//  ACPresenter.swift
//  ACNotificationsDemo
//
//  Created by Yury on 11/07/16.
//  Copyright © 2016 Avtolic. All rights reserved.
//

import Foundation
import UIKit

public protocol ACPresenter: class {
    func addView(view: UIView)
    func removeView(view: UIView)
}

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

class ACPresenterStatusBar: ACPresenter {
    func addView(view: UIView) { }
    func removeView(view: UIView) { }
}

class ACPresenterNavigationBar: ACPresenter {
    init(navigationBar: UINavigationBar) { }
    func addView(view: UIView) { }
    func removeView(view: UIView) { }
}

class ACPresenterView: ACPresenter {
    init(view: UIView) { }
    func addView(view: UIView) { }
    func removeView(view: UIView) { }
}