//
//  AnnouncementVo.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 14-6-17.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnnouncementVo : NSObject

@property(nonatomic,strong)NSString *strID;                 //公告ID
@property(nonatomic,strong)NSString *strTitle;  //title
@property(nonatomic,strong)NSString *strImageURL;//公告图片
@property(nonatomic,strong)UIImage *imgBuffer;//公告图片(for buffer)
@property(nonatomic,strong)NSString *strBlogID;//分享ID
@property(nonatomic)NSInteger nNoticeType;//公告类型(1-公告;2-节假日;3-纪念日)
@property(nonatomic,strong)NSString *strCreateDate;//创建日期
@property(nonatomic,strong)NSString *strStartDate;//公告起始日期
@property(nonatomic,strong)NSString *strEndDate;//公告结束日期
@property(nonatomic,strong)NSString *strCreatorID;//创建者ID
@property(nonatomic,strong)NSString *strCreatorName;//创建者姓名
@property(nonatomic,strong)NSString *strCreatorImage;//创建者头像

@end
