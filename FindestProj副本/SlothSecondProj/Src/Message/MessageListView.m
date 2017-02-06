//
//  MessageListView.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-19.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "MessageListView.h"
#import "UIImage+Extras.h"
#import "UIImageView+WebCache.h"
#import "ServerURL.h"
#import "MessageDetailViewController.h"

@implementation MessageListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.imgViewBK = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imgViewBK.image = [[UIImage imageNamed:@"msg_list_bk"] stretchableImageWithLeftCapWidth:160 topCapHeight:14.5];
        [self addSubview:_imgViewBK];
        
        self.imgViewMsgState = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_imgViewMsgState];
        
        self.imgViewHead = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_imgViewHead];
        
        self.lblSender = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblSender.backgroundColor = [UIColor clearColor];
        self.lblSender.font = [UIFont systemFontOfSize:17];
        self.lblSender.textAlignment = NSTextAlignmentLeft;
        self.lblSender.textColor = [UIColor blackColor];
        [self addSubview:_lblSender];
        
        self.lblDateTime = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblDateTime.backgroundColor = [UIColor clearColor];
        self.lblDateTime.font = [UIFont systemFontOfSize:TextH(13)];
        self.lblDateTime.textAlignment = NSTextAlignmentRight;
        self.lblDateTime.textColor = COLOR(153, 153, 153, 1.0);
        [self addSubview:_lblDateTime];
        
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblTitle.backgroundColor = [UIColor clearColor];
        self.lblTitle.font = [UIFont systemFontOfSize:TextH(14)];
        self.lblTitle.textAlignment = NSTextAlignmentLeft;
        self.lblTitle.textColor = COLOR(51, 51, 51, 1.0);
        [self addSubview:_lblTitle];
        
        self.lblContent = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblContent.backgroundColor = [UIColor clearColor];
        self.lblContent.font = [UIFont systemFontOfSize:TextH(14)];
        self.lblContent.textAlignment = NSTextAlignmentLeft;
        self.lblContent.lineBreakMode = NSLineBreakByTruncatingTail;
        self.lblContent.textColor = COLOR(153, 153, 153, 1.0);
        [self addSubview:_lblContent];
        
        self.lblAttachmentNum = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblAttachmentNum.backgroundColor = [UIColor clearColor];
        self.lblAttachmentNum.font = [UIFont systemFontOfSize:13];
        self.lblAttachmentNum.textAlignment = NSTextAlignmentLeft;
        self.lblAttachmentNum.textColor = COLOR(153, 153, 153, 1.0);
        [self addSubview:_lblAttachmentNum];
        
        self.lblFromGroup = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblFromGroup.backgroundColor = [UIColor clearColor];
        self.lblFromGroup.font = [UIFont systemFontOfSize:16];
        self.lblFromGroup.textAlignment = NSTextAlignmentLeft;
        self.lblFromGroup.lineBreakMode = NSLineBreakByTruncatingTail;
        self.lblFromGroup.textColor = COLOR(0, 0, 0, 1.0);
        [self addSubview:_lblFromGroup];
        
        self.imgViewAttachmentIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imgViewAttachmentIcon.image = [UIImage imageNamed:@"attachment_icon"];
        [self addSubview:_imgViewAttachmentIcon];
        
        self.viewTap = [[UIView alloc]initWithFrame:CGRectMake(1, 1, 1, 1)];
        self.viewTap.backgroundColor = [UIColor clearColor];
        [self addSubview:_viewTap];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSingleViewTap)];
        singleTap.numberOfTapsRequired = 1;
        [self.viewTap addGestureRecognizer:singleTap];
    }
    return self;
}

-(CGFloat)initWithMessageVo:(MessageVo*)messageVo
{
    CGFloat fHeight = 15;
    self.messageVo = messageVo;
    
    //0.head image
    self.imgViewHead.frame = CGRectMake(20, fHeight, 40, 40);
    UIImage *phImageName = [[UIImage imageNamed:@"default_m"] roundedWithSize:CGSizeMake(40,40)];
    [self.imgViewHead sd_setImageWithURL:[NSURL URLWithString:messageVo.strAuthorHeadImg] placeholderImage:phImageName];
    
    //1.email sender、attachment num、datetime,group
    self.lblSender.text = messageVo.strAuthorName;
    self.lblSender.frame = CGRectMake(65, fHeight+2+9, 145, 18);
    NSUInteger nAttachmentCount = messageVo.aryAttachmentList.count;
    if (nAttachmentCount>0)
    {
        self.lblAttachmentNum.text = [NSString stringWithFormat:@"%lu",(unsigned long)nAttachmentCount];
        CGSize sizeSender = [Common getStringSize:self.lblSender.text font:self.lblSender.font bound:CGSizeMake(MAXFLOAT, 18) lineBreakMode:NSLineBreakByCharWrapping];
        if (sizeSender.width>145)
        {
            self.imgViewAttachmentIcon.frame = CGRectMake(210, fHeight+2+2, 15, 13.5);
            self.lblAttachmentNum.frame = CGRectMake(210+13.5+3, fHeight+2+2, 15, 13.5);
        }
        else
        {
            self.imgViewAttachmentIcon.frame = CGRectMake(65+sizeSender.width+4, fHeight+2+2, 15, 13.5);
            self.lblAttachmentNum.frame = CGRectMake(65+sizeSender.width+4+13.5+3, fHeight+2+2, 15, 13.5);
        }
    }
    
    self.lblDateTime.text = [Common getChatTimeStr:messageVo.strCreateDate];
    self.lblDateTime.frame = CGRectMake(240, fHeight+4, 60, TextH(14));
    
//    self.lblFromGroup.text = [NSString stringWithFormat:@"来自组："];
//    self.lblFromGroup.frame = CGRectMake(65, fHeight+2+20, 145, 18);
    
    //2.title
    fHeight += 50+4;
    self.lblTitle.text = messageVo.strTitle;
    self.lblTitle.frame = CGRectMake(20, fHeight, 280, TextH(15));
    
    //3.content
    fHeight += TextH(15)+4;
    self.lblContent.text = messageVo.strTextContent;
    CGSize sizeContent = [Common getStringSize:self.lblContent.text font:self.lblContent.font bound:CGSizeMake(kScreenWidth-40, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    if (sizeContent.height>20)
    {
        //more than 1 line
        self.lblContent.frame = CGRectMake(20, fHeight, kScreenWidth-40, TextH(40));
        self.lblContent.numberOfLines = 2;
    }
    else
    {
        //1 line
        self.lblContent.frame = CGRectMake(20, fHeight, kScreenWidth-40, TextH(20));
        self.lblContent.numberOfLines = 1;
    }
    
    //4.email state
    fHeight += self.lblContent.frame.size.height+10;
    
    //5.imageview bk
    self.imgViewBK.frame = CGRectMake(0, 0, kScreenWidth, fHeight);
    
    self.viewTap.frame = CGRectMake(0, 0, kScreenWidth, fHeight);
    
    return fHeight;
}

-(void)doSingleViewTap
{
    [self.parentViewController tapOneMessage:self.messageVo];
}

@end
