//
//  ACSimpleNotifications.swift
//  ACNotificationsDemo
//
//  Created by Yury on 11/07/16.
//  Copyright © 2016 Avtolic. All rights reserved.
//

import Foundation
import UIKit

open class ACNotificationLog: ACNotification {
    
    open var notificationView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    var notificationDuration: TimeInterval = 5
    func stateChanged(_ state: ACNotificationState) {
        print(Date(), "ACNotification : stateChanged(\(state))")
    }
}

open class ACViewNotification: ACNotification {
    
    fileprivate(set) open var notificationView: UIView
    
    init(view: UIView) {
        notificationView = view
    }
}

extension UIView: ACNotification {
    open var notificationView: UIView { return self }
}

open class UILabelEdged: UILabel {
    override open var intrinsicContentSize : CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width - 40.0, height: size.height + 40)
    }
//    override func textRectForBounds(bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
//        print(bounds, super.textRectForBounds(bounds, limitedToNumberOfLines: numberOfLines))
//        let ggg = super.textRectForBounds(bounds, limitedToNumberOfLines: numberOfLines).insetBy(dx: 100, dy: -10)
//        print(ggg)
//        return ggg
//    }
}

open class SlimNotification: UILabel {
    
    public init() {
        super.init(frame: CGRect.zero)
        numberOfLines = 1
        textAlignment = .center
        backgroundColor = UIColor.green
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//    override var intrinsicContentSize : CGSize {
//        let size = super.intrinsicContentSize
//        return CGSize(width: size.width - 0.0, height: size.height + 0)
//    }
    //    override func textRectForBounds(bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
    //        print(bounds, super.textRectForBounds(bounds, limitedToNumberOfLines: numberOfLines))
    //        let ggg = super.textRectForBounds(bounds, limitedToNumberOfLines: numberOfLines).insetBy(dx: 100, dy: -10)
    //        print(ggg)
    //        return ggg
    //    }
}

