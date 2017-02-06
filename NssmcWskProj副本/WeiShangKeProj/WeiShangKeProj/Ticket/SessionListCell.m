//
//  SessionListCell.m
//  WeiShangKeProj
//
//  Created by 焱 孙 on 5/17/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import "SessionListCell.h"
#import "UIImage+Extras.h"
#import "UIImageView+WebCache.h"
#import "ChatCountDao.h"
#import "SessionListViewController.h"
#import "BusinessCommon.h"

@implementation SessionListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        self.imgViewHead = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imgViewHead.userInteractionEnabled = YES;
        [self.imgViewHead.layer setBorderWidth:1.0];
        [self.imgViewHead.layer setCornerRadius:2];
        self.imgViewHead.layer.borderColor = [[UIColor clearColor] CGColor];
        [self.imgViewHead.layer setMasksToBounds:YES];
        [self addSubview:self.imgViewHead];
        
        self.imgViewUnseeNum = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imgViewUnseeNum.image = [UIImage imageNamed:@"chat_unsee_num"];
        [self addSubview:self.imgViewUnseeNum];
        
        self.lblUnseeNum = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblUnseeNum.backgroundColor = [UIColor clearColor];
        self.lblUnseeNum.font = [UIFont systemFontOfSize:11];
        self.lblUnseeNum.textAlignment = NSTextAlignmentCenter;
        self.lblUnseeNum.textColor = [UIColor whiteColor];
        [self addSubview:self.lblUnseeNum];
        
        self.lblName = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblName.backgroundColor = [UIColor clearColor];
        self.lblName.font = [UIFont systemFontOfSize:14];
        self.lblName.lineBreakMode = NSLineBreakByTruncatingTail;
        self.lblName.textColor = COLOR(0,0,0,1);
        [self addSubview:self.lblName];
        
        self.lblChatMsg = [[FaceLabel alloc] initWithFrame:CGRectZero andFont:[UIFont systemFontOfSize:14]];
        self.lblChatMsg.backgroundColor = [UIColor clearColor];
        self.lblChatMsg.font = [UIFont systemFontOfSize:13];
        self.lblChatMsg.lineBreakMode = NSLineBreakByTruncatingTail;
        self.lblChatMsg.textColor = COLOR(142,142,147,1);
        self.lblChatMsg.numberOfLines = 1;
        [self addSubview:self.lblChatMsg];
        
        self.lblDateTime = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblDateTime.backgroundColor = [UIColor clearColor];
        self.lblDateTime.font = [UIFont systemFontOfSize:13];
        self.lblDateTime.textColor = COLOR(178,178,178,1);
        self.lblDateTime.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.lblDateTime];
        
        self.viewLine = [[UIView alloc]init];
        self.viewLine.backgroundColor = COLOR(200, 194, 204, 1.0);
        [self addSubview: self.viewLine];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)initWithChatObjectVo:(ChatObjectVo*)chatObjectVo
{
    self.m_chatObjectVo = chatObjectVo;
    
    //1.header img
    self.imgViewHead.frame = CGRectMake(10,7,36,36);
    self.imgViewHead.image = [UIImage imageNamed:[BusinessCommon getSessionHeadBySource:chatObjectVo.nLastChatFrom]];
   
    //2.unsee num and name
    self.lblName.frame = CGRectMake(56, 8, kScreenWidth-140, 17);
    NSMutableString *strName = [[NSMutableString alloc]initWithString:chatObjectVo.strCustomerNickName];
    if (chatObjectVo.strCustomerCode.length>0)
    {
        [strName appendFormat:@" [%@]",chatObjectVo.strCustomerCode];
    }
    //single chat
    NSString *strKey = [NSString stringWithFormat:@"session_%@",chatObjectVo.strID];
    NSString *strStatusKey = [ChatCountDao getSessionKeyByStatus:chatObjectVo.nSessionStatus];
    NSInteger nUnseenNum = 0;
    if (strStatusKey != nil)
    {
        nUnseenNum = [ChatCountDao getUnseenChatNumByKey:strKey status:strStatusKey];
    }
    
    //nUnseenNum = 8;
    if (nUnseenNum>0)
    {
        self.lblUnseeNum.text = (nUnseenNum>9)?@"N":[NSString stringWithFormat:@"%li",(long)nUnseenNum];
    }
    else
    {
        self.lblUnseeNum.text = @"";
    }
    self.lblName.text = strName;
    
    if (self.lblUnseeNum.text.length>0)
    {
        self.imgViewUnseeNum.frame = CGRectMake(10+36-18/2-2,self.imgViewHead.frame.origin.y-18/2+5,18,18);
        self.lblUnseeNum.frame = CGRectMake(self.imgViewUnseeNum.frame.origin.x,self.imgViewUnseeNum.frame.origin.y-0.5,self.imgViewUnseeNum.frame.size.width,self.imgViewUnseeNum.frame.size.height);
        self.lblUnseeNum.font = [UIFont systemFontOfSize:11];
    }
    else
    {
        self.lblUnseeNum.frame = CGRectZero;
        self.imgViewUnseeNum.frame = CGRectZero;
    }
    
    //3.chat msg
    self.lblChatMsg.frame = CGRectMake(56, 28, kScreenWidth-80, 16);
    NSString *strChatContent = chatObjectVo.strLastChatCon;
   
    [self.lblChatMsg calculateTextHeight:strChatContent andBound:CGSizeMake(self.lblChatMsg.frame.size.width, MAXFLOAT)];
    self.lblChatMsg.text = strChatContent;
    [self.lblChatMsg setNeedsDisplay];
    
    //4.chat datetime
    self.lblDateTime.frame = CGRectMake(kScreenWidth-60-8, 11.5, 60, 14);
    self.lblDateTime.text = [Common getChatTimeStr:chatObjectVo.strLastChatTime];
    
    //5.line
    self.viewLine.frame = CGRectMake(0, 50, kScreenWidth, 0.5);
}

+ (CGFloat)calculateCellHeight
{
    return 50.5;
}

@end
