//
//  UserViewController.swift
//  CNode
//
//  Created by Klesh Wong on 1/11/16.
//  Copyright © 2016 Klesh Wong. All rights reserved.
//

import UIKit
import SwiftyJSON

class UserViewController : UITableViewController {
    var header: UserHeaderView!
    var loginname: String!
    var user: JSON!
    let menuItems = [
        (code: "recent_replies", text: "最近回复"),
        (code: "recent_topics", text: "最近发表")
    ]
    
    override func viewDidLoad() {
        header = tableView.dequeueReusableCellWithIdentifier("userHeader") as! UserHeaderView
        tableView.tableHeaderView = header
        
        // bind
        ApiClient(self).getUser(loginname) { response in
            self.user = response["data"]
            self.header.bind(self.user)
        }
        
        // 添加关闭按钮
        navigationItem.leftBarButtonItem = Utils.navButton(0xf00d, target: self, action: "close")
        
        // 设定标题
        navigationItem.title = loginname
        
        // 去掉尾部线条
        tableView.tableFooterView = UIView()
    }
    
    func close() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userMenuItem", forIndexPath: indexPath)
        cell.textLabel?.text = menuItems[indexPath.row].text
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //performSegueWithIdentifier("recentActivities", sender: self)
    }
    
    class func create(loginname: String) -> UIViewController {
        let sb = UIStoryboard(name: "Options", bundle: nil)
        let navCtrl = sb.instantiateViewControllerWithIdentifier("userScene") as! UINavigationController
        let userCtrl = navCtrl.viewControllers[0] as! UserViewController
        userCtrl.loginname = loginname
        return navCtrl
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let dest = segue.destinationViewController as! UserActivitiesController
        let code = menuItems[tableView.indexPathForSelectedRow!.row].code
        dest.navigationItem.title = loginname
        dest.activities = user[code].arrayValue
    }
}