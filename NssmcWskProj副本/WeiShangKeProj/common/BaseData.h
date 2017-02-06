//
//  BaseData.h
//  WeiShangKeProj
//
//  Created by 焱 孙 on 5/17/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

//会话状态
typedef enum _SessionState
{
    SessionUnassigned = -1,   //未处理
    SessionUnprocess = 1,   //未处理
    SessionProcessing = 2,  //处理中
    SessionSuspended = 3,   //已暂停
    SessionProcessed = 4    //已处理
}SessionState;

@interface BaseData : NSObject

@end
