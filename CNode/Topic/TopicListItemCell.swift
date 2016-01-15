//
//  TopicTableViewCell.swift
//  CNode
//
//  Created by Klesh Wong on 1/3/16.
//  Copyright © 2016 Klesh Wong. All rights reserved.
//

import UIKit

class TopicListItemCell: UITableViewCell {
    @IBOutlet weak var tab: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var avatar: UIButton!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var figures: UILabel!
    @IBOutlet weak var create_at: UILabel!
    @IBOutlet weak var reply_before: UILabel!
    @IBOutlet weak var good: UIImageView!
    
    
    @IBAction func avatarDidTapped(sender: AnyObject) {
        AppDelegate.app.drawer.presentViewController(UserViewController.create(author.text!), animated: true, completion: nil)
    }
}
