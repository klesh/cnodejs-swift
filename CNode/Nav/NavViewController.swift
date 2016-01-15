//
//  NavViewController.swift
//  CNode
//
//  Created by Klesh Wong on 1/10/16.
//  Copyright © 2016 Klesh Wong. All rights reserved.
//

import UIKit

class NavViewController : UITableViewController {
    var header: NavHeaderView!
    var tabs = [UITableViewCell]()
    var options = [UITableViewCell]()
    var selected = NSIndexPath(forItem: 0, inSection: 0)
    var messageItem: NavMenuItemView!
    var loading = false
    var loadingUnread = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初始化顶部登际信息
        header = tableView.dequeueReusableCellWithIdentifier("navHeader") as! NavHeaderView
        tableView.tableHeaderView = header
        
        // 初始化标签选项菜单
        for tab in ApiClient.TABS {
            let tabCell = tableView.dequeueReusableCellWithIdentifier("navMenuItem") as! NavMenuItemView
            tabCell.bind(tab.0, text: tab.1)
            tabs.append(tabCell)
        }
        
        // 初始化选项菜单
        for (code, text) in ["message": "消息", "setting": "设置", "about": "关于"].reverse() {
            let optionCell = tableView.dequeueReusableCellWithIdentifier("navMenuItem") as! NavMenuItemView
            if code == "message" {
                messageItem = optionCell
            }
            optionCell.bind(code, text: text)
            options.append(optionCell)
        }
        
        // 加载用户资料
        reloadLogin()
    }
    
    override func viewDidAppear(animated: Bool) {
        tableView.selectRowAtIndexPath(selected, animated: false, scrollPosition: UITableViewScrollPosition.None)
        reloadUnreadsCount()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? tabs.count : options.count
    }

    // 高度直接指定，否则受 header 高度影响
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    // 给 tableView 返回缓存的 cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = (indexPath.section == 0 ? tabs[indexPath.row] : options[indexPath.row]) as! NavMenuItemView
        if indexPath.row == 0 && indexPath.section == 1 {
            // 添加选项分隔条
            let sepFrame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 1)
            let sepView = UIView(frame: sepFrame)
            sepView.backgroundColor = UIColor.lightGrayColor()
            cell.addSubview(sepView)
        }
        return cell
    }
    
    // 主导航栏选项被点击事件
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selected = indexPath
        AppDelegate.app.closeNavView()
        if indexPath.section == 0 {
            let cell = tabs[indexPath.row] as! NavMenuItemView
            let tab = cell.code
            let topicViewController = AppDelegate.app.topicList
            topicViewController.tab = tab!
            topicViewController.refresh()
        } else {
            let cell = options[indexPath.row] as! NavMenuItemView
            if cell.code == "message" && AppDelegate.app.user == nil {
                Utils.ensureLogon(AppDelegate.app.drawer) {
                    let sb = UIStoryboard(name: "Options", bundle: nil)
                    let opt = sb.instantiateViewControllerWithIdentifier("messageScene")
                    AppDelegate.app.drawer.presentViewController(opt, animated: true, completion: nil)
                }
                return
            }
            
            let sb = UIStoryboard(name: "Options", bundle: nil)
            let opt = sb.instantiateViewControllerWithIdentifier(cell.code + "Scene")
            AppDelegate.app.drawer.presentViewController(opt, animated: true, completion: nil)
        }
    }
    
    // 根据登录状态刷新控件
    func reloadLogin() {
        print("reloadLogin")
        if loading {
            return
        }
        if let user = AppDelegate.app.user {
            
            // 异步加载头像，积分
            loading = true
            ApiClient(self).getUser(user.loginname,
                done: {
                    self.loading = false
                },
                success: { data in
                    let d = data["data"]
                    self.header.theAvatar.kf_setImageWithURL(Utils.toURL(d["avatar_url"].string), forState: UIControlState.Normal)
                    self.header.theScore.text = "积分：" + d["score"].stringValue
                    self.reloadUnreadsCount()
                }
            )
            
            header.theLoginname.text = user.loginname
            header.theLogout.hidden = false
        } else {
            header.theAvatar.setImage(UIImage(named: "avatar_ph.png"), forState: UIControlState.Normal)
            header.theLoginname.text = "点击头像登陆"
            header.theScore.text = ""
            header.theLogout.hidden = true
        }
    }
    
    // 取得未读消息数量
    func reloadUnreadsCount() {
        print("reloadUnreadsCount")
        if loadingUnread {
            return
        }
        if let user = AppDelegate.app.user {
            loadingUnread = true
            ApiClient(self).getUnreadsCount(user.token,
                done: {
                    self.loadingUnread = false
                },
                success: { count in
                    self.messageItem.theInfo.text = String(count)
                    self.messageItem.theInfo.hidden = count == 0
                }
            )
        } else {
            self.messageItem.theInfo.hidden = false
        }
    }
}