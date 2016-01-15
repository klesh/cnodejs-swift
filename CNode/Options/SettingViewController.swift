//
//  SettingViewController.swift
//  CNode
//
//  Created by Klesh Wong on 1/14/16.
//  Copyright © 2016 Klesh Wong. All rights reserved.
//

import UIKit

class SettingViewController : UIViewController {
    @IBOutlet weak var theDraftEnabled: UISwitch!
    @IBOutlet weak var theSignatureEnabled: UISwitch!
    @IBOutlet weak var theEditSignatureButton: UIButton!
    @IBOutlet weak var theAccessTokenLabel: UILabel!
    @IBOutlet weak var theAccessToken: UITextField!
    @IBOutlet weak var theAccessTokenMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = Utils.navButton(0xf00d, target: self, action: "close")
        
        reload()

        #if DEBUG
            if let token = AppDelegate.app.user?.token {
                theAccessToken.text = token
                theAccessTokenMessage.text = "已登录"
            }
            theAccessTokenMessage.text = ""
        #else
            theAccessTokenLabel.hidden = true
            theAccessToken.hidden = true
            theAccessTokenMessage.hidden = true
        #endif
    }
    
    func close() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func reload() {
        let setting = AppDelegate.app.setting
        theDraftEnabled.setOn(setting.draftEnabled, animated: true)
        theSignatureEnabled.setOn(setting.signatureEnabled, animated: true)
        theEditSignatureButton.enabled = setting.signatureEnabled
    }
    
    @IBAction func draftEnabledTapped(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(theDraftEnabled.on, forKey: "draftEnabled")
        defaults.synchronize()
        reload()
    }
    
    @IBAction func signatureEnabledTapped(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(theSignatureEnabled.on, forKey: "signatureEnabled")
        defaults.synchronize()
        reload()
    }
    
    @IBAction func accessTokenChanged(sender: AnyObject) {
        if let token = theAccessToken.text {
            if token.characters.count == 36 {
                ApiClient(self).validateToken(token,
                    error: { err in
                        self.theAccessTokenMessage.text = "Access Token 无效"
                    },
                    success: { data in
                        self.theAccessTokenMessage.text = "已登录"
                        AppDelegate.app.doLogin(data["loginname"].stringValue, token: token)
                    }
                )
            } else {
                self.theAccessTokenMessage.text = "请输入您的 AccessToken"
            }
        }
    }
}
