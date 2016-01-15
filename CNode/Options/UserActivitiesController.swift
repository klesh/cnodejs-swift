//
//  UserActivitiesController.swift
//  CNode
//
//  Created by Klesh Wong on 1/11/16.
//  Copyright © 2016 Klesh Wong. All rights reserved.
//

import UIKit
import SwiftyJSON

class UserActivitiesController : UITableViewController, UserActivitiesCellDelegate {
    var activities: [JSON]!
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userActivitiesItem", forIndexPath: indexPath) as! UserActivitiesCell
        cell.delegate = self
        cell.bind(activities[indexPath.row])
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.navigationController?.pushViewController(TopicDetailViewController.create(activities[indexPath.row]), animated: true)
    }
    
    func avatarTapped(author: String, cell: UserActivitiesCell) {
        presentViewController(UserViewController.create(author), animated: true, completion: nil)
    }
}
