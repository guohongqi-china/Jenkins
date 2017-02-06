//
//  AnswerVo.h
//  SlothSecondProj
//
//  Created by visionet on 14-3-24.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnswerVo : NSObject

@property (nonatomic, retain) NSString *answerId;                //Id
@property (nonatomic, retain) NSString *questId;                 //questId
@property (nonatomic, retain) NSString *answerText;              //回答内容
@property (nonatomic, retain) NSString *answerHtml;              //回答内容,html
@property (nonatomic, retain) NSString *strUserName;             //用户名称
@property (nonatomic, retain) NSString *userId;                 //用户Id
@property (nonatomic, retain) NSString *strParentId;             //追加回答id
@property (nonatomic, retain) NSString *strCreateDate;           //创建时间
@property (nonatomic, retain) NSString *strDeleteDate;           //删除时间
@property (nonatomic, assign) int nPraiseCount;                  //赞数
@property (nonatomic, assign) int nDelFlag;                      //删除标志
@property (nonatomic, assign) int isSolution;                    //是否解决（0—否，1—是）
@property (nonatomic, retain) NSString *orgId;                   //公司ID
@property (nonatomic, retain) NSString *vestImg;                 //头像
@property (nonatomic, retain) NSString *mentionId;               //操作人是否对该回答进行赞过，为null没有点赞，为数字点赞过
@property (nonatomic, retain) NSString *answers;                 //追加回答
@property (nonatomic, retain) NSMutableArray *paiserArray;

@property (nonatomic, retain) NSString *strPictureUrl;           //默认第一张图片

@end
