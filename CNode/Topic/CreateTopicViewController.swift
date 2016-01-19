//
//  CreateTopicViewController.swift
//  CNode
//
//  Created by Klesh Wong on 1/14/16.
//  Copyright © 2016 Klesh Wong. All rights reserved.
//

import UIKit

class CreateTopicViewController : UIViewController {
    @IBOutlet weak var theContent: PHTextView!
    @IBOutlet weak var theTab: UISegmentedControl!
    @IBOutlet weak var theTitle: UITextField!
    
    static let TAB_CODE = [ "share", "ask", "job" ]
    
    override func viewDidLoad() {
        theContent.placeHolder.text = "正文内容"
        
        navigationItem.rightBarButtonItem = Utils.navButton(0xf00c, target: self, action: "save")
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let draftText = defaults.objectForKey("draftText") as? String where AppDelegate.app.setting.draftEnabled {
            theContent.text = draftText
            theContent.placeHolder.hidden = !draftText.isEmpty
        }
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func save() {
        if !Utils.checkRequired(theTitle) || !Utils.checkRequired(theContent) {
            return
        }
        
        let title = theTitle.text!
        let content = theContent.text!
        let tab = CreateTopicViewController.TAB_CODE[theTab.selectedSegmentIndex]
        
        ApiClient(self).createTopic(AppDelegate.app.user!.token, title: title, tab: tab, content: Utils.processContent(content)) { data in
            self.theContent.text = ""
            self.navigationController?.popViewControllerAnimated(true)
            let topicListController = self.navigationController?.viewControllers.last as! TopicListViewController
            topicListController.refresh()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        if AppDelegate.app.setting.draftEnabled {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(theContent.text!, forKey: "draftText")
            defaults.synchronize()
        }
    }
}