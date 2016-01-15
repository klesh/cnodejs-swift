//
//  MessagesViewController.swift
//  CNode
//
//  Created by Klesh Wong on 1/11/16.
//  Copyright © 2016 Klesh Wong. All rights reserved.
//

import UIKit
import SwiftyJSON

class MessagesViewController : AHTableViewController, MessagesCellDelegate {
    var unreads: JSON!
    var reads: JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 添加一个 loading 的图标
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        
        // 设定回复按钮
        navigationItem.leftBarButtonItem = Utils.navButton(0xf00d, target: self, action: "close")
        
        // 设定标记已读按钮
        navigationItem.rightBarButtonItem = Utils.navButton(0xf00c, target: self, action: "markAll")
        
        refresh()
    }
    
    func refresh() {
        self.refreshControl?.beginRefreshing()
        
        ApiClient(self).getMessages(AppDelegate.app.user!.token,
            done: {
                self.refreshControl?.endRefreshing()
            },
            success: { data in
                self.unreads = data["hasnot_read_messages"]
                self.reads = data["has_read_messages"]
                
                self.setSection("messageItem", count: self.unreads.count, section: 0)
                self.setSection("messageItem", count: self.reads.count, section: 1)
            }
        )
    }
    
    func close() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func markAll() {
        ApiClient(self).markAllAsRead(AppDelegate.app.user!.token) { data in
            self.refresh()
        }
    }
    
    override func populateCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let messageCell = cell as! MessagesCell
        let messageData = indexPath.section == 0 ? unreads[indexPath.row] : reads[indexPath.row]
        
        messageCell.bind(messageData)
        messageCell.delegate = self
    }
    
    func avatarTapped(author: String, cell: MessagesCell) {
        self.presentViewController(UserViewController.create(author), animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let message = indexPath.section == 0 ? self.unreads[indexPath.row] : self.reads[indexPath.row]
        let topic = message["topic"]
        self.navigationController?.pushViewController(TopicDetailViewController.create(topic), animated: true)
    }
}
