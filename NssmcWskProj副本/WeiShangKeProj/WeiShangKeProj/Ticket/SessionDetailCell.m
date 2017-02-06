//
//  SessionDetailCell.m
//  WeiShangKeProj
//
//  Created by 焱 孙 on 5/18/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import "SessionDetailCell.h"
#import "SessionDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Extras.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "SDWebImageDataSource.h"
#import "KTPhotoScrollViewController.h"
#import "FileBrowserViewController.h"
#import <math.h>
#import "UIViewExt.h"
#import "CustomWebViewController.h"
#import "DocViewController.h"

#define CHAT_CONTENT_WIDTH ((kScreenWidth-320)+220)//260
//时间占位符 12:12
#define CHAT_TIME_PLACEHOLDER @"　　 "
#define AUDIO_MESSAGE_W 120
#define AUDIO_MESSAGE_H 38

#define VIDEO_MESSAGE_W 120
#define VIDEO_MESSAGE_H 40

@implementation SessionDetailCell
@synthesize imgViewChatBK;
@synthesize imgViewDateTime;
@synthesize txtViewContent;
@synthesize lblDate;
@synthesize lblTime;
@synthesize topNavController;
@synthesize imgViewChat;
@synthesize m_chatContentVo;
@synthesize btnConCover;
@synthesize imgTransfer;
@synthesize longPress;
@synthesize imgViewAttachmentIcon;
@synthesize lblAttachmentName;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        //2.chat bk
        self.imgViewChatBK = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imgViewChatBK.userInteractionEnabled = YES;
        [self.contentView addSubview:imgViewChatBK];
        
        //3.datetime bk
        self.imgViewDateTime = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imgViewDateTime.image = [[UIImage imageNamed:@"chat_datetime_bk"]stretchableImageWithLeftCapWidth:15 topCapHeight:0];
        [self.contentView addSubview:imgViewDateTime];
        
        //4.1 chat content
        self.txtViewContent = [[FaceLabel alloc] initWithFrame:CGRectZero andFont:[UIFont systemFontOfSize:15]];
        self.txtViewContent.font = [UIFont systemFontOfSize:15];
        self.txtViewContent.bShowGIF = YES;
        self.txtViewContent.backgroundColor = [UIColor clearColor];
        self.txtViewContent.textColor = [UIColor blackColor];
        self.txtViewContent.numberOfLines = 0;
        self.txtViewContent.lineBreakMode = NSLineBreakByCharWrapping;
        [self.contentView addSubview:self.txtViewContent];
        
        self.txtLinkContent = [[UILabel alloc] initWithFrame:CGRectZero];
        self.txtLinkContent.backgroundColor = [UIColor clearColor];
        self.txtLinkContent.font = [UIFont systemFontOfSize:15];
        self.txtLinkContent.numberOfLines = 0;
        self.txtLinkContent.lineBreakMode = NSLineBreakByCharWrapping;
        [self.contentView addSubview:self.txtLinkContent];
        
        //4.2 chat image
        self.imgViewChat = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imgViewChat.contentMode = UIViewContentModeScaleAspectFill;
        self.imgViewChat.clipsToBounds = YES;
        self.imgViewChat.userInteractionEnabled = YES;
        [self.imgViewChat.layer setBorderWidth:1.0];
        [self.imgViewChat.layer setCornerRadius:5];
        self.imgViewChat.layer.borderColor = [[UIColor clearColor] CGColor];
        [self.imgViewChat.layer setMasksToBounds:YES];
        [self.contentView addSubview:imgViewChat];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showChatImage:)];
        [self.imgViewChat addGestureRecognizer:singleTap];
        
        //5.date time
        self.lblDate = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblDate.backgroundColor = [UIColor clearColor];
        self.lblDate.font = [UIFont systemFontOfSize:12];
        self.lblDate.textColor = [UIColor whiteColor];
        [self.contentView addSubview:lblDate];
        
        //5.date time
        self.lblTime = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblTime.font = [UIFont systemFontOfSize:11];
        self.lblTime.textAlignment = NSTextAlignmentRight;
        self.lblTime.layer.cornerRadius = 3;
        self.lblTime.layer.masksToBounds = YES;
        [self.contentView addSubview:lblTime];
        
        //6.附件icon
        self.imgViewAttachmentIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:imgViewAttachmentIcon];
        
        //7.附件名称
        self.lblAttachmentName = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblAttachmentName.backgroundColor = [UIColor clearColor];
        self.lblAttachmentName.numberOfLines = 0;
        self.lblAttachmentName.font = [UIFont systemFontOfSize:15];
        self.lblAttachmentName.textColor = [UIColor blackColor];
        self.lblAttachmentName.lineBreakMode = NSLineBreakByWordWrapping;
        [self.contentView addSubview:lblAttachmentName];
        
        //通知提示信息
        self.lblChatNotification = [[InsetsLabel alloc] initWithInsets:UIEdgeInsetsMake(3, 2, 3, 2)];
        [self.lblChatNotification.layer setBorderWidth:0];
        [self.lblChatNotification.layer setCornerRadius:4];
        self.lblChatNotification.layer.borderColor = [[UIColor clearColor] CGColor];
        [self.lblChatNotification.layer setMasksToBounds:YES];
        self.lblChatNotification.backgroundColor = COLOR(207, 207, 207, 1.0);
        self.lblChatNotification.numberOfLines = 0;
        self.lblChatNotification.font = [UIFont systemFontOfSize:13];
        self.lblChatNotification.textColor = [UIColor whiteColor];
        self.lblChatNotification.lineBreakMode = NSLineBreakByCharWrapping;

        [self.contentView addSubview:self.lblChatNotification];
        
        //语音相关
        self.lblAudioDuration = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblAudioDuration.backgroundColor = [UIColor clearColor];
        self.lblAudioDuration.font = [UIFont systemFontOfSize:14];
        self.lblAudioDuration.textColor = COLOR(153, 153, 153, 1.0);
        [self.contentView addSubview:self.lblAudioDuration];
        
        self.imgViewAudioIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.imgViewAudioIcon];
        
        //8.conver button
        self.btnConCover = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnConCover.frame = CGRectZero;
        [btnConCover addTarget:self action:@selector(touchButtonDown) forControlEvents:UIControlEventTouchDown];
        [btnConCover addTarget:self action:@selector(touchButtonUpInside) forControlEvents:UIControlEventTouchUpInside];
        [btnConCover addTarget:self action:@selector(touchButtonUp) forControlEvents:UIControlEventTouchUpOutside];
        [btnConCover addTarget:self action:@selector(touchButtonUp) forControlEvents:UIControlEventTouchDragOutside];
        [btnConCover addTarget:self action:@selector(touchButtonUp) forControlEvents:UIControlEventTouchCancel];
        [self.contentView addSubview:self.btnConCover];
        
        self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressChat:)];
        [self.btnConCover addGestureRecognizer:longPress];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)initWithChatContent:(ChatContentVo *)chatContentVo
{
    self.m_chatContentVo = chatContentVo;
    CGFloat fHeight = 5;
    
    //1.date
    NSString *strChatDateTime = [Common getDateTimeStrStyle2:chatContentVo.strChatTime andFormatStr:@"yyyy-MM-dd"];
    CGSize labelSize = [Common getStringSize:strChatDateTime font:lblDate.font bound:CGSizeMake(MAXFLOAT, 14) lineBreakMode:lblDate.lineBreakMode];
    self.lblDate.frame = CGRectMake((kScreenWidth-labelSize.width)/2, fHeight+1, labelSize.width, labelSize.height);
    self.lblDate.text = strChatDateTime;
    self.lblDate.hidden = NO;
    
    //2.date time bk
    self.imgViewDateTime.frame = CGRectMake((kScreenWidth-labelSize.width)/2-5, fHeight, labelSize.width+10,18);
    self.imgViewDateTime.hidden = NO;
    fHeight += 18;
    fHeight += 7.5;
    
    //比较与上次的聊天时间间隔是否在一天内，若是则不显示时间
    NSString *dateLastChat = [Common getDateTimeStrStyle2:self.strLastChatTime andFormatStr:@"yyyy-MM-dd"];
    NSString *dateNowChat = [Common getDateTimeStrStyle2:chatContentVo.strChatTime andFormatStr:@"yyyy-MM-dd"];
    if (dateLastChat != nil && dateNowChat != nil && [dateLastChat isEqualToString:dateNowChat])
    {
        fHeight -= (18+7.5);
        self.lblDate.frame = CGRectZero;
        self.imgViewDateTime.frame = CGRectZero;
    }
    
    //0:文本(text)  1:图片(image)  2:语音(voice)  3:视频(video) 4:音频(audio) 5:位置(location) 6:链接(link)
    if(chatContentVo.nContentType == 1)
    {
        //图片
        if (m_chatContentVo.nSenderType != 1)
        {
            //客服 self right side
            //chat bk image
            self.imgViewChatBK.frame = CGRectMake(76+CHAT_CONTENT_WIDTH-IMAGE_CHAT_THUMB, fHeight, IMAGE_CHAT_THUMB+16,IMAGE_CHAT_THUMB+8);
            self.imgViewChatBK.image = [[UIImage imageNamed:@"chat_send_text_bk"]stretchableImageWithLeftCapWidth:10 topCapHeight:9];
            
            self.imgViewChat.frame = CGRectMake(self.imgViewChatBK.left+4, fHeight+4,IMAGE_CHAT_THUMB,IMAGE_CHAT_THUMB);
            self.lblTime.frame = CGRectMake(self.imgViewChatBK.right-46-16, self.imgViewChatBK.bottom-25, 46, 16);
            
            //set image
            [self setImageContent:1];
            
        }
        else
        {
            //others left side
            //chat bk image
            self.imgViewChatBK.frame = CGRectMake(8, fHeight, IMAGE_CHAT_THUMB+14,IMAGE_CHAT_THUMB+8);
            self.imgViewChatBK.image = [[UIImage imageNamed:@"chat_receive_text_bk"]stretchableImageWithLeftCapWidth:18 topCapHeight:9];
            
            self.imgViewChat.frame = CGRectMake(self.imgViewChatBK.left+10, fHeight+4,IMAGE_CHAT_THUMB,IMAGE_CHAT_THUMB);
            self.lblTime.frame = CGRectMake(self.imgViewChatBK.right-46-10, self.imgViewChatBK.bottom-25, 46, 16);
            
            //set image
            [self setImageContent:2];
        }
        self.imgViewChat.hidden = NO;
        self.txtViewContent.hidden = YES;
        self.btnConCover.frame = self.imgViewChatBK.frame;
        self.imgViewAttachmentIcon.hidden = YES;
        self.lblAttachmentName.hidden = YES;
        self.lblChatNotification.hidden = YES;
        self.txtLinkContent.hidden = YES;
        self.lblAudioDuration.hidden = YES;
        self.imgViewAudioIcon.hidden = YES;
        
        //time
        self.lblTime.text =  [Common getDateTimeStrStyle2:chatContentVo.strChatTime andFormatStr:@"hh:mm"];
        self.lblTime.textAlignment = NSTextAlignmentCenter;
        self.lblTime.backgroundColor = COLOR(55, 55, 55, 0.7);
        self.lblTime.textColor = [UIColor whiteColor];
    }
    else if(chatContentVo.nContentType == 6)
    {
        //超链接
        NSString *strContent = [NSString stringWithFormat:@"%@%@",chatContentVo.strContent,CHAT_TIME_PLACEHOLDER];//加入时间区域
        CGSize sizeLabel = [Common getStringSize:strContent font:self.txtLinkContent.font bound:CGSizeMake(CHAT_CONTENT_WIDTH, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
        //CGFloat != float,接受类型要与赋值类型一致
        CGFloat fContentWidth = sizeLabel.width;
        CGFloat fContentHeight = sizeLabel.height;
        
        if (m_chatContentVo.nSenderType != 1)
        {
            //客服 - (right side)
            float fChatBKWidth = fContentWidth+37;
            fChatBKWidth = (fChatBKWidth < 66)?66:fChatBKWidth;
            fContentHeight = (fContentHeight < 19)?19:fContentHeight;
            self.imgViewChatBK.frame = CGRectMake(55+CHAT_CONTENT_WIDTH-fContentWidth, fHeight, fChatBKWidth,fContentHeight+16);
            self.imgViewChatBK.image = [[UIImage imageNamed:@"chat_send_text_bk"]stretchableImageWithLeftCapWidth:10 topCapHeight:9];
            
            self.txtLinkContent.frame = CGRectMake(self.imgViewChatBK.left+15, fHeight+7,fContentWidth,fContentHeight);
            
            self.lblTime.frame = CGRectMake(self.imgViewChatBK.right-56-15, self.imgViewChatBK.bottom-19, 56, 16);
        }
        else
        {
            //other - (left side)
            float fChatBKWidth = fContentWidth+37;
            fChatBKWidth = (fChatBKWidth < 66)?66:fChatBKWidth;
            fContentHeight = (fContentHeight < 19)?19:fContentHeight;
            self.imgViewChatBK.frame = CGRectMake(8, fHeight,fChatBKWidth,fContentHeight+16);
            self.imgViewChatBK.image = [[UIImage imageNamed:@"chat_receive_text_bk"]stretchableImageWithLeftCapWidth:18 topCapHeight:9];
            
            self.txtLinkContent.frame = CGRectMake(self.imgViewChatBK.left+20, fHeight+7,fContentWidth,fContentHeight);
            
            self.lblTime.frame = CGRectMake(self.imgViewChatBK.right-56-10, self.imgViewChatBK.bottom-19, 56, 16);
        }
        //设置内容是为了赋值
        NSDictionary *dicAttri = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle),
                                   NSFontAttributeName:[UIFont systemFontOfSize:15],
                                   NSForegroundColorAttributeName:COLOR(0, 165, 225, 1.0),
                                   NSBaselineOffsetAttributeName:[NSNumber numberWithFloat:0]};
        
        NSAttributedString *attriString = [[NSAttributedString alloc]initWithString:strContent attributes:dicAttri];
        self.txtLinkContent.attributedText = attriString;
        self.txtLinkContent.hidden = NO;
        
        self.txtViewContent.hidden = YES;
        self.btnConCover.frame = self.imgViewChatBK.frame;
        self.imgViewChat.hidden = YES;
        self.imgViewAttachmentIcon.hidden = YES;
        self.lblAttachmentName.hidden = YES;
        self.lblChatNotification.hidden = YES;
        self.lblAudioDuration.hidden = YES;
        self.imgViewAudioIcon.hidden = YES;
        
        //time
        self.lblTime.text =  [Common getDateTimeStrStyle2:chatContentVo.strChatTime andFormatStr:@"hh:mm"];
        self.lblTime.textAlignment = NSTextAlignmentRight;
        self.lblTime.backgroundColor = [UIColor clearColor];
        self.lblTime.textColor = COLOR(154, 173, 138, 1.0);
    }
    else if(chatContentVo.nContentType == 2 || chatContentVo.nContentType == 4)
    {
        //音频
        if(m_chatContentVo.nSenderType != 1)
        {
            //客服 self right side
            //chat bk image
            self.imgViewChatBK.frame = CGRectMake(76+CHAT_CONTENT_WIDTH-AUDIO_MESSAGE_W, fHeight, AUDIO_MESSAGE_W+16,AUDIO_MESSAGE_H+8);
            self.imgViewChatBK.image = [[UIImage imageNamed:@"chat_send_text_bk"]stretchableImageWithLeftCapWidth:10 topCapHeight:9];
            
            //语音icon
            self.imgViewAudioIcon.frame = CGRectMake(self.imgViewChatBK.right-40, fHeight+9.5, 20, 20);
            self.imgViewAudioIcon.image = nil;
            if (chatContentVo.bAudioPlaying)
            {
                self.imgViewAudioIcon.image = [UIImage animatedImageWithImages:self.topNavController.arySenderAudioIcon duration:1.0];
            }
            else
            {
                self.imgViewAudioIcon.image = [UIImage imageNamed:@"SenderVoiceNodePlaying"];
            }
            
            //tip
            self.lblAudioDuration.textAlignment = NSTextAlignmentRight;
            self.lblAudioDuration.frame = CGRectMake(self.imgViewAudioIcon.left-80, fHeight+2, 60, AUDIO_MESSAGE_H);
            self.lblAudioDuration.text = @"语音消息";
            
            self.lblTime.frame = CGRectMake(self.imgViewChatBK.right-56-15, self.imgViewChatBK.bottom-19, 56, 16);
        }
        else
        {
            //others(left side)
            //chat bk image
            self.imgViewChatBK.frame = CGRectMake(8, fHeight, AUDIO_MESSAGE_W+14,AUDIO_MESSAGE_H+8);
            self.imgViewChatBK.image = [[UIImage imageNamed:@"chat_receive_text_bk"]stretchableImageWithLeftCapWidth:18 topCapHeight:9];
            
            //语音icon
            self.imgViewAudioIcon.frame = CGRectMake(self.imgViewChatBK.frame.origin.x+20, fHeight+9.5, 20, 20);
            self.imgViewAudioIcon.image = nil;
            if (chatContentVo.bAudioPlaying)
            {
                self.imgViewAudioIcon.image = [UIImage animatedImageWithImages:self.topNavController.aryReceiverAudioIcon duration:1.0];
            }
            else
            {
                self.imgViewAudioIcon.image = [UIImage imageNamed:@"ReceiverVoiceNodePlaying"];
            }
            
            //tip
            self.lblAudioDuration.textAlignment = NSTextAlignmentLeft;
            self.lblAudioDuration.frame = CGRectMake(self.imgViewAudioIcon.right+18, fHeight+2, 60, AUDIO_MESSAGE_H);
            self.lblAudioDuration.text = @"语音消息";
            
            self.lblTime.frame = CGRectMake(self.imgViewChatBK.right-56-10, self.imgViewChatBK.bottom-19, 56, 16);
        }
        self.txtViewContent.hidden = YES;
        self.btnConCover.frame = self.imgViewChatBK.frame;
        self.imgViewChat.hidden = YES;
        self.imgViewAttachmentIcon.hidden = YES;
        self.lblAttachmentName.hidden = YES;
        self.txtLinkContent.hidden = YES;
        self.lblAudioDuration.hidden = NO;
        self.imgViewAudioIcon.hidden = NO;
        
        //time
        self.lblTime.text =  [Common getDateTimeStrStyle2:chatContentVo.strChatTime andFormatStr:@"hh:mm"];
        self.lblTime.textAlignment = NSTextAlignmentRight;
        self.lblTime.backgroundColor = [UIColor clearColor];
        self.lblTime.textColor = COLOR(154, 173, 138, 1.0);
    }
    else if(chatContentVo.nContentType == 3)
    {
        //视频
        if(m_chatContentVo.nSenderType != 1)
        {
            //客服 self right side
            //chat bk image
            self.imgViewChatBK.frame = CGRectMake(76+CHAT_CONTENT_WIDTH-VIDEO_MESSAGE_W, fHeight, VIDEO_MESSAGE_W+16,VIDEO_MESSAGE_H+8);
            self.imgViewChatBK.image = [[UIImage imageNamed:@"chat_send_text_bk"]stretchableImageWithLeftCapWidth:10 topCapHeight:9];
            
            //语音icon
            self.imgViewAudioIcon.frame = CGRectMake(self.imgViewChatBK.right-VIDEO_MESSAGE_H-12, fHeight+4, VIDEO_MESSAGE_H, VIDEO_MESSAGE_H);
            self.imgViewAudioIcon.image = [UIImage imageNamed:@"message_video_icon"];
            
            //tip
            self.lblAudioDuration.textAlignment = NSTextAlignmentRight;
            self.lblAudioDuration.frame = CGRectMake(self.imgViewAudioIcon.left-80, fHeight, 60, AUDIO_MESSAGE_H);
            self.lblAudioDuration.text = @"视频消息";
            
            self.lblTime.frame = CGRectMake(self.lblAudioDuration.left, self.imgViewChatBK.bottom-19, 60, 16);
        }
        else
        {
            //others(left side)
            //chat bk image
            self.imgViewChatBK.frame = CGRectMake(8, fHeight, VIDEO_MESSAGE_W+14,VIDEO_MESSAGE_H+8);
            self.imgViewChatBK.image = [[UIImage imageNamed:@"chat_receive_text_bk"]stretchableImageWithLeftCapWidth:18 topCapHeight:9];
            
            //语音icon
            self.imgViewAudioIcon.frame = CGRectMake(self.imgViewChatBK.frame.origin.x+10, fHeight+4,VIDEO_MESSAGE_H, VIDEO_MESSAGE_H);
            self.imgViewAudioIcon.image = [UIImage imageNamed:@"message_video_icon"];
            
            //tip
            self.lblAudioDuration.textAlignment = NSTextAlignmentRight;
            self.lblAudioDuration.frame = CGRectMake(self.imgViewChatBK.right-56-10, fHeight, 56, AUDIO_MESSAGE_H);
            self.lblAudioDuration.text = @"视频消息";
            
            self.lblTime.frame = CGRectMake(self.imgViewChatBK.right-56-10, self.imgViewChatBK.bottom-19, 56, 16);
        }
        self.txtViewContent.hidden = YES;
        self.btnConCover.frame = self.imgViewChatBK.frame;
        self.imgViewChat.hidden = YES;
        self.imgViewAttachmentIcon.hidden = YES;
        self.lblAttachmentName.hidden = YES;
        self.txtLinkContent.hidden = YES;
        self.lblAudioDuration.hidden = NO;
        self.imgViewAudioIcon.hidden = NO;
        
        //time
        self.lblTime.text =  [Common getDateTimeStrStyle2:chatContentVo.strChatTime andFormatStr:@"hh:mm"];
        self.lblTime.textAlignment = NSTextAlignmentRight;
        self.lblTime.backgroundColor = [UIColor clearColor];
        self.lblTime.textColor = COLOR(154, 173, 138, 1.0);
    }
    else
    {
        //未知类型默认为【聊天文本内容】 if(chatContentVo.nContentType == 0)
        NSString *strContent = [NSString stringWithFormat:@"%@%@",chatContentVo.strContent,CHAT_TIME_PLACEHOLDER];//加入时间区域
        CGSize sizeLabel = [self.txtViewContent calculateTextHeight:strContent andBound:CGSizeMake(CHAT_CONTENT_WIDTH, MAXFLOAT)];
        //CGFloat != float,接受类型要与赋值类型一致
        CGFloat fContentWidth = sizeLabel.width;
        CGFloat fContentHeight = sizeLabel.height;
        
        if (m_chatContentVo.nSenderType == 1)
        {
            //other - (left side)
            float fChatBKWidth = fContentWidth+37;
            fChatBKWidth = (fChatBKWidth < 66)?66:fChatBKWidth;
            fContentHeight = (fContentHeight < 19)?19:fContentHeight;
            self.imgViewChatBK.frame = CGRectMake(8, fHeight,fChatBKWidth,fContentHeight+16);
            self.imgViewChatBK.image = [[UIImage imageNamed:@"chat_receive_text_bk"]stretchableImageWithLeftCapWidth:18 topCapHeight:9];
            
            self.txtViewContent.frame = CGRectMake(self.imgViewChatBK.left+20, fHeight+7,fContentWidth,fContentHeight);
            
            self.lblTime.frame = CGRectMake(self.imgViewChatBK.right-56-10, self.imgViewChatBK.bottom-19, 56, 16);
        }
        else if (m_chatContentVo.nSenderType == 4)
        {
            CGSize sizelbl = [Common getStringSize:strContent font:[UIFont systemFontOfSize:13.0] bound:CGSizeMake(200, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
            
            
            if (self.imgViewDateTime.frame.size.width == 0) {
                self.lblChatNotification.frame = CGRectMake((kScreenWidth - sizelbl.width) * 0.5, 20, sizelbl.width + 4, sizelbl.height + 6);
            }else{
                self.lblChatNotification.frame = CGRectMake((kScreenWidth - sizelbl.width) * 0.5, self.imgViewDateTime.frame.size.height + 10, sizelbl.width + 4, sizelbl.height + 6);
                
            }

            if (sizelbl.height < 19) {
                self.lblChatNotification.textAlignment = NSTextAlignmentCenter;
            }else{
                self.lblChatNotification.textAlignment = NSTextAlignmentLeft;
            }
            
        }else{
            
            //客服 - (right side)
            float fChatBKWidth = fContentWidth+37;
            fChatBKWidth = (fChatBKWidth < 66)?66:fChatBKWidth;
            fContentHeight = (fContentHeight < 19)?19:fContentHeight;
            self.imgViewChatBK.frame = CGRectMake(55+CHAT_CONTENT_WIDTH-fContentWidth, fHeight, fChatBKWidth,fContentHeight+16);
            self.imgViewChatBK.image = [[UIImage imageNamed:@"chat_send_text_bk"]stretchableImageWithLeftCapWidth:10 topCapHeight:9];
            
            self.txtViewContent.frame = CGRectMake(self.imgViewChatBK.left+15, fHeight+7,fContentWidth,fContentHeight);
            
            self.lblTime.frame = CGRectMake(self.imgViewChatBK.right-56-15, self.imgViewChatBK.bottom-19, 56, 16);
            
        }
        
        
        if (m_chatContentVo.nSenderType == 4) {
            self.lblChatNotification.text = strContent;
            [self.lblChatNotification setNeedsDisplay];
            self.lblChatNotification.hidden = NO;
            self.txtViewContent.hidden = YES;
        
            self.imgViewChatBK.hidden = YES;
            self.lblTime.hidden = YES;
            
            
        }else{
            self.txtViewContent.text = strContent;
            [self.txtViewContent setNeedsDisplay];
            self.lblChatNotification.hidden = YES;
            self.txtViewContent.hidden = NO;
        
            self.btnConCover.frame = self.imgViewChatBK.frame;
            self.imgViewChat.hidden = YES;
            self.imgViewAttachmentIcon.hidden = YES;
            self.lblAttachmentName.hidden = YES;

            self.txtLinkContent.hidden = YES;
            self.lblAudioDuration.hidden = YES;
            self.imgViewAudioIcon.hidden = YES;
            
            //time
            self.lblTime.text =  [Common getDateTimeStrStyle2:chatContentVo.strChatTime andFormatStr:@"hh:mm"];
            self.lblTime.textAlignment = NSTextAlignmentRight;
            self.lblTime.backgroundColor = [UIColor clearColor];
            self.lblTime.textColor = COLOR(154, 173, 138, 1.0);
        }
    }
}

+ (CGFloat)calculateCellHeight:(ChatContentVo *)chatContentVo andLastChatTime:(NSString*)strLastTime
{
    //top 间距
    CGFloat fHeight = 5;
    
    fHeight += 18;
    fHeight += 7.5;
    //比较与上次的聊天时间间隔是否在一分钟内，若是则不显示时间
    NSString *dateLastChat = [Common getDateTimeStrStyle2:strLastTime andFormatStr:@"yyyy-MM-dd"];
    NSString *dateNowChat = [Common getDateTimeStrStyle2:chatContentVo.strChatTime andFormatStr:@"yyyy-MM-dd"];
    if (dateLastChat != nil && dateNowChat != nil && [dateLastChat isEqualToString:dateNowChat])
    {
        fHeight -= (18+7.5);
    }
    
    //0:文本(text)  1:图片(image)  2:语音(voice)  3:视频(video) 4:音频(audio) 5:位置(location) 6:链接(link)
    if(chatContentVo.nContentType == 1)
    {
        //图片
        fHeight += IMAGE_CHAT_THUMB+8;
    }
    else if(chatContentVo.nContentType == 6)
    {
        //link
        NSString *strContent = [NSString stringWithFormat:@"%@%@",chatContentVo.strContent,CHAT_TIME_PLACEHOLDER];//加入时间区域
        CGSize sizeLabel = [Common getStringSize:strContent font:[UIFont systemFontOfSize:15] bound:CGSizeMake(CHAT_CONTENT_WIDTH, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
        fHeight += 16+sizeLabel.height;
    }
    else if(chatContentVo.nContentType == 3)
    {
        //视频
        fHeight += VIDEO_MESSAGE_H+8;
    }
    else if(chatContentVo.nContentType == 2 || chatContentVo.nContentType == 4)
    {
        //音频
        fHeight += AUDIO_MESSAGE_H+8;
    }
    else
    {
        //纯文本
        FaceLabel *lblText = [FaceLabel getFaceLabelInstanceWithFont:[UIFont systemFontOfSize:15]];
        NSString *strContent = [NSString stringWithFormat:@"%@%@",chatContentVo.strContent,CHAT_TIME_PLACEHOLDER];//加入时间区域
        fHeight += 16+[lblText calculateTextHeight:strContent andBound:CGSizeMake(CHAT_CONTENT_WIDTH, MAXFLOAT)].height;
    }
    
    //bottom 间距
    fHeight += 5;
    fHeight = fHeight < 40?40:fHeight;
    
    return fHeight;
}

//跳转图片显示视图（详情显示大图）
- (void)showChatImage:(UITapGestureRecognizer *)recognizer
{
    NSString *url = nil;
    if (m_chatContentVo.strImgURL != nil && [m_chatContentVo.strImgURL length] > 0)
    {
        url = m_chatContentVo.strImgURL;
        
        if(url != nil)
        {
            [self previewImage:url];
        }
    }
}

//跳转文档显示视图
- (void)showDocView:(UITapGestureRecognizer *)recognizer
{
//    if (m_chatContentVo.strFileURL != nil && [m_chatContentVo.strFileURL length] > 0)
//    {
//        if(m_chatContentVo.strFileID.length>0)
//        {
//            //存在FileID,跳转到下载打开模块
//            FileBrowserViewController *fileBrowserViewController = [[FileBrowserViewController alloc]init];
//            FileVo *fileVo = [[FileVo alloc]init];
//            fileVo.strID = m_chatContentVo.strFileID;
//            fileVo.strName = m_chatContentVo.strFileName;
//            fileVo.strFileURL = m_chatContentVo.strFileURL;
//            fileVo.lFileSize = m_chatContentVo.lFileSize;
//            fileBrowserViewController.m_fileVo = fileVo;
//            [self.topNavController.navigationController pushViewController:fileBrowserViewController animated:YES];
//        }
//        else
//        {
//            //无文件ID,默认原来方式
//            DocViewController *docViewController = [[DocViewController alloc] init];
//            docViewController.strDocName = m_chatContentVo.strFileName;
//            docViewController.urlFile = [NSURL URLWithString:m_chatContentVo.strFileURL];
//            [self.topNavController.navigationController pushViewController:docViewController animated:YES];
//        }
//    }
}


- (void)previewImage:(NSString*)url
{
    SDWebImageDataSource *dataSource = [[SDWebImageDataSource alloc] init];
    NSInteger nImageIndex = 0;
    
    if (self.topNavController.aryImageURL == nil || self.topNavController.aryImageURL.count == 0)
    {
        if (m_chatContentVo.nImgSource == 1)
        {
            //local image
            dataSource.images_ = [NSArray arrayWithObject:[NSArray arrayWithObject:[NSURL fileURLWithPath:url]]];
        }
        else
        {
            //network image
            dataSource.images_ = [NSArray arrayWithObject:[NSArray arrayWithObject:[NSURL URLWithString:url]]];
        }
    }
    else
    {
        dataSource.images_ = self.topNavController.aryImageURL;
        if (self.m_chatContentVo.nImageIndex>=0)
        {
            nImageIndex = self.m_chatContentVo.nImageIndex;
        }
        else
        {
            nImageIndex = [self getImageIndex];
            self.m_chatContentVo.nImageIndex = nImageIndex;
        }
    }
    
    KTPhotoScrollViewController *photoScrollViewController = [[KTPhotoScrollViewController alloc]
                                                              initWithDataSource:dataSource
                                                              andStartWithPhotoAtIndex:nImageIndex];
    photoScrollViewController.bShowImageNumBarBtn = YES;
    [self.topNavController.navigationController pushViewController:photoScrollViewController animated:YES];
}

//长按
- (void)longPressChat:(UITapGestureRecognizer *)gestureRecognizer
{
    //附件没有复制功能
    if (self.m_chatContentVo.nContentType != 2 && self.m_chatContentVo.nContentType != 3 && self.m_chatContentVo.nContentType != 4)
    {
        if ([gestureRecognizer state] == UIGestureRecognizerStateBegan)
        {
            UIMenuController *menuController = [UIMenuController sharedMenuController];
            UIMenuItem *copyMenuItem = [[UIMenuItem alloc] initWithTitle:[Common localStr:@"Common_Copy" value:@"复制"] action:@selector(copyAction:)];
            CGPoint ptLocation = [gestureRecognizer locationInView:[gestureRecognizer view]];
            
            [self becomeFirstResponder];
            [menuController setMenuItems:[NSArray arrayWithObjects:copyMenuItem,nil]];
            [menuController setTargetRect:CGRectMake(self.btnConCover.center.x,[self getPopMenuYOffset:ptLocation], 0, 0) inView:self.contentView];//[gestureRecognizer view]
            [menuController setMenuVisible:YES animated:YES];
        }
    }
}

//复制文字和图片
- (void)copyAction:(id)sender
{
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    if(m_chatContentVo.nContentType == 1)
    {
        //复制图片
        if (imgTransfer != nil)
        {
            pboard.image = imgTransfer;
        }
    }
    else
    {
        //复制文本
        pboard.string = [Common htmlTextToPlainText:self.m_chatContentVo.strContent];
    }
}

#pragma mark -
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(copyAction:))
    {
        return YES;
    }
    
    return [super canPerformAction:action withSender:sender];
}

-(void)tapHeaderImageView
{
    //    UserCenterViewController *userCenterViewController = [[UserCenterViewController alloc]init];
    //    UserVo *userVo = [[UserVo alloc]init];
    //    userVo.strUserID = self.m_chatContentVo.strVestId;
    //    userCenterViewController.m_userVo = userVo;
    //    [self.topNavController.navigationController pushViewController:userCenterViewController animated:YES];
}

-(void)setImageContent:(int)nDirection
{
    if(m_chatContentVo.nImgSource == 1)
    {
        //本地图片
        NSString *strImgPath = m_chatContentVo.strImgURL;
        if(strImgPath == nil)
        {
            strImgPath = m_chatContentVo.strSmallImgURL;
        }
        
        UIImage *imgTemp = [UIImage imageWithContentsOfFile:strImgPath];
        self.imgViewChat.image = imgTemp;
        self.imgTransfer = imgTemp;
    }
    else
    {
        //网络图片
        NSString *strImgPath = m_chatContentVo.strSmallImgURL;
        if(strImgPath == nil)
        {
            strImgPath = m_chatContentVo.strImgURL;
        }
        
        if(m_chatContentVo.imgChatTemp == nil)
        {
            UIImage *imgTemp = [UIImage imageNamed:@"timeline_image_loading"];
            __weak SessionDetailCell *weakSelf = self;
            [self.imgViewChat sd_setImageWithURL:[NSURL URLWithString:strImgPath] placeholderImage:imgTemp completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image)
                {
                    weakSelf.m_chatContentVo.imgChatTemp = image;
                    weakSelf.imgViewChat.image = image;
                    weakSelf.imgTransfer = image;
                }
            }];
        }
        else
        {
            self.imgViewChat.image = m_chatContentVo.imgChatTemp;
            self.imgTransfer = m_chatContentVo.imgChatTemp;
            //[self resetImageViewFrame:nDirection];
        }
    }
    
    //[self resetImageViewFrame:nDirection];
}

-(void)resetImageViewFrame:(int)nDirection
{
//    CGSize sizeImg = self.imgViewChat.image.size;
//    if (sizeImg.height > 0 && sizeImg.width >0 )
//    {
//        
//    }
//    else
//    {
//        sizeImg = CGSizeMake(IMAGE_CHAT_THUMB, IMAGE_CHAT_THUMB);
//    }
//    
//    if (sizeImg.width>sizeImg.height)
//    {
//        sizeImg = CGSizeMake(IMAGE_CHAT_THUMB, (IMAGE_CHAT_THUMB*sizeImg.height)/sizeImg.width);
//    }
//    else
//    {
//        sizeImg = CGSizeMake((IMAGE_CHAT_THUMB*sizeImg.width)/sizeImg.height,IMAGE_CHAT_THUMB);
//    }
//    
//    if(nDirection == 1)
//    {
//        //right self
//        CGRect rectTemp = self.imgViewChat.frame;
//        self.imgViewChat.frame = CGRectMake(80+CHAT_CONTENT_WIDTH-sizeImg.width,rectTemp.origin.y,sizeImg.width,sizeImg.height);
//        
//        //5.chat image
//        rectTemp = self.imgViewChatBK.frame;
//        self.imgViewChatBK.frame = CGRectMake(76+CHAT_CONTENT_WIDTH-sizeImg.width,rectTemp.origin.y,sizeImg.width+16,sizeImg.height+8);//sizeImg.width+35,sizeImg.height+30
//    }
//    else
//    {
//        CGRect rectTemp = self.imgViewChat.frame;
//        self.imgViewChat.frame = CGRectMake(rectTemp.origin.x,rectTemp.origin.y,sizeImg.width,sizeImg.height);
//        
//        //5.chat image
//        rectTemp = self.imgViewChatBK.frame;
//        self.imgViewChatBK.frame = CGRectMake(rectTemp.origin.x,rectTemp.origin.y,sizeImg.width+37,sizeImg.height+30);//66,54//sizeImg.width+37,sizeImg.height+30
//    }
//    
//    //缓存图片宽度
//    self.m_chatContentVo.fImageHeight = self.imgViewChatBK.height;
}

-(float)getPopMenuYOffset:(CGPoint)ptTouch
{
    float fYOffse = 0.0;
    CGRect rcButton = self.btnConCover.frame;
    UITableView *tb = [Common getTableViewByCell:self];
    CGPoint pt = tb.contentOffset;
    CGRect rect = self.frame;
    if (rcButton.size.height>370)
    {
        fYOffse = ptTouch.y+30;
        [UIMenuController sharedMenuController].arrowDirection = UIMenuControllerArrowDown;
    }
    else
    {
        if (pt.y > rect.origin.y)
        {
            //顶部以上
            fYOffse = rcButton.origin.y+rcButton.size.height+5;
            [UIMenuController sharedMenuController].arrowDirection = UIMenuControllerArrowUp;
            
        }
        else
        {
            fYOffse = rcButton.origin.y-5;
            [UIMenuController sharedMenuController].arrowDirection = UIMenuControllerArrowDown;
        }
    }
    return fYOffse;
}

-(void)touchButtonDown
{
    if (topNavController.faceToolBar.bBottomShow)
    {
        //底栏要保证隐藏
        [topNavController.faceToolBar dismissKeyBoard];
        //解决体验问题
        [self.btnConCover removeGestureRecognizer:longPress];
    }
    else
    {
        [self.btnConCover addGestureRecognizer:longPress];
        if (m_chatContentVo.nSenderType != 1)
        {
            //客服 right
            self.imgViewChatBK.image = [[UIImage imageNamed:@"chat_send_text_press_bk"]stretchableImageWithLeftCapWidth:10 topCapHeight:9];
        }
        else
        {
            //left
            self.imgViewChatBK.image = [[UIImage imageNamed:@"chat_receive_text_press_bk"]stretchableImageWithLeftCapWidth:18 topCapHeight:9];
        }
    }
}

-(void)touchButtonUp
{
    if (m_chatContentVo.nSenderType != 1)
    {
        //客服 right
        self.imgViewChatBK.image = [[UIImage imageNamed:@"chat_send_text_bk"]stretchableImageWithLeftCapWidth:10 topCapHeight:9];
    }
    else
    {
        self.imgViewChatBK.image = [[UIImage imageNamed:@"chat_receive_text_bk"]stretchableImageWithLeftCapWidth:18 topCapHeight:9];
    }
}

-(void)touchButtonUpInside
{
    if(m_chatContentVo.nContentType == 1)
    {
        [self showChatImage:nil];
    }
    else if(m_chatContentVo.nContentType == 2 || m_chatContentVo.nContentType == 4)
    {
        //音频
        [self.topNavController tackleAudioAction:self.m_chatContentVo andImgView:self.imgViewAudioIcon];
    }
    else if (m_chatContentVo.nContentType == 3)
    {
        DocViewController *docViewController = [[DocViewController alloc]init];
        docViewController.urlFile = [NSURL URLWithString:self.m_chatContentVo.strFileURL];
        [self.topNavController.navigationController pushViewController:docViewController animated:YES];
    }
    else if(m_chatContentVo.nContentType == 6)
    {
        //link
        CustomWebViewController *customWebViewController = [[CustomWebViewController alloc]init];
        customWebViewController.urlFile = [NSURL URLWithString:self.m_chatContentVo.strChatURL];
        NSLog(@"strChatURL:%@",self.m_chatContentVo.strChatURL);
        [self.topNavController.navigationController pushViewController:customWebViewController animated:YES];
    }
    [self touchButtonUp];
}

//获取
-(NSInteger)getImageIndex
{
    for (int i=0;i<self.topNavController.aryImageList.count;i++)
    {
        ChatContentVo *content = self.topNavController.aryImageList[i];
        if ([content.strCId isEqualToString:self.m_chatContentVo.strCId])
        {
            return i;
        }
    }
    return 0;
}

@end
