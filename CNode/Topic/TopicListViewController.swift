//
//  MainTableViewController.swift
//  CNode
//
//  Created by Klesh Wong on 1/3/16.
//  Copyright © 2016 Klesh Wong. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftDate
import Kingfisher

class TopicListViewController: UITableViewController {

    var topics = [JSON]()
    var page = 1
    var tab = ""
    var loading = false

    // 初始化
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 添加loading动画
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        self.refreshControl = refresher
        
        // 添加 nav icon
        self.navigationItem.leftBarButtonItem = Utils.navButton(0xf0c9, target: UIApplication.sharedApplication().delegate, action: "openNavView")
        self.navigationItem.rightBarButtonItem = Utils.navButton(0xf067, target: self, action: "createTopic")
        
        
        refresh()
    }
    
    func createTopic() {
        Utils.ensureLogon(self) {
            self.performSegueWithIdentifier("createTopic", sender: self)
        }
    }

    // 第一次加载数据 或 刷新
    func refresh() {
        loading = true
        page = 1
        self.navigationItem.title = ApiClient.TABS[self.tab]
        self.refreshControl?.beginRefreshing()
        
        // 传入 self 是为了出错时提示警告窗
        ApiClient(self).getTopicList(page, tab: tab,
            done: {
                self.refreshControl!.endRefreshing()
                self.loading = false
            },
            success: { data in
                self.topics.removeAll();
                self.topics.appendContentsOf(data["data"].arrayValue)
                print("topic count: \(self.topics.count)  data count: \(data["data"].arrayValue.count)")
                self.tableView.reloadData();
            }
        )
    }
    
    // 滚动事件
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if loading {
            return
        }
        let topMargin = scrollView.contentOffset.y
        let height = scrollView.contentSize.height
        if (height - topMargin < 1000) {
            print("trigger load more...")
            loadMore()
        }
    }
    
    // 加载更多
    func loadMore() {
        loading = true
        page++
        print(topics.count)
        ApiClient(self).getTopicList(page, tab: tab,
            done: {
                self.loading = false
            },
            success: { data in
                self.topics.appendContentsOf(data["data"].arrayValue)
                self.tableView.reloadData()
            }
        )
    }

    // 指定 TableView 有几个分区，列表页只有一种
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    // 多少行
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }

    // 设定话题行(一行只有一个单元格，所以 Row 跟 Cell 在这里是同一个东西)
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 这里应用 **重用** 特性，下面的方法可能会返回“被推出屏幕外的 Cell 实例”。所以每次都要显式地对每个控件进行设定（言下之意不能依赖初始值）
        let cell = tableView.dequeueReusableCellWithIdentifier("topicListItem", forIndexPath: indexPath) as! TopicListItemCell

        let topic = topics[indexPath.row]

        cell.title.text = topic["title"].string
        cell.author.text = topic["author"]["loginname"].string
        cell.create_at.text = "创建于：" + Utils.isoDateStringToLocal(topic["create_at"].stringValue) // 使用了 SwiftDate 组件

        // 头像圆形化
        Utils.circleUp(cell.avatar)
        
        // 这里使用 Kingfisher 组件加载头像，它带有缓存系统，当 Cell 被重用时。就不用再次从网上加载图片了。
        cell.avatar.kf_setImageWithURL(Utils.toURL(topic["author"]["avatar_url"].stringValue), forState: .Normal)
        
        // 显式指定“精华”标签是否显示，而不依赖于Storyboard上面的设定
        cell.good.hidden = !topic["good"].boolValue
        
        // 圆角化
        Utils.roundUp(cell.tab, radius: 5)
        Utils.setupTabLabel(cell.tab, top: topic["top"].boolValue, tab: topic["tab"].string)    
        
        let replyCount = topic["reply_count"].stringValue
        let visitCount = topic["visit_count"].stringValue
        
        // 在 Label 中显示两种颜色的文本
        let mutated = NSMutableAttributedString(string: replyCount + " / " + visitCount)
        mutated.addAttribute(NSForegroundColorAttributeName, value: Utils.TOP_BG, range: NSRange(location: 0, length: replyCount.characters.count))
        cell.figures.attributedText = mutated
        
        
        if let lastRepliedAt = topic["last_reply_at"].string {
            cell.reply_before.text = Utils.relativeTillNow(lastRepliedAt.toDateFromISO8601())
            
        } else {
            cell.reply_before.text = ""
        }
        return cell
    }
    
    // 跳到话题详细页之前要把 topic 传过去
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "topicDetail" {
            let detailView = segue.destinationViewController as! TopicDetailViewController
            detailView.topic = topics[tableView.indexPathForSelectedRow!.row]
        }
    }

}
