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
    var presenter: ACPresenterView!
    
    let manager = ACManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = ACPresenterView(view: presentView)
        manager.defaultPresenter = ACPresenterStatusBar()//ACPresenterView(view: presentView)
        manager.defaultAnimation = ACAnimationSlideDown()
        manager.defaultDelay = 4

        let notification = SlimNotification()
        notification.text = "Loading..."
        notification.font = UIFont.systemFont(ofSize: 16)
        
        let notification2 = SlimNotification()
        notification2.text = "Finished!"

        let notification3 = UILabelEdged()
        notification3.text = "Hello world!!! Мой дядя самых честных правил когда не в шутку занемог, он уважать себя заставил и лучше выдумать не мог!"
        notification3.textAlignment = .center
        notification3.numberOfLines = 0
        notification3.backgroundColor = UIColor.red
        
        let notification4 = UILabelEdged()
        notification4.text = "Его пример другим наука; Но, боже мой, какая скука С больным сидеть и день и ночь, Не отходя ни шагу прочь!"
        notification4.textAlignment = .center
        notification4.numberOfLines = 0
        notification4.backgroundColor = UIColor.red
        
        presentView.clipsToBounds = true
        
        let _ = manager.add(notification: notification)
        let _ = manager.add(notification: notification2)
        let _ = manager.add(notification: notification3, delay: nil, presenter: presenter)
        let _ = manager.add(notification: notification4, delay: nil, presenter: presenter)
    }
}

