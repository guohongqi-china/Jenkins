//
//  ChatContentCell.m
//  Sloth
//
//  Created by 焱 孙 on 13-6-19.
//
//

#import "ChatContentCell.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Extras.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "SDWebImageDataSource.h"
#import "KTPhotoScrollViewController.h"
#import "ChatContentViewController.h"
#import "DocViewController.h"
#import "UserCenterViewController.h"
#import "FileBrowserViewController.h"
#import <math.h>

#define CHAT_CONTENT_WIDTH ((kScreenWidth-320)+185)

@implementation ChatContentCell
@synthesize imgViewHead;    
@synthesize imgViewChatBK;   
@synthesize imgViewDateTime; 
@synthesize txtViewContent;
@synthesize lblDateTime;         
@synthesize topNavController;
@synthesize imgViewChat;
@synthesize m_chatContentVo;
@synthesize imgHeadSelf; 
@synthesize imgHeadOther;
@synthesize lblName;
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
        
        //1.头像
        self.imgViewHead = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imgViewHead.userInteractionEnabled = YES;
        [self.imgViewHead.layer setBorderWidth:1.0];
        [self.imgViewHead.layer setCornerRadius:3];
        self.imgViewHead.layer.borderColor = [[UIColor clearColor] CGColor];
        [self.imgViewHead.layer setMasksToBounds:YES];
        [self.contentView addSubview:imgViewHead];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHeaderImageView)];
        [imgViewHead addGestureRecognizer:singleTap];
        
        //2.name
        self.lblName = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblName.backgroundColor = [UIColor clearColor];
        self.lblName.font = [UIFont systemFontOfSize:12];
        self.lblName.textAlignment = NSTextAlignmentCenter;
        self.lblName.textColor = COLOR(92,93,94,1.0);
        [self.contentView addSubview:lblName];
        
        //2.chat bk
        self.imgViewChatBK = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imgViewChatBK.userInteractionEnabled = YES;
        [self.contentView addSubview:imgViewChatBK];
        
        //3.datetime bk
        self.imgViewDateTime = [[UIImageView alloc] initWithFrame:CGRectZero];
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
        
        //4.2 chat image
        self.imgViewChat = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imgViewChat.contentMode = UIViewContentModeScaleAspectFit;
        self.imgViewChat.userInteractionEnabled = YES;
        [self.imgViewChat.layer setBorderWidth:1.0];
        [self.imgViewChat.layer setCornerRadius:5];
        self.imgViewChat.layer.borderColor = [[UIColor clearColor] CGColor];
        [self.imgViewChat.layer setMasksToBounds:YES];
        [self.contentView addSubview:imgViewChat];
        
        singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showChatImage:)];
        [self.imgViewChat addGestureRecognizer:singleTap];
        
        //5.date time
        self.lblDateTime = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblDateTime.backgroundColor = [UIColor clearColor];
        self.lblDateTime.font = [UIFont systemFontOfSize:12];
        self.lblDateTime.textColor = [UIColor whiteColor];
        [self.contentView addSubview:lblDateTime];
        
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
        
        //语音相关
        self.lblAudioDuration = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblAudioDuration.backgroundColor = [UIColor clearColor];
        self.lblAudioDuration.font = [UIFont systemFontOfSize:13];
        self.lblAudioDuration.textColor = COLOR(153, 153, 153, 1.0);
        [self.contentView addSubview:self.lblAudioDuration];

        self.imgViewAudioIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.imgViewAudioIcon];
        
        //通知提示信息
        self.lblChatNotification = [[InsetsLabel alloc] initWithInsets:UIEdgeInsetsMake(5, 10, 5, 10)];
        [self.lblChatNotification.layer setBorderWidth:0];
        [self.lblChatNotification.layer setCornerRadius:5];
        self.lblChatNotification.layer.borderColor = [[UIColor clearColor] CGColor];
        [self.lblChatNotification.layer setMasksToBounds:YES];
        self.lblChatNotification.backgroundColor = COLOR(207, 207, 207, 1.0);
        self.lblChatNotification.numberOfLines = 0;
        self.lblChatNotification.font = [UIFont systemFontOfSize:14];
        self.lblChatNotification.textColor = [UIColor whiteColor];
        self.lblChatNotification.lineBreakMode = NSLineBreakByCharWrapping;
        [self.contentView addSubview:self.lblChatNotification];
        
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
    CGFloat fHeight = 14;
    
    //1.date time
    NSString *strChatDateTime = [Common getChatTimeStr2:chatContentVo.strChatTime];
    CGSize labelSize = [Common getStringSize:strChatDateTime font:lblDateTime.font bound:CGSizeMake(MAXFLOAT, 14) lineBreakMode:lblDateTime.lineBreakMode];//[strChatDateTime sizeWithFont:lblDateTime.font];
    self.lblDateTime.frame = CGRectMake((kScreenWidth-labelSize.width)/2, fHeight+1, labelSize.width, labelSize.height);
    self.lblDateTime.text = strChatDateTime;
    self.lblDateTime.hidden = NO;
    
    //2.date time bk
    self.imgViewDateTime.frame = CGRectMake((kScreenWidth-labelSize.width)/2-5, fHeight, labelSize.width+10,18);
    self.imgViewDateTime.image = [[UIImage imageNamed:@"chat_datetime_bk"]stretchableImageWithLeftCapWidth:15 topCapHeight:0];
    self.imgViewDateTime.hidden = NO;
    fHeight += 18;
    fHeight += 11;
    //比较与上次的聊天时间间隔是否在一分钟内，若是则不显示时间
    NSDate *dateLastChat = [Common getDateFromString:self.strLastChatTime andFormatStr:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateNowChat = [Common getDateFromString:chatContentVo.strChatTime andFormatStr:@"yyyy-MM-dd HH:mm:ss"];
    if (dateLastChat != nil && dateNowChat != nil)
    {
        NSTimeInterval timeInterval = [dateNowChat timeIntervalSinceDate:dateLastChat];
        if (timeInterval < 60)
        {
            fHeight -= (18+11);
            self.lblDateTime.frame = CGRectZero;
            self.imgViewDateTime.frame = CGRectZero;
        }
    }
    
    //3.设置头像
    UIImage *phImageName = [UIImage imageNamed:@"default_m"];
    if(self.imgHeadSelf == nil)
    {
        self.imgHeadSelf = phImageName;
    }
    
    if (self.imgHeadOther == nil) 
    {
        self.imgHeadOther = phImageName;
    }
    
    if (chatContentVo.nChatType == 1) 
    {
        //single chat
        if([chatContentVo.strVestId isEqualToString:[Common getCurrentUserVo].strUserID])
        {
            //self
            self.imgViewHead.image = imgHeadSelf;
        }
        else
        {
            //other
            self.imgViewHead.image = imgHeadOther;
        }
    }
    else
    {
        //群聊 group chat
        if([chatContentVo.strVestId isEqualToString:[Common getCurrentUserVo].strUserID])
        {
            //self
            self.imgViewHead.image = imgHeadSelf;
        }
        else
        {
            //other
            [self.imgViewHead setImageWithURL:[NSURL URLWithString:chatContentVo.strHeadImg] placeholderImage:phImageName options:0 success:nil failure:^(NSError *error) {}];
        }
    }
    lblName.text = chatContentVo.strName;
    
    //4.聊天文本内容或者@某人
    if(chatContentVo.nContentType == 0 || chatContentVo.nContentType == 5)
    {
        CGSize sizeLabel = [self.txtViewContent calculateTextHeight:chatContentVo.strContent andBound:CGSizeMake(CHAT_CONTENT_WIDTH, MAXFLOAT)];
        //CGFloat != float,接受类型要与赋值类型一致
        CGFloat fContentWidth = sizeLabel.width;
        CGFloat fContentHeight = sizeLabel.height;

        //222-185==37
        if ([chatContentVo.strVestId isEqualToString:[Common getCurrentUserVo].strUserID])
        {
            //self(right side)
            self.imgViewHead.frame = CGRectMake(kScreenWidth-10-40, fHeight,40,40);
            self.lblName.frame = CGRectMake(kScreenWidth-60,fHeight+43,60,15);
            
            //5.chat image
            float fChatBKWidth = fContentWidth+37;
            fChatBKWidth = (fChatBKWidth < 66)?66:fChatBKWidth;
            fContentHeight = (fContentHeight < 19)?19:fContentHeight;
            self.imgViewChatBK.frame = CGRectMake(37+CHAT_CONTENT_WIDTH-(fChatBKWidth-37), fHeight, fChatBKWidth,fContentHeight+35);
            self.imgViewChatBK.image = [[UIImage imageNamed:@"chat_send_text_bk"]stretchableImageWithLeftCapWidth:35 topCapHeight:29];
            
            self.txtViewContent.frame = CGRectMake(self.imgViewChatBK.frame.origin.x+15, fHeight+14,fContentWidth,fContentHeight);//fContentWidth+2
        }
        else
        {
            //others(left side)
            self.imgViewHead.frame = CGRectMake(10, fHeight,40,40);
            self.lblName.frame = CGRectMake(0, fHeight+43,60,15);
            
            //5.chat image
            float fChatBKWidth = fContentWidth+37;
            fChatBKWidth = (fChatBKWidth < 66)?66:fChatBKWidth;
            fContentHeight = (fContentHeight < 19)?19:fContentHeight;
            self.imgViewChatBK.frame = CGRectMake(58, fHeight,fChatBKWidth,fContentHeight+35);
            self.imgViewChatBK.image = [[UIImage imageNamed:@"chat_receive_text_bk"]stretchableImageWithLeftCapWidth:35 topCapHeight:29];
            
            self.txtViewContent.frame = CGRectMake(self.imgViewChatBK.frame.origin.x+20, fHeight+14,fContentWidth,fContentHeight);//fContentWidth+2
        }
        //设置内容是为了赋值
        self.txtViewContent.text = chatContentVo.strContent;
        [self.txtViewContent setNeedsDisplay];
        self.txtViewContent.hidden = NO;
        self.btnConCover.frame = self.imgViewChatBK.frame;
        imgViewChat.frame = CGRectZero;
        self.imgViewAttachmentIcon.hidden = YES;
        self.lblAttachmentName.hidden = YES;
        self.lblAudioDuration.hidden = YES;
        self.imgViewAudioIcon.hidden = YES;
        self.lblChatNotification.hidden = YES;
    }
    else if(chatContentVo.nContentType == 1)
    {
        //聊天图片
        if ([chatContentVo.strVestId isEqualToString:[Common getCurrentUserVo].strUserID])
        {
            //self
            self.imgViewHead.frame = CGRectMake(kScreenWidth-10-40, fHeight,40,40);
            self.lblName.frame = CGRectMake(kScreenWidth-60,fHeight+43,60,15);
        
            self.imgViewChat.frame = CGRectMake(50+CHAT_CONTENT_WIDTH-IMAGE_BLOG_THUMB, fHeight+11,IMAGE_BLOG_THUMB,IMAGE_BLOG_THUMB);
            
            //5.chat image
            self.imgViewChatBK.frame = CGRectMake(35+CHAT_CONTENT_WIDTH-IMAGE_BLOG_THUMB, fHeight, IMAGE_BLOG_THUMB+35,IMAGE_BLOG_THUMB+30);
            self.imgViewChatBK.image = [[UIImage imageNamed:@"chat_send_text_bk"]stretchableImageWithLeftCapWidth:35 topCapHeight:29];
            
            //set image
            [self setImageContent:1];
        }
        else
        {
            //others
            self.imgViewHead.frame = CGRectMake(10, fHeight,40,40);
            self.lblName.frame = CGRectMake(0, fHeight+43,60,15);
            
            self.imgViewChat.frame = CGRectMake(79, fHeight+11,IMAGE_BLOG_THUMB,IMAGE_BLOG_THUMB);
            
            //chat image
            self.imgViewChatBK.frame = CGRectMake(58, fHeight, IMAGE_BLOG_THUMB+35,IMAGE_BLOG_THUMB+30);
            self.imgViewChatBK.image = [[UIImage imageNamed:@"chat_receive_text_bk"]stretchableImageWithLeftCapWidth:35 topCapHeight:29];
            
            //set image
            [self setImageContent:2];
        }
        self.txtViewContent.hidden = YES;
        self.btnConCover.frame = self.imgViewChatBK.frame;
        self.imgViewAttachmentIcon.hidden = YES;
        self.lblAttachmentName.hidden = YES;
        self.lblAudioDuration.hidden = YES;
        self.imgViewAudioIcon.hidden = YES;
        self.lblChatNotification.hidden = YES;
    }
    else if (chatContentVo.nContentType == 2)
    {
        //聊天附件
        if ([chatContentVo.strVestId isEqualToString:[Common getCurrentUserVo].strUserID])
        {
            //self(right side)
            //1.head image and name
            self.imgViewHead.frame = CGRectMake(kScreenWidth-10-40, fHeight,40,40);
            self.lblName.frame = CGRectMake(kScreenWidth-60,fHeight+43,60,15);
            
            //2.attachment icon and file name
            self.imgViewAttachmentIcon.frame = CGRectMake(37+17,fHeight+10,30,30);
            self.imgViewAttachmentIcon.image = [UIImage imageNamed:[Common getFileIconImageByName:chatContentVo.strFileName]];
            
            CGSize sizeFileName = [Common getStringSize:chatContentVo.strFileName font:lblAttachmentName.font bound:CGSizeMake(CHAT_CONTENT_WIDTH-30, MAXFLOAT) lineBreakMode:lblAttachmentName.lineBreakMode];
            self.lblAttachmentName.frame = CGRectMake(37+17+30+3,fHeight+10,CHAT_CONTENT_WIDTH-30,sizeFileName.height);
            self.lblAttachmentName.text = chatContentVo.strFileName;
            
            CGFloat fFileNameHeight = sizeFileName.height;
            if (sizeFileName.height < 30)
            {
                fFileNameHeight = 30;
            }
            
            //3.chat bk image
            self.imgViewChatBK.frame = CGRectMake(37, fHeight, CHAT_CONTENT_WIDTH+37,fFileNameHeight+30);
            self.imgViewChatBK.image = [[UIImage imageNamed:@"chat_send_text_bk"]stretchableImageWithLeftCapWidth:35 topCapHeight:29];
            
        }
        else
        {
            //others(left side)
            //1.head image and name
            self.imgViewHead.frame = CGRectMake(10, fHeight,40,40);
            self.lblName.frame = CGRectMake(0, fHeight+43,60,15);
            
            //2.attachment icon and file name
            self.imgViewAttachmentIcon.frame = CGRectMake(58+17,fHeight+10,30,30);
            self.imgViewAttachmentIcon.image = [UIImage imageNamed:[Common getFileIconImageByName:chatContentVo.strFileName]];
            
            CGSize sizeFileName = [Common getStringSize:chatContentVo.strFileName font:lblAttachmentName.font bound:CGSizeMake(CHAT_CONTENT_WIDTH-30, MAXFLOAT) lineBreakMode:lblAttachmentName.lineBreakMode];
            self.lblAttachmentName.frame = CGRectMake(58+17+30+3,fHeight+10,CHAT_CONTENT_WIDTH-30,sizeFileName.height);
            self.lblAttachmentName.text = chatContentVo.strFileName;
            
            CGFloat fFileNameHeight = sizeFileName.height;
            if (sizeFileName.height < 30)
            {
                fFileNameHeight = 30;
            }

            //3.chat bk image
            self.imgViewChatBK.frame = CGRectMake(58, fHeight, CHAT_CONTENT_WIDTH+37,fFileNameHeight+30);
            self.imgViewChatBK.image = [[UIImage imageNamed:@"chat_receive_text_bk"]stretchableImageWithLeftCapWidth:35 topCapHeight:29];
            
        }
        self.txtViewContent.hidden = YES;
        self.btnConCover.frame = self.imgViewChatBK.frame;
        self.imgViewChat.frame = CGRectZero;
        self.imgViewAttachmentIcon.hidden = NO;
        self.lblAttachmentName.hidden = NO;
        self.lblAudioDuration.hidden = YES;
        self.imgViewAudioIcon.hidden = YES;
        self.lblChatNotification.hidden = YES;
    }
    else if (chatContentVo.nContentType == 3)
    {
        self.imgViewAudioIcon.hidden = NO;
        //聊天语音
        CGFloat fChatBKW = [self getAudioBKLength:chatContentVo.strContent];
        if ([chatContentVo.strVestId isEqualToString:[Common getCurrentUserVo].strUserID])
        {
            //self(right side)
            //1.head image and name
            self.imgViewHead.frame = CGRectMake(kScreenWidth-10-40, fHeight,40,40);
            self.lblName.frame = CGRectMake(kScreenWidth-60,fHeight+43,60,15);
            
            //2.chat bk image
            self.imgViewChatBK.frame = CGRectMake(37+CHAT_CONTENT_WIDTH-(fChatBKW-37), fHeight, fChatBKW,54);
            self.imgViewChatBK.image = [[UIImage imageNamed:@"chat_send_text_bk"]stretchableImageWithLeftCapWidth:35 topCapHeight:29];
            
            //2.语音长度、语音icon
            CGFloat fLeft = self.imgViewChatBK.frame.origin.x;
            self.lblAudioDuration.textAlignment = NSTextAlignmentRight;
            self.lblAudioDuration.frame = CGRectMake(fLeft-40, fHeight+16, 40, 13);
            self.lblAudioDuration.text = [NSString stringWithFormat:@"%@''",chatContentVo.strContent];
            
            fLeft += self.imgViewChatBK.frame.size.width;
            self.imgViewAudioIcon.frame = CGRectMake(fLeft-40, fHeight+12.5, 20, 20);
            self.imgViewAudioIcon.image = nil;
            if (chatContentVo.bAudioPlaying)
            {
                self.imgViewAudioIcon.image = [UIImage animatedImageWithImages:self.topNavController.arySenderAudioIcon duration:1.0];
            }
            else
            {
                self.imgViewAudioIcon.image = [UIImage imageNamed:@"SenderVoiceNodePlaying"];
            }
        }
        else
        {
            //others(left side)
            //1.head image and name
            self.imgViewHead.frame = CGRectMake(10, fHeight,40,40);
            self.lblName.frame = CGRectMake(0, fHeight+43,60,15);
            
            //2.chat bk image
            self.imgViewChatBK.frame = CGRectMake(58, fHeight, fChatBKW,54);
            self.imgViewChatBK.image = [[UIImage imageNamed:@"chat_receive_text_bk"]stretchableImageWithLeftCapWidth:35 topCapHeight:29];
            
            //3.语音长度、语音icon
            self.lblAudioDuration.textAlignment = NSTextAlignmentLeft;
            self.lblAudioDuration.frame = CGRectMake(self.imgViewChatBK.frame.origin.x+fChatBKW+2, fHeight+16, 40, 13);
            self.lblAudioDuration.text = [NSString stringWithFormat:@"%@''",chatContentVo.strContent];
            
            self.imgViewAudioIcon.frame = CGRectMake(self.imgViewChatBK.frame.origin.x+20, fHeight+12.5, 20, 20);
            self.imgViewAudioIcon.image = nil;
            if (chatContentVo.bAudioPlaying)
            {
                self.imgViewAudioIcon.image = [UIImage animatedImageWithImages:self.topNavController.aryReceiverAudioIcon duration:1.0];
            }
            else
            {
                self.imgViewAudioIcon.image = [UIImage imageNamed:@"ReceiverVoiceNodePlaying"];
            }
        }
        self.txtViewContent.hidden = YES;
        self.btnConCover.frame = self.imgViewChatBK.frame;
        self.imgViewChat.frame = CGRectZero;
        self.imgViewAttachmentIcon.hidden = YES;
        self.lblAttachmentName.hidden = YES;
        self.lblAudioDuration.hidden = NO;
        self.imgViewAudioIcon.hidden = NO;
        self.lblChatNotification.hidden = YES;
    }
    else if (chatContentVo.nContentType == 4)
    {
        //（有人加入和退出群聊）
        fHeight += 2;
        CGSize size = [Common getStringSize:chatContentVo.strContent font:self.lblChatNotification.font bound:CGSizeMake(kScreenWidth-48-20, MAXFLOAT) lineBreakMode:self.lblChatNotification.lineBreakMode];
        if (size.height>25)//超过一行
        {
            self.lblChatNotification.textAlignment = NSTextAlignmentLeft;
            self.lblChatNotification.frame = CGRectMake(24, fHeight, kScreenWidth-48, size.height+10);
        }
        else
        {
            self.lblChatNotification.textAlignment = NSTextAlignmentCenter;
            self.lblChatNotification.frame = CGRectMake((kScreenWidth-size.width-20)/2, fHeight, size.width+20, size.height+10);
        }
        self.lblChatNotification.text = chatContentVo.strContent;
        
        self.imgViewHead.frame = CGRectZero;
        self.lblName.frame = CGRectZero;
        self.imgViewChatBK.frame = CGRectZero;
        
        self.txtViewContent.hidden = YES;
        self.btnConCover.frame = self.imgViewChatBK.frame;
        self.imgViewChat.frame = CGRectZero;
        self.imgViewAttachmentIcon.hidden = YES;
        self.lblAttachmentName.hidden = YES;
        self.lblAudioDuration.hidden = YES;
        self.imgViewAudioIcon.hidden = YES;
        self.lblChatNotification.hidden = NO;
    }
}

+ (CGFloat)calculateCellHeight:(ChatContentVo *)chatContentVo andLastChatTime:(NSString*)strLastTime
{
    CGFloat fHeight = 14;
    
    fHeight += 18;
    fHeight += 11;
    //比较与上次的聊天时间间隔是否在一分钟内，若是则不显示时间
    NSDate *dateLastChat = [Common getDateFromString:strLastTime andFormatStr:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateNowChat = [Common getDateFromString:chatContentVo.strChatTime andFormatStr:@"yyyy-MM-dd HH:mm:ss"];
    if (dateLastChat != nil && dateNowChat != nil)
    {
        NSTimeInterval timeInterval = [dateNowChat timeIntervalSinceDate:dateLastChat];
        if (timeInterval < 60)
        {
            fHeight -= (18+11);
        }
    }
    //type:0纯文本1图片2文件3语音4有人加入群聊5@某人
    if(chatContentVo.nContentType == 0 || chatContentVo.nContentType == 5)
    {
        //纯文本
        FaceLabel *lblText = [FaceLabel getFaceLabelInstanceWithFont:[UIFont systemFontOfSize:15]];
        fHeight += 15+20+[lblText calculateTextHeight:chatContentVo.strContent andBound:CGSizeMake(CHAT_CONTENT_WIDTH, MAXFLOAT)].height;
    }
    else if(chatContentVo.nContentType == 1)
    {
        //图片
        fHeight += 15+20 + IMAGE_BLOG_THUMB;
    }
    else if(chatContentVo.nContentType == 2)
    {
        CGSize sizeFileName = [Common getStringSize:chatContentVo.strFileName font:[UIFont systemFontOfSize:15] bound:CGSizeMake(CHAT_CONTENT_WIDTH-30, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
        if(sizeFileName.height <30)
        {
            fHeight += 15+20 + 30;
        }
        else
        {
            fHeight += 15+20 + sizeFileName.height;
        }
    }
    else if(chatContentVo.nContentType == 3)
    {
        //语音
        fHeight += 15+20+18;
    }
    else if (chatContentVo.nContentType == 4)
    {
        //通知（有人加入和退出群聊）
        fHeight += 2;
        CGSize size = [Common getStringSize:chatContentVo.strContent font:[UIFont systemFontOfSize:14] bound:CGSizeMake(kScreenWidth-48-20, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
        fHeight += size.height+10;
        fHeight += 10;
    }
    
    fHeight += 5;
    if (chatContentVo.nContentType != 4)
    {
        fHeight = (fHeight < (100-29))?(100-29):fHeight;
    }
    
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
    if (m_chatContentVo.strFileURL != nil && [m_chatContentVo.strFileURL length] > 0)
    {
        if(m_chatContentVo.strFileID.length>0)
        {
            //存在FileID,跳转到下载打开模块
            FileBrowserViewController *fileBrowserViewController = [[FileBrowserViewController alloc]init];
            FileVo *fileVo = [[FileVo alloc]init];
            fileVo.strID = m_chatContentVo.strFileID;
            fileVo.strName = m_chatContentVo.strFileName;
            fileVo.strFileURL = m_chatContentVo.strFileURL;
            fileVo.lFileSize = m_chatContentVo.lFileSize;
            fileBrowserViewController.m_fileVo = fileVo;
            [self.topNavController.navigationController pushViewController:fileBrowserViewController animated:YES];
        }
        else
        {
            //无文件ID,默认原来方式
            DocViewController *docViewController = [[DocViewController alloc] init];
            docViewController.strDocName = m_chatContentVo.strFileName;
            docViewController.urlFile = [NSURL URLWithString:m_chatContentVo.strFileURL];
            [self.topNavController.navigationController pushViewController:docViewController animated:YES];
        }
    }
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

//转发文字和图片
- (void)transferAction:(id)sender
{
    if(m_chatContentVo.nContentType != 1)
    {
        imgTransfer = nil;
    }
    [self.topNavController writeButtonClicked:[Common htmlTextToPlainText:self.m_chatContentVo.strContent] andImage:imgTransfer];
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
    
    if (action == @selector(transferAction:))
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
           __weak ChatContentCell *weakSelf = self;
           [self.imgViewChat setImageWithURL:[NSURL URLWithString:strImgPath] placeholderImage:imgTemp options:0 success:^(UIImage *image) {
               weakSelf.m_chatContentVo.imgChatTemp = image;
               weakSelf.imgViewChat.image = image;
               weakSelf.imgTransfer = image;
               [weakSelf resetImageViewFrame:nDirection];
           } failure:^(NSError *error) {}];
       }
       else
       {
           self.imgViewChat.image = m_chatContentVo.imgChatTemp;
           self.imgTransfer = m_chatContentVo.imgChatTemp;
           [self resetImageViewFrame:nDirection];
       }
   }
    
    [self resetImageViewFrame:nDirection];
}

-(void)resetImageViewFrame:(int)nDirection
{
    CGSize sizeImg = self.imgViewChat.image.size;
    if (sizeImg.height > 0 && sizeImg.width >0 )
    {
        
    }
    else
    {
        sizeImg = CGSizeMake(IMAGE_BLOG_THUMB, IMAGE_BLOG_THUMB);
    }
    
    if (sizeImg.width>sizeImg.height)
    {
        sizeImg = CGSizeMake(IMAGE_BLOG_THUMB, (IMAGE_BLOG_THUMB*sizeImg.height)/sizeImg.width);
    }
    else
    {
        sizeImg = CGSizeMake((IMAGE_BLOG_THUMB*sizeImg.width)/sizeImg.height,IMAGE_BLOG_THUMB);
    }
    
    if(nDirection == 1)
    {
        //right self
        CGRect rectTemp = self.imgViewChat.frame;
        self.imgViewChat.frame = CGRectMake(50+CHAT_CONTENT_WIDTH-sizeImg.width,rectTemp.origin.y,sizeImg.width,sizeImg.height);
        
        //5.chat image
        rectTemp = self.imgViewChatBK.frame;
        self.imgViewChatBK.frame = CGRectMake(35+CHAT_CONTENT_WIDTH-sizeImg.width,rectTemp.origin.y,sizeImg.width+35,sizeImg.height+30);//sizeImg.width+35,sizeImg.height+30
    }
    else
    {
        CGRect rectTemp = self.imgViewChat.frame;
        self.imgViewChat.frame = CGRectMake(rectTemp.origin.x,rectTemp.origin.y,sizeImg.width,sizeImg.height);
        
        //5.chat image
        rectTemp = self.imgViewChatBK.frame;
        self.imgViewChatBK.frame = CGRectMake(rectTemp.origin.x,rectTemp.origin.y,sizeImg.width+37,sizeImg.height+30);//66,54//sizeImg.width+37,sizeImg.height+30
    }
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
        if ([m_chatContentVo.strVestId isEqualToString:[Common getCurrentUserVo].strUserID])
        {
            self.imgViewChatBK.image = [[UIImage imageNamed:@"chat_send_text_press_bk"]stretchableImageWithLeftCapWidth:35 topCapHeight:29];
        }
        else
        {
            self.imgViewChatBK.image = [[UIImage imageNamed:@"chat_receive_text_press_bk"]stretchableImageWithLeftCapWidth:35 topCapHeight:29];
        }
    }
}

-(void)touchButtonUp
{
    if ([m_chatContentVo.strVestId isEqualToString:[Common getCurrentUserVo].strUserID])
    {
        self.imgViewChatBK.image = [[UIImage imageNamed:@"chat_send_text_bk"]stretchableImageWithLeftCapWidth:35 topCapHeight:29];
    }
    else
    {
        self.imgViewChatBK.image = [[UIImage imageNamed:@"chat_receive_text_bk"]stretchableImageWithLeftCapWidth:35 topCapHeight:29];
    }
}

-(void)touchButtonUpInside
{
    if(m_chatContentVo.nContentType == 1)
    {
        [self showChatImage:nil];
    }
    else if(m_chatContentVo.nContentType == 2)
    {
        [self showDocView:nil];
    }
    else if(m_chatContentVo.nContentType == 3)
    {
        [self.topNavController tackleAudioAction:self.m_chatContentVo andImgView:self.imgViewAudioIcon];
    }
    [self touchButtonUp];
}

//获取语音的bk长度
-(CGFloat)getAudioBKLength:(NSString*)strLength
{
    NSInteger nLength = strLength.integerValue*10;
    nLength = nLength>600?600:nLength;
    
    //定义时间范围在1~60秒乘以10（10~600）(采用对数方案)lg600 = 2.778;
    //标准值,66是最小宽度
    CGFloat fStandardW = (CHAT_CONTENT_WIDTH+37.0-66)/(2.778-1);
    CGFloat fAudioBKW = 66 + (log10(nLength)-1)*fStandardW;//减去lg10
    return fAudioBKW;
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
