//
//  ACSimpleNotifications.swift
//  ACNotificationsDemo
//
//  Created by Yury on 11/07/16.
//  Copyright © 2016 Avtolic. All rights reserved.
//

import Foundation
import UIKit

class ACNotificationLog: ACNotification {
    
    var notificationView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    var notificationDuration: NSTimeInterval = 5
    func stateChanged(state: ACNotificationState) {
        print(NSDate(), "ACNotification : stateChanged(\(state))")
    }
}

class ACViewNotification: ACNotification {
    
    private(set) var notificationView: UIView
    private(set) var notificationDuration: NSTimeInterval
    
    init(view: UIView, duration: NSTimeInterval) {
        notificationView = view
        notificationDuration = duration
    }
}

class ACTextNotification: UILabel, ACNotification {
    
    var notificationView: UIView { return self }
    private(set) var notificationDuration: NSTimeInterval
    
    init(duration: NSTimeInterval) {
        notificationDuration = duration
        super.init(frame: CGRectZero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
