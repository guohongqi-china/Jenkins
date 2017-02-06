//
//  MessageCurrentView.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-20.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "MessageCurrentView.h"
#import "UIImage+Extras.h"
#import "UIImageView+WebCache.h"
#import "ServerURL.h"
#import "MessageDetailViewController.h"
#import "ReceiverVo.h"
#import "UserVo.h"
#import "Utils.h"
#import "ScheduleJoinStateVo.h"
#import "AttachmentVo.h"
#import "UIImage+UIImageScale.h"
#import "ResizeImage.h"
#import "UIImage+Extras.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "KTPhotoScrollViewController.h"
#import "SDWebImageDataSource.h"
#import "LotteryVo.h"
#import "LotteryOptionVo.h"
//#import "UserCenterViewController.h"
#import "FileBrowserViewController.h"
#import "UIViewExt.h"
#import "FullScreenWebViewController.h"

@implementation MessageCurrentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
        self.calendarEventDao = [[CalendarEventDao alloc]init];
        
        self.imgViewStar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_star"]];
        [self addSubview:_imgViewStar];
        
        self.imgViewHead = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imgViewHead.userInteractionEnabled = YES;
        [self addSubview:_imgViewHead];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHeaderImageView)];
        [self.imgViewHead addGestureRecognizer:singleTap];
        
        self.lblSender = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblSender.backgroundColor = [UIColor clearColor];
        self.lblSender.font = [UIFont systemFontOfSize:TextH(15)];
        self.lblSender.textAlignment = NSTextAlignmentLeft;
        self.lblSender.textColor = [SkinManage colorNamed:@"metting_Tite_color"];
        //[UIColor blackColor];
        [self addSubview:_lblSender];
        
        self.lblDateTime = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblDateTime.backgroundColor = [UIColor clearColor];
        self.lblDateTime.font = [UIFont systemFontOfSize:TextH(13)];
        self.lblDateTime.textAlignment = NSTextAlignmentRight;
        self.lblDateTime.textColor = [SkinManage colorNamed:@"myjob_Button_title_color"];
        //COLOR(153, 153, 153, 1.0);
        [self addSubview:_lblDateTime];
        
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblTitle.backgroundColor = [UIColor clearColor];
        self.lblTitle.font = [UIFont systemFontOfSize:TextH(14)];
        self.lblTitle.textAlignment = NSTextAlignmentLeft;
        self.lblTitle.textColor = [SkinManage colorNamed:@"message_color"];//COLOR(51, 51, 51, 1.0);
        self.lblTitle.numberOfLines = 0;
        [self addSubview:_lblTitle];
        
        /////////////////////////////////////////////////////
        self.lblSenderDetail = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblSenderDetail.backgroundColor = [UIColor clearColor];
        self.lblSenderDetail.font = [UIFont systemFontOfSize:14];
        self.lblSenderDetail.textAlignment = NSTextAlignmentLeft;
        self.lblSenderDetail.textColor = [SkinManage colorNamed:@"myjob_Button_title_color"];
        //COLOR(153, 153, 153, 1.0);
        self.lblSenderDetail.numberOfLines = 0;
        [self addSubview:_lblSenderDetail];
        
        self.lblReceiverDetail = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblReceiverDetail.backgroundColor = [UIColor clearColor];
        self.lblReceiverDetail.font = [UIFont systemFontOfSize:14];
        self.lblReceiverDetail.textAlignment = NSTextAlignmentLeft;
        self.lblReceiverDetail.textColor = [SkinManage colorNamed:@"myjob_Button_title_color"];//COLOR(153, 153, 153, 1.0);
        self.lblReceiverDetail.numberOfLines = 0;
        [self addSubview:_lblReceiverDetail];
        
        self.lblCCDetail = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblCCDetail.backgroundColor = [UIColor clearColor];
        self.lblCCDetail.font = [UIFont systemFontOfSize:14];
        self.lblCCDetail.textAlignment = NSTextAlignmentLeft;
        self.lblCCDetail.textColor = [SkinManage colorNamed:@"myjob_Button_title_color"];//COLOR(153, 153, 153, 1.0);
        self.lblCCDetail.numberOfLines = 0;
        [self addSubview:_lblCCDetail];
        
        self.lblBCCDetail = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblBCCDetail.backgroundColor = [UIColor clearColor];
        self.lblBCCDetail.font = [UIFont systemFontOfSize:14];
        self.lblBCCDetail.textAlignment = NSTextAlignmentLeft;
        self.lblBCCDetail.textColor = [SkinManage colorNamed:@"myjob_Button_title_color"];//COLOR(153, 153, 153, 1.0);
        self.lblBCCDetail.numberOfLines = 0;
        [self addSubview:_lblBCCDetail];
        
        self.lblDateTimeDetail = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblDateTimeDetail.backgroundColor = [UIColor clearColor];
        self.lblDateTimeDetail.font = [UIFont systemFontOfSize:14];
        self.lblDateTimeDetail.textAlignment = NSTextAlignmentLeft;
        self.lblDateTimeDetail.textColor = [SkinManage colorNamed:@"myjob_Button_title_color"];//COLOR(153, 153, 153, 1.0);
        self.lblDateTimeDetail.numberOfLines = 0;
        [self addSubview:self.lblDateTimeDetail];
        
        self.lblAttachmentDetail = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblAttachmentDetail.backgroundColor = [UIColor clearColor];
        self.lblAttachmentDetail.font = [UIFont systemFontOfSize:14];
        self.lblAttachmentDetail.textAlignment = NSTextAlignmentLeft;
        self.lblAttachmentDetail.textColor = [SkinManage colorNamed:@"myjob_Button_title_color"];//COLOR(153, 153, 153, 1.0);
        self.lblAttachmentDetail.numberOfLines = 0;
        [self addSubview:self.lblAttachmentDetail];
        /////////////////////////////////////////////////////
        
        self.webViewContent = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 1, 1)];
        self.webViewContent.delegate = self;
        [self.webViewContent setAutoresizesSubviews:YES];
        [self.webViewContent setAutoresizingMask:UIViewAutoresizingNone];
        [self.webViewContent setUserInteractionEnabled:YES];
        self.webViewContent.scrollView.alwaysBounceVertical = NO;//内容小于frame时纵向不滚动
        [self.webViewContent setOpaque:NO ]; //透明
        self.webViewContent.backgroundColor= [SkinManage colorNamed:@"Function_BK_Color"];
        self.webViewContent.scrollView.scrollsToTop = NO;
        [self addSubview: self.webViewContent];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleWebViewImage:)];
        tap.delegate = self;
        [self.webViewContent addGestureRecognizer:tap];
        
        self.lblAttachmentNum = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblAttachmentNum.backgroundColor = [UIColor clearColor];
        self.lblAttachmentNum.font = [UIFont systemFontOfSize:13];
        self.lblAttachmentNum.textAlignment = NSTextAlignmentLeft;
        self.lblAttachmentNum.textColor = [SkinManage colorNamed:@"myjob_Button_title_color"];//COLOR(153, 153, 153, 1.0);
        [self addSubview:_lblAttachmentNum];
        
        self.lblFromGroup = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblFromGroup.backgroundColor = [UIColor clearColor];
        self.lblFromGroup.font = [UIFont systemFontOfSize:16];
        self.lblFromGroup.textAlignment = NSTextAlignmentLeft;
        self.lblFromGroup.lineBreakMode = NSLineBreakByTruncatingTail;
        self.lblFromGroup.textColor = [SkinManage colorNamed:@"metting_Tite_color"];//COLOR(0, 0, 0, 1.0);
        [self addSubview:_lblFromGroup];
        
        self.lblReceiver = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblReceiver.backgroundColor = [UIColor clearColor];
        self.lblReceiver.font = [UIFont systemFontOfSize:14];
        self.lblReceiver.textAlignment = NSTextAlignmentLeft;
        self.lblReceiver.lineBreakMode = NSLineBreakByTruncatingTail;
        self.lblReceiver.textColor = [SkinManage colorNamed:@"message_color"];//COLOR(51, 51, 51, 1.0);
        [self addSubview:_lblReceiver];
        
        self.btnShowDetail = [UIButton buttonWithType:UIButtonTypeSystem];
        [_btnShowDetail setTitleColor:[SkinManage colorNamed:@"Tab_Item_Color"] forState:UIControlStateNormal];
        [_btnShowDetail.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14.0]];
        self.btnShowDetail.frame = CGRectZero;
        [_btnShowDetail addTarget:self action:@selector(showDetailReceiverList) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_btnShowDetail];
        
        self.imgViewAttachmentIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imgViewAttachmentIcon.image = [UIImage imageNamed:@"attachment_icon"];
        [self addSubview:_imgViewAttachmentIcon];
        
        self.viewSingleLine1 = [[UIView alloc]initWithFrame:CGRectZero];
        self.viewSingleLine1.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];//COLOR(183, 183, 183, 1.0);
        [self addSubview:_viewSingleLine1];
        
        self.viewSingleLine2 = [[UIView alloc]initWithFrame:CGRectZero];
        self.viewSingleLine2.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];//COLOR(183, 183, 183, 1.0);
        [self addSubview:_viewSingleLine2];
        
        self.viewSingleLine3 = [[UIView alloc]initWithFrame:CGRectZero];
        self.viewSingleLine3.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];//COLOR(183, 183, 183, 1.0);
        [self addSubview:_viewSingleLine3];
        
        self.bShow = NO;
    }
    return self;
}

//bStatus:是否为显示/隐藏收件人操作(避免webView再次刷新)
-(CGFloat)initWithMessageVo:(MessageVo*)messageVo andStatus:(BOOL)bStatus
{
    self.m_currMessageVo = messageVo;
    
    CGFloat fHeight = 15;
    
    UIView *viewSingleLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 0.5)];
    viewSingleLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [self addSubview:viewSingleLine];
    
    //star image
    CGFloat fLeft = 10;
    if (self.m_currMessageVo.bHasStarTag)
    {
        self.imgViewStar.frame = CGRectMake(fLeft, 27, 15, 15);
        fLeft = 30;
    }
    else
    {
        self.imgViewStar.frame = CGRectZero;
    }
    
    //0.head image
    self.imgViewHead.frame = CGRectMake(fLeft, fHeight, 40, 40);
    UIImage *phImageName = [[UIImage imageNamed:@"default_m"] roundedWithSize:CGSizeMake(40,40)];
    [self.imgViewHead sd_setImageWithURL:[NSURL URLWithString:messageVo.strAuthorHeadImg] placeholderImage:phImageName];
    
    //1.email sender、attachment num、datetime,group
    self.lblSender.text = messageVo.strAuthorName;
    self.lblSender.frame = CGRectMake(fLeft+40+5, fHeight+2+9, kScreenWidth-175, TextH(18));
    NSUInteger nAttachmentCount = messageVo.aryAttachmentList.count;
    if (nAttachmentCount>0)
    {
        self.lblAttachmentNum.text = [NSString stringWithFormat:@"%lu",(unsigned long)nAttachmentCount];
        CGSize sizeSender = [Common getStringSize:self.lblSender.text font:self.lblSender.font bound:CGSizeMake(MAXFLOAT, 18) lineBreakMode:NSLineBreakByCharWrapping];
        if (sizeSender.width>145)
        {
            self.imgViewAttachmentIcon.frame = CGRectMake(kScreenWidth-110, fHeight+2+9+2, 15, 13.5);
            self.lblAttachmentNum.frame = CGRectMake(kScreenWidth-110+13.5+3, fHeight+2+9+2, 15, 13.5);
        }
        else
        {
            self.imgViewAttachmentIcon.frame = CGRectMake(self.lblSender.left+sizeSender.width+4, fHeight+2+9+2, 15, 13.5);
            self.lblAttachmentNum.frame = CGRectMake(self.lblSender.left+sizeSender.width+4+13.5+3, fHeight+2+9+2, 15, 13.5);
        }
    }
    else
    {
        self.imgViewAttachmentIcon.frame = CGRectZero;
        self.lblAttachmentNum.frame = CGRectZero;
    }
    
    self.lblDateTime.text = [Common getDateTimeStrStyle2:messageVo.strCreateDate andFormatStr:@"yyyy-MM-dd HH:mm"];
    self.lblDateTime.frame = CGRectMake(kScreenWidth-130, fHeight+4, 120, TextH(14));
    
    self.viewSingleLine1.frame = CGRectMake(0, fHeight+40+7, kScreenWidth, 0.5);
    
    //2.title
    fHeight += 40+7+7;
    self.lblTitle.text = messageVo.strTitle;
    CGSize sizeTitle = [Common getStringSize:self.lblTitle.text font:self.lblTitle.font bound:CGSizeMake(kScreenWidth-20, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    self.lblTitle.frame = CGRectMake(10, fHeight, kScreenWidth-20, sizeTitle.height);
    
    self.viewSingleLine2.frame = CGRectMake(0, fHeight+sizeTitle.height+7, kScreenWidth, 0.5);
    
    fHeight += sizeTitle.height+7;
    if ([messageVo.strMsgType isEqualToString:@"N"])
    {
        //通知不显示收件人
    }
    else
    {
        //3.收件人
        if (self.bShow)
        {
            //已展开
            [_btnShowDetail setTitle:@"隐藏详情" forState:UIControlStateNormal];
            self.btnShowDetail.frame = CGRectMake(kScreenWidth-80, fHeight+4, 80, 27);
            
            self.lblReceiver.frame = CGRectZero;
            self.lblReceiver.hidden = YES;
            
            //发件人
            self.lblSenderDetail.text = [NSString stringWithFormat:@"发件人：%@",messageVo.strAuthorName];
            self.lblSenderDetail.frame = CGRectMake(10, fHeight+10, kScreenWidth-20, 14);
            self.lblSenderDetail.hidden = NO;
            fHeight += self.lblSenderDetail.frame.size.height + 10+5;
            
            //收件人
            NSString *strValue = [BusinessCommon getReceiverListString:messageVo.aryReceiverList andType:@"T"];
            if (strValue.length>0)
            {
                CGSize sizeValue = [Common getStringSize:strValue font:self.lblReceiverDetail.font bound:CGSizeMake(kScreenWidth-20, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
                self.lblReceiverDetail.text = strValue;
                self.lblReceiverDetail.frame = CGRectMake(10, fHeight, kScreenWidth-20, sizeValue.height);
                self.lblReceiverDetail.hidden = NO;
                fHeight += self.lblReceiverDetail.frame.size.height + 5;
            }
            else
            {
                self.lblReceiverDetail.frame = CGRectZero;
                self.lblReceiverDetail.hidden = YES;
            }
            
            //抄送
            NSString *strValueCC = [BusinessCommon getReceiverListString:messageVo.aryCCList andType:@"C"];
            if (strValueCC.length>0)
            {
                CGSize sizeValue = [Common getStringSize:strValueCC font:self.lblCCDetail.font bound:CGSizeMake(kScreenWidth-20, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
                self.lblCCDetail.text = strValueCC;
                self.lblCCDetail.hidden = NO;
                self.lblCCDetail.frame = CGRectMake(10, fHeight, kScreenWidth-20, sizeValue.height);
                fHeight += self.lblCCDetail.frame.size.height + 5;
            }
            else
            {
                self.lblCCDetail.frame = CGRectZero;
                self.lblCCDetail.hidden = YES;
            }
            
            //密送
            NSString *strValueBCC = [BusinessCommon getReceiverListString:messageVo.aryBCCList andType:@"B"];
            if (strValueBCC.length>0 && [self.m_currMessageVo.strAuthorID isEqualToString:[Common getCurrentUserVo].strUserID])
            {
                //有密送，并且当前作者为自己
                CGSize sizeValue = [Common getStringSize:strValueCC font:self.lblBCCDetail.font bound:CGSizeMake(kScreenWidth-20, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
                self.lblBCCDetail.text = strValueBCC;
                self.lblBCCDetail.hidden = NO;
                self.lblBCCDetail.frame = CGRectMake(10, fHeight, kScreenWidth-20, sizeValue.height);
                fHeight += self.lblBCCDetail.frame.size.height + 5;
            }
            else
            {
                self.lblBCCDetail.frame = CGRectZero;
                self.lblBCCDetail.hidden = YES;
            }
            
            //时间
            self.lblDateTimeDetail.text = [NSString stringWithFormat:@"时　间：%@",[Common getDateTimeAndNoSecond:messageVo.strCreateDate]];
            self.lblDateTimeDetail.frame = CGRectMake(10, fHeight, kScreenWidth-20, 14);
            fHeight += self.lblDateTimeDetail.frame.size.height + 5;
            self.lblDateTimeDetail.hidden = NO;
            
            //附件
            NSString *strAttachList = [BusinessCommon getAttachmentListString:messageVo.aryAttachmentList];
            if (strAttachList.length>0)
            {
                CGSize sizeValue = [Common getStringSize:strAttachList font:self.lblAttachmentDetail.font bound:CGSizeMake(kScreenWidth-20, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
                self.lblAttachmentDetail.text = strAttachList;
                self.lblAttachmentDetail.hidden = NO;
                self.lblAttachmentDetail.frame = CGRectMake(10, fHeight, kScreenWidth-20, sizeValue.height);
                fHeight += self.lblAttachmentDetail.frame.size.height+5;
            }
            else
            {
                self.lblAttachmentDetail.frame = CGRectZero;
                self.lblAttachmentDetail.hidden = YES;
            }
            fHeight += 5;
        }
        else
        {
            //已隐藏
            [_btnShowDetail setTitle:@"显示详情" forState:UIControlStateNormal];
            self.btnShowDetail.frame = CGRectMake(kScreenWidth-80, fHeight+4, 80, 27);
            
            NSMutableString *strReceiver = [NSMutableString string];
            [strReceiver appendString:@"收件人："];
            if (messageVo.aryReceiverList.count>0)
            {
                for (int i=0; i<messageVo.aryReceiverList.count;i++)
                {
                    ReceiverVo *receiverVo = [messageVo.aryReceiverList objectAtIndex:i];
                    if (i == 0)
                    {
                        [strReceiver appendFormat:@"%@",receiverVo.strName];
                    }
                    else
                    {
                        [strReceiver appendFormat:@"、%@",receiverVo.strName];
                    }
                }
            }
            self.lblReceiver.text = strReceiver;
            self.lblReceiver.frame = CGRectMake(10, fHeight+10, kScreenWidth-80, 14);
            self.lblReceiver.hidden = NO;
            
            self.lblSenderDetail.frame = CGRectZero;
            self.lblSenderDetail.hidden = YES;
            self.lblReceiverDetail.frame = CGRectZero;
            self.lblReceiverDetail.hidden = YES;
            self.lblCCDetail.frame = CGRectZero;
            self.lblCCDetail.hidden = YES;
            self.lblBCCDetail.frame = CGRectZero;
            self.lblBCCDetail.hidden = YES;
            self.lblDateTimeDetail.frame = CGRectZero;
            self.lblDateTimeDetail.hidden = YES;
            self.lblAttachmentDetail.frame = CGRectZero;
            self.lblAttachmentDetail.hidden = YES;
            
            fHeight += 27;
        }
        
        self.viewSingleLine3.frame = CGRectMake(0, fHeight+4, kScreenWidth, 0.5);
    }
    
    //4.content
    fHeight += 4+5;
    self.webViewContent.frame = CGRectMake(0, fHeight, kScreenWidth, self.parentViewController.nWebViewHeight);
    if (!bStatus)//当高度已经计算，则不要重新赋值
    {
        if(self.m_currMessageVo.nComeFromType == 15)
        {
            //工单
            NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:self.m_currMessageVo.strHtmlContent]];
            [self.webViewContent loadRequest:request];
        }
        else
        {
            [self.webViewContent loadHTMLString:messageVo.strHtmlContent baseURL:nil];
        }
    }
    fHeight += self.parentViewController.nWebViewHeight;
    
    //A.attachment
    fHeight += [self initAttachmentView:fHeight];
    
    //B.Lottery
    fHeight += [self initLotteryView:fHeight];
    
    //C.投票
    fHeight += [self initVoteView:fHeight];
    
    //D.约会
    fHeight += [self initScheduleView:fHeight];
    
    //E.引用视图
    fHeight += [self initOrignaBloglView:fHeight];
    
    //F.修改记录
    fHeight += 20;
    
    return fHeight;
}

//1.初始化附件视图
-(CGFloat)initAttachmentView:(CGFloat)fTopHeight
{
    CGFloat fHeight = 0.0;
    if (self.viewAttachmentContainer != nil)
    {
        [self.viewAttachmentContainer removeFromSuperview];
    }
    if(self.m_currMessageVo.aryAttachmentList.count == 0)
    {
        return fHeight;
    }
    
    self.viewAttachmentContainer = [[UIView alloc]init];
    self.viewAttachmentContainer.backgroundColor = [UIColor clearColor];
    
    for (int i=0; i<self.m_currMessageVo.aryAttachmentList.count; i++)
    {
        fHeight += 10.0;
        AttachmentVo *attachmentVo = [self.m_currMessageVo.aryAttachmentList objectAtIndex:i];
        
        //BK
        UIImageView *imgViewAttachmentBK = [[UIImageView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 47)];
        imgViewAttachmentBK.image = [[UIImage imageNamed:@"groupedit_cell_bk"] stretchableImageWithLeftCapWidth:105 topCapHeight:22];
        [self.viewAttachmentContainer addSubview:imgViewAttachmentBK];
        
        //attachment icon
        UIImageView *imgViewAttachmentIcon = [[UIImageView alloc]initWithFrame:CGRectMake(18, fHeight+(47-32)/2, 32, 32)];
        imgViewAttachmentIcon.image = [UIImage imageNamed:[Common getFileIconImageByName:attachmentVo.strAttachmentName]];
        [self.viewAttachmentContainer addSubview:imgViewAttachmentIcon];
        
        //attachment name
        UILabel *lblAttachmentName = [[UILabel alloc]initWithFrame:CGRectMake(50+5, fHeight+11, kScreenWidth-82, 15)];
        lblAttachmentName.text = attachmentVo.strAttachmentName;
        lblAttachmentName.textColor = [SkinManage colorNamed:@"message_color"];//COLOR(51, 51, 51, 1.0);
        lblAttachmentName.font = [UIFont fontWithName:@"Helvetica" size:14.0];
        lblAttachmentName.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self.viewAttachmentContainer addSubview:lblAttachmentName];
        
        //attachment size
        UILabel *lblAttachmentSize = [[UILabel alloc]initWithFrame:CGRectMake(50+5, fHeight+27, kScreenWidth-82, 13)];
        lblAttachmentSize.textColor = [SkinManage colorNamed:@"myjob_Button_title_color"];//COLOR(153, 153, 153, 1.0);
        lblAttachmentSize.font = [UIFont fontWithName:@"Helvetica" size:12.0];
        [self.viewAttachmentContainer addSubview:lblAttachmentSize];
        if (attachmentVo.lAttachmentSize>(1024*1024))
        {
            //Mb
            lblAttachmentSize.text = [NSString stringWithFormat:@"%.2f MB",(double)attachmentVo.lAttachmentSize/(1024*1024)];
        }
        else
        {
            //Kb
            lblAttachmentSize.text = [NSString stringWithFormat:@"%.2f KB",(double)attachmentVo.lAttachmentSize/1024];
        }
        
        //attachment arrow
        UIImageView *imgViewAttachmentArrow = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth-26, fHeight+(47-13)/2, 13, 13)];
        imgViewAttachmentArrow.image = [[UIImage imageNamed:@"cell_right_arrow"] stretchableImageWithLeftCapWidth:150.5 topCapHeight:15];
        [self.viewAttachmentContainer addSubview:imgViewAttachmentArrow];
        
        //attachment button
        UIButton *btnAttachment = [UIButton buttonWithType:UIButtonTypeCustom];
        btnAttachment.tag = 1000+i;
        btnAttachment.frame = CGRectMake(11, fHeight+1.5, kScreenWidth-22, 47-3);
        [btnAttachment addTarget:self action:@selector(doViewAttachment:) forControlEvents:UIControlEventTouchUpInside];
        [btnAttachment setBackgroundImage:[Common getImageWithColor:COLOR(150, 150, 150, 0.4)] forState:UIControlStateHighlighted];
        [self.viewAttachmentContainer addSubview:btnAttachment];
        [btnAttachment.layer setBorderWidth:1.0];
        [btnAttachment.layer setCornerRadius:3];
        btnAttachment.layer.borderColor = [[UIColor clearColor] CGColor];
        [btnAttachment.layer setMasksToBounds:YES];
        fHeight += 47;
    }
    fHeight += 15;
    self.viewAttachmentContainer.frame = CGRectMake(0, fTopHeight, kScreenWidth, fHeight);
    [self addSubview:self.viewAttachmentContainer];
    
    return fHeight;
}

//2.初始化投票视图
-(CGFloat)initVoteView:(CGFloat)fTopHeight
{
    CGFloat fHeight = 0.0;
    if (self.viewVoteContainer != nil)
    {
        [self.viewVoteContainer removeFromSuperview];
    }
    if(self.m_currMessageVo.voteVo == nil)
    {
        return fHeight;
    }
    self.viewVoteContainer = [[UIView alloc]init];
    self.viewVoteContainer.backgroundColor = [UIColor clearColor];
    
    //BK
    UIImageView *imgViewVoteBK = [[UIImageView alloc]init];
    imgViewVoteBK.image = [[UIImage imageNamed:@"groupedit_cell_bk"] stretchableImageWithLeftCapWidth:105 topCapHeight:22];
    [self.viewVoteContainer addSubview:imgViewVoteBK];
    
    fHeight += 15;
    //Vote Option
    if (!self.m_currMessageVo.voteVo.bAlreadVote)
    {
        //1.未投票
        for (int i=0; i<self.m_currMessageVo.voteVo.aryVoteOption.count; i++)
        {
            VoteOptionVo *voteOptionVo = [self.m_currMessageVo.voteVo.aryVoteOption objectAtIndex:i];
            
            //vote option name
            UILabel *lblVoteOptionName = [[UILabel alloc]init];
            lblVoteOptionName.text = voteOptionVo.strOptionName;
            lblVoteOptionName.textColor = [SkinManage colorNamed:@"message_color"];//COLOR(51, 51, 51, 1.0);
            //
            lblVoteOptionName.font = [UIFont fontWithName:@"Helvetica" size:14.0];
            lblVoteOptionName.textAlignment = NSTextAlignmentLeft;
            lblVoteOptionName.numberOfLines = 0;
            [self.viewVoteContainer addSubview:lblVoteOptionName];
            CGSize sizeLabel = [Common getStringSize:lblVoteOptionName.text font:lblVoteOptionName.font bound:CGSizeMake(kScreenWidth-125, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
            lblVoteOptionName.frame = CGRectMake(105, fHeight+13, kScreenWidth-125,sizeLabel.height);
            
            //check button
            UIButton *btnVote = [UIButton buttonWithType:UIButtonTypeCustom];
            btnVote.frame = CGRectMake(11, fHeight+1.5, 33, 40);
            btnVote.tag = 3000+voteOptionVo.nOptionId;
            [btnVote addTarget:self action:@selector(doVoteOperation:) forControlEvents:UIControlEventTouchUpInside];
            [btnVote setImage:[UIImage imageNamed:@"vote_unchk"] forState:UIControlStateNormal];
            [self.viewVoteContainer addSubview:btnVote];
            
            UIImageView *voteImgViewHead = [[UIImageView alloc] initWithFrame:CGRectMake(55, fHeight+3.5, 35,35)];
            voteImgViewHead.clipsToBounds = YES;
            voteImgViewHead.contentMode = UIViewContentModeScaleAspectFill;
            voteImgViewHead.userInteractionEnabled = YES;
            voteImgViewHead.tag = 999+i;
            
            UIImage *phTempImage =[UIImage imageNamed:@"vote_default"];
            if (voteOptionVo.strImage != nil)
            {
                [voteImgViewHead sd_setImageWithURL:[NSURL URLWithString:voteOptionVo.strImage] placeholderImage:phTempImage];
            }
            else
            {
                voteImgViewHead.image = phTempImage;
            }
            [self.viewVoteContainer addSubview:voteImgViewHead];
            
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapVoteImageView:)];
            [voteImgViewHead addGestureRecognizer:singleTap];
            
            if (i != (self.m_currMessageVo.voteVo.aryVoteOption.count-1))
            {
                UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(9.5,fHeight+13+sizeLabel.height+12, kScreenWidth-19, 0.5)];
                viewLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
                [self.viewVoteContainer addSubview:viewLine];
            }
            fHeight += 13+sizeLabel.height+13;
        }
        //竖线
        UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(45,15, 0.5,fHeight-15)];
        viewLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
        
        //COLOR(183, 183, 183, 1.0);
        [self.viewVoteContainer addSubview:viewLine];
        imgViewVoteBK.frame = CGRectMake(0, 15, kScreenWidth, fHeight-15);
        
        //提交和匿名提交
        UIButton *btnCommit = [UIButton buttonWithType:UIButtonTypeCustom];
        btnCommit.frame = CGRectMake(kScreenWidth/2-10-130, fHeight+15, 130, 36);
        btnCommit.tag = 501;
        [btnCommit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnCommit setTitleColor:[SkinManage colorNamed:@"myjob_Button_title_color"] forState:UIControlStateHighlighted];
        btnCommit.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];;
        [btnCommit setTitle:@"提交" forState:UIControlStateNormal];
        [btnCommit addTarget:self action:@selector(doCommitVote:) forControlEvents:UIControlEventTouchUpInside];
        [btnCommit.layer setBorderWidth:1.0];
        [btnCommit.layer setCornerRadius:4];
        btnCommit.layer.borderColor = [[UIColor clearColor] CGColor];
        [btnCommit.layer setMasksToBounds:YES];
        [btnCommit setBackgroundImage:[Common getImageWithColor:[SkinManage skinColor]] forState:UIControlStateNormal];
        [self.viewVoteContainer addSubview:btnCommit];
        
        UIButton *btnAnonymousCommit = [UIButton buttonWithType:UIButtonTypeCustom];
        btnAnonymousCommit.frame = CGRectMake(kScreenWidth/2+10, fHeight+15, 130, 36);
        btnAnonymousCommit.tag = 502;
        [btnAnonymousCommit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnAnonymousCommit setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
        btnAnonymousCommit.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
        [btnAnonymousCommit setTitle:@"匿名提交" forState:UIControlStateNormal];
        [btnAnonymousCommit.layer setBorderWidth:1.0];
        [btnAnonymousCommit.layer setCornerRadius:4];
        btnAnonymousCommit.layer.borderColor = [[UIColor clearColor] CGColor];
        [btnAnonymousCommit.layer setMasksToBounds:YES];
        [btnAnonymousCommit addTarget:self action:@selector(doCommitVote:) forControlEvents:UIControlEventTouchUpInside];
        [btnAnonymousCommit setBackgroundImage:[Common getImageWithColor:[SkinManage skinColor]] forState:UIControlStateNormal];
        [self.viewVoteContainer addSubview:btnAnonymousCommit];
        fHeight += 36+15;
    }
    else
    {
        //2.已投票
        for (int i=0; i<self.m_currMessageVo.voteVo.aryVoteOption.count; i++)
        {
            CGFloat fStartHeight = fHeight;
            VoteOptionVo *voteOptionVo = [self.m_currMessageVo.voteVo.aryVoteOption objectAtIndex:i];
            
            //check button
            UIButton *btnVote = [UIButton buttonWithType:UIButtonTypeCustom];
            btnVote.frame = CGRectMake(11, fHeight+1.5, 33, 40);
            btnVote.enabled = NO;
            [self.viewVoteContainer addSubview:btnVote];
            if (voteOptionVo.bAlreadyVote)
            {
                [btnVote setImage:[UIImage imageNamed:@"vote_chk"] forState:UIControlStateNormal];
            }
            else
            {
                [btnVote setImage:[UIImage imageNamed:@"vote_unchk"] forState:UIControlStateNormal];
            }
            
            //vote option name
            UILabel *lblVoteOptionName = [[UILabel alloc]init];
            lblVoteOptionName.text = voteOptionVo.strOptionName;
            lblVoteOptionName.textColor = [SkinManage colorNamed:@"message_color"];//COLOR(51, 51, 51, 1.0);
            //
            lblVoteOptionName.font = [UIFont fontWithName:@"Helvetica"size:14.0];
            lblVoteOptionName.textAlignment = NSTextAlignmentLeft;
            lblVoteOptionName.numberOfLines = 0;
            [self.viewVoteContainer addSubview:lblVoteOptionName];
            CGSize sizeLabel = [Common getStringSize:lblVoteOptionName.text font:lblVoteOptionName.font bound:CGSizeMake(kScreenWidth-190, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
            lblVoteOptionName.frame = CGRectMake(105, fHeight+13, kScreenWidth-190, sizeLabel.height);
            
            UIImageView *voteImgViewHead = [[UIImageView alloc] initWithFrame:CGRectMake(55, fHeight+3.5, 35,35)];
            voteImgViewHead.contentMode = UIViewContentModeScaleAspectFill;
            voteImgViewHead.clipsToBounds = YES;
            voteImgViewHead.userInteractionEnabled = YES;
            voteImgViewHead.tag = 999+i;
            UIImage *phTempImage =[UIImage imageNamed:@"vote_default"];
            if (voteOptionVo.strImage != nil)
            {
                [voteImgViewHead sd_setImageWithURL:[NSURL URLWithString:voteOptionVo.strImage] placeholderImage:phTempImage];
            }
            else
            {
                voteImgViewHead.image = phTempImage;
            }
            [self.viewVoteContainer addSubview:voteImgViewHead];
            
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapVoteImageView:)];
            [voteImgViewHead addGestureRecognizer:singleTap];
            
            //vote option proportion
            UILabel *lblProportion = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth-114.5, fHeight+16, 100, 16.0)];
            int nPercent = 0;
            if (self.m_currMessageVo.voteVo.nVoteTotal != 0)
            {
                nPercent = 100*(voteOptionVo.nCount*1.0/self.m_currMessageVo.voteVo.nVoteTotal);
            }
            
            lblProportion.text = [NSString stringWithFormat:@"%li(%i%%)",(long)voteOptionVo.nCount,nPercent];
            lblProportion.textColor = COLOR(142, 142, 142, 1.0);
            lblProportion.font = [UIFont fontWithName:@"Helvetica" size:15.0];
            lblProportion.textAlignment = NSTextAlignmentRight;
            [self.viewVoteContainer addSubview:lblProportion];
            
            fHeight += 13+sizeLabel.height;
            
            ///////////////////////////////////////////////////////////////////////////
            if ([self.m_currMessageVo.strAuthorID isEqualToString:[Common getCurrentUserVo].strUserID])
            {
                //本人
                UILabel *lblVoterName = [[UILabel alloc]init];
                lblVoterName.textColor = COLOR(102, 102, 102, 1.0);
                //
                lblVoterName.font = [UIFont fontWithName:@"Helvetica" size:12.0];
                lblVoterName.textAlignment = NSTextAlignmentLeft;
                lblVoterName.numberOfLines = 0;
                [self.viewVoteContainer addSubview:lblVoterName];
                if (voteOptionVo.strVoterName !=nil && voteOptionVo.strVoterName.length>0)
                {
                    lblVoterName.text = [voteOptionVo.strVoterName stringByReplacingOccurrencesOfString:@"#" withString:@","];
                }
                else
                {
                    lblVoterName.text = @"";
                }
                sizeLabel = [Common getStringSize:lblVoterName.text font:lblVoterName.font bound:CGSizeMake(kScreenWidth-70, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
                
                //popup view click button
                UIButton *btnPopupView = [Utils getTransparentButton:CGRectZero target:self action:@selector(doViewVoterName:)];
                btnPopupView.tag = 3000+i;
                [self.viewVoteContainer addSubview:btnPopupView];
                
                if(voteOptionVo.bExpansion)
                {
                    fHeight += 13;
                    lblVoterName.hidden = NO;
                    lblVoterName.frame = CGRectMake(55, fHeight, kScreenWidth-40, sizeLabel.height);
                    
                    fHeight += sizeLabel.height;
                    btnPopupView.frame = CGRectMake(10, fStartHeight, kScreenWidth-20, fHeight-fStartHeight+13);
                }
                else
                {
                    lblVoterName.hidden = YES;
                    btnPopupView.frame = CGRectMake(10, fStartHeight, kScreenWidth-20, fHeight-fStartHeight+13);
                }
            }
            
            [self.viewVoteContainer bringSubviewToFront:voteImgViewHead];
            ///////////////////////////////////////////////////////////////////////////
            
            if (i != (self.m_currMessageVo.voteVo.aryVoteOption.count-1))
            {
                UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(9.5,fHeight+12, kScreenWidth-19, 0.5)];
                viewLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
                [self.viewVoteContainer addSubview:viewLine];
            }
            
            fHeight += 13;
        }
        
        //竖线
        UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(45,15, 0.5,fHeight-15)];
        viewLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
        [self.viewVoteContainer addSubview:viewLine];
        imgViewVoteBK.frame = CGRectMake(0, 15, kScreenWidth, fHeight-15);
    }
    
    fHeight += 15;
    self.viewVoteContainer.frame = CGRectMake(0, fTopHeight, kScreenWidth, fHeight);
    [self addSubview:self.viewVoteContainer];
    return fHeight;
}

-(void)tapVoteImageView:(id)sender
{
    UITapGestureRecognizer *singleTap = (UITapGestureRecognizer *)sender;
    VoteOptionVo *voteOptionVo = [self.m_currMessageVo.voteVo.aryVoteOption objectAtIndex:[singleTap view].tag-999];
    if (voteOptionVo.strImage != nil)
    {
        SDWebImageDataSource *dataSource = [[SDWebImageDataSource alloc] init];
        dataSource.images_ = [NSArray arrayWithObject:[NSArray arrayWithObject:[NSURL URLWithString:voteOptionVo.strImage]]];
        
        KTPhotoScrollViewController *photoScrollViewController = [[KTPhotoScrollViewController alloc]
                                                                  initWithDataSource:dataSource
                                                                  andStartWithPhotoAtIndex:0];
        photoScrollViewController.bShowToolBarBtn = NO;
        [self.parentViewController presentViewController:photoScrollViewController animated:YES completion: nil];
    }
}

//3.初始化日程视图
-(CGFloat)initScheduleView:(CGFloat)fTopHeight
{
    CGFloat fHeight = 0.0;
    
    if (self.viewScheduleContainer != nil)
    {
        [self.viewScheduleContainer removeFromSuperview];
    }
    
    if(self.m_currMessageVo.scheduleVo == nil)
    {
        return fHeight;
    }
    
    self.viewScheduleContainer = [[UIView alloc]init];
    self.viewScheduleContainer.backgroundColor = [UIColor clearColor];
    
    fHeight = 15.0;
    //选择按钮
    if (![self.m_currMessageVo.strAuthorID isEqualToString:[Common getCurrentUserVo].strUserID])
    {
        CGFloat fButtonW = (kScreenWidth-20)/3;
        //创建者隐藏不显示参与按钮
        UIImageView *imgViewScheduleBtnBK = [[UIImageView alloc]initWithFrame:CGRectMake(9.5, fHeight, kScreenWidth-19, 47)];
        imgViewScheduleBtnBK.image = [[UIImage imageNamed:@"schedule_btn_bk"] stretchableImageWithLeftCapWidth:150 topCapHeight:23];
        [self.viewScheduleContainer addSubview:imgViewScheduleBtnBK];
        
        UIView *viewScheduleLine1 = [[UIView alloc]initWithFrame:CGRectMake(fButtonW, 0.5, 0.5, 46)];
        viewScheduleLine1.backgroundColor = COLOR(204, 204, 204, 1.0);
        [imgViewScheduleBtnBK addSubview:viewScheduleLine1];
        
        UIView *viewScheduleLine2 = [[UIView alloc]initWithFrame:CGRectMake(fButtonW*2, 0.5, 0.5, 46)];
        viewScheduleLine2.backgroundColor = COLOR(204, 204, 204, 1.0);
        [imgViewScheduleBtnBK addSubview:viewScheduleLine2];
        
        UILabel *lblJoin = [[UILabel alloc]initWithFrame:CGRectMake(10, fHeight+30/2, fButtonW, 17)];
        lblJoin.text = @"参加";
        lblJoin.textColor = COLOR(102, 102, 102, 1.0);
        lblJoin.font = [UIFont fontWithName:@"Helvetica" size:16.0];
        lblJoin.textAlignment = NSTextAlignmentCenter;
        [self.viewScheduleContainer addSubview:lblJoin];
        
        UILabel *lblNotJoin = [[UILabel alloc]initWithFrame:CGRectMake(lblJoin.right, fHeight+30/2, fButtonW,17)];
        lblNotJoin.text = @"不参加";
        lblNotJoin.textColor = COLOR(102, 102, 102, 1.0);
        lblNotJoin.font = [UIFont fontWithName:@"Helvetica" size:16.0];
        lblNotJoin.textAlignment = NSTextAlignmentCenter;
        [self.viewScheduleContainer addSubview:lblNotJoin];
        
        UILabel *lblNotSure = [[UILabel alloc]initWithFrame:CGRectMake(lblNotJoin.right, fHeight+30/2, fButtonW, 17)];
        lblNotSure.text = @"不确定";
        lblNotSure.textColor = COLOR(102, 102, 102, 1.0);
        lblNotSure.font = [UIFont fontWithName:@"Helvetica" size:16.0];
        lblNotSure.textAlignment = NSTextAlignmentCenter;
        [self.viewScheduleContainer addSubview:lblNotSure];
        
        UIButton *btnJoin = [Utils getTransparentButton:CGRectMake(10, fHeight, fButtonW, 47) target:self action:@selector(doJoinScheduleOperation:)];
        btnJoin.tag = 2001;
        [self.viewScheduleContainer addSubview:btnJoin];
        
        UIButton *btnNotJoin = [Utils getTransparentButton:CGRectMake(lblJoin.right, fHeight, fButtonW, 47) target:self action:@selector(doJoinScheduleOperation:)];
        btnNotJoin.tag = 2002;
        [self.viewScheduleContainer addSubview:btnNotJoin];
        
        UIButton *btnNotSure = [Utils getTransparentButton:CGRectMake(lblNotJoin.right, fHeight, fButtonW, 47) target:self action:@selector(doJoinScheduleOperation:)];
        btnNotSure.tag = 2003;
        [self.viewScheduleContainer addSubview:btnNotSure];
        
        fHeight += 47;
        fHeight += 10;
    }
    
    //参加的约会成员
    CGFloat fMemBKHeight = fHeight;
    UIImageView *imgViewScheduleMemBK = [[UIImageView alloc]init];
    imgViewScheduleMemBK.image = [[UIImage imageNamed:@"groupedit_cell_bk"] stretchableImageWithLeftCapWidth:105 topCapHeight:22];
    [self.viewScheduleContainer addSubview:imgViewScheduleMemBK];
    
    fHeight += 15;
    UILabel *lblJoinMem = [[UILabel alloc]init];
    lblJoinMem.text = [NSString stringWithFormat:@"参加人: %@",[BusinessCommon getScheduleMemberByType:1 andArray:self.m_currMessageVo.scheduleVo.aryUserJoinState]];
    lblJoinMem.textColor = COLOR(102, 102, 102, 1.0);
    //
    lblJoinMem.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    lblJoinMem.textAlignment = NSTextAlignmentLeft;
    lblJoinMem.numberOfLines = 0;
    [self.viewScheduleContainer addSubview:lblJoinMem];
    CGSize sizeLabel = [Common getStringSize:lblJoinMem.text font:lblJoinMem.font bound:CGSizeMake(kScreenWidth-40, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    lblJoinMem.frame = CGRectMake(20, fHeight, kScreenWidth-40, sizeLabel.height);
    fHeight += sizeLabel.height;
    
    fHeight += 15;
    UILabel *lblNotJoinMem = [[UILabel alloc]init];
    lblNotJoinMem.text = [NSString stringWithFormat:@"不参加: %@",[BusinessCommon getScheduleMemberByType:2 andArray:self.m_currMessageVo.scheduleVo.aryUserJoinState]];
    lblNotJoinMem.textColor = COLOR(102, 102, 102, 1.0);
    lblNotJoinMem.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    lblNotJoinMem.textAlignment = NSTextAlignmentLeft;
    lblNotJoinMem.numberOfLines = 0;
    [self.viewScheduleContainer addSubview:lblNotJoinMem];
    sizeLabel = [Common getStringSize:lblNotJoinMem.text font:lblNotJoinMem.font bound:CGSizeMake(kScreenWidth-40, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    lblNotJoinMem.frame = CGRectMake(20, fHeight, kScreenWidth-40, sizeLabel.height);
    fHeight += sizeLabel.height;
    
    fHeight += 15;
    UILabel *lblNotSureMem = [[UILabel alloc]init];
    lblNotSureMem.text = [NSString stringWithFormat:@"不确定: %@",[BusinessCommon getScheduleMemberByType:3 andArray:self.m_currMessageVo.scheduleVo.aryUserJoinState]];
    lblNotSureMem.textColor = COLOR(102, 102, 102, 1.0);
    lblNotSureMem.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    lblNotSureMem.textAlignment = NSTextAlignmentLeft;
    lblNotSureMem.numberOfLines = 0;
    lblNotSureMem.lineBreakMode = NSLineBreakByWordWrapping;
    [self.viewScheduleContainer addSubview:lblNotSureMem];
    sizeLabel = [Common getStringSize:lblNotSureMem.text font:lblNotSureMem.font bound:CGSizeMake(kScreenWidth-40, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    lblNotSureMem.frame = CGRectMake(20, fHeight, kScreenWidth-40, sizeLabel.height);
    fHeight += sizeLabel.height;
    
    fHeight += 15;
    imgViewScheduleMemBK.frame = CGRectMake(0, fMemBKHeight, kScreenWidth, fHeight-fMemBKHeight);
    
    fHeight += 15;
    self.viewScheduleContainer.frame = CGRectMake(0, fTopHeight, kScreenWidth, fHeight);
    [self addSubview:self.viewScheduleContainer];
    
    return fHeight;
}

//4.初始化抽奖视图
-(CGFloat)initLotteryView:(CGFloat)fTopHeight
{
    CGFloat fHeight = 0.0;
    if (self.viewLotteryContainer != nil)
    {
        [self.viewLotteryContainer removeFromSuperview];
    }
    if(self.m_currMessageVo.lotteryVo == nil)
    {
        return fHeight;
    }
    self.viewLotteryContainer = [[UIView alloc]init];
    self.viewLotteryContainer.backgroundColor = [UIColor clearColor];
    
    //截止时间
    UILabel *lblEndTime = [[UILabel alloc]init];
    NSString *strEndTime = [Common getDateTimeAndNoSecond:self.m_currMessageVo.lotteryVo.strEndTime];
    if (strEndTime == nil)
    {
        strEndTime = self.m_currMessageVo.lotteryVo.strEndTime;
    }
    lblEndTime.text = [NSString stringWithFormat:@"抽奖截止日期：%@",strEndTime];
    lblEndTime.textColor = COLOR(51, 51, 51, 1.0);
    lblEndTime.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    lblEndTime.textAlignment = NSTextAlignmentLeft;
    lblEndTime.frame = CGRectMake(10, fHeight, kScreenWidth-20, 25);
    [self.viewLotteryContainer addSubview:lblEndTime];
    fHeight += 30;
    
    //BK
    UIImageView *imgViewLotteryBK = [[UIImageView alloc]init];
    imgViewLotteryBK.image = [[UIImage imageNamed:@"groupedit_cell_bk"] stretchableImageWithLeftCapWidth:105 topCapHeight:22];
    [self.viewLotteryContainer addSubview:imgViewLotteryBK];
    
    //奖项
    NSString *strWinLotteryContent = @"";
    for (int i=0; i<self.m_currMessageVo.lotteryVo.aryLotteryOption.count; i++)
    {
        CGFloat fStartHeight = fHeight;
        fHeight += 10;
        //CGFloat fStartHeight = fHeight;
        LotteryOptionVo *lotteryOptionVo = [self.m_currMessageVo.lotteryVo.aryLotteryOption objectAtIndex:i];
        
        //lottery image
        UIImageView *imgViewLotteryOption = [[UIImageView alloc] initWithFrame:CGRectZero];
        imgViewLotteryOption.contentMode = UIViewContentModeScaleAspectFill;
        imgViewLotteryOption.clipsToBounds = YES;
        imgViewLotteryOption.userInteractionEnabled = YES;
        imgViewLotteryOption.tag = 10000+i;
        UIImage *phTempImage =[UIImage imageNamed:@"vote_default"];
        if (lotteryOptionVo.strLotteryImgUrl != nil && lotteryOptionVo.strLotteryImgUrl.length>0)
        {
            imgViewLotteryOption.frame = CGRectMake(20, fHeight, 35,35);
            [imgViewLotteryOption sd_setImageWithURL:[NSURL URLWithString:lotteryOptionVo.strLotteryImgUrl] placeholderImage:phTempImage];
        }
        else
        {
            imgViewLotteryOption.frame = CGRectMake(0, 0, 0, 0);
        }
        [self.viewLotteryContainer addSubview:imgViewLotteryOption];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLotteryImageView:)];
        [imgViewLotteryOption addGestureRecognizer:singleTap];
        
        //lottery option name
        UILabel *lblLotteryOptionName = [[UILabel alloc]init];
        lblLotteryOptionName.text = lotteryOptionVo.strLotteryName;
        lblLotteryOptionName.textColor = COLOR(51, 51, 51, 1.0);
        //
        lblLotteryOptionName.font = [UIFont fontWithName:@"Helvetica"size:14.0];
        lblLotteryOptionName.textAlignment = NSTextAlignmentLeft;
        lblLotteryOptionName.numberOfLines = 0;
        [self.viewLotteryContainer addSubview:lblLotteryOptionName];
        CGSize sizeLabel;
        if (imgViewLotteryOption.frame.size.width > 0)
        {
            sizeLabel = [Common getStringSize:lblLotteryOptionName.text font:lblLotteryOptionName.font bound:CGSizeMake(kScreenWidth-135, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
            lblLotteryOptionName.frame = CGRectMake(65, fHeight, kScreenWidth-135, sizeLabel.height);
        }
        else
        {
            sizeLabel = [Common getStringSize:lblLotteryOptionName.text font:lblLotteryOptionName.font bound:CGSizeMake(kScreenWidth-90, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
            lblLotteryOptionName.frame = CGRectMake(20, fHeight, kScreenWidth-90, sizeLabel.height);
        }
        
        //vote option proportion
        UILabel *lblProportion = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth-114.5, fHeight, 100, 35.0)];
        lblProportion.text = [NSString stringWithFormat:@"总数:%li \n 剩余:%li",(long)lotteryOptionVo.nLotteryNum,(long)lotteryOptionVo.nLotteryLeftNum];
        lblProportion.textColor = COLOR(142, 142, 142, 1.0);
        lblProportion.font = [UIFont fontWithName:@"Helvetica" size:14.0];
        lblProportion.textAlignment = NSTextAlignmentRight;
        lblProportion.numberOfLines = 2;
        [self.viewLotteryContainer addSubview:lblProportion];
        
        //win lottery person name
        if ((sizeLabel.height + 10)>45)
        {
            fHeight += sizeLabel.height + 10;
        }
        else
        {
            fHeight += 45;
        }
        UILabel *lblWinLotteryName = [[UILabel alloc]init];
        lblWinLotteryName.text = [NSString stringWithFormat:@"中奖者：%@",lotteryOptionVo.strWinLotteryName];
        lblWinLotteryName.textColor = COLOR(102, 102, 102, 1.0);
        lblWinLotteryName.font = [UIFont fontWithName:@"Helvetica" size:16.0];
        lblWinLotteryName.textAlignment = NSTextAlignmentLeft;
        lblWinLotteryName.numberOfLines = 1;
        [self.viewLotteryContainer addSubview:lblWinLotteryName];
        
        //popup view click button(显示更多抽奖人或者仅一行)
        UIButton *btnPopupView = [Utils getTransparentButton:CGRectZero target:self action:@selector(doViewWinLotteryName:)];
        btnPopupView.tag = 10000+i;
        [self.viewLotteryContainer addSubview:btnPopupView];
        if(lotteryOptionVo.bExpansion)
        {
            CGSize sizeLabel = [Common getStringSize:lblWinLotteryName.text font:lblWinLotteryName.font bound:CGSizeMake(kScreenWidth-40, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
            lblWinLotteryName.numberOfLines = 0;
            lblWinLotteryName.frame = CGRectMake(20, fHeight, kScreenWidth-40,sizeLabel.height);
            fHeight += sizeLabel.height;
            
            btnPopupView.frame = CGRectMake(10, fStartHeight, kScreenWidth-20, fHeight-fStartHeight+10);
        }
        else
        {
            CGSize sizeLabel = [Common getStringSize:@"test height word" font:lblWinLotteryName.font bound:CGSizeMake(kScreenWidth-40, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
            lblWinLotteryName.numberOfLines = 1;
            lblWinLotteryName.frame = CGRectMake(20, fHeight, kScreenWidth-40,sizeLabel.height);
            fHeight += sizeLabel.height;
            
            btnPopupView.frame = CGRectMake(10, fStartHeight, kScreenWidth-20, fHeight-fStartHeight+10);
        }
        
        [self.viewLotteryContainer bringSubviewToFront:imgViewLotteryOption];
        
        if (i != (self.m_currMessageVo.lotteryVo.aryLotteryOption.count-1))
        {
            UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(9.5,fHeight+10, kScreenWidth-19, 0.5)];
            viewLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
            [self.viewLotteryContainer addSubview:viewLine];
        }
        fHeight += 10;
        
        //get current person win lottery info
        if (self.m_currMessageVo.lotteryVo.bDrawLottery && [lotteryOptionVo.strLotteryOptionID isEqualToString:self.m_currMessageVo.lotteryVo.strWinOptionID])
        {
            strWinLotteryContent = lotteryOptionVo.strLotteryName;
        }
    }
    
    //set bk frame
    imgViewLotteryBK.frame = CGRectMake(0, 30, kScreenWidth, fHeight-30);
    
    //中奖信息
    fHeight += 20;
    UILabel *lblLotteryResult = [[UILabel alloc]init];
    lblLotteryResult.textColor = [SkinManage colorNamed:@"message_color"];
    lblLotteryResult.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    lblLotteryResult.textAlignment = NSTextAlignmentCenter;
    lblLotteryResult.numberOfLines = 0;
    lblLotteryResult.lineBreakMode = NSLineBreakByWordWrapping;
    [self.viewLotteryContainer addSubview:lblLotteryResult];
    
    //中奖信息的背景
    UIImageView *imgViewLotteryResultBK = [[UIImageView alloc]init];
    imgViewLotteryResultBK.image = [[UIImage imageNamed:@"lottery_result_bk"]stretchableImageWithLeftCapWidth:0 topCapHeight:15];
    [self.viewLotteryContainer addSubview:imgViewLotteryResultBK];
    
    //抽奖按钮以及其他信息显示
    UIButton *btnDrawLotter = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDrawLotter setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnDrawLotter.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:15.0]];
    [btnDrawLotter.layer setBorderWidth:1.0];
    [btnDrawLotter.layer setCornerRadius:3];
    btnDrawLotter.layer.borderColor = [[UIColor clearColor] CGColor];
    [btnDrawLotter.layer setMasksToBounds:YES];
    [self.viewLotteryContainer addSubview:btnDrawLotter];
    
    BOOL bShowLabel = NO;
    if ([self.m_currMessageVo.strAuthorID isEqualToString:[Common getCurrentUserVo].strUserID])
    {
        //本人
        [btnDrawLotter setTitle:@"你是抽奖发起人" forState:UIControlStateNormal];
        [btnDrawLotter setBackgroundImage:[Common getImageWithColor:SLOTH_GRAY] forState:UIControlStateNormal];
    }
    else if(self.m_currMessageVo.lotteryVo.bDrawLottery)
    {
        //已抽奖
        if (self.m_currMessageVo.lotteryVo.strWinOptionID.length == 0)
        {
            [btnDrawLotter setTitle:@"没有抽中奖" forState:UIControlStateNormal];
            [btnDrawLotter setBackgroundImage:[Common getImageWithColor:SLOTH_GRAY] forState:UIControlStateNormal];
        }
        else
        {
            bShowLabel = YES;
            lblLotteryResult.text = strWinLotteryContent;//@"上海科技大学（ShanghaiTech University，简称上科大）是由上海市人民政府与中国科学院共同举办、共同建设，经教育部批准，由上海市人民政府主管的小规模、高水平、国际化的创新型大学。学校以理工科和管理学科为主，突出科教结合，注重学科交叉。当前共设四个学院——物质科学与技术学院、信息科学与技术学院、生命科学与技术学院和创业与管理学院，并设有上海免疫化学和iHuman两个研究所。2013年学校依托中科院上海分院各研究院所招收硕士研究生，2014年起开始招收本科生。";//strWinLotteryContent;
        }
    }
    else
    {
        //未抽奖
        if(self.m_currMessageVo.lotteryVo.bExpired)
        {
            //已过期
            [btnDrawLotter setTitle:@"该奖已过期" forState:UIControlStateNormal];
            [btnDrawLotter setBackgroundImage:[Common getImageWithColor:SLOTH_GRAY] forState:UIControlStateNormal];
        }
        else
        {
            //未过期(显示抽奖按钮)
            [btnDrawLotter setTitle:@"抽  奖" forState:UIControlStateNormal];
            [btnDrawLotter setBackgroundImage:[Common getImageWithColor:[SkinManage skinColor]] forState:UIControlStateNormal];
            [btnDrawLotter addTarget:self action:@selector(drawLotteryAction) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    //换行
    if (bShowLabel)
    {
        CGSize sizeTitle = [Common getStringSize:lblLotteryResult.text font:lblLotteryResult.font bound:CGSizeMake(kScreenWidth-40, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        imgViewLotteryResultBK.frame = CGRectMake(0, fHeight, kScreenWidth, 70+sizeTitle.height);
        lblLotteryResult.frame = CGRectMake(20, fHeight+15, kScreenWidth-40, sizeTitle.height);
        btnDrawLotter.frame = CGRectZero;
        fHeight += sizeTitle.height + 70;
    }
    else
    {
        lblLotteryResult.frame = CGRectZero;
        btnDrawLotter.frame = CGRectMake(60, fHeight+10, kScreenWidth-120, 30);
        fHeight += 30 + 20;
    }
    
    self.viewLotteryContainer.frame = CGRectMake(0, fTopHeight, kScreenWidth, fHeight);
    [self addSubview:self.viewLotteryContainer];
    return fHeight;
}

-(void)tapLotteryImageView:(id)sender
{
    UITapGestureRecognizer *singleTap = (UITapGestureRecognizer *)sender;
    LotteryOptionVo *lotteryOptionVo = [self.m_currMessageVo.lotteryVo.aryLotteryOption objectAtIndex:[singleTap view].tag-10000];
    if (lotteryOptionVo.strLotteryImgUrl != nil)
    {
        SDWebImageDataSource *dataSource = [[SDWebImageDataSource alloc] init];
        dataSource.images_ = [NSArray arrayWithObject:[NSArray arrayWithObject:[NSURL URLWithString:lotteryOptionVo.strLotteryImgUrl]]];
        
        KTPhotoScrollViewController *photoScrollViewController = [[KTPhotoScrollViewController alloc]
                                                                  initWithDataSource:dataSource
                                                                  andStartWithPhotoAtIndex:0];
        photoScrollViewController.bShowToolBarBtn = NO;
        [self.parentViewController presentViewController:photoScrollViewController animated:YES completion: nil];
    }
}

//5.初始化转发的原文视图
-(CGFloat)initOrignaBloglView:(CGFloat)fTopHeight
{
    CGFloat fHeight = 0.0;
    return fHeight;
}

-(void)tapHeaderImageView
{
    //    UserCenterViewController *userCenterViewController = [[UserCenterViewController alloc]init];
    //    UserVo *userVo = [[UserVo alloc]init];
    //    userVo.strUserID = self.m_currMessageVo.strAuthorID;
    //    userCenterViewController.m_userVo = userVo;
    //    [self.parentViewController.navigationController pushViewController:userCenterViewController animated:YES];
}

- (void)previewImage:(NSString*)url
{
    SDWebImageDataSource *dataSource = [[SDWebImageDataSource alloc] init];
    dataSource.images_ = [NSArray arrayWithObject:[NSArray arrayWithObject:[NSURL URLWithString:url]]];
    
    KTPhotoScrollViewController *photoScrollViewController = [[KTPhotoScrollViewController alloc]
                                                              initWithDataSource:dataSource
                                                              andStartWithPhotoAtIndex:0];
    [self.parentViewController.navigationController pushViewController:photoScrollViewController animated:YES];
}

- (void)handleWebViewImage:(UITapGestureRecognizer *)sender
{
    if (!self.parentViewController.bScrolling)
    {
        CGPoint touchPoint = [sender locationInView:self.webViewContent];
        NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).getAttribute('img-max')", touchPoint.x, touchPoint.y];//img-max
        NSString *strImgMax = [_webViewContent stringByEvaluatingJavaScriptFromString:imgURL];
        if (strImgMax != nil && strImgMax.length>0)
        {
            //先获取大图
            [self previewImage:strImgMax];
        }
        else
        {
            //大图不存在，则获取中图
            NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
            NSString *strImgSrc = [_webViewContent stringByEvaluatingJavaScriptFromString:imgURL];
            if (strImgSrc != nil && strImgSrc.length>0)
            {
                [self previewImage:strImgSrc];
            }
        }
    }
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (self.parentViewController.nWebViewHeight>1)
    {
        self.hidden = NO;
        [self.parentViewController isHideActivity:YES];
    }
    else
    {
        NSString *fitHeight = [webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"];
        self.parentViewController.nWebViewHeight = [fitHeight floatValue];
        [self.parentViewController initMiddleView];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        NSString *strURL = [request URL].absoluteString;
        if (strURL != nil && strURL.length>0)
        {
            NSRange range = [strURL rangeOfString:@"tel:"];
            if(range.length>0 && range.location == 0)
            {
                NSString *strPhoneTipInfo = [NSString stringWithFormat:@"您确定要呼叫 %@ ？",[strURL substringFromIndex:4]];
                if ([Common ask:strPhoneTipInfo] == 1)
                {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strURL]];
                }
            }
            else
            {
                FullScreenWebViewController *fullScreenWebViewController = [[FullScreenWebViewController alloc]init];
                fullScreenWebViewController.urlFile = [request URL];
                [self.parentViewController.navigationController pushViewController:fullScreenWebViewController animated:YES];
            }
        }
        return NO;
    }
    else
    {
        [self.parentViewController isHideActivity:NO];
    }
    return YES;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

//show or hide message detail
-(void)showDetailReceiverList
{
    self.bShow = !self.bShow;
    [self.parentViewController updateMsgListFrame];
}

//attachment/////////////////////////////////////////////////////////////////////////////////
//查看附件
-(void)doViewAttachment:(UIButton*)sender
{
    FileBrowserViewController *fileBrowserViewController = [[FileBrowserViewController alloc]init];
    AttachmentVo *attachmentVo = [self.m_currMessageVo.aryAttachmentList objectAtIndex:(sender.tag-1000)];
    FileVo *fileVo = [[FileVo alloc]init];
    fileVo.strID = attachmentVo.strID;
    fileVo.strName = attachmentVo.strAttachmentName;
    fileVo.strFileURL = attachmentVo.strAttachmentURL;
    fileVo.lFileSize = attachmentVo.lAttachmentSize;
    fileBrowserViewController.m_fileVo = fileVo;
    [self.parentViewController.navigationController pushViewController:fileBrowserViewController animated:YES];
}

//vote/////////////////////////////////////////////////////////////////////////////////
//选择投票项
-(void)doVoteOperation:(UIButton*)sender
{
    if (self.m_currMessageVo.voteVo.nVoteType == 0)
    {
        //single choose
        for (int i=0; i<self.m_currMessageVo.voteVo.aryVoteOption.count; i++)
        {
            VoteOptionVo *voteOptionVo = [self.m_currMessageVo.voteVo.aryVoteOption objectAtIndex:i];
            if (voteOptionVo.nOptionId == (sender.tag-3000))
            {
                //sender
                voteOptionVo.nSelected = 1;
                voteOptionVo.nCount ++;
                UIButton *btnVoteOption = (UIButton *)[self.viewVoteContainer viewWithTag:(voteOptionVo.nOptionId+3000)];
                [btnVoteOption setImage:[UIImage imageNamed:@"vote_chk"] forState:UIControlStateNormal];
            }
            else
            {
                if (voteOptionVo.nSelected == 1)
                {
                    //update value
                    voteOptionVo.nSelected = 0;
                    voteOptionVo.nCount --;
                }
                UIButton *btnVoteOption = (UIButton *)[self.viewVoteContainer viewWithTag:(voteOptionVo.nOptionId+3000)];
                [btnVoteOption setImage:[UIImage imageNamed:@"vote_unchk"] forState:UIControlStateNormal];
            }
        }
    }
    else
    {
        //multiple choose
        for (int i=0; i<self.m_currMessageVo.voteVo.aryVoteOption.count; i++)
        {
            VoteOptionVo *voteOptionVo = [self.m_currMessageVo.voteVo.aryVoteOption objectAtIndex:i];
            if (voteOptionVo.nOptionId == (sender.tag-3000))
            {
                //sender
                if (voteOptionVo.nSelected == 0)
                {
                    //will choose
                    voteOptionVo.nSelected = 1;
                    voteOptionVo.nCount ++;
                    [sender setImage:[UIImage imageNamed:@"vote_chk"] forState:UIControlStateNormal];
                }
                else
                {
                    //will cancel choose
                    voteOptionVo.nSelected = 0;
                    voteOptionVo.nCount --;
                    [sender setImage:[UIImage imageNamed:@"vote_unchk"] forState:UIControlStateNormal];
                }
                break;
            }
        }
    }
}

//提交投票
-(void)doCommitVote:(UIButton*)sender
{
    int nType = 0;
    if (sender.tag == 501)
    {
        //实名提交
        nType = 0;
    }
    else
    {
        //匿名提交
        nType = 1;
    }
    
    NSMutableArray *aryOptionID = [NSMutableArray array];
    for (int i=0; i<self.m_currMessageVo.voteVo.aryVoteOption.count; i++)
    {
        VoteOptionVo *voteOptionVo = [self.m_currMessageVo.voteVo.aryVoteOption objectAtIndex:i];
        if (voteOptionVo.nSelected)
        {
            [aryOptionID addObject:[NSNumber numberWithInteger:voteOptionVo.nOptionId]];
            voteOptionVo.bAlreadyVote = YES;
        }
        else
        {
            voteOptionVo.bAlreadyVote = NO;
        }
    }
    
    //空选项退出
    if (aryOptionID.count == 0)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [Common tipAlert:@"请选择投票项"];
            [self.parentViewController isHideActivity:YES];
        });
        return;
    }
    
    
    [self.parentViewController isHideActivity:NO];
    [ServerProvider operateVote:self.m_currMessageVo.voteVo.strID andVoteOption:aryOptionID andType:nType result:^(ServerReturnInfo *retInfo) {
        [self.parentViewController isHideActivity:YES];
        if (retInfo.bSuccess)
        {
            [self.parentViewController initData];
            [Common tipAlert:@"投票成功"];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

//查看投票人操作
-(void)doViewVoterName:(UIButton*)sender
{
    VoteOptionVo *voteOptionVo = [self.m_currMessageVo.voteVo.aryVoteOption objectAtIndex:(sender.tag-3000)];
    voteOptionVo.bExpansion = !voteOptionVo.bExpansion;
    [self.parentViewController updateMsgListFrame];
}

//schedule/////////////////////////////////////////////////////////////////////////////////
//参与约会操作
-(void)doJoinScheduleOperation:(UIButton*)sender
{
    int nType = 1;
    if (sender.tag == 2001)
    {
        nType = 1;
    }
    else if (sender.tag == 2002)
    {
        nType = 2;
    }
    else if (sender.tag == 2003)
    {
        nType = 3;
    }
    
    if(nType == 1 || nType == 3)
    {
        //是否加入系统日历
        if ([Common ask:@"是否加入系统日历？"])
        {
            [self joinPhoneAlert];
        }
    }
    
    [self.parentViewController isHideActivity:NO];
    [ServerProvider operateSchedule:self.m_currMessageVo.scheduleVo.strId andType:nType result:^(ServerReturnInfo *retInfo) {
        [self.parentViewController isHideActivity:YES];
        if (retInfo.bSuccess)
        {
            [self.parentViewController isHideActivity:YES];
            
            for (int i=0; i<self.m_currMessageVo.scheduleVo.aryUserJoinState.count; i++)
            {
                ScheduleJoinStateVo *scheduleVo = [self.m_currMessageVo.scheduleVo.aryUserJoinState objectAtIndex:i];
                if([scheduleVo.strUserID isEqualToString:[Common getCurrentUserVo].strUserID])
                {
                    scheduleVo.nReply = nType;
                    //update ui
                    [self.parentViewController updateMsgListFrame];
                    break;
                }
            }
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

//加入手机提醒
-(void)joinPhoneAlert
{
    CalendarEventVo *calendarEventVo = [self.calendarEventDao getCalendarEventByBlogId:self.m_currMessageVo.scheduleVo.strId];
    if (calendarEventVo == nil)
    {
        //add phone alert
        calendarEventVo = [[CalendarEventVo alloc]init];
        calendarEventVo.strSCHEDULE_ID = self.m_currMessageVo.scheduleVo.strId;
        calendarEventVo.strTopic = self.m_currMessageVo.strTitle;
        calendarEventVo.strStreamContent = self.m_currMessageVo.strTextContent;
        calendarEventVo.strStartTime = self.m_currMessageVo.scheduleVo.strStartTime;
        
        [CalendarEventOperation saveCalendarEvent:calendarEventVo andOperation:CREATE_CALENDAR_EVENT andShowAlert:FALSE];
    }
    else
    {
        //update phone alert
        calendarEventVo.strTopic = self.m_currMessageVo.strTitle;
        calendarEventVo.strStreamContent = self.m_currMessageVo.strTextContent;
        calendarEventVo.strStartTime = self.m_currMessageVo.scheduleVo.strStartTime;
        
        [CalendarEventOperation saveCalendarEvent:calendarEventVo andOperation:UPDATE_CALENDAR_EVENT andShowAlert:FALSE];
    }
}

//update star frame
-(void)updateStarFrame
{
    CGFloat fLeft = 10;
    if (self.m_currMessageVo.bHasStarTag)
    {
        self.imgViewStar.frame = CGRectMake(fLeft, 27, 15, 15);
        fLeft = 30;
    }
    else
    {
        self.imgViewStar.frame = CGRectZero;
    }
    
    self.imgViewHead.frame = CGRectMake(fLeft, self.imgViewHead.frame.origin.y, 40, 40);
    
    self.lblSender.frame = CGRectMake(fLeft+40+5, self.lblSender.frame.origin.y, 145, 18);
    
    NSUInteger nAttachmentCount = self.m_currMessageVo.aryAttachmentList.count;
    if (nAttachmentCount>0)
    {
        self.lblAttachmentNum.text = [NSString stringWithFormat:@"%lu",(unsigned long)nAttachmentCount];
        CGSize sizeSender = [Common getStringSize:self.lblSender.text font:self.lblSender.font bound:CGSizeMake(MAXFLOAT, 18) lineBreakMode:NSLineBreakByCharWrapping];
        if (sizeSender.width>145)
        {
            self.imgViewAttachmentIcon.frame = CGRectMake(210, self.imgViewAttachmentIcon.frame.origin.y, 15, 13.5);
            self.lblAttachmentNum.frame = CGRectMake(210+13.5+3,self.lblAttachmentNum.frame.origin.y, 15, 13.5);
        }
        else
        {
            self.imgViewAttachmentIcon.frame = CGRectMake(self.lblSender.frame.origin.x+sizeSender.width+4, self.imgViewAttachmentIcon.frame.origin.y, 15, 13.5);
            self.lblAttachmentNum.frame = CGRectMake(self.lblSender.frame.origin.x+sizeSender.width+4+13.5+3, self.lblAttachmentNum.frame.origin.y, 15, 13.5);
        }
    }
}

//lottery/////////////////////////////////////////////////////////////////////////////////
//抽奖操作
-(void)drawLotteryAction
{
    //打开抽奖视图
    [self isHideDrawLotteryView:NO];
    [ServerProvider drawLotteryAction:self.m_currMessageVo.lotteryVo.strLotteryID result:^(ServerReturnInfo *retInfo) {
        [self isHideDrawLotteryView:YES];
        if (retInfo.bSuccess)
        {
            LotteryOptionVo *lotteryOptionVo = retInfo.data;
            [self.parentViewController initData];
            //移除抽奖视图
            [self isHideDrawLotteryView:YES];
            
            //
            if([lotteryOptionVo.strLotteryOptionID isEqualToString:@"-1"])
            {
                //没有抽中
                [Common tipAlert:@"很遗憾，您没有抽中！"];
            }
            else
            {
                [Common tipAlert:[NSString stringWithFormat:@"恭喜你抽中了：%@",lotteryOptionVo.strLotteryName]];
            }
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

//查看中奖人操作
-(void)doViewWinLotteryName:(UIButton*)sender
{
    LotteryOptionVo *lotteryOptionVo = [self.m_currMessageVo.lotteryVo.aryLotteryOption objectAtIndex:(sender.tag-10000)];
    lotteryOptionVo.bExpansion = !lotteryOptionVo.bExpansion;
    [self.parentViewController updateMsgListFrame];
}

-(void)isHideDrawLotteryView:(BOOL)bHide
{
    if (bHide)
    {
        [self.drawLotteryView removeFromSuperview];
        self.drawLotteryView = nil;
    }
    else
    {
        self.drawLotteryView = [[DrawLotteryView alloc]initWithFrame:CGRectMake(0, (kScreenHeight-320)/2, kScreenWidth, 320)];
        [self.parentViewController.view addSubview:self.drawLotteryView];
        [self.drawLotteryView drawLotteryAction];
    }
}

@end
