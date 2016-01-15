//
//  CNWebView.swift
//  CNode
//
//  Created by Klesh Wong on 1/13/16.
//  Copyright © 2016 Klesh Wong. All rights reserved.
//

import UIKit

class CNWebView : AHWebView {
    // 设定 webView 中的超链接在浏览器中打开
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked {
            print(request.URL)
            UIApplication.sharedApplication().openURL(request.URL!)
            return false
        }
        return true
    }
}