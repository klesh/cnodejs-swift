//
//  TopicDetailReplyCell.swift
//  CNode
//
//  Created by Klesh Wong on 1/5/16.
//  Copyright © 2016 Klesh Wong. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol DetailCellButtonsDelegate: class {
    func thumbUpTapped(id: String, cell: TopicDetailReplyCell)
    func replyToTapped(id: String, cell: TopicDetailReplyCell)
}

class TopicDetailReplyCell: UITableViewCell {
    weak var delegate: DetailCellButtonsDelegate?
    
    @IBOutlet weak var avatar: UIButton!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var create_before: UILabel!
    @IBOutlet weak var ups_count: UILabel!
    @IBOutlet weak var content: CNWebView!
    
    @IBOutlet weak var up: UIButton!
    @IBOutlet weak var reply: UIButton!
    
    var id: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // 设定 顶 和 回复 font icon，可以自由设定颜色和大小，多科学。
        // 这里用了 FontAwesome ，官网有 cheatsheet 可以查到 code 的值。也比较方便，不然管理一大把的 icon 也是个麻烦事
        // 引入方式：把 fontawesome-webfont.ttf 拖放到工程中，在 Info.plist 加一行 Fonts provided by application （Array型）
        //         再 Item N 中加一个 fontawesome-webfont.ttf 就可以了。那编辑器真是难用！很容易点错。其实整个 xcdoe 真是难用得一逼。
        Utils.fontAwesome(up, code: 0xf164, size: 20)
        Utils.fontAwesome(reply, code: 0xf112, size: 20)
    }
    
    func bind(reply: JSON, row: Int) {
        id = reply["id"].stringValue
        
        Utils.circleUp(avatar)
        avatar.kf_setImageWithURL(Utils.toURL(reply["author"]["avatar_url"].stringValue), forState: .Normal)
        author.text = "\(row + 1)楼 " + reply["author"]["loginname"].stringValue
        create_before.text = Utils.relativeTillNow(reply["create_at"].stringValue.toDateFromISO8601())
        ups_count.text = String(reply["ups"].arrayValue.count)
        content.loadHTMLAsPageOnce(reply["content"].stringValue, baseURL: ApiClient.BASE_URL)
    }
    
    
    @IBAction func avatarTapped(sender: AnyObject) {
        AppDelegate.app.drawer.presentViewController(UserViewController.create(author.text!), animated: true, completion: nil)
    }


    @IBAction func upTapped(sender: AnyObject) {
        if let d = delegate {
            d.thumbUpTapped(id, cell: self)
        }
    }
    
    
    @IBAction func replyTapped(sender: AnyObject) {
        if let d = delegate {
            d.replyToTapped(id, cell: self)
        }
    }
}