////
////  ChatListCell.m
////  Sloth
////
////  Created by 焱 孙 on 13-6-18.
////
////
//
//#import "ChatListCell.h"
//#import <QuartzCore/QuartzCore.h>
//#import "UIImage+Extras.h"
//#import "UIImageView+WebCache.h"
//#import "ChatCountDao.h"
//#import "ServerURL.h"
//#import "ChatListViewController.h"
//
//@implementation ChatListCell
//@synthesize imgViewHead;
//@synthesize lblName;
//@synthesize lblChatMsg;
//@synthesize lblDateTime;
//@synthesize m_chatObjectVo;
//@synthesize parentView;
//@synthesize imgViewUnseeNum;
//@synthesize lblUnseeNum;
//
//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
//{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self) 
//    {
//        // Initialization code
//        self.imgViewHead = [[UIImageView alloc] initWithFrame:CGRectZero];
//        self.imgViewHead.userInteractionEnabled = YES;
//        [self.imgViewHead.layer setBorderWidth:1.0];
//        [self.imgViewHead.layer setCornerRadius:2];
//        imgViewHead.layer.borderColor = [[UIColor clearColor] CGColor];
//        [self.imgViewHead.layer setMasksToBounds:YES];
//        [self addSubview:imgViewHead];
//        
//        self.imgViewUnseeNum = [[UIImageView alloc] initWithFrame:CGRectZero];
//        self.imgViewUnseeNum.image = [UIImage imageNamed:@"chat_unsee_num"];
//        [self addSubview:imgViewUnseeNum];
//        
//        self.lblUnseeNum = [[UILabel alloc] initWithFrame:CGRectZero];
//        self.lblUnseeNum.backgroundColor = [UIColor clearColor];
//        self.lblUnseeNum.font = [UIFont systemFontOfSize:11];
//        self.lblUnseeNum.textAlignment = NSTextAlignmentCenter;
//        self.lblUnseeNum.textColor = [UIColor whiteColor];
//        [self addSubview:lblUnseeNum];
//        
//        self.lblName = [[UILabel alloc] initWithFrame:CGRectZero];
//        self.lblName.backgroundColor = [UIColor clearColor];
//        self.lblName.font = [UIFont boldSystemFontOfSize:16];
//        self.lblName.lineBreakMode = NSLineBreakByTruncatingTail;
//        self.lblName.textColor = COLOR(17,17,17,1);
//        [self addSubview:lblName];
//        
//        self.lblReplyMe = [[UILabel alloc] initWithFrame:CGRectZero];
//        self.lblReplyMe.backgroundColor = [UIColor clearColor];
//        self.lblReplyMe.font = [UIFont systemFontOfSize:14];
//        self.lblReplyMe.textAlignment = NSTextAlignmentCenter;
//        self.lblReplyMe.textColor = COLOR(183, 20, 20, 1.0);
//        self.lblReplyMe.text = [Common localStr:@"Chat_AT_Somebody" value:@"[有人@我]"];
//        [self addSubview:self.lblReplyMe];
//        
//        self.lblChatMsg = [[FaceLabel alloc] initWithFrame:CGRectZero andFont:[UIFont systemFontOfSize:14]];
//        self.lblChatMsg.backgroundColor = [UIColor clearColor];
//        self.lblChatMsg.font = [UIFont systemFontOfSize:14];
//        self.lblChatMsg.lineBreakMode = NSLineBreakByTruncatingTail;
//        self.lblChatMsg.textColor = COLOR(136,136,136,1);
//        self.lblChatMsg.numberOfLines = 1;
//        [self addSubview:lblChatMsg];
//        
//        self.lblDateTime = [[UILabel alloc] initWithFrame:CGRectZero];
//        self.lblDateTime.backgroundColor = [UIColor clearColor];
//        self.lblDateTime.font = [UIFont systemFontOfSize:13];
//        self.lblDateTime.textColor = COLOR(178,178,178,1);
//        self.lblDateTime.textAlignment = NSTextAlignmentRight;
//        [self addSubview:lblDateTime];
//        
//        self.imgViewReject = [[UIImageView alloc] initWithFrame:CGRectZero];
//        self.imgViewReject.image = [UIImage imageNamed:@"chatNotPush"];
//        [self addSubview:self.imgViewReject];
//    }
//    return self;
//}
//
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    [super setSelected:selected animated:animated];
//    // Configure the view for the selected state
//}
//
//-(void)initWithChatObjectVo:(ChatObjectVo*)chatObjectVo
//{
//    self.m_chatObjectVo = chatObjectVo;
//    //0.置顶，设置背景色
//    if (self.m_chatObjectVo.bTopMsg)
//    {
//        self.backgroundColor = COLOR(235, 244, 246, 1.0);
//    }
//    else
//    {
//        self.backgroundColor = [UIColor clearColor];
//    }
//    
//    //1.header img
//    self.imgViewHead.frame = CGRectMake(10,10,45,45);
//    NSString *phImageName = nil;
//    if (chatObjectVo.nType == 1)
//    {
//        phImageName = @"default_m";
//    }
//    else
//    {
//        phImageName = @"ph_group";
//    }
//    
//    UIImage *phImage =[UIImage imageNamed:phImageName];
//    __weak ChatListCell *weakSelf = self;
//    [self.imgViewHead setImageWithURL:[NSURL URLWithString:chatObjectVo.strIMGURL] placeholderImage:phImage options:0 success:^(UIImage *image) {
//        dispatch_async(dispatch_get_main_queue(),^{
//            if ([Common isImageValid:image])
//            {
//                weakSelf.imgViewHead.image = image;
//            }
//            else
//            {
//                weakSelf.imgViewHead.image = phImage;
//            }
//        });}failure:^(NSError *error) {}];
//    
//    //2.unsee num and name
//    self.lblName.frame = CGRectMake(10+45+10, 13, kScreenWidth-140, 17);
//    if (chatObjectVo.nType == 1)
//    {
//        //single chat
//        NSString *strKey = [NSString stringWithFormat:@"vest_%@",chatObjectVo.strVestID];
//        int nUnseenNum = [ChatCountDao getUnseenChatNumByKey:strKey];
//        if (nUnseenNum>0)
//        {
//            lblUnseeNum.text = (nUnseenNum>9)?@"N":[NSString stringWithFormat:@"%i",nUnseenNum];
//        }
//        else
//        {
//            lblUnseeNum.text = @"";
//        }
//        lblName.text = chatObjectVo.strCustomerNickName;
//    }
//    else
//    {
//        //group chat
//        NSString *strKey = [NSString stringWithFormat:@"group_%@",chatObjectVo.strGroupNodeID];
//        int nUnseenNum = [ChatCountDao getUnseenChatNumByKey:strKey];
//        if (nUnseenNum>0)
//        {
//            lblUnseeNum.text = (nUnseenNum>9)?@"N":[NSString stringWithFormat:@"%i",nUnseenNum];
//        }
//        else
//        {
//            lblUnseeNum.text = @"";
//        }
//        lblName.text = chatObjectVo.strGroupName;
//    }
//    
//    if (lblUnseeNum.text.length>0)
//    {
//        self.imgViewUnseeNum.frame = CGRectMake(10+45-18/2,self.imgViewHead.frame.origin.y-18/2,18,18);
//        self.lblUnseeNum.frame = CGRectMake(imgViewUnseeNum.frame.origin.x,imgViewUnseeNum.frame.origin.y-0.5,imgViewUnseeNum.frame.size.width,imgViewUnseeNum.frame.size.height);
//        self.lblUnseeNum.font = [UIFont systemFontOfSize:11];
//    }
//    else
//    {
//        lblUnseeNum.frame = CGRectZero;
//        imgViewUnseeNum.frame = CGRectZero;
//    }
//    
//    //3.chat msg
//    self.lblReplyMe.hidden = YES;
//    self.lblChatMsg.frame = CGRectMake(10+45+10, 38, kScreenWidth-80, 18);
//    NSString *strChatContent = nil;
//    if (chatObjectVo.nType == 1)
//    {
//        strChatContent = chatObjectVo.strLastChatCon;
//    }
//    else if (chatObjectVo.nType == 2 && chatObjectVo.strLastChatCon.length>0)
//    {
//        NSString *strKey = [NSString stringWithFormat:@"group_reply_%@",chatObjectVo.strGroupNodeID];
//        int nUnseenNum = [ChatCountDao getUnseenChatNumByKey:strKey];
//        if (nUnseenNum>0)
//        {
//            //[有人@我]
//            self.lblReplyMe.hidden = NO;
//            CGSize sizeAT = [Common getStringSize:self.lblReplyMe.text font:self.lblReplyMe.font bound:CGSizeMake(MAXFLOAT, 20) lineBreakMode:self.lblReplyMe.lineBreakMode];
//            self.lblReplyMe.frame = CGRectMake(10+45+8, 38, sizeAT.width, 15);
//            self.lblChatMsg.frame = CGRectMake(10+45+10+sizeAT.width, 38, kScreenWidth-80-sizeAT.width, 16);
//        }
//        
//        strChatContent = [NSString stringWithFormat:@"%@: %@",chatObjectVo.strNAME,chatObjectVo.strLastChatCon];
//    }
//    else
//    {
//        strChatContent = chatObjectVo.strLastChatCon;
//    }
//    [self.lblChatMsg calculateTextHeight:strChatContent andBound:CGSizeMake(self.lblChatMsg.frame.size.width, MAXFLOAT)];
//    lblChatMsg.text = strChatContent;
//    [self.lblChatMsg setNeedsDisplay];
//    
//    //4.chat datetime
//    self.lblDateTime.frame = CGRectMake(kScreenWidth-60-8, 11.5, 60, 14);
//    lblDateTime.text = [Common getChatTimeStr:chatObjectVo.strLastChatTime];
//    
//    //5.chat reject img
//    if (chatObjectVo.bReject)
//    {
//        self.imgViewReject.frame = CGRectMake(kScreenWidth-50, 25, 50, 38);
//    }
//    else
//    {
//        self.imgViewReject.frame = CGRectZero;
//    }
//}
//
//+ (CGFloat)calculateCellHeight
//{
//    return 65;
//}
//
////删除会话，聊天记录不删除
//-(void)doDelete
//{
//    if ([Common ask:[Common localStr:@"Chat_Delete" value:@"确认要删除该聊天？"]])
//    {
//        [self.parentView isHideActivity:NO];
//        dispatch_async(dispatch_get_global_queue(0,0),^{
//            //do thread work
//            ServerReturnInfo *retInfo = [ServerProvider deleteChatSingleSession:self.m_chatObjectVo];
//            if (retInfo.bSuccess)
//            {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.parentView.aryObject removeObject:self.m_chatObjectVo];
//                    [self.parentView.tableViewChatObject reloadData];
//                    [self.parentView isHideActivity:YES];
//                });
//            }
//            else
//            {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [Common tipAlert:retInfo.strErrorMsg];
//                    [self.parentView isHideActivity:YES];
//                });
//            }
//        });
//    }
//}
//
//@end
