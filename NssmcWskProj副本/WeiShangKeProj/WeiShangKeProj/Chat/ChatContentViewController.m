//
//  ChatContentViewController.m
//  Sloth
//
//  Created by 焱 孙 on 13-6-18.
//
//m_chatObjectVo

#import "ChatContentViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <QuartzCore/QuartzCore.h>
#import "Utils.h"
#import "ChatCountDao.h"
#import "ServerURL.h"
#import "ChatPostImageView.h"
#import "UIImage+UIImageScale.h"
#import "ResizeImage.h"
#import "ChatInfoViewController.h"
#import "SYTextAttachment.h"
#import "VoiceConverter.h"

@interface ChatContentViewController ()

@end

@implementation ChatContentViewController
@synthesize m_chatObjectVo;
@synthesize aryChatCon;
@synthesize tableViewChat;
@synthesize faceToolBar;
@synthesize photoController;
@synthesize photoAlbumController;
@synthesize activity;
@synthesize m_sendChatVo;
@synthesize serverReturnInfo;
@synthesize imgHeadSelf; 
@synthesize imgHeadOther;
@synthesize bReturnRefresh;
@synthesize bFirstLoad;
@synthesize bRunningUpdate;

- (void)dealloc
{
    [self clearInformation];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:JPUSH_REFRESH_CHATCONTENT object:nil];
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
    
    //没有被踢出讨论组或群
    if (!self.m_chatObjectVo.bReject)
    {
        //右边按钮（聊天信息）
        if (self.m_chatObjectVo.nType == 1)
        {
            //私聊
            UIButton *btnRight = [Utils buttonWithImageName:[UIImage imageNamed:@"chat_single_info"] frame:[Utils getNavRightBtnFrame:CGSizeMake(86,66)] target:self action:@selector(getChatInfo)];
            [self setRightBarButton:btnRight];
        }
        else
        {
            //群聊
            UIButton *btnRight = [Utils buttonWithImageName:[UIImage imageNamed:@"chat_group_info"] frame:[Utils getNavRightBtnFrame:CGSizeMake(86,66)] target:self action:@selector(getChatInfo)];
            [self setRightBarButton:btnRight];
        }
    }
    else
    {
        UIButton *btnRight = [Utils buttonWithImageName:[UIImage imageNamed:@"chatNotPush"] frame:[Utils getNavRightBtnFrame:CGSizeMake(100,76)] target:self action:@selector(getChatInfo)];
        [self setRightBarButton:btnRight];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(doJPushRefreshChatlist:) name:JPUSH_REFRESH_CHATCONTENT object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(doCustomPasteNotify) name:@"CustomPasteNotify" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(doRefreshChatContent:) name:@"DoRefreshChatContentPage" object:nil];
    //注册接近传感器的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:) name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
    
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
    [AppDelegate getSlothAppDelegate].currentPageName = ChatContentPage;
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
    self.bRefreshATList = NO;
    self.bAudioPlaying = NO;
    self.bReturnRefresh = NO;
    self.bFirstLoad = YES;
    self.aryChatCon = [[NSMutableArray alloc]init];
    self.aryReceiverAudioIcon = [[NSMutableArray alloc]init];
    self.arySenderAudioIcon = [[NSMutableArray alloc]init];
    self.m_sendChatVo = [[SendChatVo alloc]init];
    self.aryImageList = [[NSMutableArray alloc]init];
    self.aryImageURL = [[NSMutableArray alloc]init];
    self.aryReplyUser = [[NSMutableArray alloc]init];
    self.nImageMaxIndex = 1000;
    self.m_endMessageID = @"";
    
    //初始化语音icon
    for (int i=0; i<4; i++)
    {
        UIImage *imgReceiver = [UIImage imageNamed:[NSString stringWithFormat:@"ReceiverVoiceNodePlaying00%i",i]];
        [self.aryReceiverAudioIcon addObject:imgReceiver];
        UIImage *imgSender = [UIImage imageNamed:[NSString stringWithFormat:@"SenderVoiceNodePlaying00%i",i]];
        [self.arySenderAudioIcon addObject:imgSender];
    }
    
    //set basic value
    self.m_sendChatVo.nSendType = m_chatObjectVo.nType;
    self.m_sendChatVo.strOtherVestID = m_chatObjectVo.strVestID;
    self.m_sendChatVo.strOtherVestNodeID = m_chatObjectVo.strVestNodeID;
    self.m_sendChatVo.strTeamID = m_chatObjectVo.strGroupID;
    self.m_sendChatVo.strTeamNodeID = m_chatObjectVo.strGroupNodeID;
    
    self.nQueryDateTime = 0;
    self.nChatPageNum = 1;
    
    //head image
    dispatch_async(dispatch_get_global_queue(0,0),^{
        NSURL *urlSelf = [NSURL URLWithString:[Common getCurrentUserVo].strHeadImageURL];
        UIImage *imgTemp = [UIImage imageWithData:[NSData dataWithContentsOfURL:urlSelf]];
        dispatch_async(dispatch_get_main_queue(),^{
            self.imgHeadSelf = imgTemp;
        });
    });
    
    //other image
    dispatch_async(dispatch_get_global_queue(0,0),^{
        NSURL *urlOther = [NSURL URLWithString:m_chatObjectVo.strIMGURL];
        UIImage *imgTemp = [UIImage imageWithData:[NSData dataWithContentsOfURL:urlOther]];
        dispatch_async(dispatch_get_main_queue(),^{
            self.imgHeadOther = imgTemp;
        });
    });
    
    //清除 聊天数量为查看数目
    if(m_chatObjectVo.nType == 1)
    {
        //私聊
        NSString *strKey = [NSString stringWithFormat:@"vest_%@",m_chatObjectVo.strVestID];
        [ChatCountDao removeObjectByKey:strKey];
    }
    else
    {
        //群聊
        NSString *strKey = [NSString stringWithFormat:@"group_%@",m_chatObjectVo.strGroupNodeID];
        [ChatCountDao removeObjectByKey:strKey];
        
        //清除@标志
        NSString *strReplyKey = [NSString stringWithFormat:@"group_reply_%@",m_chatObjectVo.strGroupNodeID];
        [ChatCountDao removeObjectByKey:strReplyKey];
    }
    //更新主tab下面的聊天数量
    [[NSNotificationCenter defaultCenter]postNotificationName:@"UpdateChatUnreadAllNum" object:nil];
    
    [self setLeftReturnButton];
}

- (void)initCtrlLayout
{
    self.view.backgroundColor = COLOR(241, 241, 241, 1.0);
    if (m_chatObjectVo.nType == 1)
    {
        //私聊
        [self setTopNavBarTitle:m_chatObjectVo.strNAME];
    }
    else
    {
        //群聊
        [self setTopNavBarTitle:m_chatObjectVo.strGroupName];
    }
    
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
    
    //FaceToolBar
    self.faceToolBar = [[FaceToolBar alloc]init:CGRectMake(0,0,kScreenWidth,kScreenHeight) superView:self.view];
    self.faceToolBar.delegateFaceToolBar=self;
    [faceToolBar dismissKeyBoard];
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
    if(m_chatObjectVo.nType == 1)
    {
        //单聊历史数据
        ServerReturnInfo *retInfo = [ServerProvider getSingleHistoryChatList:self.m_chatObjectVo.strID endMessageID:self.m_endMessageID];
        if (retInfo.bSuccess)
        {
            dataArray = (NSMutableArray *)retInfo.data;
            //pagenum ++
            if (dataArray!=nil && dataArray.count>0)
            {
                if (self.nChatPageNum == 1)
                {
                    //init data
                    [self.aryChatCon removeAllObjects];
                    self.m_endMessageID = retInfo.data2;
                }
                self.nChatPageNum ++;
            }
        }
    }
    else
    {
        //群聊历史数据
        ServerReturnInfo *retInfo = [ServerProvider getGroupHistoryChatList:self.m_chatObjectVo andStartDateTime:self.nQueryDateTime andPageNum:self.nChatPageNum];
        if (retInfo.bSuccess)
        {
            dataArray = (NSMutableArray *)retInfo.data;
            
            //pagenum ++
            if (dataArray!=nil && dataArray.count>0)
            {
                if (self.nChatPageNum == 1)
                {
                    //init data
                    [self.aryChatCon removeAllObjects];
                    self.nQueryDateTime = [retInfo.data2 longLongValue];
                }
                self.nChatPageNum ++;
            }
        }
    }
        
    dispatch_async(dispatch_get_main_queue(), ^{
        if (dataArray != nil && [dataArray count] > 0)
        {
            NSMutableArray *newArray = [NSMutableArray arrayWithArray:dataArray];
            [newArray addObjectsFromArray:aryChatCon];
            self.aryChatCon = newArray;
            [self.tableViewChat reloadData];
        }
        [self isHideActivity:YES];
        
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

//在聊天详细页面，生成讨论组，开始新的聊天
-(void)startNewChat:(ChatObjectVo*)chatObjectVo
{
    self.m_chatObjectVo = chatObjectVo;
    
    //set basic value
    self.m_sendChatVo.nSendType = m_chatObjectVo.nType;
    self.m_sendChatVo.strOtherVestID = m_chatObjectVo.strVestID;
    self.m_sendChatVo.strOtherVestNodeID = m_chatObjectVo.strVestNodeID;
    self.m_sendChatVo.strTeamID = m_chatObjectVo.strGroupID;
    self.m_sendChatVo.strTeamNodeID = m_chatObjectVo.strGroupNodeID;
    
    self.nQueryDateTime = 0;
    self.nChatPageNum = 1;
    bFirstLoad = YES;
    
    //clear old data
    [self.aryChatCon removeAllObjects];
    [self.tableViewChat reloadData];
    
    [self.aryImageList removeAllObjects];
    [self.aryImageURL removeAllObjects];
    
    [self.aryReplyUser removeAllObjects];
    
    //群聊
    [self setTopNavBarTitle:m_chatObjectVo.strGroupName];
    
    UIButton *btnRight = [Utils buttonWithImageName:[UIImage imageNamed:@"chat_group_info"] frame:[Utils getNavRightBtnFrame:CGSizeMake(86,66)] target:self action:@selector(getChatInfo)];
    [self setRightBarButton:btnRight];
    
    [self loadDataTask];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.aryChatCon count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //1.init cell
    NSUInteger row = [indexPath row];
    ChatContentVo *chatContentVo = [aryChatCon objectAtIndex:row];
    
    static NSString *identifier = @"groupCell";
    ChatContentCell *cell = (ChatContentCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) 
    {
        cell = [[ChatContentCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.imgHeadSelf = self.imgHeadSelf;
        cell.imgHeadOther = self.imgHeadOther;
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

#pragma mark - Table view delegate
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
    return [ChatContentCell calculateCellHeight:[aryChatCon objectAtIndex:indexPath.row] andLastChatTime:strLastChatTime];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - FaceToolBarDelegate
//发送文本
-(void)sendTextAction:(NSAttributedString *)inputText
{
    if (self.m_chatObjectVo.bReject)
    {
        [Common tipAlert:[Common localStr:@"Chat_CanNot_Send" value:@"您已不在该聊天组，不能发信息"]];
    }
    else
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
        
        if (m_sendChatVo.nSendType == 2)
        {
            //判断是否存在该@的人
            for (NSInteger i=self.aryReplyUser.count-1; i>=0; i--)
            {
                UserVo *userVo = self.aryReplyUser[i];
                NSString *strReplyUser = [NSString stringWithFormat:@"@%@ ",userVo.strUserName];
                NSRange range = [m_sendChatVo.strStreamContent rangeOfString:strReplyUser options:NSCaseInsensitiveSearch];
                if (range.length == 0)
                {
                    [self.aryReplyUser removeObjectAtIndex:i];
                }
            }
            m_sendChatVo.aryReplyUser = self.aryReplyUser;
        }
        
        [self isHideActivity:NO];
        dispatch_async(dispatch_get_global_queue(0,0),^{
            //do thread work
            [self sendChatContentToServerTask];
        });
    }
}

//发送图片
-(void)sendImageAction
{
    if (self.m_chatObjectVo.bReject)
    {
        [Common tipAlert:[Common localStr:@"Chat_CanNot_Send" value:@"您已不在该聊天组，不能发信息"]];
    }
    else
    {
        m_sendChatVo.strStreamContent = @"";
        m_sendChatVo.nContentType = 1;
        
        [self isHideActivity:NO];
        dispatch_async(dispatch_get_global_queue(0,0),^{
            //do thread work
            [self sendChatContentToServerTask];
        });
    }
}

//发送语音
-(void)sendAudioAction:(NSString *)strFilePath andDuration:(NSString *)strDuration
{
    if (self.m_chatObjectVo.bReject)
    {
        [Common tipAlert:[Common localStr:@"Chat_CanNot_Send" value:@"您已不在该聊天组，不能发信息"]];
    }
    else
    {
        m_sendChatVo.strStreamContent = strDuration;
        m_sendChatVo.nContentType = 3;
        m_sendChatVo.strFilePath = strFilePath;
        
        [self isHideActivity:NO];
        dispatch_async(dispatch_get_global_queue(0,0),^{
            //do thread work
            [self sendChatContentToServerTask];
        });
    }
}

//@回复别人的操作
-(void)replyUserAction
{
    if(self.m_chatObjectVo.nType == 2)
    {
        //只有群聊才会有@操作
        if (self.replyUserViewController == nil)
        {
            self.replyUserViewController = [[ReplyUserViewController alloc]init];
            self.replyUserViewController.delegate = self;
            self.replyUserViewController.chatObjectVo = self.m_chatObjectVo;
        }
        else
        {
            //是否刷新@列表，当有加入和减人推送操作
            if (self.bRefreshATList)
            {
                [self.replyUserViewController refreshData];
            }
        }
        self.bRefreshATList = NO;
        [self.navigationController pushViewController:self.replyUserViewController animated:YES];
    }
}
//删除空格操作，用来判断是否删除@人操作
-(BOOL)deleteBlankSpace
{
    BOOL bRes = NO;
    //判断是否存在该@的人
    for (NSInteger i=self.aryReplyUser.count-1; i>=0; i--)
    {
        UserVo *userVo = self.aryReplyUser[i];
        NSString *strReplyUser = [NSString stringWithFormat:@"@%@ ",userVo.strUserName];
        
        NSMutableAttributedString *strText = [[NSMutableAttributedString alloc]initWithAttributedString:self.faceToolBar.textView.attributedString];
        NSRange range = NSMakeRange(strText.length-strReplyUser.length, strReplyUser.length);
        NSAttributedString *attributedSubStr = [strText attributedSubstringFromRange:range];
        if ([attributedSubStr.string isEqualToString:strReplyUser])
        {
            [strText deleteCharactersInRange:range];
            self.faceToolBar.textView.attributedString = strText;
            [self.aryReplyUser removeObjectAtIndex:i];
            bRes = YES;
            break;
        }
    }
    return bRes;
}

- (void)sendChatContentToServerTask
{
    //check group chat or single chat
    if (m_sendChatVo.nSendType == 1)
    {
        //私聊
        self.serverReturnInfo = [ServerProvider sendSingleChat:m_sendChatVo];
    }
    else
    {
        //群聊
        self.serverReturnInfo = [ServerProvider sendGroupChat:m_sendChatVo];
    }
    
    dispatch_async(dispatch_get_main_queue(),^{
        [self isHideActivity:YES];
        if (serverReturnInfo.bSuccess)
        {
            //1.add one record and reload tableview
            ChatContentVo *contentVoReturn = self.serverReturnInfo.data;//发送数据成功后服务器返回的数据
            
            bReturnRefresh = YES;
            ChatContentVo *chatContentVo = [[ChatContentVo alloc]init];
            chatContentVo.strCId = contentVoReturn.strCId;
            
            if (m_sendChatVo.nSendType == 1)
            {
                chatContentVo.nChatType = 1;
            }
            else
            {
                chatContentVo.nChatType = 2;
            }
            
            //2.check img
            if (m_sendChatVo.nContentType == 1)
            {
                //img
                chatContentVo.nContentType = 1;
                chatContentVo.strImgURL = m_sendChatVo.strFilePath;
                chatContentVo.nImageIndex = -1;
                chatContentVo.nImgSource = 1;
                
                //方便聊天图片的滑动显示多个
                [self.aryImageList addObject:contentVoReturn];
                NSURL *urlMax = [NSURL URLWithString:contentVoReturn.strImgURL];
                if (urlMax != nil)
                {
                    NSArray *ary = @[urlMax,urlMax];
                    [self.aryImageURL addObject:ary];
                }
            }
            else if (m_sendChatVo.nContentType == 2)
            {
                //file
            }
            else if (m_sendChatVo.nContentType == 3)
            {
                //audio
                chatContentVo.nContentType = 3;
                chatContentVo.strContent = m_sendChatVo.strStreamContent;//语音时间
                chatContentVo.strFileID = contentVoReturn.strFileID;//fileID
                chatContentVo.strFilePath = [[Utils getSloth2AudioPath]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.amr",chatContentVo.strFileID]];
                //从临时目录复制到音频目录
                [Utils copyFile:m_sendChatVo.strFilePath toPath:chatContentVo.strFilePath];
            }
            else
            {
                //text
                chatContentVo.nContentType = 0;
                chatContentVo.strContent = [Common replaceLineBreak:m_sendChatVo.strStreamContent];
                
                //clear text view
                [faceToolBar.textView clearText];
            }
            
            chatContentVo.strVestId = [Common getCurrentUserVo].strUserID;
            chatContentVo.strHeadImg = @"";
            chatContentVo.strChatTime = [Common getCurrentDateTime];
            chatContentVo.strName = [Common getCurrentUserVo].strUserName;
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
        }
        else
        {
            if (serverReturnInfo.strErrorMsg == nil || serverReturnInfo.strErrorMsg.length==0)
            {
                serverReturnInfo.strErrorMsg = [Common localStr:@"Chat_Failed_Send" value:@"发送失败"];
            }
            [Common tipAlert:serverReturnInfo.strErrorMsg];
        }
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

- (void)clickMoreBtnAction:(UIButton*)btnSender
{
    if (btnSender.tag == 5001)
    {
        //picture
        self.photoAlbumController = [[UIImagePickerController alloc] init];
        photoAlbumController.delegate = self;
        photoAlbumController.mediaTypes = [NSArray arrayWithObjects:@"public.image",@"public.movie", nil];
        photoAlbumController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        photoAlbumController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        photoAlbumController.allowsEditing = NO;
        [photoAlbumController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        
        [self presentViewController:photoAlbumController animated:YES completion:nil];
    }
    else if (btnSender.tag == 5002)
    {
        //camera
        
        //判断隐私中相机是否启用
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus != AVAuthorizationStatusAuthorized && authStatus != AVAuthorizationStatusNotDetermined)
        {
            [Common tipAlert:[NSString stringWithFormat:[Common localStr:@"Common_Private_Camera" value:@"请在iPhone的“设置-隐私-相机”选项中，允许 %@ 访问你的相机。"],[Common getAppName]]];
            return;
        }
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) 
        {
            return;
        }
        
        self.photoController = [[UIImagePickerController alloc] init];
        photoController.delegate = self;
        photoController.mediaTypes = [[NSArray alloc]initWithObjects:(NSString*)kUTTypeImage,nil];
        photoController.sourceType = UIImagePickerControllerSourceTypeCamera;
        photoController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        photoController.allowsEditing = NO;
        [photoController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        
        [self presentViewController:photoController animated:YES  completion: nil];
    }
}

- (void)doTouchTableView
{
    [self.faceToolBar dismissKeyBoard];
}

//收到推送消息
- (void)doJPushRefreshChatlist:(NSNotification*)notifaction
{
    NSDictionary *userInfo = (NSDictionary*)[notifaction object];
    NSDictionary *dicAPS = [userInfo valueForKey:@"aps"];
    //发送者名字放在聊天内容里面，用冒号隔开
    NSString *content = [Common replaceLineBreak:[dicAPS valueForKey:@"alert"]];
    NSString *strChatContent = nil;     //聊天内容
    NSString *strSender = nil;          //发送者
    NSRange range = [content rangeOfString:@":" options:NSCaseInsensitiveSearch];
    if (range.length>0)
    {
        strSender = [content substringToIndex:range.location];
        if(content.length>(range.location+1))
        {
            strChatContent = [content substringFromIndex:range.location+1];
        }
    }
    else
    {
        //not find
        strChatContent = content;
    }
    bReturnRefresh = YES;
    
    //是否有@功能
    NSString *strReplyCon = [userInfo valueForKey:@"con"];
    if (strReplyCon != nil)
    {
        strChatContent = strReplyCon;
    }
    
    if(userInfo)
    {
        int nNotifyType = -1;
        id objType = [userInfo valueForKey:@"type"];
        if (objType != nil && objType != [NSNull null])
        {
            nNotifyType = [objType intValue];
        }
        
        if (nNotifyType == 0 || nNotifyType == 5)
        {
            if (m_chatObjectVo.nType == 1)
            {
                //当前为私聊
                NSString *strVestID = nil;
                id tempID = [userInfo valueForKey:@"uid"];
                if (tempID == nil && tempID == [NSNull null])
                {
                    strVestID = nil;
                }
                else
                {
                    strVestID = [tempID stringValue];
                }
                
                if (strVestID !=nil && [m_chatObjectVo.strVestID isEqualToString:strVestID])
                {
                    //发给当前用户
                    //a:清空提醒数目
                    NSString *strKey = [NSString stringWithFormat:@"vest_%@",strVestID];
                    [ChatCountDao removeObjectByKey:strKey];
                    
                    //b:增加记录条数
                    ChatContentVo *tempVo = [[ChatContentVo alloc]init];
                    tempVo.strCId = [NSString stringWithFormat:@"%li",(long)self.nImageMaxIndex++];
                    tempVo.nImageIndex = -1;//图片的位置
                    tempVo.strVestId = strVestID;
                    tempVo.strName = m_chatObjectVo.strNAME;
                    tempVo.strHeadImg = m_chatObjectVo.strIMGURL;
                    tempVo.strChatTime = [Common getCurrentDateTime];
                    tempVo.strContent = strChatContent;
                    tempVo.nChatType = 1;
                    
                    //附件类型(0纯文本 1图片 2文件 3语音 4有人加入群聊 5@某人)
                    id ct = [userInfo valueForKey:@"ct"];
                    if (ct == nil || ct == [NSNull null])
                    {
                        tempVo.nContentType = 0;
                    }
                    else
                    {
                        tempVo.nContentType = [ct intValue];
                        tempVo.strFileName = [Common checkStrValue:[userInfo valueForKey:@"fn"]];
                    }
                    
                    NSString *strFilePath = [Common checkStrValue:[userInfo valueForKey:@"path"]];
                    if (tempVo.nContentType == 1)
                    {
                        //图片,追加前缀
                        tempVo.strImgURL = [ServerURL getWholeURL:strFilePath];
                        tempVo.strSmallImgURL = tempVo.strImgURL;
                        
                        //方便聊天图片的滑动显示多个
                        ChatContentVo *contentVoImage = [[ChatContentVo alloc]init];
                        contentVoImage.strCId = tempVo.strCId;
                        contentVoImage.strImgURL = tempVo.strImgURL;
                        [self.aryImageList addObject:contentVoImage];
                        
                        NSURL *urlMax = [NSURL URLWithString:tempVo.strImgURL];
                        if (urlMax != nil)
                        {
                            NSArray *ary = @[urlMax,urlMax];
                            [self.aryImageURL addObject:ary];
                        }
                    }
                    else if(tempVo.nContentType == 2)
                    {
                        //文件,追加前缀
                        tempVo.strFileURL = [ServerURL getWholeURL:strFilePath];
                    }
                    else if(tempVo.nContentType == 3)
                    {
                        //语音,追加前缀
                        tempVo.strFileURL = [ServerURL getWholeURL:strFilePath];
                        tempVo.strFileID = [Common checkStrValue:[userInfo valueForKey:@"fid"]];
                        tempVo.strContent = [Common checkStrValue:[userInfo valueForKey:@"t"]];//语音时间
                    }
                    
                    //c:判断是否是长文本，若是长文本则通过HTTP到服务器重新请求
                    id longTextId = [userInfo valueForKey:@"id"];
                    if (longTextId == nil || longTextId == [NSNull null])
                    {
                        [self.aryChatCon addObject:tempVo];
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
                        //长文本
                        tempVo.strCId = [longTextId stringValue];
                        [self loadLongTextChatContent:tempVo];
                    }
                }
                else
                {
                    //其他用户或群聊
                    //a:返回按钮显示未查看条数
                    [self setLeftReturnButton];
                }
            }
            else
            {
                //群聊
                NSString *strGroupNodeID=nil;
                id tempID = [userInfo valueForKey:@"team"];
                if (tempID == nil && tempID == [NSNull null])
                {
                    strGroupNodeID = nil;
                }
                else
                {
                    strGroupNodeID = tempID;
                }
                
                if (strGroupNodeID != nil && [m_chatObjectVo.strGroupNodeID isEqualToString:strGroupNodeID] && nNotifyType == 5)
                {
                    //发给当前群聊
                    //a:清空提醒数目
                    NSString *strKey = [NSString stringWithFormat:@"group_%@",strGroupNodeID];
                    [ChatCountDao removeObjectByKey:strKey];

                    //清除@标志
                    NSString *strReplyKey = [NSString stringWithFormat:@"group_reply_%@",strGroupNodeID];
                    [ChatCountDao removeObjectByKey:strReplyKey];
                    
                    //b:增加记录条数
                    ChatContentVo *tempVo = [[ChatContentVo alloc]init];
                    tempVo.strCId = [NSString stringWithFormat:@"%li",(long)self.nImageMaxIndex++];
                    tempVo.nImageIndex = -1;//图片的位置
                    tempVo.strGroupId = strGroupNodeID;
                    id tempID = [userInfo valueForKey:@"uid"];
                    if ([tempID isKindOfClass:[NSString class]])
                    {
                        tempVo.strVestId = tempID;
                    }
                    else
                    {
                        tempVo.strVestId = [tempID stringValue];
                    }
                    
                    GroupAndUserDao *tempDao = [[GroupAndUserDao alloc]init];
                    ChatObjectVo *tempChatObjectVo = [tempDao getUserInfoByUserID:tempVo.strVestId];
                    if (tempChatObjectVo)
                    {
                        tempVo.strName = tempChatObjectVo.strNAME;
                        tempVo.strHeadImg = tempChatObjectVo.strIMGURL;
                    }
                    else
                    {
                        tempVo.strName = strSender;
                        tempVo.strHeadImg = nil;
                    }
                    
                    tempVo.strChatTime = [Common getCurrentDateTime];
                    tempVo.strContent = strChatContent;
                    tempVo.nChatType = 2;
                    
                    //附件类型((0纯文本 1图片 2文件 3语音 4有人加入群聊 5@某人))
                    id ct = [userInfo valueForKey:@"ct"];
                    if (ct == nil || ct == [NSNull null] || [ct integerValue] == 0)
                    {
                        tempVo.nContentType = 0;
                    }
                    else
                    {
                        tempVo.nContentType = [ct intValue];
                        tempVo.strFileName = [Common checkStrValue:[userInfo valueForKey:@"fn"]];
                    }
                    
                    //当前群聊中是发给自己的，则屏蔽掉(除了类别为4，通知信息)
                    if ([tempVo.strVestId isEqualToString:[Common getCurrentUserVo].strUserID] && tempVo.nContentType != 4)
                    {
                        return;
                    }
                    
                    NSString *strFilePath = [Common checkStrValue:[userInfo valueForKey:@"path"]];
                    if (tempVo.nContentType == 1)
                    {
                        //图片,追加前缀
                        tempVo.strImgURL = [ServerURL getWholeURL:strFilePath];
                        tempVo.strSmallImgURL = tempVo.strImgURL;
                        
                        //方便聊天图片的滑动显示多个
                        ChatContentVo *contentVoImage = [[ChatContentVo alloc]init];
                        contentVoImage.strCId = tempVo.strCId;
                        contentVoImage.strImgURL = tempVo.strImgURL;
                        [self.aryImageList addObject:contentVoImage];
                        
                        NSURL *urlMax = [NSURL URLWithString:tempVo.strImgURL];
                        if (urlMax != nil)
                        {
                            NSArray *ary = @[urlMax,urlMax];
                            [self.aryImageURL addObject:ary];
                        }
                    }
                    else if(tempVo.nContentType == 2)
                    {
                        //文件,追加前缀
                        tempVo.strFileURL = [ServerURL getWholeURL:strFilePath];
                    }
                    else if(tempVo.nContentType == 3)
                    {
                        //语音,追加前缀
                        tempVo.strFileURL = [ServerURL getWholeURL:strFilePath];
                        tempVo.strFileID = [Common checkStrValue:[userInfo valueForKey:@"fid"]];
                        tempVo.strContent = [Common checkStrValue:[userInfo valueForKey:@"t"]];//语音时间
                    }
                    else if(tempVo.nContentType == 4)
                    {
                        self.bRefreshATList = YES;
                    }
                    
                    //c:判断是否是长文本，若是长文本则通过HTTP到服务器重新请求
                    id longTextId = [userInfo valueForKey:@"id"];
                    if (longTextId == nil || longTextId == [NSNull null])
                    {
                        [self.aryChatCon addObject:tempVo];
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
                        //长文本
                        tempVo.strCId = [longTextId stringValue];
                        [self loadLongTextChatContent:tempVo];
                    }
                }
                else
                {
                    //其他用户或群聊
                    //a:返回按钮显示未查看条数
                    [self setLeftReturnButton];
                }
            }
        }
    }
}

//加载长文本即时聊天
- (void)loadLongTextChatContent:(ChatContentVo*)tempVo
{
    dispatch_async(dispatch_get_global_queue(0,0),^{
		//do thread work
        ServerReturnInfo *retInfo = nil;
        if (tempVo.nChatType == 1)
        {
            //私聊
            retInfo = [ServerProvider getChatContentByCId:tempVo.strCId];
        }
        else if(tempVo.nChatType == 2)
        {
            //群聊
            retInfo = [ServerProvider getGroupChatContentByCId:tempVo.strCId];
        }
        
        if (retInfo.bSuccess)
        {
            ChatContentVo *chatConVo = retInfo.data;
            tempVo.strContent = (NSString*)chatConVo.strContent;
        
            dispatch_async(dispatch_get_main_queue(),^{
                //do main thread work
                [self.aryChatCon addObject:tempVo];
                [self.tableViewChat reloadData];
                
                float fHeight = self.tableViewChat.contentSize.height - self.tableViewChat.frame.size.height;
                if (fHeight > 0 && fHeight < self.tableViewChat.contentSize.height)
                {
                    [UIView animateWithDuration:Time animations:^{
                        [tableViewChat setContentOffset:CGPointMake(0,fHeight) animated:YES];
                    }];
                }
            });
        }
	});
}

//设置返回按钮内容【消息(12)】 
-(void)setLeftReturnButton
{
    //返回按钮
    int nSumNum = [ChatCountDao getUnseenChatSumNum];
    NSString *strText;
    if (nSumNum>99)
    {
        strText = [NSString stringWithFormat:@"%@(99+)",[Common localStr:@"Common_NAV_Chat" value:@"消息"]];
    }
    else if(nSumNum>0)
    {
        strText = [NSString stringWithFormat:@"%@(%i)",[Common localStr:@"Common_NAV_Chat" value:@"消息"],nSumNum];
    }
    else
    {
        strText = [Common localStr:@"Common_NAV_Chat" value:@"消息"];
    }

    UIFont *font = [UIFont systemFontOfSize:15];
    CGSize size = [strText sizeWithFont:font];
    float fWidth = size.width>48?(125+size.width-48+10):120;

    UIButton *backItem = [Utils leftButtonWithTitle:strText frame:[Utils getNavLeftBtnFrame:CGSizeMake(fWidth,76)] target:self action:@selector(clickReturnBtn)];
    [self setLeftBarButton:backItem];
    
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
    
    //clear 音频 object
    if (self.audioPlayer != nil)
    {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    }
    
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

//2.转发（快速发表界面）
- (void)writeButtonClicked:(NSString*)strContent andImage:(UIImage*)imgTransfer
{ 
    //首先进入群组选择
//    ChooseGroupViewController *chooseGroupViewController = [[ChooseGroupViewController alloc] init];
//    chooseGroupViewController.topViewController = self;
//    chooseGroupViewController.chooseGroupDelegate = FastPublicType;
//    chooseGroupViewController.strPublicContent = strContent;
//    chooseGroupViewController.imgTransfer = imgTransfer;
//    [self.navigationController pushViewController:chooseGroupViewController animated:YES];
//    [chooseGroupViewController createTokenFieldView];
//    [chooseGroupViewController release];
}

- (void)firstDelayLoadData
{
    dispatch_async(dispatch_get_global_queue(0,0),^{
    	//do thread work
        bFirstLoad = YES;
        [self loadDataTask];
        
        //请求聊天图片数据,用于滑动显示多个
        ServerReturnInfo *retInfo;
        if(self.m_chatObjectVo.nType == 1)
        {
            //私聊
            //retInfo = [ServerProvider getSingleChatImageList:self.m_chatObjectVo.strVestID];
        }
        else
        {
            //群聊
            retInfo = [ServerProvider getGroupChatImageList:self.m_chatObjectVo];
        }
        
        if (retInfo.data != nil)
        {
            [self.aryImageList addObjectsFromArray:retInfo.data];
        }
        if (retInfo.data2 != nil)
        {
            self.aryImageURL = retInfo.data2;
        }
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
        //复制图片
        CGRect rectBounds = [[UIScreen mainScreen] bounds];
        ChatPostImageView *chatPostImageView = [[ChatPostImageView alloc]initWithFrame:CGRectMake(0, 0, rectBounds.size.width, rectBounds.size.height)];
        chatPostImageView.chatContentViewController = self;
        UIWindow *windowTemp = [[UIApplication sharedApplication].windows objectAtIndex:1];
        [windowTemp addSubview:chatPostImageView];
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

//获取聊天信息
- (void)getChatInfo
{
    if (m_chatObjectVo.bReject)
    {
        [Common tipAlert:[Common localStr:@"Chat_Not_InGroup" value:@"您已不在该聊天组"]];
    }
    else
    {
        [self.faceToolBar.textView resignFirstResponder];
        
        ChatInfoViewController *chatInfoViewController = [[ChatInfoViewController alloc]init];
        chatInfoViewController.m_parentController = self;
        chatInfoViewController.m_chatObjectVo = self.m_chatObjectVo;
        [self.navigationController pushViewController:chatInfoViewController animated:YES];
    }
}

-(void)doRefreshChatContent:(NSNotification*)notification
{
    NSMutableDictionary* dicNotify = [notification object];
    NSString *strValue = [dicNotify objectForKey:@"RefreshPara"];
    if ([strValue isEqualToString:@"refreshData"])
    {
        //重新刷新数据（清除聊天记录）
        self.nChatPageNum = 1;
        //请求失败，则手动清理数据
        [self.aryChatCon removeAllObjects];
        [self.tableViewChat reloadData];
    }
    else if ([strValue isEqualToString:@"refreshTitle"])
    {
        [self setTopNavBarTitle:[dicNotify objectForKey:@"Title"]];
    }
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
            
            if ([chatContentVo.strVestId isEqualToString:[Common getCurrentUserVo].strUserID])
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
            if ([chatContentVo.strVestId isEqualToString:[Common getCurrentUserVo].strUserID])
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
        if ([chatContentVo.strVestId isEqualToString:[Common getCurrentUserVo].strUserID])
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
    
    //获取文件
    NSString *strAmrPath = [NSString stringWithFormat:@"%@/%@.amr",[Utils getSloth2AudioPath],chatContentVo.strFileID];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:strAmrPath];
    if(!fileExists)
    {
        //文件不存在，则下载
        NSData *dataAudio = [NSData dataWithContentsOfURL:[NSURL URLWithString:chatContentVo.strFileURL]];
        //写入文件
        if(dataAudio != nil)
        {
            [dataAudio writeToFile:strAmrPath atomically:YES];
        }
        else
        {
            [self stopAudioPlaying];
            return;
        }
    }
    
    //amr to wav 的转码处理
    NSString *strWavPath = [VoiceConverter amrToWav:strAmrPath];
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:[NSData dataWithContentsOfFile:strWavPath] error:nil];
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
    
    self.bAudioPlaying = YES;
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
        [Common bubbleTip:[Common localStr:@"Chat_Swith_Speaker" value:@"已从听筒切换回扬声器播放"] andView:self.view];
    }
}

#pragma mark - ReplyUserDelegate
-(void)completeChooseUserAction:(UserVo*)userVo
{
    NSMutableAttributedString *strTemp = [[NSMutableAttributedString alloc]initWithAttributedString:self.faceToolBar.textView.attributedString];
    NSString *strReplyName;
    if (iOSPlatform <= 7)
    {
        //iOS7
        strReplyName = [NSString stringWithFormat:@"@%@ ",userVo.strUserName];
    }
    else
    {
        //iOS8
        strReplyName = [NSString stringWithFormat:@"%@ ",userVo.strUserName];
    }
    
    NSAttributedString *strUserName = [[NSAttributedString alloc]initWithString:strReplyName attributes:[NSDictionary dictionaryWithObject:self.faceToolBar.textView.font forKey:NSFontAttributeName]];
    [strTemp appendAttributedString:strUserName];
    self.faceToolBar.textView.attributedString = strTemp;
    //增加@回复的人
    [self.aryReplyUser addObject:userVo];
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

//YES:开始录音操作，停止其他行为,NO:停止录音，恢复
-(void)recordAudioStateChanged:(BOOL)bState
{
    if(bState)
    {
        self.tableViewChat.userInteractionEnabled = NO;
        [self stopAudioPlaying];
    }
    else
    {
        self.tableViewChat.userInteractionEnabled = YES;
    }
}

@end
