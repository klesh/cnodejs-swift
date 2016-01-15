//
//  NavHeaderView.swift
//  CNode
//
//  Created by Klesh Wong on 1/10/16.
//  Copyright © 2016 Klesh Wong. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher

class NavHeaderView : UITableViewCell {
    @IBOutlet weak var theAvatar: UIButton!
    @IBOutlet weak var theLoginname: UILabel!
    @IBOutlet weak var theScore: UILabel!
    @IBOutlet weak var theLogout: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        Utils.circleUp(theAvatar)
    }
    
    // 登录事件
    @IBAction func didLoginTapped(sender: AnyObject) {
        if let user = AppDelegate.app.user {
            AppDelegate.app.drawer.presentViewController(UserViewController.create(user.loginname), animated: true, completion: nil)
        } else {
            AppDelegate.app.drawer.presentViewController(LoginViewController.create(), animated: true, completion: nil)
        }
    }
    
    // 登出事件
    @IBAction func didLogoutTapped(sender: AnyObject) {
        AppDelegate.app.doLogout()
    }
}