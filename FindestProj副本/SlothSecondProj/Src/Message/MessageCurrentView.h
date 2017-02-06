//
//  MessageCurrentView.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-20.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageVo.h"
#import "CalendarEventOperation.h"
#import "DrawLotteryView.h"
#import "CalendarEventDao.h"

@class  MessageDetailViewController;

@interface MessageCurrentView : UIView<UIWebViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,strong)MessageVo *m_currMessageVo;
@property (nonatomic)BOOL bShow;       //展开和隐藏

////////////////////////////////////////////////////////////////////////////////
@property (nonatomic,strong)UILabel *lblSender;                     //发件人

@property (nonatomic,strong)UILabel *lblSenderDetail;               //发件人详细
@property (nonatomic,strong)UILabel *lblReceiverDetail;             //收件人详细
@property (nonatomic,strong)UILabel *lblCCDetail;                   //抄送人详细
@property (nonatomic,strong)UILabel *lblBCCDetail;                  //密送人详细
@property (nonatomic,strong)UILabel *lblDateTimeDetail;             //时间
@property (nonatomic,strong)UILabel *lblAttachmentDetail;           //附件

@property (nonatomic,strong)UILabel *lblTitle;                      //消息标题
@property (nonatomic,strong)UILabel *lblReceiver;                   //收件人名称
@property (nonatomic,strong)UIButton *btnShowDetail;                //显示、隐藏收件人

@property (nonatomic,strong)UIWebView *webViewContent;              //消息内容
@property (nonatomic,strong)UILabel *lblDateTime;                   //消息时间
@property (nonatomic,strong)UILabel *lblAttachmentNum;              //附件个数
@property (nonatomic,strong)UILabel *lblFromGroup;                  //来自组

@property (nonatomic,strong)UIImageView *imgViewStar;               //星标
@property (nonatomic,strong)UIImageView *imgViewHead;               //头像
@property (nonatomic,strong)UIImageView *imgViewAttachmentIcon;

@property (nonatomic,strong)UIView *viewSingleLine1;
@property (nonatomic,strong)UIView *viewSingleLine2;
@property (nonatomic,strong)UIView *viewSingleLine3;

//attachment view
@property(nonatomic,strong)UIView *viewAttachmentContainer;

//lottery view
@property(nonatomic,strong)UIView *viewLotteryContainer;

//vote view
@property(nonatomic,strong)UIView *viewVoteContainer;

//schedule view
@property(nonatomic,strong)UIView *viewScheduleContainer;
@property(nonatomic,strong)CalendarEventDao *calendarEventDao;

//parent view
@property (nonatomic,weak)MessageDetailViewController *parentViewController;

@property(nonatomic,strong)DrawLotteryView *drawLotteryView;



-(CGFloat)initWithMessageVo:(MessageVo*)messageVo andStatus:(BOOL)bStatus;
-(void)updateStarFrame;

@end
