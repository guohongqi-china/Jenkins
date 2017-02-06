//
//  NoticeNumView.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 14-6-3.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "NoticeNumView.h"

//全局变量
NSInteger g_nNoticeNum = 0;
NSInteger g_nMsgNum = 0;
NSDate *g_dateNotice = nil;

@implementation NoticeNumView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BindNoticeNum" object:nil];
    
    g_nNoticeNum = 0;
    g_nMsgNum = 0;
    g_dateNotice = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.hidden = YES;
        self.userInteractionEnabled = NO;
        
        self.imgViewNotice = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"tabbar_badge"] stretchableImageWithLeftCapWidth:9 topCapHeight:0]];
        [self addSubview:self.imgViewNotice];
        
        self.lblNoticeNum = [[UILabel alloc]initWithFrame:CGRectZero];
        self.lblNoticeNum.font = [UIFont fontWithName:APP_FONT_NAME size:15];
        self.lblNoticeNum.textColor = [UIColor whiteColor];
        self.lblNoticeNum.textAlignment = NSTextAlignmentCenter;
        self.lblNoticeNum.backgroundColor = [UIColor clearColor];
        [self addSubview:self.lblNoticeNum];
    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bindData) name:@"BindNoticeNum" object:nil];
        
        [self updateNoticeNum];
    }
    return self;
}

- (void)updateNoticeNum
{
//    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:g_dateNotice];
//    if (g_dateNotice == nil || timeInterval>10)
//    {
//        dispatch_async(dispatch_get_global_queue(0,0),^{
//            //do thread work
//            ServerReturnInfo *retInfo = [ServerProvider getAllNotifyTypeUnreadNum];
//            if (retInfo.bSuccess)
//            {
//                //我的提醒和群组总量
//                NSMutableArray *aryData = retInfo.data;
//                if (aryData != nil && aryData.count>0)
//                {
//                    g_nNoticeNum = [[aryData objectAtIndex:1] integerValue];
//                    g_nNoticeNum += [[aryData objectAtIndex:2] integerValue];
//                    g_nMsgNum = [[aryData objectAtIndex:3] integerValue];
//                }
//                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    g_dateNotice = [NSDate date];
//                    
//                    //通知所有其他提醒更新提醒数字，包括自己
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"BindNoticeNum" object:nil];
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateMsgUnreadAllNum" object:nil];
//                });
//            }
//        });
//    }
//    else
//    {
//        [self bindData];
//    }
}

- (void)bindData
{
    NSString *strCount = @"";
    if (g_nNoticeNum>99)
    {
        strCount = @"99+";
    }
    else
    {
        strCount = [NSString stringWithFormat:@"%li",(long)g_nNoticeNum];
    }
    
    CGSize sizeLbl = [Common getStringSize:strCount font:[UIFont fontWithName:APP_FONT_NAME size:15] bound:CGSizeMake(CGFLOAT_MAX, 18) lineBreakMode:NSLineBreakByCharWrapping];
    CGFloat fWidth = 18;
    if (sizeLbl.width > fWidth || g_nNoticeNum >= 10)
    {
        fWidth = sizeLbl.width + 10;
    }
    
    if (g_nNoticeNum == 0)
    {
        self.imgViewNotice.frame = CGRectZero;
        self.hidden = YES;
    }
    else
    {
        self.imgViewNotice.frame = CGRectMake(0, 0, fWidth, 18);
        self.hidden = NO;
    }
    
    self.lblNoticeNum.text = strCount;
    self.lblNoticeNum.frame = CGRectMake(0, 0, self.imgViewNotice.frame.size.width, self.imgViewNotice.frame.size.height);
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.imgViewNotice.frame.size.width, self.imgViewNotice.frame.size.height);
}

+ (NSInteger)getNoticeNum
{
    return g_nNoticeNum;
}

+ (void)setNoticeNum:(NSInteger)nNoticeNum
{
    g_nNoticeNum = nNoticeNum;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BindNoticeNum" object:nil];
}

+ (NSInteger)getMsgNum
{
    return g_nMsgNum;
}

+ (void)setMsgNum:(NSInteger)nMsgNum
{
    g_nMsgNum = nMsgNum;
}

@end
