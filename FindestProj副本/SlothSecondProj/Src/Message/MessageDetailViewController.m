//
//  MessageDetailViewController.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-19.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "MessageDetailViewController.h"
#import "Utils.h"
#import "MessageListView.h"
#import "MessageCurrentView.h"
#import "MainMessageListViewController.h"
#import "PublishMessageViewController.h"
#import "UserVo.h"
#import "UIImage+UIImageScale.h"
#import "UIViewExt.h"
#import "CommonNavigationController.h"

@interface MessageDetailViewController ()

@end

@implementation MessageDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initData];
    [self initView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.nWebViewHeight = 1;
    
    //middle view
    self.m_scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT-50)];
    self.m_scrollView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.m_scrollView.delegate = self;
    self.m_scrollView.autoresizingMask = NO;
    self.m_scrollView.clipsToBounds = YES;
    [self.view addSubview:self.m_scrollView];
    
    //bottom button
    //6. 底部按钮
    self.viewBottom = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight-50, kScreenWidth, 50)];
    self.viewBottom.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    [self.view addSubview:_viewBottom];
    
    self.imgViewTabLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 1.5)];
    self.imgViewTabLine.image = [[UIImage imageNamed:@"tab_line"]stretchableImageWithLeftCapWidth:10 topCapHeight:0];
    [self.viewBottom addSubview:self.imgViewTabLine];
    
    CGFloat fTabW = kScreenWidth/3;
    //星标
    self.btnStar = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnStar.frame = CGRectMake(0, 0, fTabW, 50);
    [self.btnStar setImage:[UIImage imageNamed:@"tab_star"] forState:UIControlStateNormal];
    [self.btnStar setImage:[UIImage imageNamed:@"tab_star_h"] forState:UIControlStateHighlighted];
    [self.btnStar addTarget:self action:@selector(clickBottomBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewBottom addSubview:self.btnStar];
    
    UIView *viewSeparate = [[UIView alloc]initWithFrame:CGRectMake(self.btnStar.right, 15, 0.5, 20)];
    viewSeparate.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [self.viewBottom addSubview:viewSeparate];
    
    //转发或回复
    self.btnForward = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnForward.frame = CGRectMake(fTabW, 0, fTabW, 50);
    [self.btnForward setImage:[UIImage imageNamed:@"tab_reply_forward"] forState:UIControlStateNormal];
    [_btnForward addTarget:self action:@selector(clickBottomBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewBottom addSubview:_btnForward];
    
    viewSeparate = [[UIView alloc]initWithFrame:CGRectMake(self.btnForward.right, 15, 0.5, 20)];
    viewSeparate.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [self.viewBottom addSubview:viewSeparate];
    
    //删除
    self.btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnDelete.frame = CGRectMake(fTabW*2, 0, kScreenWidth-fTabW*2, 50);
    [self.btnDelete setImage:[UIImage imageNamed:@"tab_delete"] forState:UIControlStateNormal];
    [_btnDelete addTarget:self action:@selector(clickBottomBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewBottom addSubview:_btnDelete];
}

- (void)initData
{
    //title
    [self setTopNavBarTitle:self.m_currMessageVo.strTitle];
    
    self.aryMsgListView = [NSMutableArray array];
    self.arySessionMsgList = [NSMutableArray array];
    
    if([self.m_currMessageVo.strMsgType isEqualToString:@"N"])
    {
        //通知隐藏bottom
        self.btnStar.hidden = YES;
        self.btnForward.hidden = YES;
        self.btnDelete.hidden = YES;
        self.btnMore.hidden = YES;
        self.m_scrollView.frame = CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT);
    }
    
    if ([self.m_currMessageVo.strMsgType isEqualToString:@"D"])
    {
        //草稿
        [self isHideActivity:NO];
        [ServerProvider getMessageDetailByID:self.m_currMessageVo.strID result:^(ServerReturnInfo *retInfo) {
            [self isHideActivity:YES];
            if (retInfo.bSuccess)
            {
                [self dataFinishedLoading:retInfo];
            }
            else
            {
                [Common tipAlert:retInfo.strErrorMsg];
            }
        }];
    }
    else if ([self.m_currMessageVo.strMsgType isEqualToString:@"N"])
    {
        //通知
        ServerReturnInfo *retInfoTop = [[ServerReturnInfo alloc]init];
        retInfoTop.bSuccess = YES;
        
        NSMutableArray *aryNoticeList = [NSMutableArray array];
        [aryNoticeList addObject:self.m_currMessageVo];
        retInfoTop.data = aryNoticeList;
        
        [self dataFinishedLoading:retInfoTop];
    }
    else
    {
        [self isHideActivity:NO];
        [ServerProvider getSessionMsgList:self.m_currMessageVo.strID andTitleID:self.m_currMessageVo.strTitleID result:^(ServerReturnInfo *retInfo) {
            [self isHideActivity:YES];
            if (retInfo.bSuccess)
            {
                [self dataFinishedLoading:retInfo];
            }
            else
            {
                [Common tipAlert:retInfo.strErrorMsg];
            }
        }];
    }
}

- (void)dataFinishedLoading:(ServerReturnInfo*)retInfoTop
{
    //设置为已读
    if (self.m_currMessageVo.nUnreader == 1 && self.parentView != nil)
    {
        self.m_currMessageVo.nUnreader = 0;
        [self.parentView.tableViewMsgList reloadData];
        //        //刷新消息数据未读数量
        //        NSInteger nNum = [NoticeNumView getMsgNum];
        //        if (nNum >0)
        //        {
        //            [NoticeNumView setMsgNum:(--nNum)];
        //        }
    }
    
    self.arySessionMsgList = retInfoTop.data;
    [self isHideActivity:YES];
    self.nWebViewHeight = 1;
    [self initMiddleView];
    
    if (self.m_currMessageVo.bHasStarTag)
    {
        //has star tag
        [_btnStar setImage:[UIImage imageNamed:@"tab_star_h"] forState:UIControlStateNormal];
    }
    else
    {
        [_btnStar setImage:[UIImage imageNamed:@"tab_star"] forState:UIControlStateNormal];
    }
    
    //该消息不存在或已被删除
    if (self.arySessionMsgList.count == 0)
    {
        self.btnStar.enabled = NO;
        self.btnForward.enabled = NO;
        self.btnDelete.enabled = NO;
        [Common tipAlert:@"该消息不存在或已被删除！"];
    }
    else
    {
        self.btnStar.enabled = YES;
        self.btnForward.enabled = YES;
        self.btnDelete.enabled = YES;
    }
}

- (void)doEdit
{
    
}

//消息底部按钮操作
-(void)clickBottomBtn:(UIButton*)sender
{
    if(sender == self.btnStar)
    {
        if (self.m_currMessageVo.bHasStarTag)
        {
            [ServerProvider removeTagFromMessage:self.m_currMessageVo.strID andTagsID:@"1" result:^(ServerReturnInfo *retInfo) {
                if (retInfo.bSuccess)
                {
                    [self tagActionFinished];
                }
                else
                {
                    [Common tipAlert:retInfo.strErrorMsg];
                }
            }];
        }
        else
        {
            [ServerProvider addTagToMessage:self.m_currMessageVo.strID andTagsID:@"1" result:^(ServerReturnInfo *retInfo) {
                if (retInfo.bSuccess)
                {
                    [self tagActionFinished];
                }
                else
                {
                    [Common tipAlert:retInfo.strErrorMsg];
                }
            }];
        }
    }
    else if (sender == self.btnForward)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"回复",@"转发",nil];
        actionSheet.tag = 1001;
        [actionSheet showInView:self.view];
    }
    else if (sender == self.btnDelete)
    {
        if ([Common ask:@"你确认要删除该消息？"])
        {
            [self isHideActivity:NO];
            [ServerProvider deleteMessage:self.m_currMessageVo.strID result:^(ServerReturnInfo *retInfo) {
                [self isHideActivity:YES];
                if (retInfo.bSuccess)
                {
                    if (self.parentView != nil)
                    {
                        [self.parentView refreshMsgListAfterDel:self.m_currMessageVo];
                    }
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else
                {
                    [Common tipAlert:retInfo.strErrorMsg];
                }
            }];
        }
    }
    else if (sender == self.btnMore)
    {
        
    }
}

- (void)tagActionFinished
{
    if (self.m_currMessageVo.bHasStarTag)
    {
        //remove star tag success
        [self.btnStar setImage:[UIImage imageNamed:@"tab_star"] forState:UIControlStateNormal];
        self.m_currMessageVo.bHasStarTag = NO;
    }
    else
    {
        //add star tag success
        [self.btnStar setImage:[UIImage imageNamed:@"tab_star_h"] forState:UIControlStateNormal];
        self.m_currMessageVo.bHasStarTag = YES;
    }
    
    //update star frame
    MessageCurrentView *messageCurrentView = (MessageCurrentView *)[self.viewMsgContainer viewWithTag:1000+[self.m_currMessageVo.strID intValue]];
    if (messageCurrentView != nil)
    {
        [messageCurrentView updateStarFrame];
    }
    
    [self showHudView];
}

-(void)actionSheet:(UIActionSheet*)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1001)
    {
        if (buttonIndex == 0)
        {
            //回复
            PublishMessageViewController *publishMessageViewController = [[PublishMessageViewController alloc]init];
            publishMessageViewController.m_preMessageVo = self.m_currMessageVo;
            publishMessageViewController.publishMessageFromType = PublishMessageReplyType;
            
            CommonNavigationController *navController = [[CommonNavigationController alloc] initWithRootViewController:publishMessageViewController];
            navController.navigationBarHidden = YES;
            [self presentViewController:navController animated:YES completion:nil];
        }
        else if (buttonIndex == 1)
        {
            //转发
            PublishMessageViewController *publishMessageViewController = [[PublishMessageViewController alloc]init];
            publishMessageViewController.m_preMessageVo = self.m_currMessageVo;
            publishMessageViewController.publishMessageFromType = PublishMessageForwardType;
            
            CommonNavigationController *navController = [[CommonNavigationController alloc] initWithRootViewController:publishMessageViewController];
            navController.navigationBarHidden = YES;
            [self presentViewController:navController animated:YES completion:nil];
        }
    }
}

//init middle view
-(void)initMiddleView
{
    if (self.viewMsgContainer != nil)
    {
        [self.viewMsgContainer removeFromSuperview];
    }
    self.viewMsgContainer = [[UIView alloc]init];
    
    CGFloat fHeight = 10.0;
    CGFloat fCurrentStartH = 10.0;
    for (int i=0; i<self.arySessionMsgList.count; i++)
    {
        MessageVo *messageVo = [self.arySessionMsgList objectAtIndex:i];
        
        if ([messageVo.strID isEqualToString:self.m_currMessageVo.strID])
        {
            //1.current view
            fCurrentStartH = fHeight-10;
            self.m_currMessageVo = messageVo;//session messgage vo 是比较详细的
            [self setTopNavBarTitle:self.m_currMessageVo.strTitle];
            fHeight += [self initMsgCurrentView:fHeight andMsgVo:messageVo];
        }
        else
        {
            //2.top or bottom msg
            fHeight += [self initMsgSingleView:fHeight andMsgVo:messageVo];
        }
    }
    
    self.viewMsgContainer.frame = CGRectMake(0, 0, kScreenWidth, fHeight);
    [self.m_scrollView addSubview:self.viewMsgContainer];
    fHeight += 260;
    [self.m_scrollView setContentSize:CGSizeMake(kScreenWidth, fHeight)];
    //设置scrollview 初始滚动到当前消息的顶部
    [self.m_scrollView setContentOffset:CGPointMake(0, fCurrentStartH) animated:YES];
    
    if (self.m_currMessageVo.bHasStarTag)
    {
        //has star tag
        [self.btnStar setImage:[UIImage imageNamed:@"tab_star_h"] forState:UIControlStateNormal];
    }
    else
    {
        [self.btnStar setImage:[UIImage imageNamed:@"tab_star"] forState:UIControlStateNormal];
    }
}

//init single msg list view
-(CGFloat)initMsgSingleView:(CGFloat)fTopHeight andMsgVo:(MessageVo*)messageVo
{
    MessageListView *messageListView = [[MessageListView alloc]initWithFrame:CGRectZero];
    messageListView.tag = 1000+[messageVo.strID intValue];
    messageListView.parentViewController = self;
    CGFloat fHeight = [messageListView initWithMessageVo:messageVo];
    
    messageListView.frame = CGRectMake(0, fTopHeight, kScreenWidth, fHeight);
    [self.viewMsgContainer addSubview:messageListView];
    
    fHeight += 10;//后面
    
    return fHeight;
}

//init current msg list view
-(CGFloat)initMsgCurrentView:(CGFloat)fTopHeight andMsgVo:(MessageVo*)messageVo
{
    MessageCurrentView *messageCurrentView = [[MessageCurrentView alloc]initWithFrame:CGRectZero];
    messageCurrentView.tag = 1000+[messageVo.strID intValue];
    messageCurrentView.parentViewController = self;
    CGFloat fHeight= [messageCurrentView initWithMessageVo:messageVo andStatus:NO];
    
    messageCurrentView.frame = CGRectMake(0, fTopHeight, kScreenWidth, fHeight);
    [self.viewMsgContainer addSubview:messageCurrentView];
    
    return fHeight+10;
}

//tap one message from msg list
-(void)tapOneMessage:(MessageVo*)messageVo
{
    self.m_currMessageVo = messageVo;
    self.nWebViewHeight = 1;
    [self initMiddleView];
}

//显示/隐藏收件人后，更改view的位置(webview 不重新加载)
-(void)updateMsgListFrame
{
    CGFloat fYOffset = 0.0;
    for (int i=0; i<self.arySessionMsgList.count; i++)
    {
        MessageVo *messageVo = [self.arySessionMsgList objectAtIndex:i];
        
        if ([messageVo.strID isEqualToString:self.m_currMessageVo.strID])
        {
            //1.current view
            MessageCurrentView *messageCurrentView = (MessageCurrentView *)[self.viewMsgContainer viewWithTag:1000+[messageVo.strID intValue]];
            CGRect rectOld = messageCurrentView.frame;
            CGFloat fNewHeight = [messageCurrentView initWithMessageVo:self.m_currMessageVo andStatus:YES];
            fYOffset = fNewHeight - rectOld.size.height;
            messageCurrentView.frame = CGRectMake(rectOld.origin.x, rectOld.origin.y, rectOld.size.width, rectOld.size.height+fYOffset);
        }
        else
        {
            NSInteger nMessageVoID = [messageVo.strID integerValue];
            NSInteger nCurrID = [self.m_currMessageVo.strID integerValue];
            if (nMessageVoID > nCurrID)
            {
                //2.bottom view(时间正序，错误会影响视图布局)
                MessageListView *messageListView = (MessageListView *)[self.viewMsgContainer viewWithTag:1000+[messageVo.strID intValue]];
                messageListView.center = CGPointMake(messageListView.center.x, messageListView.center.y+fYOffset);
            }
        }
    }
    
    self.viewMsgContainer.frame = CGRectMake(0, 0, kScreenWidth, self.viewMsgContainer.frame.size.height+fYOffset);
    [self.m_scrollView setContentSize:CGSizeMake(kScreenWidth, self.m_scrollView.contentSize.height+fYOffset)];
}

-(void)showHudView
{
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    self.hud.delegate = self;
    [self.view addSubview:self.hud];
    
    self.hud.mode = MBProgressHUDModeText;
    self.hud.labelText = self.m_currMessageVo.bHasStarTag ? @"成功添加星标" : @"成功取消星标";
    
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:0.8];
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    // Remove HUD from screen when the HUD was hidded
    [self.hud removeFromSuperview];
    self.hud = nil;
}

-(UIImage*)getStarImage:(BOOL)bHigh andStar:(BOOL)bStar
{
    UIImage *imgStar = nil;
    CGSize size = self.btnStar.frame.size;
    if (bHigh)
    {
        if (bStar)
        {
            imgStar = [[UIImage imageNamed:@"btn_msg_has_star_h"] getSubImage:CGRectMake((320-size.width*2)/2, 0, size.width*2, 100)];
        }
        else
        {
            imgStar = [[UIImage imageNamed:@"btn_msg_star_h"] getSubImage:CGRectMake((320-size.width*2)/2, 0, size.width*2, 100)];
        }
    }
    else
    {
        if (bStar)
        {
            imgStar = [[UIImage imageNamed:@"btn_msg_has_star"] getSubImage:CGRectMake((320-size.width*2)/2, 0, size.width*2, 100)];
        }
        else
        {
            imgStar = [[UIImage imageNamed:@"btn_msg_star"] getSubImage:CGRectMake((320-size.width*2)/2, 0, size.width*2, 100)];
        }
    }
    return imgStar;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.m_scrollView)
    {
        self.bScrolling = YES;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == self.m_scrollView)
    {
        __block MessageDetailViewController* bself = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
            bself.bScrolling = NO;
        });
    }
}

@end
