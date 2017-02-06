//
//  ChatListCell.m
//  Sloth
//
//  Created by 焱 孙 on 13-6-18.
//
//

#import "ChatListCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Extras.h"
#import "UIImageView+WebCache.h"
#import "ChatCountDao.h"
#import "ServerURL.h"
#import "ChatListViewController.h"
#import "UIViewExt.h"

@implementation ChatListCell
@synthesize imgViewHead;
@synthesize lblName;
@synthesize lblChatMsg;
@synthesize lblDateTime;
@synthesize m_chatObjectVo;
@synthesize parentView;
@synthesize imgViewUnseeNum;
@synthesize lblUnseeNum;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
        // Initialization code
        self.imgViewHead = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imgViewHead.userInteractionEnabled = YES;
        [self.imgViewHead.layer setBorderWidth:0];
        [self.imgViewHead.layer setCornerRadius:5];
        imgViewHead.layer.borderColor = [[UIColor clearColor] CGColor];
        [self.imgViewHead.layer setMasksToBounds:YES];
        [self addSubview:imgViewHead];
        
        self.imgViewUnseeNum = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imgViewUnseeNum.image = [UIImage imageNamed:@"chat_unsee_num"];
        [self addSubview:imgViewUnseeNum];
        
        self.lblUnseeNum = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblUnseeNum.backgroundColor = [UIColor clearColor];
        self.lblUnseeNum.font = [UIFont systemFontOfSize:11];
        self.lblUnseeNum.textAlignment = NSTextAlignmentCenter;
        self.lblUnseeNum.textColor = [UIColor whiteColor];
        [self addSubview:lblUnseeNum];
        
        self.lblName = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblName.backgroundColor = [UIColor clearColor];
        self.lblName.font = [Common fontWithName:@"PingFangSC-Medium" size:14];
        self.lblName.lineBreakMode = NSLineBreakByTruncatingTail;
        self.lblName.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
        [self addSubview:lblName];
        
        self.lblChatMsg = [[FaceLabel alloc] initWithFrame:CGRectZero andFont:[UIFont systemFontOfSize:14]];
        self.lblChatMsg.bShowGIF = NO;
        self.lblChatMsg.backgroundColor = [UIColor clearColor];
        self.lblChatMsg.textColor = [SkinManage colorNamed:@"Share_Content_Color"];
        self.lblChatMsg.numberOfLines = 1;
        self.lblChatMsg.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:lblChatMsg];
        
        self.lblDateTime = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblDateTime.backgroundColor = [UIColor clearColor];
        self.lblDateTime.font = [UIFont systemFontOfSize:12];
        self.lblDateTime.textColor = [SkinManage colorNamed:@"Notify_Date_Color"];
        self.lblDateTime.textAlignment = NSTextAlignmentRight;
        [self addSubview:lblDateTime];
        
        self.imgViewReject = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imgViewReject.image = [UIImage imageNamed:@"chatNotPush"];
        [self addSubview:self.imgViewReject];
        
        self.viewSeperate = [[UIView alloc]init];
        self.viewSeperate.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
        [self addSubview:self.viewSeperate];
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
    //0.置顶，设置背景色
    if (self.m_chatObjectVo.bTopMsg)
    {
        self.backgroundColor = [SkinManage colorNamed:@"Chat_bg_list"];
    }
    else
    {
        self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    }
    
    //1.header img
    self.imgViewHead.frame = CGRectMake(12,12,44,44);
    NSString *phImageName = @"default_m";
    
    UIImage *phImage =[UIImage imageNamed:phImageName];
    __weak ChatListCell *weakSelf = self;
    [self.imgViewHead sd_setImageWithURL:[NSURL URLWithString:chatObjectVo.strIMGURL] placeholderImage:phImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if ([Common isImageValid:image])
        {
            weakSelf.imgViewHead.image = image;
        }
        else
        {
            weakSelf.imgViewHead.image = phImage;
        }
    }];
    
    //2.unsee num and name
    self.lblName.frame = CGRectMake(self.imgViewHead.right+10, 12, kScreenWidth-140, 20);
    if (chatObjectVo.nType == 1)
    {
        //single chat
        NSString *strKey = [NSString stringWithFormat:@"vest_%@",chatObjectVo.strVestID];
        int nUnseenNum = [ChatCountDao getUnseenChatNumByKey:strKey];
        if (nUnseenNum>0)
        {
            lblUnseeNum.text = (nUnseenNum>9)?@"N":[NSString stringWithFormat:@"%i",nUnseenNum];
        }
        else
        {
            lblUnseeNum.text = @"";
        }
        lblName.text = chatObjectVo.strNAME;
    }
    else
    {
        //group chat
        NSString *strKey = [NSString stringWithFormat:@"group_%@",chatObjectVo.strGroupNodeID];
        int nUnseenNum = [ChatCountDao getUnseenChatNumByKey:strKey];
        if (nUnseenNum>0)
        {
            lblUnseeNum.text = (nUnseenNum>9)?@"N":[NSString stringWithFormat:@"%i",nUnseenNum];
        }
        else
        {
            lblUnseeNum.text = @"";
        }
        lblName.text = chatObjectVo.strGroupName;
    }
    
    if (lblUnseeNum.text.length>0)
    {
        self.imgViewUnseeNum.frame = CGRectMake(10+45-18/2,self.imgViewHead.frame.origin.y-18/2,18,18);
        self.lblUnseeNum.frame = CGRectMake(imgViewUnseeNum.frame.origin.x,imgViewUnseeNum.frame.origin.y-0.5,imgViewUnseeNum.frame.size.width,imgViewUnseeNum.frame.size.height);
        self.lblUnseeNum.font = [UIFont systemFontOfSize:11];
    }
    else
    {
        lblUnseeNum.frame = CGRectZero;
        imgViewUnseeNum.frame = CGRectZero;
    }
    
    //3.chat msg
    self.lblChatMsg.frame = CGRectMake(self.imgViewHead.right+10, self.lblName.bottom+5, kScreenWidth-80, 20);
    NSString *strChatContent = nil;
    if (chatObjectVo.nType == 1)
    {
        strChatContent = chatObjectVo.strLastChatCon;
    }
    else if (chatObjectVo.nType == 2 && chatObjectVo.strLastChatCon.length>0)
    {
        strChatContent = [NSString stringWithFormat:@"%@: %@",chatObjectVo.strNAME,chatObjectVo.strLastChatCon];
    }
    else
    {
        strChatContent = chatObjectVo.strLastChatCon;
    }
    [self.lblChatMsg calculateTextHeight:strChatContent andBound:CGSizeMake(kScreenWidth-80, MAXFLOAT)];
    lblChatMsg.text = strChatContent;
    [self.lblChatMsg setNeedsDisplay];
    
    //4.chat datetime
    self.lblDateTime.frame = CGRectMake(kScreenWidth-80-8, 12, 80, 17);
    lblDateTime.text = [Common getChatTimeStr:chatObjectVo.strLastChatTime];
    
    //5.chat reject img
    if (chatObjectVo.bReject)
    {
        self.imgViewReject.frame = CGRectMake(kScreenWidth-50, 25, 50, 38);
    }
    else
    {
        self.imgViewReject.frame = CGRectZero;
    }
    
    //seperate line
    self.viewSeperate.frame = CGRectMake(12, 67.5, kScreenWidth-10, 0.5);
}

+ (CGFloat)calculateCellHeight
{
    return 68;
}

//删除会话，聊天记录不删除
-(void)doDelete
{
    if ([Common ask:@"确认要删除该聊天？"])
    {
        [Common showProgressView:nil view:self.parentView.view modal:NO];
        [ServerProvider deleteChatSingleSession:self.m_chatObjectVo result:^(ServerReturnInfo *retInfo) {
            [Common hideProgressView:self.parentView.view];
            if (retInfo.bSuccess)
            {
                [self.parentView.aryObject removeObject:self.m_chatObjectVo];
                [self.parentView.tableViewChat reloadData];
            }
            else
            {
                [Common tipAlert:retInfo.strErrorMsg];
            }
        }];
    }
}

@end
