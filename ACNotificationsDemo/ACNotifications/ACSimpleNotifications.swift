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
    
    init(view: UIView) {
        notificationView = view
    }
}

extension UIView: ACNotification {
    var notificationView: UIView { return self }
}

class UILabelEdged: UILabel {
    override func intrinsicContentSize() -> CGSize {
        let size = super.intrinsicContentSize()
        return CGSizeMake(size.width - 40.0, size.height + 40)
    }
//    override func textRectForBounds(bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
//        print(bounds, super.textRectForBounds(bounds, limitedToNumberOfLines: numberOfLines))
//        let ggg = super.textRectForBounds(bounds, limitedToNumberOfLines: numberOfLines).insetBy(dx: 100, dy: -10)
//        print(ggg)
//        return ggg
//    }
}