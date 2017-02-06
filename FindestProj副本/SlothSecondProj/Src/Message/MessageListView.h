//
//  MessageListView.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-19.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageVo.h"

@class  MessageDetailViewController;

@interface MessageListView : UIView

@property (nonatomic,strong)MessageVo *messageVo;

@property (nonatomic,strong)UILabel *lblSender;                 //发件人名称
@property (nonatomic,strong)UILabel *lblTitle;                  //消息标题
@property (nonatomic,strong)UILabel *lblContent;                //消息内容
@property (nonatomic,strong)UILabel *lblDateTime;               //消息时间
@property (nonatomic,strong)UILabel *lblAttachmentNum;          //附件个数
@property (nonatomic,strong)UILabel *lblFromGroup;              //来自组

@property (nonatomic,strong)UIImageView *imgViewHead;           //头像
@property (nonatomic,strong)UIImageView *imgViewMsgState;       //邮件状态
@property (nonatomic,strong)UIImageView *imgViewAttachmentIcon;

@property (nonatomic,strong)UIImageView *imgViewBK;

@property (nonatomic,strong)UIView *viewTap;

//parent view
@property (nonatomic,weak)MessageDetailViewController *parentViewController;

-(CGFloat)initWithMessageVo:(MessageVo*)messageVo;

@end
