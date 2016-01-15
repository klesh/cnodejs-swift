//
//  AppDelegate.swift
//  CNode
//
//  Created by Klesh Wong on 1/3/16.
//  Copyright © 2016 Klesh Wong. All rights reserved.
//

import UIKit
import SwiftyJSON
import MMDrawerController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var drawer: MMDrawerController!
    var nav: NavViewController!
    var topicList: TopicListViewController!
    
    var user: (loginname: String, token: String)? {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let token = defaults.objectForKey("token") as? String {
            return ( loginname: defaults.objectForKey("loginname") as! String, token: token )
        }
        return nil
    }
    
    var setting: (draftEnabled: Bool, signatureEnabled: Bool, signatureText: String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        return (
            draftEnabled: defaults.boolForKey("draftEnabled"),
            signatureEnabled: defaults.boolForKey("signatureEnabled"),
            signatureText: defaults.objectForKey("signatureText") as! String
        )
    }
    
    func doLogin(loginname: String, token: String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(loginname, forKey: "loginname")
        defaults.setObject(token, forKey: "token")
        defaults.synchronize()
        nav.reloadLogin()
    }
    
    func doLogout() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("loginname")
        defaults.removeObjectForKey("token")
        defaults.synchronize()
        nav.reloadLogin()
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // create default controller
        let mainFrame = UIScreen.mainScreen().bounds
        window = UIWindow(frame: mainFrame)
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let navViewController = mainStoryboard.instantiateViewControllerWithIdentifier("mainNavMenu")
        let topicListViewController = mainStoryboard.instantiateViewControllerWithIdentifier("topicListScene")
        let mainViewController = UINavigationController(rootViewController: topicListViewController)
        //mainViewController.hidesBarsOnSwipe = true
        
        nav = navViewController as! NavViewController
        topicList = topicListViewController as! TopicListViewController
        
        drawer = MMDrawerController(centerViewController: mainViewController, leftDrawerViewController: navViewController)
        
        drawer.maximumLeftDrawerWidth = mainFrame.maxX * 0.7
        drawer.openDrawerGestureModeMask = .All
        drawer.closeDrawerGestureModeMask = .All
        drawer.setDrawerVisualStateBlock { (drawerController, drawerSide, percentVisible) -> Void in
            
            var sideDrawerViewController:UIViewController?
            if(drawerSide == MMDrawerSide.Left){
                sideDrawerViewController = drawerController.leftDrawerViewController;
            }
            sideDrawerViewController?.view.alpha = percentVisible
        }

        window?.rootViewController = drawer
        window?.makeKeyAndVisible()
        
        // setup default options
        NSUserDefaults.standardUserDefaults().registerDefaults(
            [
                "draftEnabled": true,
                "signatureEnabled": true,
                "signatureText": "Sent from CNodejs for iOS"
            ]
        )
        return true
    }
    
    func openNavView() {
        drawer.openDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    
    func closeNavView() {
        drawer.closeDrawerAnimated(true, completion: nil)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    class var app: AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
}

