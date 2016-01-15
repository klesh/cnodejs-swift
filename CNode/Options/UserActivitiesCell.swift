//
//  UserActivitiesCell.swift
//  CNode
//
//  Created by Klesh Wong on 1/11/16.
//  Copyright © 2016 Klesh Wong. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol UserActivitiesCellDelegate : class {
    func avatarTapped(author: String, cell: UserActivitiesCell)
}

class UserActivitiesCell : UITableViewCell {
    @IBOutlet weak var theAvatar: UIButton!
    @IBOutlet weak var theTitle: UILabel!
    @IBOutlet weak var theAuthor: UILabel!
    @IBOutlet weak var theCreatedBefore: UILabel!
    weak var delegate: UserActivitiesCellDelegate?
    
    override func awakeFromNib() {
        Utils.circleUp(theAvatar)
    }
    
    func bind(activity: JSON) {
        theAvatar.kf_setImageWithURL(Utils.toURL(activity["author"]["avatar_url"].string), forState: .Normal)
        theTitle.text = activity["title"].string
        theAuthor.text = activity["author"]["loginname"].string
        if let last_reply_at = activity["last_reply_at"].string {
            theCreatedBefore.text = Utils.relativeTillNow(last_reply_at.toDateFromISO8601())
        } else {
            theCreatedBefore.text = ""
        }
        
    }
    
    @IBAction func avatarDidTapped(sender: AnyObject) {
        if let d = delegate {
            d.avatarTapped(theAuthor.text!, cell: self)
        }
    }
}
