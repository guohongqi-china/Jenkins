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
#import "Common.h"
#import "UIImage+Category.h"
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
            UIButton *btnRight = [Utils buttonWithImage:[SkinManage imageNamed:@"chat_single_info"] frame:[Utils getNavRightBtnFrame:CGSizeMake(86,66)] target:self action:@selector(getChatInfo)];
            [self setRightBarButton:btnRight];
        }
        else
        {
            //群聊
            UIButton *btnRight = [Utils buttonWithImage:[SkinManage imageNamed:@"chat_group_info"] frame:[Utils getNavRightBtnFrame:CGSizeMake(86,66)] target:self action:@selector(getChatInfo)];
            [self setRightBarButton:btnRight];
        }
    }
    else
    {
        UIButton *btnRight = [Utils buttonWithImage:[UIImage imageNamed:@"chatNotPush_white"] frame:[Utils getNavRightBtnFrame:CGSizeMake(100,76)] target:self action:@selector(getChatInfo)];
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
    
    self.tableViewChat.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.faceToolBar.viewContainer.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    
    self.faceToolBar.toolBar.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.faceToolBar.scrollViewMore.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.faceToolBar.scrollViewFacial.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    if ([SkinManage getCurrentSkin] == SkinNightType) {
        self.faceToolBar.toolBar.image = [UIImage imageWithColor:[SkinManage colorNamed:@"Function_BK_Color"]];
        self.faceToolBar.textView.internalTextView.layer.borderColor = [UIColor clearColor].CGColor;
    }
    self.faceToolBar.textView.internalTextView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.faceToolBar.textView.textColor = [SkinManage colorNamed:@"share_text_textColor"];
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
    self.bAudioPlaying = NO;
    self.bReturnRefresh = NO;
    self.bFirstLoad = YES;
    self.aryChatCon = [[NSMutableArray alloc]init];
    self.aryHeaderImage = [[NSMutableArray alloc]init];
    self.aryReceiverAudioIcon = [[NSMutableArray alloc]init];
    self.arySenderAudioIcon = [[NSMutableArray alloc]init];
    self.m_sendChatVo = [[SendChatVo alloc]init];
    
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
    }
    //更新主tab下面的聊天数量
    [[NSNotificationCenter defaultCenter]postNotificationName:@"UpdateChatUnreadAllNum" object:nil];
    
    [self setLeftReturnButton];
}

- (void)initCtrlLayout
{
    self.view.backgroundColor = COLOR(250, 246, 245, 1.0);
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
    tableViewChat.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
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
    self.faceToolBar.textView.internalTextView.enablesReturnKeyAutomatically = YES;
    self.faceToolBar.delegateFaceToolBar=self;
    [faceToolBar dismissKeyBoard];
}

- (void)loadDataTask:(void(^)(void))finished
{
    if (bRunningUpdate)
    {
        //正在更新
        return;
    }
    bRunningUpdate = YES;
    
    if(m_chatObjectVo.nType == 1)
    {
        //单聊历史数据
        [self isHideActivity:NO];
        [ServerProvider getSingleHistoryChatList:m_chatObjectVo.strVestID andStartDateTime:self.nQueryDateTime andPageNum:self.nChatPageNum result:^(ServerReturnInfo *retInfo) {
            [self isHideActivity:YES];
            if (retInfo.bSuccess)
            {
                NSMutableArray *dataArray = (NSMutableArray *)retInfo.data;
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
                    
                    [self historyChatFinishedLoading:dataArray];
                }
            }
            
            if (finished)
            {
                finished();
            }
        }];
    }
    else
    {
        //群聊历史数据
        [self isHideActivity:NO];
        [ServerProvider getGroupHistoryChatList:self.m_chatObjectVo andStartDateTime:self.nQueryDateTime andPageNum:self.nChatPageNum result:^(ServerReturnInfo *retInfo) {
            [self isHideActivity:YES];
            if (retInfo.bSuccess)
            {
                NSMutableArray *dataArray = (NSMutableArray *)retInfo.data;
                
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
                    
                    [self historyChatFinishedLoading:dataArray];
                }
            }
            
            if (finished)
            {
                finished();
            }
        }];
    }
}

- (void)historyChatFinishedLoading:(NSMutableArray*)dataArray
{
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
        if (fHeight>0)
        {
            [tableViewChat setContentOffset:CGPointMake(0,fHeight) animated:NO];
        }
    }
    bRunningUpdate = NO;
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
        [Common tipAlert:@"您已不在该聊天组，不能发信息"];
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
                [Common tipAlert:[NSString stringWithFormat:@"超过1000字限制，当前已输入%lu 个字",(unsigned long)inputText.length]];
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
        
        [self sendChatContentToServerTask];
    }
}
//发送图片
-(void)sendImageAction
{
    if (self.m_chatObjectVo.bReject)
    {
        [Common tipAlert:@"您已不在该聊天组，不能发信息"];
    }
    else
    {
        m_sendChatVo.strStreamContent = @"";
        m_sendChatVo.nContentType = 1;
        
        [self sendChatContentToServerTask];
    }
}
//发送语音
-(void)sendAudioAction:(NSString *)strFilePath andDuration:(NSString *)strDuration
{
    if (self.m_chatObjectVo.bReject)
    {
        [Common tipAlert:@"您已不在该聊天组，不能发信息"];
    }
    else
    {
        m_sendChatVo.strStreamContent = strDuration;
        m_sendChatVo.nContentType = 3;
        m_sendChatVo.strFilePath = strFilePath;
        
        [self sendChatContentToServerTask];
    }
}

- (void)sendChatContentToServerTask
{
    void (^callbackAction)(ServerReturnInfo *) = ^(ServerReturnInfo *serverReturnInfo){
        if (serverReturnInfo.bSuccess)
        {
            //1.add one record and reload tableview
            bReturnRefresh = YES;
            ChatContentVo *chatContentVo = [[ChatContentVo alloc]init];
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
                chatContentVo.nImgSource = 1;
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
                chatContentVo.strFileID = serverReturnInfo.data;//fileID
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
                serverReturnInfo.strErrorMsg = @"发送失败";
            }
            [Common tipAlert:serverReturnInfo.strErrorMsg];
        }
    };
    
    //check group chat or single chat
    if (m_sendChatVo.nSendType == 1) 
    {
        //私聊
        [self isHideActivity:NO];
        [ServerProvider sendSingleChat:m_sendChatVo result:^(ServerReturnInfo *retInfo) {
            [self isHideActivity:YES];
            if (retInfo.bSuccess)
            {
                callbackAction(retInfo);
            }
            else
            {
                [Common tipAlert:retInfo.strErrorMsg];
            }
        }];
    }
    else
    {
        //群聊
        [self isHideActivity:NO];
        [ServerProvider sendGroupChat:m_sendChatVo result:^(ServerReturnInfo *retInfo) {
            [self isHideActivity:YES];
            if (retInfo.bSuccess)
            {
                callbackAction(retInfo);
            }
            else
            {
                [Common tipAlert:retInfo.strErrorMsg];
            }
        }];
    }
}

-(void)toolBarYOffsetChange:(float)fYOffset
{
    [UIView animateWithDuration:Time animations:^{
        CGRect rect = CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, fYOffset-NAV_BAR_HEIGHT);
        self.tableViewChat.frame = rect;
        //tableview back to bottommost
        float fHeight = self.tableViewChat.contentSize.height - self.tableViewChat.frame.size.height;
        if (fHeight>0)
        {
            [tableViewChat setContentOffset:CGPointMake(0,fHeight) animated:YES];
        }
    }];
}

-(void)refreshView:(UIRefreshControl *)refresh
{
    self.bFirstLoad = NO;
    [self loadDataTask:^{
        [refresh endRefreshing];
    }];
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
            sizeImage = CGSizeMake(1024, (1024*sizeImage.height)/sizeImage.width);
        }
        imageToSave = [ResizeImage imageWithImage:imageToSave scaledToSize:sizeImage];
        
        //保存图片
        NSData *imageData = UIImageJPEGRepresentation(imageToSave, 0.5);
        NSString *imagePathDir = [[Utils tmpDirectory] stringByAppendingPathComponent:CHAT_TEMP_DIRECTORY];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL fileExists = [fileManager fileExistsAtPath:imagePathDir];
        if (!fileExists) 
        {
            //create director
            [fileManager createDirectoryAtPath:imagePathDir withIntermediateDirectories:YES  attributes:nil error:nil];
        }
        
        //save file
        NSString *imagePath = [imagePathDir stringByAppendingPathComponent:[Common createImageNameByDateTime]];
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
        //判断隐私中相机是否启用
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus != AVAuthorizationStatusAuthorized && authStatus != AVAuthorizationStatusNotDetermined)
        {
            [Common tipAlert:[NSString stringWithFormat:@"请在iPhone的“设置-隐私-相机”选项中，允许%@访问你的相机。",APP_NAME]];
            return;
        }
        
        //camera
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
- (void)doJPushRefreshChatlist:(NSNotification*)notifiaction
{
    NSDictionary *userInfo = (NSDictionary*)[notifiaction object];
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
                
                if (strVestID !=nil && [m_chatObjectVo.strVestID isEqualToString:strVestID] && nNotifyType == 0)
                {
                    //发给当前用户
                    //a:清空提醒数目
                    NSString *strKey = [NSString stringWithFormat:@"vest_%@",strVestID];
                    [ChatCountDao removeObjectByKey:strKey];
                    
                    //b:增加记录条数
                    ChatContentVo *tempVo = [[ChatContentVo alloc]init];
                    tempVo.strVestId = strVestID;
                    tempVo.strName = m_chatObjectVo.strNAME;
                    tempVo.strHeadImg = m_chatObjectVo.strIMGURL;
                    tempVo.strChatTime = [Common getCurrentDateTime];
                    tempVo.strContent = strChatContent;
                    tempVo.nChatType = 1;
                    
                    //附件类型
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
                    
                    //b:增加记录条数
                    ChatContentVo *tempVo = [[ChatContentVo alloc]init];
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
                    //当前群聊中是发给自己的，则屏蔽掉
                    if ([tempVo.strVestId isEqualToString:[Common getCurrentUserVo].strUserID])
                    {
                        return;
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
                        //1.没有找到头像，先遍历缓存数据
                        tempVo.strName = strSender;
                        for (UserVo *userVo in self.aryHeaderImage)
                        {
                            if ([userVo.strUserID isEqualToString:tempVo.strVestId])
                            {
                                tempVo.strHeadImg = userVo.strHeadImageURL;
                                break;
                            }
                        }
                        if (tempVo.strHeadImg == nil)
                        {
                            //2.没有找到头像，请求网络数据
                            [ServerProvider getUserHeaderImage:tempVo.strVestId result:^(ServerReturnInfo *retInfo) {
                                if (retInfo.bSuccess)
                                {
                                    UserVo *userVo = retInfo.data;
                                    tempVo.strHeadImg = userVo.strHeadImageURL;
                                    [self.aryHeaderImage addObject:userVo];
                                    [self.tableViewChat reloadData];
                                }
                            }];
                        }
                    }
                    
                    tempVo.strChatTime = [Common getCurrentDateTime];
                    tempVo.strContent = strChatContent;
                    tempVo.nChatType = 2;
                    
                    //附件类型
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
                    NSString *strFilePath = [Common checkStrValue:[userInfo valueForKey:@"path"]];
                    if (tempVo.nContentType == 1)
                    {
                        //图片,追加前缀
                        tempVo.strImgURL = [ServerURL getWholeURL:strFilePath];
                        tempVo.strHeadImg = tempChatObjectVo.strIMGURL;
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
        }
    }
}

//加载长文本即时聊天
- (void)loadLongTextChatContent:(ChatContentVo*)tempVo
{
    if (tempVo.nChatType == 1)
    {
        //私聊
        [ServerProvider getChatContentByCId:tempVo.strCId result:^(ServerReturnInfo *retInfo) {
            if (retInfo.bSuccess)
            {
                [self dataFinishedLoading:retInfo chatContent:tempVo];
            }
            else
            {
                [Common tipAlert:retInfo.strErrorMsg];
            }
        }];
    }
    else if(tempVo.nChatType == 2)
    {
        //群聊
        [ServerProvider getGroupChatContentByCId:tempVo.strCId result:^(ServerReturnInfo *retInfo) {
            if (retInfo.bSuccess)
            {
                [self dataFinishedLoading:retInfo chatContent:tempVo];
            }
            else
            {
                [Common tipAlert:retInfo.strErrorMsg];
            }
        }];
    }
}

- (void)dataFinishedLoading:(ServerReturnInfo*)retInfo chatContent:(ChatContentVo*)tempVo
{
    ChatContentVo *chatConVo = retInfo.data;
    tempVo.strContent = (NSString*)chatConVo.strContent;
    
    //do main thread work
    [self.aryChatCon addObject:tempVo];
    [self.tableViewChat reloadData];
    
    float fHeight = self.tableViewChat.contentSize.height - self.tableViewChat.frame.size.height;
    [UIView animateWithDuration:Time animations:^{
        [tableViewChat setContentOffset:CGPointMake(0,fHeight) animated:YES];
    }];
}

//设置返回按钮内容【消息(12)】
-(void)setLeftReturnButton
{
    //返回按钮
    int nSumNum = [ChatCountDao getUnseenChatSumNum];
    NSString *strText;
    if (nSumNum>99)
    {
        strText = [NSString stringWithFormat:@"　 %@(99+)",[Common localStr:@"Common_NAV_Chat" value:@"消息"]];
    }
    else if(nSumNum>0)
    {
        strText = [NSString stringWithFormat:@"　 %@(%i)",[Common localStr:@"Common_NAV_Chat" value:@"消息"],nSumNum];
    }
    else
    {
        strText = @"　 消息";
    }
    
    UIFont *font = [UIFont systemFontOfSize:15];
    CGSize size = [Common getStringSize:strText font:font bound:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByWordWrapping];
    float fWidth = size.width>48?(125+size.width-48+28):120;
    
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
    NSString *imagePathDir = [[Utils tmpDirectory] stringByAppendingPathComponent:CHAT_TEMP_DIRECTORY];
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
    bFirstLoad = YES;
    [self loadDataTask:nil];
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
        [faceToolBar dismissKeyBoard];
        
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
    NSString *imagePathDir = [[Utils tmpDirectory] stringByAppendingPathComponent:CHAT_TEMP_DIRECTORY];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:imagePathDir];
    if (!fileExists) 
    {
        //create director
        [fileManager createDirectoryAtPath:imagePathDir withIntermediateDirectories:YES  attributes:nil error:nil];
    }
    
    //save file
    NSString *imagePath = [imagePathDir stringByAppendingPathComponent:[Common createImageNameByDateTime]];
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
        [Common tipAlert:@"您已不在该聊天组"];
    }
    else
    {
        [self.faceToolBar.textView resignFirstResponder];
        
        ChatInfoViewController *chatInfoViewController = [[ChatInfoViewController alloc]init];
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
