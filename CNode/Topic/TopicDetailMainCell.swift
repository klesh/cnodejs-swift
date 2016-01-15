//
//  TopicDetailHeaderCell.swift
//  CNode
//
//  Created by Klesh Wong on 1/4/16.
//  Copyright © 2016 Klesh Wong. All rights reserved.
//

import UIKit
import SwiftyJSON

class TopicDetailMainCell: UITableViewCell {
   
    @IBOutlet weak var topic_title: UILabel!
    @IBOutlet weak var avatar: UIButton!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var create_before: UILabel!
    @IBOutlet weak var tab: UILabel!
    @IBOutlet weak var visit_count: UILabel!
    @IBOutlet weak var content: CNWebView!
    @IBOutlet weak var good: UIImageView!
    
    func bind(topic: JSON) {
        topic_title.text = topic["title"].string
        Utils.circleUp(avatar)
        avatar.kf_setImageWithURL(Utils.toURL(topic["author"]["avatar_url"].stringValue), forState: .Normal)
        author.text = topic["author"]["loginname"].string
        create_before.text = Utils.relativeTillNow(topic["create_at"].stringValue.toDateFromISO8601())
        Utils.setupTabLabel(tab, top: topic["top"].boolValue, tab: topic["tab"].string)
        visit_count.text = topic["visit_count"].stringValue + " 次浏览"
        content.loadHTMLAsPageOnce(topic["content"].stringValue, baseURL: ApiClient.BASE_URL)
        good.hidden = !topic["good"].boolValue
        
    }
    
    @IBAction func avatarTapped(sender: AnyObject) {
        AppDelegate.app.drawer.presentViewController(UserViewController.create(author.text!), animated: true, completion: nil)
    }
}
