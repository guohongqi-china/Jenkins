//
//  CommentVo.h
//  Sloth
//
//  Created by Ann Yao on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CommentVo;
@interface CommentVo : NSObject

@property (nonatomic, strong) NSString *strID;                  //评论ID
@property (nonatomic, strong) NSString *strBlogID;              //博文Id
@property (nonatomic, strong) NSString *strOrgId;               //公司ID
@property (nonatomic, strong) NSString *strparentId;            //评论引用的评论ID
@property (nonatomic, strong) NSString *strParentUserId;        //父评论的评论人ID
@property (nonatomic, strong) NSString *strParentUserName;      //父评论的评论人
@property (nonatomic, strong) NSString *strContent;             //评论正文
@property (nonatomic, strong) NSString *strContentHtml;         //评论正文html
@property (nonatomic, strong) NSString *strUserName;            //评论人名称
@property (nonatomic, strong) NSString *strUserID;              //评论人ID
@property (nonatomic) NSInteger nBadge;                           //勋章（用于头像显示）
@property (nonatomic) double fIntegral;                        //积分（用于头像显示）
@property (nonatomic, strong) NSString *strCreateDate;          //创建日期
@property (nonatomic, strong) NSString *strDeleteDate;          //删除日期
@property (nonatomic, strong) NSString *strUserImage;           //评论人头像
@property (nonatomic, strong) NSString *strMentionID;           //赞ID,id不为null则本人赞过，否则赞过
@property (nonatomic) NSInteger nPraiseCount;   //赞的数量

@property (nonatomic) int delFlag;                    //是否删除 1=是 0=不是

@property (assign, nonatomic) PraiseState praiseState; //点赞状态

@end
