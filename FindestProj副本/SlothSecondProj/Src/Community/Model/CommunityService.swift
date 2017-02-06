//
//  CommunityService.swift
//  FindestProj
//
//  Created by 焱 孙 on 16/6/14.
//  Copyright © 2016年 visionet. All rights reserved.
//

import UIKit

class CommunityService: NSObject {
    
    //切换／加入 组织
    static func switchCommunity(strID: String, result: ResultBlock) {
        let strURL = ServerURL.getSwitchCommunityURL() + "/" + strID
        
        let framework = VNetworkFramework(URLString: strURL)
        framework.startRequestToServer("GET", parameter: nil) { (responseObject: AnyObject!, error: NSError!) in
            let retInfo = ServerReturnInfo()
            if error != nil {
                retInfo.bSuccess = false
                retInfo.strErrorMsg = error.localizedDescription
            } else {
                retInfo.bSuccess = true
            }
            
            result(retInfo)
        }
    }
    
    //获取圈子详情
    static func getCommunityDetail(strID: String, result: ResultBlock) {
        let strURL = ServerURL.getCommunityDetailURL() + "/" + strID
        
        let framework = VNetworkFramework(URLString: strURL)
        framework.startRequestToServer("GET", parameter: nil) { (responseObject: AnyObject!, error: NSError!) in
            let retInfo = ServerReturnInfo()
            if error != nil {
                retInfo.bSuccess = false
                retInfo.strErrorMsg = error.localizedDescription
            } else {
                retInfo.bSuccess = true
                
                let communityVo = CommunityVo()
                
                let json = JSON(responseObject)
                communityVo.strID = json["id"].stringValue
                communityVo.strName = json["fullName"].stringValue
                communityVo.strShortName = json["shortName"].stringValue
                communityVo.strDesc = json["remark"].stringValue
                communityVo.strHeaderUrl = ServerURL.getWholeURL(json["logoUrl"].stringValue)
                
                if json["isFollow"].intValue == 1 {
                    communityVo.isFollow = true
                } else {
                    communityVo.isFollow = false
                }
                
                retInfo.data = communityVo
            }
            
            result(retInfo)
        }
    }
    
}
