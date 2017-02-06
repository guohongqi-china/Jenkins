//
//  MeetBookRemarkView.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/9/10.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MeetBookRemarkView;
//参数：0表示取消，1表示确认,
typedef void(^MeetBookRemarkBlock)(MeetBookRemarkView *remarkView,NSInteger nType,NSString* strTitle,NSString* strName,NSString* strContact,NSString* strRemark);

@interface MeetBookRemarkView : UIView

- (instancetype)initWithFrame:(CGRect)frame resultBlock:(MeetBookRemarkBlock)resultlBlock;

@end
