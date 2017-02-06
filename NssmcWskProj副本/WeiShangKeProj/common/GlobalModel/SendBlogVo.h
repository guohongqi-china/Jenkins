//
//  SendBlogVo.h
//  Sloth
//
//  Created by Ann Yao on 12-9-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendBlogVo : NSObject

@property (nonatomic, retain) NSString *vestId;             //用户ID
@property (nonatomic, retain) NSString *streamId;           //博文ID
@property (nonatomic, retain) NSString *parentStreamId;     //被转发博文ID
@property (nonatomic, retain) NSString *parentCommentId;    //被评论的评论ID
@property (nonatomic, retain) NSString *teamIds;            //群组ID合集 格式10,12,39
@property (nonatomic, retain) NSString *titleName;          //标题名称
@property (nonatomic, retain) NSString *streamContent;      //博文内容
@property (nonatomic, retain) NSString *transmitContent;    //转发内容
@property (nonatomic, retain) NSString *commentContent;     //评论内容
@property (nonatomic, retain) NSString *tags;               //博文标签

@property (nonatomic, assign) double latitude;              //维度
@property (nonatomic, assign) double longitude;             //经度
@property (nonatomic, assign) int mobileType;               //手机类型 4=iphone 5=android
@property (nonatomic, assign) int hasImg;                   //是否有图片 1/0
@property (nonatomic, assign) int hasTxt;                   //是否有文档 1/0
@property (nonatomic, assign) int hasSound;                 //是否有音频 1/0
@property (nonatomic, assign) int hasVideo;                 //是否有视频 1/0
@property (nonatomic, assign) int commentToAuthor;          //是否评论给当前博文的作者 1/0
@property (nonatomic, assign) int commentToOriginalAuthorId;    //是否评论给被转发博文的原文的作者 1/0
@property (nonatomic, assign) int toMyStream;                   //是否转发到我的博文 1/0
@property (nonatomic, assign) int toOriginalStreamAuthor;       //是否评论给原文作者 1/0

@property (nonatomic, retain) NSString *imagePath;              //图片路径
@property (nonatomic, retain) NSString *videoPath;              //视频路径

@end
