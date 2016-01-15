//
//  NavMenuItemView.swift
//  CNode
//
//  Created by Klesh Wong on 1/10/16.
//  Copyright © 2016 Klesh Wong. All rights reserved.
//

import UIKit

class NavMenuItemView : UITableViewCell {
    static let CODE_TO_ICON = [
        "ask": String(format: "%C", 0xf128),
        "share": String(format: "%C", 0xf1e0),
        "job": String(format: "%C", 0xf109),
        "good": String(format: "%C", 0xf164),
        "": String(format: "%C", 0xf02d),
        "message": String(format: "%C", 0xf086),
        "setting": String(format: "%C", 0xf013),
        "about": String(format: "%C", 0xf06a)
    ]
    
    @IBOutlet weak var theIcon: UILabel!
    @IBOutlet weak var theText: UILabel!
    @IBOutlet weak var theInfo: UILabel!
    
    var code: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        theInfo.hidden = true
        Utils.roundUp(theInfo, radius: 10)
    }
    
    func bind(code: String, text: String) {
        self.code = code
        theText.text = text
        theIcon.text = NavMenuItemView.CODE_TO_ICON[code]
    }
}