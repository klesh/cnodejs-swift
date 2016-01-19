//
//  WebContent.swift
//  Helloworld
//
//  Created by Klesh Wong on 1/11/16.
//  Copyright © 2016 Klesh Wong. All rights reserved.

import UIKit

class AHWebView : UIWebView, UIWebViewDelegate {
    // 调试用
    static var count = 0
    var index = 0
       
    // 初始化
    override func awakeFromNib() {
        index = AHWebView.count++
        
        scrollView.scrollEnabled = false
        self.delegate = self

        self.addObserver(self, forKeyPath: "scrollView.contentSize", options: NSKeyValueObservingOptions.New, context: nil)
        
        
    }
    
    var startAt: NSDate?
    func webViewDidStartLoad(webView: UIWebView) {
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "forceResize", userInfo: nil, repeats: false)
        startAt = NSDate()
    }
    
    var finishAt: NSDate?
    func webViewDidFinishLoad(webView: UIWebView) {
        finishAt = NSDate()
        resizeToFit()
    }
    
    var forced = false
    func forceResize() {
        if finishAt == nil {
            forced = true
            resizeToFit()
        }
        
    }
    
    let locker = NSLock();
    var reloading = false;
    func resizeToFit() {
        if reloading {
            return
        } else {
            locker.lock();
            if !reloading {
                reloading = true;
                unsafeResize();
                reloading = false;
            }
            locker.unlock();
        }
    }
    
    var prevWidth: CGFloat?
    var prevHeight: CGFloat?
    private func unsafeResize() {
        if finishAt == nil && !forced {
            return
        }
        
        let currWidth = scrollView.contentSize.width
        let currHeight = scrollView.contentSize.height
        
        if currWidth == prevWidth && currHeight == prevHeight {
            return
        }
        
        if let tableView = getTableView() {
            let tableCell = getTableCell()
            let totalMargin = tableCell.frame.height - frame.height
            
            var f = tableCell.frame
            f.size.height = totalMargin + currHeight
            tableCell.frame = f
            
            print("#\(index) reload height: \(currHeight) forced: \(forced)")
            
            tableView.reloadData()
        }
        
        prevWidth = currWidth
        prevHeight = currHeight
    }

    // 监测 html 的内容长度变化
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        resizeToFit()
    }
    
    // 释放
    deinit {
        self.removeObserver(self, forKeyPath: "scrollView.contentSize")
    }
    
    weak var tableView: UITableView?
    weak var tableCell: UITableViewCell?
    
    func getTableView() -> UITableView? {
        if tableView == nil {
            tableView = getClosestSuperView(UITableView)
        }
        return tableView
    }
    
    func getTableCell() -> UITableViewCell {
        if tableCell == nil {
            tableCell = getClosestSuperView(UITableViewCell)
        }
        return tableCell!
    }
    
    // 在 UIView 树中寻找最近指定类型的 view
    func getClosestSuperView<T>(viewType: T.Type) -> T? {
        var sv = self.superview
        while sv != nil && !(sv is T) {
            sv = sv?.superview
        }
        return sv as? T
    }
    
    // 将 html 片段包装到 html 中
    func wrapHTMLString(html: String) -> String {
        return "<html><head><style> html, body { margin: 0; padding: 0; word-wrap: break-word; font-family: 'Lucida Grande' } img { max-width:100% } </style></head><body>\(html)</body></html>"
    }
    
    var html: String?
    // 加载 html 片段，这个方法会被多次调用，为避免多次触发 webDidFinishLoad，必须作检测
    func loadHTMLAsPageOnce(html: String, baseURL: NSURL?) {
        if self.html != html {
            self.html = html
            loadHTMLString(wrapHTMLString(html), baseURL: baseURL)
        }
    }
}
