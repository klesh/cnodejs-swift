//
//  CreateReplyViewController.swift
//  CNode
//
//  Created by Klesh Wong on 1/14/16.
//  Copyright © 2016 Klesh Wong. All rights reserved.
//

import UIKit

class CreateReplyViewController : UIViewController {
    var topicId: String!
    var replyTo: String?
    var replyToText: String!
    
    @IBOutlet weak var theReplyTo: UILabel!
    @IBOutlet weak var theContent: PHTextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        theContent.placeHolder.text = "回复内容"
        // 设定标记已读按钮
        navigationItem.rightBarButtonItem = Utils.navButton(0xf00c, target: self, action: "save")
    
        theReplyTo.text = replyToText
        
        if let text = replyToText where replyTo != nil {
            let author = text.componentsSeparatedByString(" ").last!
            theContent.text = "@\(author) "
            theContent.placeHolder.hidden = true
        }
        theContent.becomeFirstResponder()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func save() {
        if !Utils.checkRequired(theContent) {
            return
        }
        
        ApiClient(self).createReply(AppDelegate.app.user!.token, id: topicId, content: Utils.processContent(theContent.text), replyTo: replyTo) { data in
            self.navigationController?.popViewControllerAnimated(true)
            let topicDetailController = self.navigationController!.viewControllers.last as! TopicDetailViewController
            topicDetailController.refresh()
        }
    }
}
