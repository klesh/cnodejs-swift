//
//  SignatureEditController.swift
//  CNode
//
//  Created by Klesh Wong on 1/14/16.
//  Copyright © 2016 Klesh Wong. All rights reserved.
//

import UIKit

class SignatureEditController : UIViewController {
    @IBOutlet weak var theSignatureText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 恢复默认
        navigationItem.rightBarButtonItem = Utils.navButton(0xf0e2, target: self, action: "reset")
        
        
        reload()
    }
    
    func reload() {
        theSignatureText.text = AppDelegate.app.setting.signatureText
    }
    
    func reset() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("signatureText")
        defaults.synchronize()
        reload()
    }
    
    func save() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(theSignatureText.text, forKey: "signatureText")
        defaults.synchronize()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        save()
    }
}