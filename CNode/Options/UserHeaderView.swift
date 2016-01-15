//
//  UserHeaderView.swift
//  CNode
//
//  Created by Klesh Wong on 1/11/16.
//  Copyright © 2016 Klesh Wong. All rights reserved.
//

import UIKit
import SwiftyJSON

class UserHeaderView : UITableViewCell {
    @IBOutlet weak var theAvatar: UIImageView!
    @IBOutlet weak var theLoginname: UILabel!
    @IBOutlet weak var theGithub: UIButton!
    @IBOutlet weak var theRegisteredAt: UILabel!
    @IBOutlet weak var theScore: UILabel!
    
    var data: JSON!
    
    @IBAction func didGithubTapped(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(Utils.toURL("https://github.com/" + data["githubUsername"].stringValue))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        Utils.circleUp(theAvatar)
    }
    
    func bind(data: JSON) {
        self.data = data
        theAvatar.kf_setImageWithURL(Utils.toURL(data["avatar_url"].string))
        theLoginname.text = data["loginname"].string
        theGithub.setTitle(data["githubUsername"].stringValue + "@github.com", forState: .Normal)
        theRegisteredAt.text = "注册日期：" + Utils.isoDateStringToLocal(data["create_at"].stringValue)
        theScore.text = String(format: "积分： %d", data["score"].intValue)
    }
}
