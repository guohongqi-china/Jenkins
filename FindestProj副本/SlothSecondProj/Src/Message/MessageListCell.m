//
//  EmailListCell.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-12.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "MessageListCell.h"
#import "ServerURL.h"
#import "UIImage+Extras.h"
#import "UIImageView+WebCache.h"
#import "ReceiverVo.h"

@implementation MessageListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
        self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
        self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
        
        
        // Initialization code
        self.imgViewMsgState = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_imgViewMsgState];
        
        self.imgViewHead = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_imgViewHead];
        
        self.lblSender = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblSender.backgroundColor = [UIColor clearColor];
        //
        self.lblSender.font = [UIFont systemFontOfSize:TextH(15)];
        self.lblSender.textAlignment = NSTextAlignmentLeft;
        self.lblSender.textColor = [UIColor blackColor];
        self.lblSender.textColor = [SkinManage colorNamed:@"metting_Tite_color"];
        [self addSubview:_lblSender];
        
        self.lblDateTime = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblDateTime.backgroundColor = [UIColor clearColor];
        self.lblDateTime.font = [UIFont systemFontOfSize:TextH(13)];
        self.lblDateTime.textAlignment = NSTextAlignmentRight;
        self.lblDateTime.textColor = COLOR(153, 153, 153, 1.0);
        self.lblDateTime.textColor = [SkinManage colorNamed:@"myjob_Button_title_color"];
        [self addSubview:_lblDateTime];
        
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblTitle.backgroundColor = [UIColor clearColor];
        self.lblTitle.font = [UIFont systemFontOfSize:TextH(14)];
        self.lblTitle.textAlignment = NSTextAlignmentLeft;
        self.lblTitle.textColor = COLOR(51, 51, 51, 1.0);
        self.lblTitle.textColor = [SkinManage colorNamed:@"message_color"];
        [self addSubview:_lblTitle];
        
        self.lblContent = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblContent.backgroundColor = [UIColor clearColor];
        self.lblContent.font = [UIFont systemFontOfSize:TextH(14)];
        self.lblContent.textAlignment = NSTextAlignmentLeft;
        self.lblContent.lineBreakMode = NSLineBreakByTruncatingTail;
        self.lblContent.textColor = COLOR(153, 153, 153, 1.0);
        self.lblDateTime.textColor = [SkinManage colorNamed:@"myjob_Button_title_color"];
        [self addSubview:_lblContent];
        
        self.lblFromGroup = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblFromGroup.backgroundColor = [UIColor clearColor];
        self.lblFromGroup.font = [UIFont systemFontOfSize:TextH(13)];
        self.lblFromGroup.textAlignment = NSTextAlignmentLeft;
        self.lblFromGroup.lineBreakMode = NSLineBreakByTruncatingTail;
        self.lblFromGroup.textColor = COLOR(153, 153, 153, 1.0);
        [self addSubview:_lblFromGroup];
        
        self.imgViewAttachmentIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imgViewAttachmentIcon.image = [UIImage imageNamed:@"attachment_icon"];
        [self addSubview:_imgViewAttachmentIcon];
        
        self.imgViewMsgType = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.imgViewMsgType];
        
        self.imgViewStarIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.imgViewStarIcon];
        
        self.imgViewArrow = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imgViewArrow.image = [[UIImage imageNamed:@"arrow_gray_right"] stretchableImageWithLeftCapWidth:160 topCapHeight:20];
        [self addSubview:self.imgViewArrow];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)initWithMessageVo:(MessageVo*)messageVo
{
    CGFloat fHeight = 15;
    self.messageVo = messageVo;
    
    //0.head image
    self.imgViewHead.frame = CGRectMake(20, fHeight, 40, 40);
    UIImage *phImageName = [[UIImage imageNamed:@"default_m"] roundedWithSize:CGSizeMake(40,40)];
    [self.imgViewHead sd_setImageWithURL:[NSURL URLWithString:messageVo.strAuthorHeadImg] placeholderImage:phImageName];
    
    self.imgViewArrow.frame = CGRectMake(kScreenWidth-26, fHeight+35, 13, 13);
    
    //1.email sender、attachment num、datetime,group
    self.lblSender.text = messageVo.strAuthorName;
    self.lblSender.frame = CGRectMake(65, fHeight+2, kScreenWidth-175, TextH(18));
    
    self.lblDateTime.text = [Common getChatTimeStr:messageVo.strCreateDate];
    self.lblDateTime.frame = CGRectMake(kScreenWidth-120, fHeight+4, 100, TextH(14));
    
    NSString *strFromGroup = [self getFromGroupString];
    if (strFromGroup.length == 0)
    {
        self.lblSender.frame = CGRectMake(65, fHeight+2+9, kScreenWidth-175, TextH(18));
        self.lblFromGroup.frame = CGRectZero;
    }
    else
    {
        self.lblSender.frame = CGRectMake(65, fHeight+2, kScreenWidth-175, TextH(18));
        self.lblFromGroup.text = [NSString stringWithFormat:@"来自组：%@",strFromGroup];
        self.lblFromGroup.frame = CGRectMake(65, fHeight+2+20, kScreenWidth-90, TextH(18));
    }
    
    //包含附件则显示附件icon
    if (messageVo.strContentType.length>0 && [self.messageVo.strContentType rangeOfString:@"A"].length>0)
    {
        CGSize sizeSender = [Common getStringSize:self.lblSender.text font:self.lblSender.font bound:CGSizeMake(MAXFLOAT, 18) lineBreakMode:NSLineBreakByCharWrapping];
        if (sizeSender.width>145)
        {
            self.imgViewAttachmentIcon.frame = CGRectMake(210, self.lblSender.frame.origin.y+2, 15, 13.5);
        }
        else
        {
            self.imgViewAttachmentIcon.frame = CGRectMake(65+sizeSender.width+4, self.lblSender.frame.origin.y+2, 15, 13.5);
        }
    }
    else
    {
        self.imgViewAttachmentIcon.frame = CGRectZero;
    }
    
    //2.title
    fHeight += 50+4;
    self.lblTitle.text = messageVo.strTitle;
    self.lblTitle.frame = CGRectMake(20, fHeight, kScreenWidth-62, TextH(15));
    
    //4.msg type icon image
    BOOL bHasContentType = YES;
    if([self.messageVo.strContentType rangeOfString:@"C"].length>0)
    {
        //vote
        self.imgViewMsgType.frame = CGRectMake(kScreenWidth-25, fHeight+1, 15, 13.5);
        self.imgViewMsgType.image = [UIImage imageNamed:@"message_vote_icon"];
    }
    else if([self.messageVo.strContentType rangeOfString:@"B"].length>0)
    {
        //schedule
        self.imgViewMsgType.frame = CGRectMake(kScreenWidth-25, fHeight+1, 15, 13.5);
        self.imgViewMsgType.image = [UIImage imageNamed:@"schedule_icon"];
    }
    else if([self.messageVo.strContentType rangeOfString:@"E"].length>0)
    {
        //lottery
        self.imgViewMsgType.frame = CGRectMake(kScreenWidth-25, fHeight+1, 15, 13.5);
        self.imgViewMsgType.image = [UIImage imageNamed:@"lottery_icon"];
    }
    else if([self.messageVo.strContentType rangeOfString:@"W"].length>0)
    {
        //工单已经评分过
        self.imgViewMsgType.frame = CGRectMake(kScreenWidth-25, fHeight+1, 15, 13.5);
        self.imgViewMsgType.image = [UIImage imageNamed:@"workorder_icon"];
    }
    else
    {
        self.imgViewMsgType.frame = CGRectZero;
        bHasContentType = NO;
    }
    
    //显示星标
    if (self.messageVo.bHasStarTag)
    {
        if (bHasContentType)
        {
            //星标+分类图标
            self.imgViewStarIcon.frame = CGRectMake(kScreenWidth-42, fHeight+1, 15, 13.5);
            self.imgViewStarIcon.image = [UIImage imageNamed:@"star_icon"];
        }
        else
        {
            //只有星标
            self.imgViewStarIcon.frame = CGRectMake(kScreenWidth-25, fHeight+1, 15, 13.5);
            self.imgViewStarIcon.image = [UIImage imageNamed:@"star_icon"];
        }
    }
    else
    {
        self.imgViewStarIcon.frame = CGRectZero;
    }
    
    //3.content
    fHeight += 15+4;
    self.lblContent.text = messageVo.strTextContent;
    CGSize sizeContent = [Common getStringSize:self.lblContent.text font:self.lblContent.font bound:CGSizeMake(kScreenWidth-40, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    if (sizeContent.height>20)
    {
        //more than 1 line
        self.lblContent.frame = CGRectMake(20, fHeight, kScreenWidth-40, 40);
        self.lblContent.numberOfLines = 2;
    }
    else
    {
        //1 line
        self.lblContent.frame = CGRectMake(20, fHeight, kScreenWidth-40, 20);
        self.lblContent.numberOfLines = 1;
    }
    
    //5.email state
    fHeight += self.lblContent.frame.size.height+10;
    self.imgViewMsgState.image = [UIImage imageNamed:[BusinessCommon getImageNameByMessageState:messageVo.nUnreader]];
    self.imgViewMsgState.frame = CGRectMake(4, (fHeight-12)/2, 12, 12);
}

-(NSString*)getFromGroupString
{
    NSMutableString *strFromGroup = [NSMutableString string];
    for (int i=0; i<self.messageVo.aryReceiverList.count; i++)
    {
        ReceiverVo *receiverVo = [self.messageVo.aryReceiverList objectAtIndex:i];
        if ([receiverVo.strType isEqualToString:@"S"])
        {
            [strFromGroup appendFormat:@"%@; ",receiverVo.strName];
        }
    }
    return strFromGroup;
}

+ (CGFloat)calculateCellHeight:(MessageVo*)messageVo
{
    CGFloat fHeight = 15;
    
    //1.email sender、attachment num、datetime
    
    //2.title
    fHeight += 50+4;
    
    //3.content
    fHeight += 15+4;
    CGSize sizeContent = [Common getStringSize:messageVo.strTextContent font:[UIFont systemFontOfSize:14] bound:CGSizeMake(270, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    if (sizeContent.height>TextH(20))
    {
        //more than 1 line
        fHeight += TextH(40);
    }
    else
    {
        //1 line
        fHeight += TextH(20);
    }
    
    //4.email state
    fHeight += 10;
    return fHeight;
}

@end
