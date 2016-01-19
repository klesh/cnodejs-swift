//
//  Api.swift
//  CNode
//
//  Created by Klesh Wong on 1/5/16.
//  Copyright © 2016 Klesh Wong. All rights reserved.
//

import Alamofire
import SwiftyJSON

class ApiClient {
    static let TABS = [
        (name: "", text: "全部"),
        (name: "good", text: "精华"),
        (name: "share", text: "分享"),
        (name: "ask", text: "问答"),
        (name: "job", text: "招聘")
    ];
    
    static let LIMIT = 20
    static let BASE_URL = NSURL(string: "https://cnodejs.org")!
    static let API_URL = "https://cnodejs.org/api/v1"
    static let TOPIC_LIST_API_URL = API_URL + "/topics"
    static let TOPIC_DETAIL_API_URL = API_URL + "/topic"
    static let ACCESS_TOKEN_URL = API_URL + "/accesstoken"
    static let USER_URL = API_URL + "/user"
    static let MESSAGES_COUNT_URL = API_URL + "/message/count"
    static let MESSAGES_URL = API_URL + "/messages"
    static let MARK_ALL_URL = API_URL + "/message/mark_all"
    
    // weak 关键字，确保不产生相互强引用导致内存泄露
    weak var viewController: UIViewController!
    
    // 保存 UIViewController 用于显示警告窗口
    init(_ viewController: UIViewController) {
        self.viewController = viewController
    }
    
    class func getTabText(name: String?) -> String {
        let n = name == nil ? "" : name!;
        for (var i = 0; i < ApiClient.TABS.count; i++) {
            if ApiClient.TABS[i].name == n {
                return ApiClient.TABS[i].text
            }
        }
        preconditionFailure(String(format: "指定的%s不存在", n))
    }
    
    // 对请求结果进行统一处理，根据是否有错误决定调用 success 还是 error(可选) 。 最后调用 done(可选)
    func process(response: Response<AnyObject, NSError>, _ error: (JSON -> Void)? = nil, _ done: (Void -> Void)? = nil, _ success: JSON -> Void)  {
        //print(response)
        if let err = response.result.error {
            Utils.alert(self.viewController, title: "网络错误", message: err.description)
            if let errorFunc = error {
                errorFunc(JSON([ "success": false, "errMessage": err.description ]))
            }
        } else {
            if response.response?.statusCode == 200 {
                var data = JSON(response.result.value!)
                
                if let err_message = data["error_msg"].string {
                    Utils.alert(viewController, errorMessage: err_message)
                } else {
                    success(data)
                }
                
            } else if let errorFunc = error {
                var data = JSON(response.result.value!)
                data["_status"] = JSON((response.response?.statusCode)!)
                data["_content"] = JSON(response.result.description)
                errorFunc(data)
            } else {
                let message = "RESPONSE: \(response.result.description)\nURL: \(response.request?.URLString)"
                Utils.alert(viewController, title: "Status: \(response.response!.statusCode)", message: message)
            }
        }
        
        // 若有指定 done , 在 success 或 error 之后，done 函数都会被调用
        if let doneFunc = done {
            doneFunc()
        }
    }
    
    // 话题列表
    func getTopicList(page: Int?, tab: String? = nil, error: (JSON -> Void)? = nil, done: (Void -> Void)? = nil, success: JSON -> Void) {
        let page_str = page == nil ? "1" : String(page!)
        let tab_str = tab == nil ? "" : tab!
        let limit_str = String(ApiClient.LIMIT)
        Alamofire.request(.GET, ApiClient.TOPIC_LIST_API_URL, parameters: [ "page": page_str, "tab": tab_str, "limit": limit_str ]).responseJSON { response in
            self.process(response, error, done, success)
        }
    }
    
    // 话题明细
    func getTopicDetail(id: String, error: (JSON -> Void)? = nil, done: (Void -> Void)? = nil, success: JSON -> Void) {
        Alamofire.request(.GET, ApiClient.TOPIC_DETAIL_API_URL + "/" + id).responseJSON { response in
            self.process(response, error, done, success)
        }
    }
    
    // 新建主题
    func createTopic(token: String, title: String, tab: String, content: String, error: (JSON -> Void)? = nil, done: (Void -> Void)? = nil, success: JSON -> Void) {
        Alamofire.request(.POST, ApiClient.TOPIC_LIST_API_URL, parameters: [
                "accesstoken": token,
                "title": title,
                "tab": tab,
                "content": content
            ]).responseJSON { response in
            self.process(response, error, done, success)
        }
    }
    
    // 创建回复
    func createReply(token: String, id: String, content: String, replyTo: String?,
        error: (JSON -> Void)? = nil, done: (Void -> Void)? = nil, success: JSON -> Void)
    {
        Alamofire.request(.POST, "\(ApiClient.TOPIC_DETAIL_API_URL)/\(id)/replies", parameters: [
                "accesstoken": token,
                "content": content,
                "reply_id": replyTo == nil ? "" : replyTo!
            ]).responseJSON { response in self.process(response, error, done, success) }
    }
    
    // 点赞或取消点赞
    func thumbsReply(token: String, replyId: String, error: (JSON -> Void)? = nil, done: (Void -> Void)? = nil, success: JSON -> Void) {
        Alamofire.request(.POST, "\(ApiClient.API_URL)/reply/\(replyId)/ups", parameters: [
                "accesstoken": token
            ]).responseJSON { response in
            self.process(response, error, done) { data in
                success(data["data"])
            }
        }
    }
    
    // 验证 Access Token 有效性
    func validateToken(token: String, error: (JSON -> Void)? = nil, done: (Void -> Void)? = nil, success: JSON -> Void) {
        Alamofire.request(.POST, ApiClient.ACCESS_TOKEN_URL, parameters: ["accesstoken": token]).responseJSON { response in
            self.process(response, error, done, success)
        }
    }
    
    // 取得用户明细
    func getUser(loginname: String, error: (JSON -> Void)? = nil, done: (Void -> Void)? = nil, success: JSON -> Void) {
        Alamofire.request(.GET, ApiClient.USER_URL + "/" + loginname).responseJSON { response in
            self.process(response, error, done, success)
        }
    }
    
    // 取得未读消息数
    func getUnreadsCount(token: String, error: (JSON -> Void)? = nil, done: (Void -> Void)? = nil, success: Int -> Void) {
        Alamofire.request(.GET, ApiClient.MESSAGES_COUNT_URL, parameters: ["accesstoken": token]).responseJSON { response in
            self.process(response, error, done) { data in
                success(data["data"].intValue)
            }
        }
    }
    
    // 取得所有消息
    func getMessages(token: String, error: (JSON -> Void)? = nil, done: (Void -> Void)? = nil, success: JSON -> Void) {
        Alamofire.request(.GET, ApiClient.MESSAGES_URL, parameters: ["accesstoken": token]).responseJSON { response in
            self.process(response, error, done) { data in
                success(data["data"])
            }
        }
    }
    
    // 将所有消息标记为已读
    func markAllAsRead(token: String, error: (JSON -> Void)? = nil, done: (Void -> Void)? = nil, success: JSON -> Void) {
        Alamofire.request(.POST, ApiClient.MARK_ALL_URL, parameters: ["accesstoken": token]).responseJSON { response in
            self.process(response, error, done) { data in
                success(data["data"])
            }
        }
    }
}