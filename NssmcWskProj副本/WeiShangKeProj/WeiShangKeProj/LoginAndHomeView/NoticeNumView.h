//
//  NoticeNumView.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 14-6-3.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoticeNumView : UIView

@property(nonatomic,strong) UIImageView *imgViewNotice;
@property(nonatomic,strong) UILabel *lblNoticeNum;

+ (NSInteger)getNoticeNum;
+ (void)setNoticeNum:(NSInteger)nNoticeNum;

+ (NSInteger)getMsgNum;
+ (void)setMsgNum:(NSInteger)nMsgNum;

- (void)updateNoticeNum;

@end
