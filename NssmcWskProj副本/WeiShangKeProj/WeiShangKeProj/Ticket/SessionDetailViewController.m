//
//  SessionDetailViewController.m
//  WeiShangKeProj
//
//  Created by 焱 孙 on 5/18/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import "SessionDetailViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <QuartzCore/QuartzCore.h>
#import "Utils.h"
#import "ChatCountDao.h"
#import "ServerURL.h"
#import "ChatPostImageView.h"
#import "UIImage+UIImageScale.h"
#import "ResizeImage.h"
#import "SYTextAttachment.h"
#import "VoiceConverter.h"
#import "SessionDetailCell.h"
#import "CustomerDetailViewController.h"
#import "BusinessCommon.h"
#import "TicketListViewController.h"
#import "KxMenu.h"
#import "CustomTicketViewController.h"
#import "UIViewExt.h"

@interface SessionDetailViewController ()

@end

@implementation SessionDetailViewController
@synthesize m_chatObjectVo;
@synthesize aryChatCon;
@synthesize tableViewChat;
@synthesize faceToolBar;
@synthesize activity;
@synthesize m_sendChatVo;
@synthesize serverReturnInfo;
@synthesize bReturnRefresh;
@synthesize bFirstLoad;
@synthesize bRunningUpdate;

- (void)dealloc
{
    [self clearInformation];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:JPUSH_REFRESH_CHATCONTENT object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WS_RECEIVE_MSG object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CustomPasteNotify" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DoRefreshChatContentPage" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
}

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
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(doJPushRefreshChatlist:) name:JPUSH_REFRESH_CHATCONTENT object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveWebSocketPush:) name:WS_RECEIVE_MSG object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(doCustomPasteNotify) name:@"CustomPasteNotify" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(doRefreshChatContent:) name:@"DoRefreshChatContentPage" object:nil];
    
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    [self initCtrlLayout];
    [self initData];
    //采用延时执行
    [self performSelector:@selector(firstDelayLoadData) withObject:nil afterDelay:0.3f];
    
    bFirstLoad = YES;
    bRunningUpdate = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [AppDelegate getSlothAppDelegate].currentPageName = SessionContentPage;
    //hide keyboard
    [faceToolBar dismissKeyBoard];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //set appdelegate name
    [AppDelegate getSlothAppDelegate].currentPageName = OtherPage;
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initData
{
    self.bAudioPlaying = NO;
    self.bReturnRefresh = NO;
    self.bFirstLoad = YES;
    self.aryChatCon = [[NSMutableArray alloc]init];
    self.aryKefu = [[NSMutableArray alloc]init];
    self.aryReceiverAudioIcon = [[NSMutableArray alloc]init];
    self.arySenderAudioIcon = [[NSMutableArray alloc]init];
   
    self.m_sendChatVo = [[SendChatVo alloc]init];
    self.aryImageList = [[NSMutableArray alloc]init];
    self.aryImageURL = [[NSMutableArray alloc]init];
    self.nImageMaxIndex = 1000;
    self.strEndMessageID = @"";
    
    //初始化语音icon
    for (int i=0; i<4; i++)
    {
        UIImage *imgReceiver = [UIImage imageNamed:[NSString stringWithFormat:@"ReceiverVoiceNodePlaying00%i",i]];
        [self.aryReceiverAudioIcon addObject:imgReceiver];
        UIImage *imgSender = [UIImage imageNamed:[NSString stringWithFormat:@"SenderVoiceNodePlaying00%i",i]];
        [self.arySenderAudioIcon addObject:imgSender];
    }
    
    //清除 聊天数量为查看数目
    NSString *strKey = [NSString stringWithFormat:@"session_%@",m_chatObjectVo.strID];
    NSString *strStatusKey = [ChatCountDao getSessionKeyByStatus:m_chatObjectVo.nSessionStatus];
    if (strStatusKey != nil)
    {
        [ChatCountDao removeObjectByKey:strKey status:strStatusKey];
    }
    
    [self setLeftReturnButton];
}

- (void)initCtrlLayout
{
    self.view.backgroundColor = COLOR(241, 241, 241, 1.0);
    [self updateTitle];
    
    UITapGestureRecognizer *titleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showCustomerDetail)];
    titleGesture.numberOfTouchesRequired = 1;
    [self.scrollViewTitle addGestureRecognizer:titleGesture];
    
    //右边按钮
    UIButton *btnRight = [Utils buttonWithImageName:[UIImage imageNamed:@"nav_ticket"] frame:[Utils getNavRightBtnFrame:CGSizeMake(100,76)] target:self action:@selector(viewTicket:)];
    [self setRightBarButton:btnRight];
    
    //tableview
    CGRect rect = CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT-toolBarHeight);
    self.tableViewChat = [[UITableView alloc] initWithFrame:rect];
    tableViewChat.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableViewChat.dataSource = self;
    tableViewChat.delegate = self;
    tableViewChat.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableViewChat.backgroundColor = [UIColor clearColor];
    if (iOSPlatform>=7)
    {
        tableViewChat.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    [self.view addSubview:tableViewChat];
    
    UITapGestureRecognizer *gesTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doTouchTableView)];
    [tableViewChat addGestureRecognizer:gesTap];
    
    UISwipeGestureRecognizer *swipeTap = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(doTouchTableView)];
    swipeTap.direction = UISwipeGestureRecognizerDirectionRight|UISwipeGestureRecognizerDirectionLeft;
    [tableViewChat addGestureRecognizer:swipeTap];
    
    //添加刷新
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.tableViewChat addSubview:_refreshControl];
    [self.tableViewChat sendSubviewToBack:_refreshControl];
    
    //已结束的会话没有
    if (self.m_chatObjectVo.nSessionStatus != 4)
    {
        //FaceToolBar
        self.faceToolBar = [[FaceToolBar alloc]init:CGRectMake(0,0,kScreenWidth,kScreenHeight) superView:self.view];
        self.faceToolBar.delegateFaceToolBar=self;
        [faceToolBar dismissKeyBoard];
    }
    else
    {
        self.tableViewChat.frame = CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT);
    }
    
    //
    self.pickerKefu = [[CustomPicker alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 260) andDelegate:self];
    [self.view addSubview:self.pickerKefu];
}

- (void)loadDataTask
{
    if (bRunningUpdate)
    {
        //正在更新
        dispatch_async(dispatch_get_main_queue(),^{
            [self isHideActivity:YES];
        });
        return;
    }
    bRunningUpdate = YES;
    
    NSMutableArray *dataArray=nil;
    //单聊历史数据
    ServerReturnInfo *retInfo = [ServerProvider getSessionDetail:m_chatObjectVo.strCustomerID endMessageID:self.strEndMessageID];
    if (retInfo.bSuccess)
    {
        dataArray = (NSMutableArray *)retInfo.data;
        //pagenum ++
        if (dataArray!=nil && dataArray.count>0)
        {
            if (self.strEndMessageID.length == 0)
            {
                [self.aryChatCon removeAllObjects];
            }
            self.strEndMessageID = retInfo.data2;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self isHideActivity:YES];
        
        if (dataArray != nil && [dataArray count] > 0)
        {
            NSMutableArray *newArray = [NSMutableArray arrayWithArray:dataArray];
            [newArray addObjectsFromArray:aryChatCon];
            self.aryChatCon = newArray;
            
            //为了下拉加载更多而不至于跳到滚动控件的顶部
            CGFloat fContentH = self.tableViewChat.contentSize.height;
            if (fContentH > 0 )//当第一页则不用做处理
            {
                CGFloat fOffsetH = self.tableViewChat.contentSize.height-self.tableViewChat.contentOffset.y;
                [self.tableViewChat reloadData];
                [tableViewChat setContentOffset:CGPointMake(0,self.tableViewChat.contentSize.height-fOffsetH) animated:NO];
            }
            else
            {
                [self.tableViewChat reloadData];
            }
        }
        
        if (bFirstLoad)
        {
            float fHeight = self.tableViewChat.contentSize.height - self.tableViewChat.frame.size.height;
            if (fHeight > 0 && fHeight < self.tableViewChat.contentSize.height)
            {
                [tableViewChat setContentOffset:CGPointMake(0,fHeight) animated:NO];
            }
        }
        bRunningUpdate = NO;
    });
}

- (void)updateTitle
{
    if (self.m_chatObjectVo.nSessionStatus == 3)
    {
        [self setTopNavBarTitle:[NSString stringWithFormat:@"%@[会话已暂停]",m_chatObjectVo.strCustomerNickName]];
    }
    else
    {
        [self setTopNavBarTitle:m_chatObjectVo.strCustomerNickName];
    }
}

-(void)clickSessionAction
{
    if (self.m_chatObjectVo.nSessionStatus == 3)
    {
        //已经处于暂停会话
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil
                                                        otherButtonTitles:@"移交会话",@"发送评分",@"关闭会话",nil];
        
        [actionSheet  showInView:self.view];
    }
    else
    {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil
                                                        otherButtonTitles:@"移交会话",@"暂停会话",@"发送评分",@"关闭会话",nil];
        
        [actionSheet  showInView:self.view];
    }
}

//查看工单
-(void)viewTicket:(UIView *)sender
{
    NSMutableArray *aryMenuItem = [NSMutableArray array];
    
    KxMenuItem *menuItem =[KxMenuItem menuItem:@"基本工单" image:nil target:self action:@selector(pushMenuItem:)];
    [aryMenuItem addObject:menuItem];
    
    menuItem =[KxMenuItem menuItem:@"自定义工单" image:nil target:self action:@selector(pushMenuItem:)];
    [aryMenuItem addObject:menuItem];
    
    
    [KxMenu showMenuInView:self.view fromRect:CGRectMake(sender.left, sender.top-2, sender.width, sender.height) menuItems:aryMenuItem];
}

- (void)pushMenuItem:(KxMenuItem*)menuItem
{
//    if([menuItem.title isEqualToString:@"基本工单"])
//    {
//        TicketListViewController *ticketListViewController = [[TicketListViewController alloc]init];
//        ticketListViewController.ticketListType = TicketListCustomerType;
//        ticketListViewController.m_chatObjectVo = self.m_chatObjectVo;
//        [self.navigationController pushViewController:ticketListViewController animated:YES];
//    }
//    else if ([menuItem.title isEqualToString:@"自定义工单"])
//    {
//        CustomTicketViewController *customTicketViewController = [[CustomTicketViewController alloc]init];
//        NSString *strCustomTicketURL = [NSString stringWithFormat:@"%@%@",[ServerURL getCustomTicketURL],m_chatObjectVo.strCustomerID];
//        customTicketViewController.strURL = strCustomTicketURL;
//        [self.navigationController pushViewController:customTicketViewController animated:YES];
//    }
}

//显示客户详情
-(void)showCustomerDetail
{
    CustomerDetailViewController *customerDetailViewController = [[CustomerDetailViewController alloc]init];
    CustomerVo *customerVo = [[CustomerVo alloc]init];
    customerVo.strID = self.m_chatObjectVo.strCustomerID;
    customerDetailViewController.m_customerVo = customerVo;
    [self.navigationController pushViewController:customerDetailViewController animated:YES];
}

//返回上一菜单
- (void)backButtonClicked
{
    if(self.bReturnRefresh)
    {
        //刷新会话列表
        if(self.refreshSessionBlock != NULL)
        {
            self.refreshSessionBlock();
        }
    }
    
    [super backButtonClicked];
}

//转交会话
- (void)transferKefu
{
    [self isHideActivity:NO];
    dispatch_async(dispatch_get_global_queue(0,0),^{
        ServerReturnInfo *retInfo = [ServerProvider getAllOnLineKefu];
        if (retInfo.bSuccess)
        {
            self.aryKefu = retInfo.data;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self isHideActivity:YES];
                [self.pickerKefu.pickerView reloadAllComponents];
                [self setPickerHidden:self.pickerKefu andHide:NO];
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [Common tipAlert:retInfo.strErrorMsg];
                [self isHideActivity:YES];
            });
        }
    });
}

#pragma mark - Table view delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.aryChatCon count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //1.init cell
    NSUInteger row = [indexPath row];
    ChatContentVo *chatContentVo = [aryChatCon objectAtIndex:row];
    
    static NSString *identifier = @"SessionDetailCell";
    SessionDetailCell *cell = (SessionDetailCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[SessionDetailCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.topNavController = self;
    //设置上一条聊天时间（一分钟内的聊天不显示聊天时间）
    if (indexPath.row < 1)
    {
        cell.strLastChatTime = nil;
    }
    else
    {
        ChatContentVo *lastChat = [aryChatCon objectAtIndex:(indexPath.row-1)];
        cell.strLastChatTime = lastChat.strChatTime;
    }
    [cell initWithChatContent:chatContentVo];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //设置上一条聊天时间（一分钟内的聊天不显示聊天时间）
    NSString *strLastChatTime = nil;
    if (indexPath.row < 1)
    {
        strLastChatTime = nil;
    }
    else
    {
        ChatContentVo *lastChat = [aryChatCon objectAtIndex:(indexPath.row-1)];
        strLastChatTime = lastChat.strChatTime;
    }
    return [SessionDetailCell calculateCellHeight:[aryChatCon objectAtIndex:indexPath.row] andLastChatTime:strLastChatTime];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - FaceToolBarDelegate
//发送文本
-(void)sendTextAction:(NSAttributedString *)inputText
{
    //1.check chat content length
    if (inputText == nil || inputText.length==0)
    {
        return;
    }
    else
    {
        if (inputText.length>CHAT_CONTENT_LENGTH)
        {
            [Common tipAlert:[NSString stringWithFormat:[Common localStr:@"Chat_NoMore_Text" value:@"超过1000字限制，当前已输入%lu 个字"],(unsigned long)inputText.length]];
            return;
        }
    }
    
    //TextView表情解析
    if (iOSPlatform >= 7)
    {
        NSMutableAttributedString *strAttribute = [[NSMutableAttributedString alloc] initWithAttributedString:inputText];
        NSMutableArray *aryRange = [NSMutableArray array];
        NSRange effectiveRange = { 0, 0 };
        do {
            NSRange range = NSMakeRange (NSMaxRange(effectiveRange),[strAttribute length] - NSMaxRange(effectiveRange));
            NSDictionary *attributeDict = [strAttribute attributesAtIndex:range.location longestEffectiveRange:&effectiveRange inRange:range];
            SYTextAttachment *temp = (SYTextAttachment *)[attributeDict objectForKey:@"NSAttachment"];
            if (temp != nil)
            {
                [aryRange addObject:[NSValue valueWithRange:effectiveRange]];
            }
        } while (NSMaxRange(effectiveRange) < [strAttribute length]);
        
        for (long i=aryRange.count-1; i>=0; i--)
        {
            NSRange range;
            [[aryRange objectAtIndex:i] getValue:&range];
            NSDictionary *attributeDict = [strAttribute attributesAtIndex:range.location longestEffectiveRange:&effectiveRange inRange:range];
            SYTextAttachment *temp = (SYTextAttachment *)[attributeDict objectForKey:@"NSAttachment"];
            [strAttribute replaceCharactersInRange:range withAttributedString:[[NSAttributedString alloc] initWithString:temp.strFaceCHS]];
        }
        
        m_sendChatVo.strStreamContent = strAttribute.mutableString;
    }
    else
    {
        //iOS6
        m_sendChatVo.strStreamContent = inputText.string;
    }
    m_sendChatVo.nContentType = 0;
    
    [self sendChatContentToServerTask:nil];
}

//发送图片
-(void)sendImageAction
{
    m_sendChatVo.strStreamContent = @"";
    m_sendChatVo.nContentType = 1;
    
    [self sendChatContentToServerTask:nil];
}

//发送知识库(1:编辑、2:文本、3:富文本)
-(void)sendFAQ:(FAQVo*)faqVo result:(SendMessageResultBlock)resultBlock type:(NSInteger)nType
{
    if (nType == 1)
    {
        //编辑
        self.faceToolBar.textView.text = faqVo.strTextContent;
        [self.faceToolBar.textView becomeFirstResponder];
    }
    else if (nType == 2)
    {
        //文本
        m_sendChatVo.nContentType = 0;
        m_sendChatVo.strStreamContent = faqVo.strTextContent;
        
        [self sendChatContentToServerTask:resultBlock];
    }
    else if (nType == 3)
    {
        //富文本
        [self isHideActivity:NO];
        dispatch_async(dispatch_get_global_queue(0,0),^{
            ServerReturnInfo *retInfo = [ServerProvider sendRichFAQ:faqVo.strID customerID:self.m_chatObjectVo.strCustomerID
                                                          sessionID:self.m_chatObjectVo.strID orign:[NSString stringWithFormat:@"%li",(long)self.m_chatObjectVo.nLastChatFrom]];
            if(retInfo.bSuccess)
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    [self isHideActivity:YES];
                    
                    //将数据插入TableView
                    [self.aryChatCon addObject:retInfo.data];
                    [self.tableViewChat reloadData];
                    
                    //table view position
                    float fHeight = self.tableViewChat.contentSize.height - self.tableViewChat.frame.size.height;
                    if (fHeight > 0 && fHeight < self.tableViewChat.contentSize.height)
                    {
                        [UIView animateWithDuration:Time animations:^{
                            [tableViewChat setContentOffset:CGPointMake(0,fHeight) animated:YES];
                        }];
                    }
                    
                    if (resultBlock != nil)
                    {
                        //回调block
                        resultBlock(YES);
                    }
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    [self isHideActivity:NO];
                    [Common tipAlert:retInfo.strErrorMsg];
                    
                    if (resultBlock != nil)
                    {
                        //回调block
                        resultBlock(NO);
                    }
                });
            }
        });
    }
}

//知识库
-(void)clickFAQAction
{
    FAQListViewController *faqListViewController = [[FAQListViewController alloc]init];
    faqListViewController.sessionDetailViewController = self;
    [self.navigationController pushViewController:faqListViewController animated:YES];
}

- (void)sendChatContentToServerTask:(SendMessageResultBlock)sendMessageResultBlock
{
    [self isHideActivity:NO];
    dispatch_async(dispatch_get_global_queue(0,0),^{
        //发送消息内容
        m_sendChatVo.strSessionID = self.m_chatObjectVo.strID;//会话ID
        self.serverReturnInfo = [ServerProvider sendSessionMessage:m_sendChatVo];

        dispatch_async(dispatch_get_main_queue(),^{
            [self isHideActivity:YES];
            
            if (serverReturnInfo.bSuccess)
            {
                if (self.m_chatObjectVo.nSessionStatus == 3)
                {
                    self.m_chatObjectVo.nSessionStatus = 2;
                    self.bReturnRefresh = YES;
                    [self updateTitle];
                }
                //1.add one record and reload tableview
                ChatContentVo *chatContentVo = self.serverReturnInfo.data;//发送数据成功后服务器返回的数据
                bReturnRefresh = YES;
                
                //2.check img
                if (m_sendChatVo.nContentType == 1)
                {
                    //img
                }
                else if (m_sendChatVo.nContentType == 2)
                {
                    //file
                }
                else
                {
                    //text
                    chatContentVo.nContentType = 0;
                    chatContentVo.strContent = [Common replaceLineBreak:m_sendChatVo.strStreamContent];
                    
                    //clear text view
                    [faceToolBar.textView clearText];
                }
                
                [self.aryChatCon addObject:chatContentVo];
                
                [self.tableViewChat reloadData];
                
                //3.table view position
                float fHeight = self.tableViewChat.contentSize.height - self.tableViewChat.frame.size.height;
                if (fHeight > 0 && fHeight < self.tableViewChat.contentSize.height)
                {
                    [UIView animateWithDuration:Time animations:^{
                        [tableViewChat setContentOffset:CGPointMake(0,fHeight) animated:YES];
                    }];
                }
                
                //如果有错误提示则显示出来
                if (self.serverReturnInfo.strErrorMsg != nil && self.serverReturnInfo.strErrorMsg.length>0)
                {
                    [Common bubbleTip:self.serverReturnInfo.strErrorMsg andView:self.view];
                }
                
                if (sendMessageResultBlock != nil)
                {
                    //回调block
                    sendMessageResultBlock(YES);
                }
            }
            else
            {
                if (serverReturnInfo.strErrorMsg == nil || serverReturnInfo.strErrorMsg.length==0)
                {
                    serverReturnInfo.strErrorMsg = [Common localStr:@"Chat_Failed_Send" value:@"发送失败"];
                }
                [Common tipAlert:serverReturnInfo.strErrorMsg];
                
                if (sendMessageResultBlock != nil)
                {
                    //回调block
                    sendMessageResultBlock(NO);
                }
            }
        });
    });
}

-(void)toolBarYOffsetChange:(float)fYOffset
{
    [UIView animateWithDuration:Time animations:^{
        CGRect rect = CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, fYOffset-NAV_BAR_HEIGHT);
        self.tableViewChat.frame = rect;
        //tableview back to bottommost
        float fHeight = self.tableViewChat.contentSize.height - self.tableViewChat.frame.size.height;
        if (fHeight > 0 && fHeight < self.tableViewChat.contentSize.height)
        {
            [tableViewChat setContentOffset:CGPointMake(0,fHeight) animated:YES];
        }
    }];
}

-(void)refreshView:(UIRefreshControl *)refresh
{
    dispatch_async(dispatch_get_global_queue(0,0),^{
        self.bFirstLoad = NO;
        //do thread work
        [self loadDataTask];
        dispatch_async(dispatch_get_main_queue(),^{
            [refresh endRefreshing];
        });
    });
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 1001)
    {
        //关闭会话
        if (buttonIndex==1)
        {
            [self isHideActivity:NO];
            dispatch_async(dispatch_get_global_queue(0,0),^{
                ServerReturnInfo *retInfo = [ServerProvider closeSession:self.m_chatObjectVo.strID];
                if (retInfo.bSuccess)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.bReturnRefresh = YES;
                        [self isHideActivity:YES];
                        [self backButtonClicked];
                    });
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [Common tipAlert:retInfo.strErrorMsg];
                        [self isHideActivity:YES];
                    });
                }
            });
        }
    }
}

#pragma mark - UIActionSheetDelegate
-(void) actionSheet:(UIActionSheet*)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString *strTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if([strTitle isEqualToString:@"移交会话"])
    {
        //移交会话
        [self.faceToolBar dismissKeyBoard];
        [self transferKefu];
    }
    else if([strTitle isEqualToString:@"暂停会话"])
    {
        //暂停会话
        [self isHideActivity:NO];
        dispatch_async(dispatch_get_global_queue(0,0),^{
            ServerReturnInfo *retInfo = [ServerProvider suspendSession:self.m_chatObjectVo.strID];
            if (retInfo.bSuccess)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.m_chatObjectVo.nSessionStatus = 3;//已暂停
                    [Common bubbleTip:@"暂停会话成功" andView:self.view];
                    [self updateTitle];
                    self.bReturnRefresh = YES;
                    [self isHideActivity:YES];
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Common tipAlert:retInfo.strErrorMsg];
                    [self isHideActivity:YES];
                });
            }
        });
    }
    else if([strTitle isEqualToString:@"发送评分"])
    {
        //发送评分
        [self isHideActivity:NO];
        dispatch_async(dispatch_get_global_queue(0,0),^{
            ServerReturnInfo *retInfo = [ServerProvider sendScoreLink:self.m_chatObjectVo.strID];
            if (retInfo.bSuccess)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Common bubbleTip:@"发送评分成功" andView:self.view];
                    [self isHideActivity:YES];
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Common tipAlert:retInfo.strErrorMsg];
                    [self isHideActivity:YES];
                });
            }
        });
    }
    else if([strTitle isEqualToString:@"关闭会话"])
    {
        //关闭会话
        UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:nil message:@"你确定要关闭该会话？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
        alertView.tag = 1001;
        [alertView show];
    }
}

#pragma mark - scrollView delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    [self doTouchTableView];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo)
    {
        editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
        
        if (editedImage)
        {
            imageToSave = editedImage;
        }
        else
        {
            imageToSave = originalImage;
            
        }
        imageToSave = [Common rotateImage:imageToSave];
        
        // Save the new image (original or edited) to the Camera Roll
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
        {
            UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
        }
        
        //当图片尺寸过大，进行缩放处理
        CGSize sizeImage = CGSizeMake(imageToSave.size.width, imageToSave.size.height);
        if (sizeImage.width>IMAGE_MAX_SIZE && sizeImage.height>IMAGE_MAX_SIZE)
        {
            sizeImage = CGSizeMake(640, (640*sizeImage.height)/sizeImage.width);
        }
        imageToSave = [ResizeImage imageWithImage:imageToSave scaledToSize:sizeImage];
        
        //保存图片
        NSData *imageData = UIImageJPEGRepresentation(imageToSave, 0.5);
        NSString *imagePathDir = [[Utils getTempPath] stringByAppendingPathComponent:CHAT_TEMP_DIRECTORY];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL fileExists = [fileManager fileExistsAtPath:imagePathDir];
        if (!fileExists)
        {
            //create director
            [fileManager createDirectoryAtPath:imagePathDir withIntermediateDirectories:YES  attributes:nil error:nil];
        }
        
        //save file
        NSString *imagePath = [imagePathDir stringByAppendingPathComponent:[Common createImageNameByDateTime:@"jpg"]];
        [fileManager createFileAtPath:imagePath contents:imageData attributes:nil];
        
        //set send parameter
        m_sendChatVo.strFilePath = imagePath;
        [self sendImageAction];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)doTouchTableView
{
    [self.faceToolBar dismissKeyBoard];
}

//收到JPUSH推送消息
- (void)doJPushRefreshChatlist:(NSNotification*)notifaction
{
    NSDictionary *userInfo = (NSDictionary*)[notifaction object];
    bReturnRefresh = YES;
    if(userInfo)
    {
        if (m_chatObjectVo.nType == 1)
        {
            //当前为私聊
            NSString *strSessionID= nil;
            id tempID = [userInfo valueForKey:@"talkId"];
            if (tempID == nil && tempID == [NSNull null])
            {
                strSessionID = nil;
            }
            else
            {
                strSessionID = [tempID stringValue];
            }
            
            if (strSessionID !=nil && [m_chatObjectVo.strID isEqualToString:strSessionID])
            {
                //发给当前用户
                //a:清空提醒数目
                NSString *strKey = [NSString stringWithFormat:@"session_%@",strSessionID];
                NSString *strStatusKey = [ChatCountDao getSessionKeyByStatus:m_chatObjectVo.nSessionStatus];
                if (strStatusKey != nil)
                {
                    [ChatCountDao removeObjectByKey:strKey status:strStatusKey];
                }
            }
            else
            {
                //其他用户
                //a:返回按钮显示未查看条数
                [self setLeftReturnButton];
            }
        }
    }
}

//收到WebSocket推送
- (void)receiveWebSocketPush:(NSNotification*)notifaction
{
    ChatObjectVo *chatObjectVo = (ChatObjectVo*)[notifaction object];
    ChatContentVo *chatContentVo = chatObjectVo.chatContentVo;
    bReturnRefresh = YES;

    //当前为私聊
    if (chatContentVo !=nil && [m_chatObjectVo.strID isEqualToString:chatContentVo.strSessionID])
    {
        //发给当前用户
        //追加数据，刷新列表
        [self.aryChatCon addObject:chatContentVo];
        [self.tableViewChat reloadData];
        
        float fHeight = self.tableViewChat.contentSize.height - self.tableViewChat.frame.size.height;
        if (fHeight > 0 && fHeight < self.tableViewChat.contentSize.height)
        {
            [UIView animateWithDuration:Time animations:^{
                [tableViewChat setContentOffset:CGPointMake(0,fHeight) animated:YES];
            }];
        }
    }
    else
    {
        //其他用户或广播发来消息（返回按钮显示未查看条数）
        [self setLeftReturnButton];
    }
}

//设置返回按钮内容【消息(12)】
-(void)setLeftReturnButton
{
    //返回按钮
    NSInteger nSumNum = [ChatCountDao getAllSessionNum];
    NSString *strText;
    if (nSumNum>99)
    {
        strText = @"  消息(99+)";
    }
    else if(nSumNum>0)
    {
        strText = [NSString stringWithFormat:@"  消息(%li)",(long)nSumNum];
    }
    else
    {
        strText = @"  消息";
    }
    
    UIFont *font = [UIFont systemFontOfSize:16];
    CGSize size = [Common getStringSize:strText font:font bound:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByWordWrapping];
    float fWidth = size.width>48?(125+size.width-48+10):120;
    
    //set left button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = [Utils getNavLeftBtnFrame:CGSizeMake(fWidth,76)];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
    [button.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:16.0]];
    [button setBackgroundImage:[[UIImage imageNamed:@"nav_left_btn"] stretchableImageWithLeftCapWidth:40 topCapHeight:0] forState:UIControlStateNormal];
    [button setTitle:strText forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickReturnBtn) forControlEvents:UIControlEventTouchUpInside];
    [self setLeftBarButton:button];
    
    [self changeTitleFrameByBackBtn];
}

//返回上一界面
-(void)clickReturnBtn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clearInformation
{
    //tableViewChat delegate 设置为nil
    //原因是scrollView释放时，scrollView滑动的动画还未结束，会调用scrollViewDidScroll:(UIScrollView *)sender方法
    self.tableViewChat.delegate = nil;
    
    //clear chat image temp file
    NSString *imagePathDir = [[Utils getTempPath] stringByAppendingPathComponent:CHAT_TEMP_DIRECTORY];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:imagePathDir error:nil];
    
    NSMutableDictionary *dicNotify = [[NSMutableDictionary alloc]init];
    if(bReturnRefresh)
    {
        //refresh chat list
        [dicNotify setObject:@"fromServer" forKey:@"RefreshPara"];//发生数据变化，从新获取服务器数据
    }
    else
    {
        [dicNotify setValue:@"fromLocal" forKey:@"RefreshPara"];//清空未读数量，从新获取本地数据
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"DoRefreshChatList" object:dicNotify];
    
    //close search state
    [[NSNotificationCenter defaultCenter]postNotificationName:@"DoCancelSearch" object:nil];
}

- (void)firstDelayLoadData
{
    dispatch_async(dispatch_get_global_queue(0,0),^{
        //do thread work
        bFirstLoad = YES;
        [self loadDataTask];
        
//        //请求聊天图片数据,用于滑动显示多个
//        ServerReturnInfo *retInfo;
//        if(self.m_chatObjectVo.nType == 1)
//        {
//            //私聊
//            retInfo = [ServerProvider getSingleChatImageList:self.m_chatObjectVo.strVestID];
//        }
        
//        if (retInfo.data != nil)
//        {
//            [self.aryImageList addObjectsFromArray:retInfo.data];
//        }
//        if (retInfo.data2 != nil)
//        {
//            self.aryImageURL = retInfo.data2;
//        }
    });
}

- (void)doCustomPasteNotify
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *strText = pasteboard.string;
    UIImage *imgTemp = pasteboard.image;
    if (strText != nil)
    {
        //复制文字
        NSMutableString *strTemp = [NSMutableString stringWithString:self.faceToolBar.textView.text];
        self.faceToolBar.textView.text = [strTemp stringByAppendingString:strText];
    }
    else if (imgTemp != nil)
    {
//        //复制图片
//        CGRect rectBounds = [[UIScreen mainScreen] bounds];
//        ChatPostImageView *chatPostImageView = [[ChatPostImageView alloc]initWithFrame:CGRectMake(0, 0, rectBounds.size.width, rectBounds.size.height)];
//        chatPostImageView.chatContentViewController = self;
//        UIWindow *windowTemp = [[UIApplication sharedApplication].windows objectAtIndex:1];
//        [windowTemp addSubview:chatPostImageView];
    }
}

//post (paste image) operate
- (void)postPasteImageOperate
{
    //保存图片
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    UIImage *imgTemp = pasteboard.image;
    
    NSData *imageData = UIImageJPEGRepresentation(imgTemp, 1.0);
    NSString *imagePathDir = [[Utils getTempPath] stringByAppendingPathComponent:CHAT_TEMP_DIRECTORY];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:imagePathDir];
    if (!fileExists)
    {
        //create director
        [fileManager createDirectoryAtPath:imagePathDir withIntermediateDirectories:YES  attributes:nil error:nil];
    }
    
    //save file
    NSString *imagePath = [imagePathDir stringByAppendingPathComponent:[Common createImageNameByDateTime:@"jpg"]];
    [fileManager createFileAtPath:imagePath contents:imageData attributes:nil];
    
    //set send parameter
    m_sendChatVo.strFilePath = imagePath;
    [self sendImageAction];
}

-(void)doRefreshChatContent:(NSNotification*)notification
{
    NSMutableDictionary* dicNotify = [notification object];
    NSString *strValue = [dicNotify objectForKey:@"RefreshPara"];
    if ([strValue isEqualToString:@"refreshData"])
    {
        //重新刷新数据（清除聊天记录）
        self.strEndMessageID = @"";
        //请求失败，则手动清理数据
        [self.aryChatCon removeAllObjects];
        [self.tableViewChat reloadData];
    }
    else if ([strValue isEqualToString:@"refreshTitle"])
    {
        [self setTopNavBarTitle:[dicNotify objectForKey:@"Title"]];
    }
}

//显示隐藏选择控件
- (void)setPickerHidden:(UIView*)pickerViewCtrl andHide:(BOOL)hidden
{
    int nHeight = pickerViewCtrl.frame.size.height * (-1);
    CGAffineTransform transform = hidden ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0, nHeight);
    pickerViewCtrl.transform = transform;
    if (!hidden)
    {
        self.view.backgroundColor = [UIColor whiteColor];
        self.tableViewChat.frame = CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, (kScreenHeight-NAV_BAR_HEIGHT-CUSTOM_PICKER_H));
    }
    else
    {
        self.tableViewChat.frame = CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT-toolBarHeight);
    }
}

#pragma mark - CustomPickerDelegate
- (void)donePickerButtonClick:(CustomPicker*)pickerViewCtrl
{
    UserVo *userVo = self.aryKefu[pickerViewCtrl.getSelectedRowNum];
    [self setPickerHidden:pickerViewCtrl andHide:YES];
    if (pickerViewCtrl == self.pickerKefu)
    {
        //转交客服
        [self isHideActivity:NO];
        dispatch_async(dispatch_get_global_queue(0,0),^{
            //do thread work
            ServerReturnInfo *retInfo = [ServerProvider transferSession:self.m_chatObjectVo.strID kefu:userVo.strUserID];
            if (retInfo.bSuccess)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //转交成功，返回上一界面，并且刷新
                    [self isHideActivity:YES];
                    self.bReturnRefresh = YES;
                    UIWindow *windowTemp = [[UIApplication sharedApplication].windows objectAtIndex:1];
                    [Common bubbleTip:@"移交会话成功" andView:windowTemp];
                    [self backButtonClicked];
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self isHideActivity:YES];
                    [Common tipAlert:retInfo.strErrorMsg];
                });
            }
        });
    }
}

- (void)cancelPickerButtonClick:(CustomPicker*)pickerViewCtrl
{
    [self setPickerHidden:pickerViewCtrl andHide:YES];
}

#pragma mark Picker Data Source Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

//每个组件的行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger nRowNum = 0;
    if (pickerView == self.pickerKefu.pickerView)
    {
        nRowNum = self.aryKefu.count;
    }
    return nRowNum;
}

//绑定选取器上面的数据，主要是文本
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *strText = @"";
    if (pickerView == self.pickerKefu.pickerView)
    {
        UserVo *userVo = [self.aryKefu objectAtIndex:row];
        strText = userVo.strRealName;
    }
    return strText;
}

//处理音频播放操作
-(void)tackleAudioAction:(ChatContentVo*)chatContentVo andImgView:(UIImageView*)imgView
{
    imgView.image = nil;
    if (self.bAudioPlaying)
    {
        //结束音频播放
        [self stopAudioPlaying];
        
        if (self.chatContentVoAudio == chatContentVo)
        {
            //点击正在播放的语音则停止播放
            self.bAudioPlaying = NO;
            self.chatContentVoAudio.bAudioPlaying = NO;
            
            if (chatContentVo.nSenderType != 1)
            {
                //self
                imgView.image = [UIImage imageNamed:@"SenderVoiceNodePlaying"];
            }
            else
            {
                //other
                imgView.image = [UIImage imageNamed:@"ReceiverVoiceNodePlaying"];
            }
        }
        else
        {
            //点击其他语音,播放其他语音
            self.bAudioPlaying = YES;
            self.chatContentVoAudio.bAudioPlaying = NO;//停止之前的播放
            self.chatContentVoAudio = chatContentVo;
            self.chatContentVoAudio.bAudioPlaying = YES;//设置新的项进行播放
            if (chatContentVo.nSenderType != 1)
            {
                //self
                imgView.image = [UIImage animatedImageWithImages:self.arySenderAudioIcon duration:1.0];
            }
            else
            {
                //other
                imgView.image = [UIImage animatedImageWithImages:self.aryReceiverAudioIcon duration:1.0];
            }
            [self.tableViewChat reloadData];//刷新数据
            
            //开始播放音频
            [self startAudioPlaying:chatContentVo];
        }
    }
    else
    {
        //开始播放语音
        self.bAudioPlaying = YES;
        self.chatContentVoAudio = chatContentVo;
        self.chatContentVoAudio.bAudioPlaying = YES;
        if (chatContentVo.nSenderType != 1)
        {
            //self
            imgView.image = [UIImage animatedImageWithImages:self.arySenderAudioIcon duration:1.0];
        }
        else
        {
            //other
            imgView.image = [UIImage animatedImageWithImages:self.aryReceiverAudioIcon duration:1.0];
        }
        
        //开始播放音频
        [self startAudioPlaying:chatContentVo];
    }
}

//开始播放音频
-(void)startAudioPlaying:(ChatContentVo*)chatContentVo
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //默认情况下扬声器播放
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    
    //获取文件(不限定amr)
    NSString *strAudioPath = [NSString stringWithFormat:@"%@/%@",[Utils getSloth2AudioPath],[chatContentVo.strChatURL lastPathComponent]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:strAudioPath];
    if(!fileExists)
    {
        //文件不存在，则下载
        NSData *dataAudio = [NSData dataWithContentsOfURL:[NSURL URLWithString:chatContentVo.strChatURL]];
        //写入文件
        if(dataAudio != nil)
        {
            [dataAudio writeToFile:strAudioPath atomically:YES];
        }
        else
        {
            [self stopAudioPlaying];
            return;
        }
    }
    
    NSString *strExtension = [strAudioPath pathExtension];
    if ([strExtension isEqualToString:@"amr"])
    {
        //amr to wav 的转码处理
        strAudioPath = [VoiceConverter amrToWav:strAudioPath];
    }
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:[NSData dataWithContentsOfFile:strAudioPath] error:nil];
    [self.audioPlayer setVolume:1];
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer setDelegate:self];
    [self.audioPlayer play];
    
    //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
}

//结束播放音频
-(void)stopAudioPlaying
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
    
    self.bAudioPlaying = NO;
    [self.audioPlayer stop];
    self.audioPlayer = nil;
    
    if (self.chatContentVoAudio != nil)
    {
        self.chatContentVoAudio.bAudioPlaying = NO;
        [self.tableViewChat reloadData];
    }
}

//切换听筒和扬声器
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
        //Device is close to user
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
    }
    else
    {
        //Device is not close to user
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [Common bubbleTip:@"已从听筒切换回扬声器播放" andView:self.view];
    }
}

#pragma mark - AVAudioPlayerDelegate
//播放结束时执行的动作
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self stopAudioPlaying];
}

//解码错误执行的动作
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error;
{
    [self stopAudioPlaying];
}

//处理中断的代码
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player;
{
    [self stopAudioPlaying];
}

@end
