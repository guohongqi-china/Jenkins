//
//  EmailListCell.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-12.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageVo.h"

@interface MessageListCell : UITableViewCell

@property (nonatomic,strong)MessageVo *messageVo;

@property (nonatomic,strong)UILabel *lblSender;                 //发件人名称
@property (nonatomic,strong)UILabel *lblTitle;                  //消息标题
@property (nonatomic,strong)UILabel *lblContent;                //消息内容
@property (nonatomic,strong)UILabel *lblDateTime;               //消息时间
@property (nonatomic,strong)UILabel *lblFromGroup;          //来自组

@property (nonatomic,strong)UIImageView *imgViewHead;         //头像
@property (nonatomic,strong)UIImageView *imgViewMsgState;     //邮件状态
@property (nonatomic,strong)UIImageView *imgViewAttachmentIcon;
@property (nonatomic,strong)UIImageView *imgViewMsgType;       //投票、日程分别显示相应的icon
@property (nonatomic,strong)UIImageView *imgViewArrow;
@property (nonatomic,strong)UIImageView *imgViewStarIcon;       //星标

-(void)initWithMessageVo:(MessageVo*)messageVo;
+(CGFloat)calculateCellHeight:(MessageVo*)messageVo;

@end
