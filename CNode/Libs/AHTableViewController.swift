//
//  AHTableViewController.swift
//  Helloworld
//
//  Created by Klesh Wong on 1/12/16.
//  Copyright © 2016 Klesh Wong. All rights reserved.
//

import UIKit

class AHTableViewController: UITableViewController {
    var cache = [[UITableViewCell]]()
    
    // 将 prototypeType cell 设定为 标头
    func setHeader<T: UITableViewCell>(identifier: String, setup: (T -> Void)) {
        let head = tableView.dequeueReusableCellWithIdentifier(identifier) as! T
        tableView.tableHeaderView = head
        setup(head)
    }
    
    // 为指定 section 创建指定条目的 cell
    func setSection(identifier: String, count: Int, var section: Int = -1) {
        if section == -1 {
            section = cache.count
        }
        while cache.count <= section {
            cache.append([UITableViewCell]())
        }
        
        for var i = cache[section].count; i < count; i++ {
            cache[section].append(tableView.dequeueReusableCellWithIdentifier(identifier)!)
        }
        
        while cache[section].count > count {
            cache[section].popLast()
        }
        
        tableView.reloadData()
    }
    
    // 清空数据，为刷新作准备
//    func clearAllSections() {
//        cache = [[UITableViewCell]]()
//    }
    
    // 负责将 cell 设定好，这个会在合适的时候才调用
    func populateCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        preconditionFailure("must be implemented")
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return cache.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cache[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return cache[indexPath.section][indexPath.row]
    }
    
    // 只有这时候才能确定宽度，再 loadHTMLString 才能得到正确的高度
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        populateCell(cell, indexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cache[indexPath.section][indexPath.row].frame.height - 1
    }
}
