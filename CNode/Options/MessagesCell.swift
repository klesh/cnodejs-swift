//
//  MessagesCell.swift
//  CNode
//
//  Created by Klesh Wong on 1/11/16.
//  Copyright © 2016 Klesh Wong. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol MessagesCellDelegate : class {
    func avatarTapped(author: String, cell: MessagesCell)
}

class MessagesCell : UITableViewCell {
    @IBOutlet weak var theAvatar: UIButton!
    @IBOutlet weak var theAuthor: UILabel!
    @IBOutlet weak var theType: UILabel!
    @IBOutlet weak var theElapse: UILabel!
    @IBOutlet weak var theReply: UIWebView!
    @IBOutlet weak var theContent: CNWebView!
    @IBOutlet weak var theTopic: UILabel!
    
    weak var delegate: MessagesCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        Utils.circleUp(theAvatar)
    }
    
    func bind(message: JSON) {
        theAvatar.kf_setImageWithURL(Utils.toURL(message["author"]["avatar_url"].string), forState: .Normal)
        theAuthor.text = message["author"]["loginname"].string
        theTopic.text = message["topic"]["title"].string
        
        let hasReply = nil != message["reply"]["id"].string
        if message["type"].stringValue == "at" {
            if hasReply {
                theType.text = "在回复中@了你"
            } else {
                theType.text = "在主题中@了你"
            }
        } else {
            theType.text = "回复了您的话题"
        }
        
        if hasReply {
            theElapse.text = Utils.relativeTillNow(message["reply"]["create_at"].stringValue.toDateFromISO8601())
            theContent.loadHTMLAsPageOnce(message["reply"]["content"].stringValue, baseURL: ApiClient.BASE_URL)
        } else {
            theElapse.text = Utils.relativeTillNow(message["topic"]["last_reply_at"].stringValue.toDateFromISO8601())
            theContent.hidden = true
        }
        
        let textColor = message["has_read"].boolValue ? UIColor.darkGrayColor() : UIColor.darkTextColor()
        
        theAuthor.textColor = textColor
        theType.textColor = textColor
        theElapse.textColor = textColor
        theTopic.textColor = textColor
    }
    
    @IBAction func avatarDidTapped(sender: AnyObject) {
        if let d = delegate {
            d.avatarTapped(theAuthor.text!, cell: self)
        }
    }
}
