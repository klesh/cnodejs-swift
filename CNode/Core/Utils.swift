//
//  Utils.swift
//  CNode
//
//  Created by Klesh Wong on 1/4/16.
//  Copyright © 2016 Klesh Wong. All rights reserved.
//

import UIKit
import SwiftDate

class Utils {
    static let DATE_TIME_FMT = DateFormat.Custom("yyyy-MM-dd HH:mm")
    static let TOP_BG = UIColor(red: (7/255.0), green: (166/255.0), blue: (7/255.0), alpha: 1.0)
    static let TAB_BG = UIColor(red: (239/255.0), green: (239/255.0), blue: (239/255.0), alpha: 1.0)

    // 提示信息
    class func alert(viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(ok)
        viewController.presentViewController(alert, animated: true, completion: nil)
    }
    
    // 提示错误信息
    class func alert(viewController: UIViewController, errorMessage: String) {
        Utils.alert(viewController, title: "出错啦", message: errorMessage)
    }
    
    // 修正以 // 为开头的网址
    class func fixURL(url: String?) -> String {
        return url!.hasPrefix("https:") ? url! : "https:" + url!;
    }
    
    // 将网址转化为 NSURL 对象
    class func toURL(url: String?) -> NSURL {
        return NSURL(string: Utils.fixURL(url))!
    }
    
    // 将控件变成圆形
    class func circleUp(view: UIView) {
        view.layer.cornerRadius = view.frame.width / 2
        view.clipsToBounds = true
    }
    
    // 给控伯加上圆角
    class func roundUp(view: UIView, radius: CGFloat) {
        view.layer.cornerRadius = radius;
        view.clipsToBounds = true
    }
    
    // 将 iso 时间转化为本地时间
    class func isoDateStringToLocal(isoDateString: String) -> String {
        return isoDateString.toDateFromISO8601()!.toString(DATE_TIME_FMT, inRegion: Region.LocalRegion())!
    }
    
    // 设置 tab 标签样式
    class func setupTabLabel(label: UILabel, top: Bool, tab: String?) {
        if (!top) {
            label.backgroundColor = TAB_BG
            label.textColor = UIColor.darkGrayColor()
            label.text = ApiClient.getTabText(tab)
        } else {
            label.backgroundColor = TOP_BG
            label.textColor = UIColor.whiteColor()
            label.text = "置顶"
        }
    }
    
    // 设置 FontAwesome
    class func fontAwesome(button: UIButton, code: Int, size: Int) {
        button.titleLabel!.font = UIFont(name: "FontAwesome", size: CGFloat(size))
        button.setTitle(String(format: "%C", code), forState: UIControlState.Normal)
    }
    
    // 创建 navigation button
    class func navButton(code: Int, target: AnyObject?, action: Selector) -> UIBarButtonItem {
        let btn = UIBarButtonItem(
            title: String(format: "%C", code),
            style: UIBarButtonItemStyle.Plain,
            target: target,
            action: action)
        btn.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "FontAwesome", size: 17)!, NSForegroundColorAttributeName: UIColor.blackColor()], forState: UIControlState.Normal)
        return btn
    }
    
    // 检测登录
    class func ensureLogon(viewController: UIViewController!, success: Void -> Void) {
        if let _ = AppDelegate.app.user {
            success()
        } else {
            let alert = UIAlertController(title: nil, message: "该操作需要登录帐户。是否现在登录？", preferredStyle: .ActionSheet)
            let ok = UIAlertAction(title: "登录", style: .Default) { action in
                viewController.presentViewController(LoginViewController.create(), animated: true) {
                    if let _ = AppDelegate.app.user {
                        success()
                    }
                }
            }
            let cancel = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
            alert.addAction(ok)
            alert.addAction(cancel)
            viewController.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    static let ONE_MINUTE = 60.0
    static let ONE_HOUR = 60 * ONE_MINUTE
    static let ONE_DAY = 24 * ONE_HOUR
    static let ONE_MONTH = 30 * ONE_DAY
    
    // 计算相对时间
    class func relativeTillNow(date: NSDate?) -> String {
        if date == nil {
            return ""
        }
        let theDate = date!
        let passed = abs(Double(theDate.timeIntervalSinceNow))
        if passed > ONE_MONTH {
            return theDate.toString(DATE_TIME_FMT, inRegion: Region.LocalRegion())!
        } else if passed > ONE_DAY {
            return String(Int(passed / ONE_DAY)) + "天前"
        } else if passed > ONE_HOUR {
            return String(Int(passed / ONE_HOUR)) + "小时前"
        } else if passed > ONE_MINUTE {
            return String(Int(passed / ONE_MINUTE)) + "分钟前"
        } else {
            return "刚刚"
        }
    }
    
    // 检测控件 text 属性是否为空，为空返回 false 并将控件设置为红色背景
    class func checkRequired(input: UIView) -> Bool {
        let text = input.valueForKey("text") as? String
        if text == nil || text!.isEmpty {
            input.backgroundColor = UIColor(red: 1.0, green: 220 / 250.0, blue: 220 / 250.0, alpha: 1.0)
            return false
        }
        input.backgroundColor = nil
        return true
    }
    
    class func processContent(content: String) -> String {
        let setting = AppDelegate.app.setting
        if setting.signatureEnabled {
            return "\(content)\n\n\(setting.signatureText)"
        }
        return content
    }
}