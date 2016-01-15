//
//  TopicDetailViewController.swift
//  CNode
//
//  Created by Klesh Wong on 1/4/16.
//  Copyright © 2016 Klesh Wong. All rights reserved.
//

import UIKit
import SwiftyJSON

class TopicDetailViewController: AHTableViewController, DetailCellButtonsDelegate  {
    var topic: JSON!
    var replyTo: String?
    var replyToText: String?
//    var reloadWhenAppear = false
    
    // 初始化，这个会在列表页的 prepareForSegue 之后被调用，这时使用 topic 变量是安全的
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 添加一个 loading 的图标
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)

        // 设定回复按钮
        self.navigationItem.rightBarButtonItem = Utils.navButton(0xf112, target: self, action: "reply")
        
        self.navigationItem.title = "话题"
        
        // 开始加载 replies 列表
        refresh()
    }
    
//    override func viewDidAppear(animated: Bool) {
//        if reloadWhenAppear {
//            reloadWhenAppear = false
//            tableView.reloadData()
//        }
//    }
    
    func reply() {
        
        Utils.ensureLogon(self) {
            self.replyTo = nil
            self.performSegueWithIdentifier("createReply", sender: self)
        }
    }
    
    // 加载主题
    func refresh() {
        self.refreshControl!.beginRefreshing()
        
        ApiClient(self).getTopicDetail(topic["id"].stringValue,
            done: {
                self.refreshControl!.endRefreshing()
                self.navigationController?.setNavigationBarHidden(false, animated: false)
            },
            success: {json in
                self.topic = json["data"]
                
                self.setSection("topicMain", count: 1, section: 0)
                self.setSection("topicReply", count: self.topic["replies"].count, section: 1)
            }
        )
    }
    
    // 填充回复单元格
    override func populateCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            (cell as! TopicDetailMainCell).bind(topic)
            return
        }
        
        let replyCell = cell as! TopicDetailReplyCell
        let replyData = topic["replies"][indexPath.row]
        replyCell.bind(replyData, row: indexPath.row)
        
        replyCell.delegate = self
    }
    
    func thumbUpTapped(id: String, cell: TopicDetailReplyCell) {
        Utils.ensureLogon(self) {
            ApiClient(self).thumbsReply(AppDelegate.app.user!.token, replyId: id) { data in
                cell.ups_count.text = String(Int(cell.ups_count.text!)! + (data["action"].stringValue == "down" ? -1 : 1))
            }
        }
    }
    
    func replyToTapped(id: String, cell: TopicDetailReplyCell) {
        Utils.ensureLogon(self) {
            self.replyTo = id
            self.replyToText = cell.author.text
            self.performSegueWithIdentifier("createReply", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let createReplyController = segue.destinationViewController as! CreateReplyViewController
        createReplyController.topicId = topic["id"].stringValue
        createReplyController.replyTo = replyTo
        createReplyController.replyToText = replyTo != nil ? replyToText : topic["title"].string
    }
    
    class func create(topic: JSON) -> TopicDetailViewController {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let detailController = mainStoryboard.instantiateViewControllerWithIdentifier("topicDetailScene") as! TopicDetailViewController
        detailController.topic = topic
        return detailController
    }
}
