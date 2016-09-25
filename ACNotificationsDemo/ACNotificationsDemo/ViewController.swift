//
//  ViewController.swift
//  ACNotificationsDemo
//
//  Created by Yury on 10/07/16.
//  Copyright © 2016 Avtolic. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var presentView: UIView!
    
    let manager = ACManagerRich()
    let animation = ACAnimationSlideDown()
    var presenter: ACPresenterView!
    let notification = UILabelEdged()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = ACPresenterView(view: presentView)
        notification.text = "Hello world!!! Мой дядя самых честных правил когда не в шутку занемог, он уважать себя заставил и лучше выдумать не мог!"
        notification.textAlignment = .center
        notification.numberOfLines = 0
        notification.backgroundColor = UIColor.red
        presentView.clipsToBounds = true
        
        let _ = manager.add(notification: notification, delay: 5, presenter: presenter, animation: animation)
//        presenter.addView(notification.notificationView)
        
//        animation.animateIn(view: notification.notificationView) {
//            self.animation.animateOut(view: self.notification.notificationView, completion: {
//                self.presenter.removeView(self.notification.notificationView)
//            })
//        }
        
    }


}

