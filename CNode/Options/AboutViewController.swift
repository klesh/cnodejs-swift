//
//  AboutViewController.swift
//  CNode
//
//  Created by Klesh Wong on 1/10/16.
//  Copyright © 2016 Klesh Wong. All rights reserved.
//

import UIKit
import APParallaxHeader

class AboutViewController : UITableViewController {
    let items = [
        (label: "当前版本", text: "1.0.14-build-20160311", href: ""),
        (label: "开发者", text: "Klesh Wong", href: ""),
        (label: "源代码贡献", text: "https://github.com/pupboss", href: "https://github.com/klesh/cnodejs-swift/blob/master/README.md#contributors"),
        (label: "开源主页", text: "https://github.com/klesh/cnodejs-swift", href: "https://github.com/klesh/cnodejs-swift"),
        (label: "关于CNODE社区", text: "https://cnodejs.org/about", href: "https://cnodejs.org/about"),
        (label: "作者博客", text: "http://kleshwong.com/blog", href: "http://kleshwong.com/blog"),
        (label: "意见反馈", text: "向作者发送电子邮件", href: "mailto:klesh@qq.com")
    ]
    
    override func viewDidLoad() {
        tableView.addParallaxWithImage(UIImage(named: "about_bg.png"), andHeight: CGFloat(180))
        tableView.tableFooterView = UIView()
        
        navigationItem.leftBarButtonItem = Utils.navButton(0xf00d, target: self, action: "close")
    }
    
    func close() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("aboutItem", forIndexPath: indexPath)
        let item = items[indexPath.row]
        cell.textLabel!.text = item.label
        cell.detailTextLabel!.text = item.text
        if item.href.isEmpty {
            cell.selectionStyle = .None
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = items[indexPath.row]
        if !item.href.isEmpty {
            UIApplication.sharedApplication().openURL(NSURL(string: item.href)!)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
