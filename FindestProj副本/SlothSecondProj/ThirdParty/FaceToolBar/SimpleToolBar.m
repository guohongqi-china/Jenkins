//
//  SimpleToolBar.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 5/6/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import "SimpleToolBar.h"
#import "SYTextAttachment.h"
#import "Utils.h"
#import "VoiceConverter.h"
#import "Common.h"
#import "SkinManage.h"
#import "UIViewExt.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "UIImage+UIImageScale.h"
#import "ResizeImage.h"
#import "UIImage+Extras.h"
#import "KTPhotoScrollViewController.h"
#import "SDWebImageDataSource.h"
#import "AttachmentVo.h"
#import "SYTextAttachment.h"
#import "UserVo.h"

@implementation SimpleToolBar
@synthesize theSuperView;
@synthesize delegateFaceToolBar;
@synthesize toolBar;
@synthesize textView;
@synthesize btnMore;
@synthesize keyboardIsShow;
@synthesize bBottomShow;
@synthesize rcSuperView;

-(void)dealloc
{
    //将FaceToolBar从通知中心移除，否则下次进来会继续向FaceToolBar发送消息，但是已经释放，会出现Clash
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(id)init:(CGRect)rcView superView:(UIView *)superView type:(SimpleToolBarType)simpleToolBarType
{
    self = [super init];
    if (self)
    {
        self.bTouchFunctionButton = NO;
        self.attachList = [NSMutableArray array];
        self.simpleToolBarType = simpleToolBarType;
        
        //初始化为NO
        keyboardIsShow=NO;
        bBottomShow = NO;
        self.bEnableAT = NO;
        self.bHideBottomTab = NO;
        self.theSuperView=superView;
        self.rcSuperView = rcView;
        self.aryReplyUser = [NSMutableArray array];
        
        //默认toolBar在视图最下方ChatToolBar
        self.toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f,rcSuperView.size.height - toolBarHeight,rcSuperView.size.width,toolBarHeight)];
        toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        toolBar.barStyle = UIBarStyleDefault;
        toolBar.translucent = YES;
        
        CGFloat fLeftOffset = 15;
        
        //可以自适应高度的文本输入框40, 5, 220, 0
        self.textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(fLeftOffset, 6, kScreenWidth-fLeftOffset-55, 34)];
        textView.isScrollable = NO;
        textView.minNumberOfLines = 1;
        textView.maxNumberOfLines = 5;
        textView.font = [UIFont fontWithName:@"Helvetica" size:15];
        textView.delegate = self;
        textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
        textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        textView.internalTextView.layer.borderColor = COLOR(172, 174, 178, 1.0).CGColor;
        [textView.internalTextView.layer setBorderWidth:0.5];
        [textView.internalTextView.layer setCornerRadius:4];
        [textView.internalTextView.layer setMasksToBounds:YES];
        textView.internalTextView.layer.backgroundColor = [[UIColor clearColor]CGColor];
        textView.backgroundColor = COLOR(254, 254, 254, 1.0);
        textView.returnKeyType = UIReturnKeySend;
        textView.internalTextView.enablesReturnKeyAutomatically = YES;
        [toolBar addSubview:textView];
        //fLeftOffset += self.textView.frame.size.width+5;
        
        if (self.simpleToolBarType == SimpleToolBarFaceType)
        {
            //表情按钮
            self.btnFacial = [UIButton buttonWithType:UIButtonTypeCustom];
            self.btnFacial.tag = 0;//当tag=1时处于键盘图标状态，tag=0时处于普通状态
            self.btnFacial.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
            [self.btnFacial setImage:[UIImage imageNamed:@"chat_bottom_smile_nor"] forState:UIControlStateNormal];
            [self.btnFacial setImage:[UIImage imageNamed:@"chat_bottom_smile_press"] forState:UIControlStateHighlighted];
            self.btnFacial.imageEdgeInsets = UIEdgeInsetsMake(5.5, 10.5, 5.5, 10.5);
            [self.btnFacial addTarget:self action:@selector(clickMoreButton:) forControlEvents:UIControlEventTouchUpInside];
            self.btnFacial.frame = CGRectMake(kScreenWidth-55,0,55,45);//toolBar.bounds.size.height-38.0f
            [toolBar addSubview:self.btnFacial];
        }
        else if (self.simpleToolBarType == SimpleToolBarAttachType)
        {
            //更多功能按钮
            self.btnMore = [UIButton buttonWithType:UIButtonTypeCustom];
            self.btnMore.tag = 0;//当tag=1时处于键盘图标状态，tag=0时处于普通状态
            btnMore.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
            [btnMore setImage:[UIImage imageNamed:@"toolbar_icon"] forState:UIControlStateNormal];
            [btnMore setImage:[UIImage imageNamed:@"toolbar_icon"] forState:UIControlStateHighlighted];
            self.btnMore.imageEdgeInsets = UIEdgeInsetsMake(5.5, 10.5, 5.5, 10.5);
            [btnMore addTarget:self action:@selector(clickMoreButton:) forControlEvents:UIControlEventTouchUpInside];
            btnMore.frame = CGRectMake(kScreenWidth-55,0,55,45);
            [toolBar addSubview:btnMore];
        }
        
        //给键盘注册通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        //创建更多键盘
        self.viewContainer=[[UIView alloc] initWithFrame:CGRectMake(0, superView.frame.size.height, superView.frame.size.width, keyboardHeight)];
        self.viewContainer.backgroundColor = COLOR(248, 248, 248, 1.0);
        
        //表情视图
        self.scrollViewFacial = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0,superView.frame.size.width, keyboardHeight)];
        [self.scrollViewFacial setShowsVerticalScrollIndicator:NO];
        [self.scrollViewFacial setShowsHorizontalScrollIndicator:NO];
        self.scrollViewFacial.pagingEnabled=YES;
        self.scrollViewFacial.delegate=self;
        self.scrollViewFacial.scrollsToTop = NO;
        [self.viewContainer addSubview:self.scrollViewFacial];
        self.scrollViewFacial.hidden = YES;
        
        int i=0;
        self.nPage = 0;
        CGFloat fOffsetW = -1+(kScreenWidth-320)/2;
        CGFloat fOffsetH = 16;
        CGFloat fFaceW = 28;
        CGFloat fFaceH = 28;
        NSArray *aryFace = [AppDelegate getSlothAppDelegate].aryFace;
        while (i<aryFace.count)
        {
            NSDictionary *dicFace = [aryFace objectAtIndex:i];
            if (i==0 || i%20!=0)
            {
                //1.计算该表情坐标
                
                CGFloat fX = fOffsetW+(i%20%7)*(fFaceW+18);
                CGFloat fY = fOffsetH+(i%20/7)*(fFaceH+14);
                
                UIButton *btnFaceIcon = [UIButton buttonWithType:UIButtonTypeCustom];
                btnFaceIcon.tag = i;
                btnFaceIcon.frame = CGRectMake(self.nPage*kScreenWidth+fX, fY, fFaceW+18, fFaceH+14);
                [btnFaceIcon setImage:[UIImage imageNamed:[dicFace objectForKey:@"image"]] forState:UIControlStateNormal];
                btnFaceIcon.imageEdgeInsets = UIEdgeInsetsMake(7, 9, 7, 9);
                [btnFaceIcon addTarget:self action:@selector(selectFace:) forControlEvents:UIControlEventTouchUpInside];
                [self.scrollViewFacial addSubview:btnFaceIcon];
            }
            else
            {
                CGFloat fX = fOffsetW+6*(fFaceW+18);
                CGFloat fY = fOffsetH+2*(fFaceH+14);
                
                //1.一页中最后一个元素，显示删除按钮
                UIButton *btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
                btnDelete.tag = 10000; //delete button tag
                btnDelete.frame = CGRectMake(self.nPage*kScreenWidth+fX, fY, fFaceW+18, fFaceH+14);
                [btnDelete setImage:[UIImage imageNamed:@"aio_face_delete"] forState:UIControlStateNormal];
                btnDelete.imageEdgeInsets = UIEdgeInsetsMake(6, 8, 6, 8);
                [btnDelete addTarget:self action:@selector(selectFace:) forControlEvents:UIControlEventTouchUpInside];
                [self.scrollViewFacial addSubview:btnDelete];
                
                //2.绘制第二页中第一个元素
                self.nPage++;//页码
                UIButton *btnFaceIcon = [UIButton buttonWithType:UIButtonTypeCustom];
                btnFaceIcon.tag = i;
                btnFaceIcon.frame = CGRectMake(self.nPage*kScreenWidth+fOffsetW, fOffsetH, fFaceW+18, fFaceH+14);
                [btnFaceIcon setImage:[UIImage imageNamed:[dicFace objectForKey:@"image"]] forState:UIControlStateNormal];
                btnFaceIcon.imageEdgeInsets = UIEdgeInsetsMake(7, 9, 7, 9);
                [btnFaceIcon addTarget:self action:@selector(selectFace:) forControlEvents:UIControlEventTouchUpInside];
                [self.scrollViewFacial addSubview:btnFaceIcon];
            }
            i++;
        }
        
        //绘制最后一页的删除按钮
        if (i>0)
        {
            CGFloat fX = fOffsetW+6*(fFaceW+18);
            CGFloat fY = fOffsetH+2*(fFaceH+14);
            UIButton *btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
            btnDelete.tag = 10000; //delete button tag
            btnDelete.frame = CGRectMake(self.nPage*kScreenWidth+fX, fY, fFaceW+18, fFaceH+14);
            btnDelete.imageEdgeInsets = UIEdgeInsetsMake(6, 8, 6, 8);
            [btnDelete setImage:[UIImage imageNamed:@"aio_face_delete"] forState:UIControlStateNormal];
            [btnDelete addTarget:self action:@selector(selectFace:) forControlEvents:UIControlEventTouchUpInside];
            [self.scrollViewFacial addSubview:btnDelete];
        }
        
        //分页控件
        self.pageControlFace = [[SMPageControl alloc]initWithFrame:CGRectMake(0, 145, kScreenWidth, 6)];//6
        [self.pageControlFace setPageIndicatorImage:[UIImage imageNamed:@"white_gray"]];
        [self.pageControlFace setCurrentPageIndicatorImage:[UIImage imageNamed:@"page_gray"]];
        self.pageControlFace.numberOfPages = self.nPage+1;
        [self.viewContainer addSubview:self.pageControlFace];
        
        self.btnSenderFacial = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.btnSenderFacial setBackgroundImage:[Common getImageWithColor:[SkinManage skinColor]] forState:UIControlStateNormal];
        self.btnSenderFacial.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [self.btnSenderFacial setTitle:@"发  送" forState:UIControlStateNormal];
        [self.btnSenderFacial setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btnSenderFacial addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
        self.btnSenderFacial.frame = CGRectMake(0,176,kScreenWidth,40);
        self.btnSenderFacial.enabled = NO;
        [self.viewContainer addSubview:self.btnSenderFacial];
        
        self.scrollViewFacial.contentSize=CGSizeMake(kScreenWidth*(self.nPage+1), keyboardHeight);
        
        if (self.simpleToolBarType == SimpleToolBarAttachType)
        {
            self.pageControlFace.hidden = YES;
            self.btnSenderFacial.hidden = YES;
        }
        
        self.viewAttach = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, TOOL_VIEW_HEIGHT)];
        self.viewAttach.backgroundColor = COLOR(248, 248, 248, 1.0);
        [self.viewContainer addSubview:self.viewAttach];
        
        CGRect rect = CGRectMake(0, 50, kScreenWidth, 1);
        UIImageView *lineImgView = [[UIImageView alloc] initWithFrame:rect];
        lineImgView.image = [UIImage imageNamed:@"tool_line"];
        [self.viewAttach addSubview:lineImgView];
        
        rect = CGRectMake(0, 0, kScreenWidth, 50);
        UIView *topView = [[UIView alloc] initWithFrame:rect];
        [self.viewAttach addSubview:topView];
        
        //相机
        int padding = 31;
        rect = CGRectMake(padding, 13, 27, 22);
        UIButton *cameraButton = [Utils buttonWithImage:[UIImage imageNamed:@"camera"] frame:rect target:self action:@selector(cameraButton:)];
        [topView addSubview:cameraButton];
        //相册
        rect.origin.x += rect.size.width + padding;
        UIButton *photoButton = [Utils buttonWithImage:[UIImage imageNamed:@"photo"] frame:rect target:self action:@selector(photoButton:)];
        [topView addSubview:photoButton];
        
        //创建ScrollView存放附件
        contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 51, kScreenWidth, 238)];
        contentView.pagingEnabled = YES;
        contentView.showsVerticalScrollIndicator = NO;
        [contentView setContentSize:CGSizeMake(kScreenWidth, 238)];
        contentView.scrollsToTop = NO;
        [self.viewAttach addSubview:contentView];
        
        [superView addSubview:self.viewContainer];
        [superView addSubview:toolBar];
    }
    return self;
}

-(void)resetFrame
{
    //self.toolBar.frame = CGRectMake(0,rcSuperView.size.height - self.toolBar.height,rcSuperView.size.width,self.toolBar.height);
    self.toolBar.frame = CGRectMake(0,kScreenHeight,rcSuperView.size.width,self.toolBar.height);
    self.viewContainer.frame = CGRectMake(0, rcSuperView.size.height, rcSuperView.size.width, keyboardHeight);
}

//输入表情
- (void)selectFace:(UIButton*)sender
{
    NSMutableAttributedString *strMutable = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.internalTextView.attributedText];
    if (sender.tag == 10000)
    {
        //删除按钮
        if (strMutable.length>0)
        {
            [strMutable deleteCharactersInRange:NSMakeRange(strMutable.length-1, 1)];
        }
    }
    else
    {
        //点击表情
        NSArray *aryFace = [AppDelegate getSlothAppDelegate].aryFace;
        NSDictionary *dicFace = [aryFace objectAtIndex:sender.tag];
        
        SYTextAttachment *textAttachment = [[SYTextAttachment alloc] init];
        
        //给附件添加图片
        textAttachment.image = [UIImage imageNamed:[dicFace objectForKey:@"image"]];
        textAttachment.strFaceCHS = [dicFace objectForKey:@"chs"];
        textAttachment.bounds = CGRectMake(0, -5, 25, 25);
        
        //把附件转换成可变字符串，用于替换掉源字符串中的表情文字
        NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [strMutable appendAttributedString:imageStr];
    }
    //添加字体
    [strMutable addAttributes:@{NSFontAttributeName:self.textView.font} range:NSMakeRange(0, strMutable.length)];
    self.textView.internalTextView.attributedText = strMutable;
    
    [self.textView textViewDidChange:self.textView.internalTextView];
}

//1.将ALAsset对象转化为 AttachmentVo
-(void)transferAssetsToAttachmentVo:(NSMutableArray *)aryAssets
{
    if (aryAssets != nil)
    {
        [self.attachList removeAllObjects];
        [self deleteAllAttachView];
        
        NSInteger nIndex = self.attachList.count;
        for (int i=0;i<aryAssets.count;i++,nIndex++)
        {
            ALAsset *asset = aryAssets[i];
            ALAssetRepresentation* representation = [asset defaultRepresentation];
            [representation orientation];
            
            //图片缩放处理
            UIImage *imageToSave = [UIImage imageWithCGImage:[representation fullScreenImage] scale:0.8 orientation:UIImageOrientationUp];
            CGSize sizeImage = [representation dimensions];
            if (sizeImage.width>IMAGE_MAX_SIZE && sizeImage.height>IMAGE_MAX_SIZE)
            {
                sizeImage = CGSizeMake(1024, (1024*sizeImage.height)/sizeImage.width);
            }
            imageToSave = [ResizeImage imageWithImage:imageToSave scaledToSize:sizeImage];
            
            //保存图片
            NSData *imageData = UIImageJPEGRepresentation(imageToSave, 0.8f);
            //自动清理上次产生的图片以及目录"tmp/TempFile"
            NSString *imagePath = [[Utils getTempPath] stringByAppendingPathComponent:[Common createImageNameByDateTimeAndPara:nIndex]];
            [imageData writeToFile:imagePath atomically:YES];
            
            AttachmentVo *attachmentVo = [[AttachmentVo alloc]init];
            attachmentVo.nAttachType = 0;
            attachmentVo.strAttachLocalPath = imagePath;
            [self.attachList addObject:attachmentVo];
            [self addImageToContent:imageToSave index:nIndex target:self action:@selector(previewButton:)];
        }
    }
}

//2.将拍照产生的ALAsset对象转化为AttachmentVo
-(void)addAssetToAttachmentVo:(ALAsset *)asset
{
    if (asset != nil)
    {
        ALAssetRepresentation* representation = [asset defaultRepresentation];
        [representation orientation];
        
        //图片缩放处理
        UIImage *imageToSave = [UIImage imageWithCGImage:[representation fullScreenImage] scale:0.8 orientation:UIImageOrientationUp];
        CGSize sizeImage = [representation dimensions];
        if (sizeImage.width>IMAGE_MAX_SIZE && sizeImage.height>IMAGE_MAX_SIZE)
        {
            sizeImage = CGSizeMake(1024, (1024*sizeImage.height)/sizeImage.width);
        }
        imageToSave = [ResizeImage imageWithImage:imageToSave scaledToSize:sizeImage];
        
        //保存图片
        NSData *imageData = UIImageJPEGRepresentation(imageToSave, 0.8f);
        //自动清理上次产生的图片以及目录"tmp/TempFile"
        NSString *imagePath = [[Utils getTempPath] stringByAppendingPathComponent:[Common createImageNameByDateTimeAndPara:0]];
        [imageData writeToFile:imagePath atomically:YES];
        
        AttachmentVo *attachmentVo = [[AttachmentVo alloc]init];
        attachmentVo.nAttachType = 0;
        attachmentVo.strAttachLocalPath = imagePath;
        NSUInteger count = self.attachList.count;
        [self.attachList addObject:attachmentVo];
        [self addImageToContent:imageToSave index:count target:self action:@selector(previewButton:)];
        
        if (self.aryAssets == nil)
        {
            self.aryAssets = [NSMutableArray array];
        }
        [self.aryAssets addObject:asset];
    }
}

//@回复别人的操作
-(void)replyUserAction
{
    //只有群聊才会有@操作
    if (self.replyUserViewController == nil)
    {
        self.replyUserViewController = [[ReplyUserViewController alloc]init];
        self.replyUserViewController.delegate = self;
    }
    
    self.replyUserViewController.bClickAtButtonEnter = NO;
    if (self.bHideBottomTab)
    {
        [self.delegateFaceToolBar hideBottomTab];
        
        //        ShareListOldViewController *viewControllerParent = (ShareListOldViewController *)self.delegateFaceToolBar;
        //        [viewControllerParent.homeViewController presentViewController:self.replyUserViewController animated:YES completion:nil];
    }
    else
    {
        UIViewController *viewControllerParent = (UIViewController *)self.delegateFaceToolBar;
        [viewControllerParent presentViewController:self.replyUserViewController animated:YES completion:nil];
    }
}

//删除空格操作，用来判断是否删除@人操作
-(BOOL)deleteBlankSpace:(NSInteger)nPosition
{
    BOOL bRes = NO;
    NSMutableAttributedString *strText = [[NSMutableAttributedString alloc]initWithAttributedString:self.textView.attributedText];
    
    //判断是否存在该@的人
    for (NSInteger i=self.aryReplyUser.count-1; i>=0; i--)
    {
        UserVo *userVo = self.aryReplyUser[i];
        NSString *strReplyUser = [NSString stringWithFormat:@"[@%@ %@]",userVo.strUserName,userVo.strUserID];
        NSInteger nStart = nPosition-strReplyUser.length;
        if (nStart>=0)
        {
            NSRange range = NSMakeRange(nStart, strReplyUser.length);
            NSAttributedString *attributedSubStr = [strText attributedSubstringFromRange:range];
            if ([attributedSubStr.string isEqualToString:strReplyUser])
            {
                [strText deleteCharactersInRange:range];
                self.textView.attributedText = strText;
                [self.aryReplyUser removeObjectAtIndex:i];
                bRes = YES;
                break;
            }
        }
    }
    return bRes;
}

//清理数据
-(void)clearToolBarData
{
    self.textView.text = @"";
    [self.aryReplyUser removeAllObjects];
}

#pragma mark - ReplyUserDelegate
-(void)completeChooseUserAction:(UserVo*)userVo
{
    NSMutableAttributedString *strTemp = [[NSMutableAttributedString alloc]initWithAttributedString:self.textView.attributedText];
    NSString *strReplyName = [NSString stringWithFormat:@"[@%@ %@] ",userVo.strUserName,userVo.strUserID];
    NSAttributedString *strUserName = [[NSAttributedString alloc]initWithString:strReplyName attributes:[NSDictionary dictionaryWithObject:self.textView.font forKey:NSFontAttributeName]];
    [strTemp appendAttributedString:strUserName];
    self.textView.attributedText = strTemp;
    //增加@回复的人
    [self.aryReplyUser addObject:userVo];
}

-(void)cancelChooseUserAction:(BOOL)bClickAtButton
{
    //输入@字符进入，则追加'@'
    if (!bClickAtButton)
    {
        NSMutableAttributedString *strTemp = [[NSMutableAttributedString alloc]initWithAttributedString:self.textView.attributedText];
        NSAttributedString *strUserName = [[NSAttributedString alloc]initWithString:@"@" attributes:[NSDictionary dictionaryWithObject:self.textView.font forKey:NSFontAttributeName]];
        [strTemp appendAttributedString:strUserName];
        self.textView.attributedText = strTemp;
    }
}

#pragma mark - UIScrollView delegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.pageControlFace.currentPage = self.scrollViewFacial.contentOffset.x/(kScreenWidth-12);
}

#pragma mark 监听键盘的显示与隐藏
-(void)inputKeyboardWillShow:(NSNotification *)notification
{
    // get keyboard size and loctaion
    CGSize kbSize = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    // get a rect for the textView frame
    CGRect containerFrame = toolBar.frame;
    containerFrame.origin.y = kScreenHeight;
    toolBar.frame = containerFrame;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.25];
    // set views with new info
    containerFrame.origin.y = kScreenHeight - kbSize.height - containerFrame.size.height;
    self.toolBar.frame = containerFrame;
    //self.viewContainer.frame = containerFrame;
    [UIView commitAnimations];
    
    
    
    //////////////////////////////////////////////////////
    [self.btnFacial setImage:[UIImage imageNamed:@"chat_bottom_smile_nor"] forState:UIControlStateNormal];
    [self.btnMore setImage:[UIImage imageNamed:@"toolbar_icon"] forState:UIControlStateNormal];
    self.btnFacial.tag = 0;
    self.btnMore.tag = 0;
    keyboardIsShow=YES;
    bBottomShow = YES;
    
    //notify the main view about the toolbar height
    [self changeChatViewHeight];
}

-(void)inputKeyboardWillHide:(NSNotification *)notification
{
    keyboardIsShow=NO;
    
    if(self.bTouchFunctionButton)
    {
        //点击toolbar 功能键，则不做处理
    }
    else
    {
        [self dismissKeyBoard];
    }
    
    //notify the main view about the toolbar height
    [self changeChatViewHeight];
}

#pragma mark HPGrowingTextViewDelegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
    CGRect r = toolBar.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    toolBar.frame = r;
}

//文本是否改变
-(void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView
{
    if ([growingTextView.text length] > 0)
    {
        self.btnSenderFacial.enabled = YES;
    }
    else
    {
        self.btnSenderFacial.enabled = NO;
    }
}

//键盘发送按钮
- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView
{
    [self tackleRichText];
    return YES;
}

-(void)tackleRichText
{
    if ([delegateFaceToolBar respondsToSelector:@selector(sendTextAction:)])
    {
        NSString *strText = @"";
        if (self.textView.internalTextView.text.length == 0)
        {
            [self.delegateFaceToolBar sendTextAction:strText];
        }
        else
        {
            //TextView表情解析
            if (iOSPlatform >= 7)
            {
                NSMutableAttributedString *strAttribute = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.internalTextView.attributedText];
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
                
                strText = strAttribute.mutableString;
            }
            else
            {
                //iOS6
                strText = self.textView.internalTextView.attributedText.string;
            }
            
            [self.delegateFaceToolBar sendTextAction:strText];
        }
    }
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    BOOL bRes = YES;
    if (self.bEnableAT)//启用@功能
    {
        if([text isEqualToString:@"@"])
        {
            bRes = NO;
            //当输入'@'字符，并且前面不是[a-zA-Z0-9]，为了防止打扰用户输入邮箱
            NSString *strText = growingTextView.text;
            if (range.location>0)//第一个字符为@可跳转
            {
                NSString *strPreChar = [strText substringWithRange:NSMakeRange(range.location-1, 1)];
                if (strPreChar != nil && strPreChar.length>0)
                {
                    unichar c = [strPreChar characterAtIndex:0];
                    if (isdigit(c) || isalpha(c))
                    {
                        //不做@跳转
                        bRes = YES;
                    }
                }
            }
            
            if (!bRes)
            {
                [self replyUserAction];
            }
        }
        else if(text.length == 0)
        {
            //删除@字符操作
            NSString *strText = growingTextView.text;
            if(range.location>0 && range.length == 1)
            {
                NSString *strPreChar = [strText substringWithRange:range];
                if ([strPreChar isEqualToString:@"]"])//删除空格
                {
                    if (self.bEnableAT)
                    {
                        if ([self deleteBlankSpace:range.location+1])
                        {
                            bRes = NO;
                        }
                    }
                }
            }
        }
    }
    return bRes;
}

#pragma mark ActionMethods  发送sendAction
-(void)sendAction
{
    [self tackleRichText];
}

/////////////////////////////////////////////////////////////////
#pragma mark 隐藏键盘
-(void)dismissKeyBoard
{
    [textView resignFirstResponder];
    //不显示toolbar，彻底关闭
    if ([delegateFaceToolBar respondsToSelector:@selector(hideKeyboard)])
    {
        [delegateFaceToolBar hideKeyboard];
    }
    
    //更新按钮图标
    [self.btnFacial setImage:[UIImage imageNamed:@"chat_bottom_smile_nor"] forState:UIControlStateNormal];
    [btnMore setImage:[UIImage imageNamed:@"toolbar_icon"] forState:UIControlStateNormal];
    
    self.btnFacial.tag = 0;
    self.btnMore.tag = 0;
    [self changeChatViewHeight];
}

-(void)showKeyboard
{
    if ([delegateFaceToolBar respondsToSelector:@selector(showKeyboard)])
    {
        [delegateFaceToolBar showKeyboard];
        [self.textView becomeFirstResponder];
    }
}

//notify the main view about the toolbar height
-(void)changeChatViewHeight
{
    //notify the main view about the toolbar height
    if ([delegateFaceToolBar respondsToSelector:@selector(toolBarYOffsetChange:)])
    {
        [delegateFaceToolBar toolBarYOffsetChange:toolBar.frame.origin.y];
    }
}

-(void)clickMoreButton:(UIButton*)sender
{
    //更新状态
    bBottomShow = YES;
    //点击表情或者更多按钮
    if (toolBar.frame.origin.y== (self.rcSuperView.size.height - toolBarHeight) && toolBar.frame.size.height==toolBarHeight)
    {
        //如果直接点击表情，通过toolbar的位置来判断
        [UIView animateWithDuration:Time delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            toolBar.frame = CGRectMake(0, self.rcSuperView.size.height-keyboardHeight-toolBarHeight,  self.rcSuperView.size.width,toolBarHeight);
        }completion:nil];
        
        [UIView animateWithDuration:Time animations:^{
            [self.viewContainer setFrame:CGRectMake(0, self.rcSuperView.size.height-keyboardHeight,self.rcSuperView.size.width, keyboardHeight)];
        }];
        
        //notify the main view about the toolbar height
        [self changeChatViewHeight];
    }
    else
    {
        if (!keyboardIsShow && sender.tag == 1)
        {
            //如果键盘没有显示并且处于键盘的按钮(点击表情了，隐藏表情，显示键盘)
            [UIView animateWithDuration:Time animations:^{
                [self.viewContainer setFrame:CGRectMake(0, self.rcSuperView.size.height, self.rcSuperView.size.width, keyboardHeight)];
            }];
            [textView becomeFirstResponder];
        }
        else
        {
            //键盘显示的时候，toolbar需要还原到正常位置，并显示表情
            [UIView animateWithDuration:Time animations:^{
                toolBar.frame = CGRectMake(0, self.rcSuperView.size.height-keyboardHeight-toolBar.frame.size.height,  self.rcSuperView.size.width,toolBar.frame.size.height);
            }];
            
            [UIView animateWithDuration:Time animations:^{
                [self.viewContainer setFrame:CGRectMake(0, self.rcSuperView.size.height-keyboardHeight,self.rcSuperView.size.width, keyboardHeight)];
            }];
            //防止隐藏键盘，将toolbar隐藏
            self.bTouchFunctionButton = YES;
            [textView resignFirstResponder];
            self.bTouchFunctionButton = NO;
        }
    }
    
    if(keyboardIsShow)
    {
        //键盘已经显示
        self.btnFacial.tag = 0;
        self.btnMore.tag = 0;
    }
    else
    {
        if (sender == self.btnFacial)
        {
            //表情视图
            self.textView.hidden = NO;
            self.scrollViewFacial.hidden = NO;
            self.viewAttach.hidden = YES;
            
            [self.btnFacial setImage:[UIImage imageNamed:@"chat_bottom_keyboard_nor"] forState:UIControlStateNormal];
            [self.btnMore setImage:[UIImage imageNamed:@"toolbar_icon"] forState:UIControlStateNormal];
            
            self.btnFacial.tag = 1;
            self.btnMore.tag = 0;
        }
        else if (sender == self.btnMore)
        {
            //更多视图
            self.textView.hidden = NO;
            self.scrollViewFacial.hidden = YES;
            self.viewAttach.hidden = NO;
            
            [self.btnFacial setImage:[UIImage imageNamed:@"chat_bottom_smile_nor"] forState:UIControlStateNormal];
            [self.btnMore setImage:[UIImage imageNamed:@"chat_bottom_keyboard_nor"] forState:UIControlStateNormal];
            
            self.btnFacial.tag = 0;
            self.btnMore.tag = 1;
        }
    }
}

//添加照片、视频和文档
- (void)addImageToContent:(UIImage *)image index:(NSUInteger)index target:(id)target action:(SEL)action
{
    UIButton *attachButton = [Utils buttonWithImage:image frame:CGRectMake(26+((64 + 26)*index), 18, 64, 64) target:target action:action];
    attachButton.tag = index;
    attachButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [attachButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:attachButton];
    
    [contentView setContentSize:CGSizeMake(attachButton.frame.origin.x + attachButton.frame.size.width + 26, 64)];
}

#pragma mark - Tool view delegate
//拍照
- (void)cameraButton:(id)sender
{
    UIViewController *viewController = (UIViewController *)self.delegateFaceToolBar;
    if (self.attachList.count >= 9)
    {
        [Common bubbleTip:@"最多选择9张照片" andView:viewController.view];
    }
    else
    {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
            return;
        }
        
        //判断隐私中相机是否启用
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus != AVAuthorizationStatusAuthorized && authStatus != AVAuthorizationStatusNotDetermined)
        {
            [Common tipAlert:[NSString stringWithFormat:@"请在iPhone的“设置-隐私-相机”选项中，允许%@访问你的相机。",APP_NAME]];
            return;
        }
        
        UIImagePickerController *photoController = [[UIImagePickerController alloc] init];
        photoController.delegate = self;
        photoController.sourceType = UIImagePickerControllerSourceTypeCamera;
        photoController.mediaTypes = @[(NSString*)kUTTypeImage];
        photoController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        photoController.allowsEditing = NO;
        [viewController presentViewController:photoController animated:YES completion:nil];
    }
}

//相册
- (void)photoButton:(id)sender
{
    UIViewController *viewController = (UIViewController *)self.delegateFaceToolBar;
    
    if (self.attachList.count >= 9)
    {
        [Common bubbleTip:@"最多选择9张照片" andView:viewController.view];
    }
    else
    {
        if (self.aryAssets == nil)
        {
            self.aryAssets = [NSMutableArray array];
        }
        
        CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
        picker.assetsFilter = [ALAssetsFilter allPhotos];
        picker.delegate = self;
        picker.selectedAssets = [NSMutableArray arrayWithArray:self.aryAssets];//共用一个数组引用，需要重新初始化一个
        [viewController presentViewController:picker animated:YES completion:^(void){}];
    }
}

#pragma mark - Assets Picker Delegate
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:^(void){
        
    }];
    
    self.aryAssets = [NSMutableArray arrayWithArray:assets];
    [self transferAssetsToAttachmentVo:self.aryAssets];
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldEnableAssetForSelection:(ALAsset *)asset
{
    // Enable video clips if they are at least 5s
    if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo])
    {
        NSTimeInterval duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
        return lround(duration) >= 5;
    }
    else
    {
        return YES;
    }
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(ALAsset *)asset
{
    NSInteger nMaxUploadNum = 9;
    if (picker.selectedAssets.count >= nMaxUploadNum)
    {
        [Common bubbleTip:[NSString stringWithFormat:@"最多选择%li张照片",(long)nMaxUploadNum] andView:picker.view];
    }
    
    if (!asset.defaultRepresentation)
    {
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"Attention"
                                   message:@"Your asset has not yet been downloaded to your device"
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:@"OK", nil];
        
        [alertView show];
    }
    
    return (picker.selectedAssets.count < nMaxUploadNum && asset.defaultRepresentation != nil);
}
//默认进入相机胶卷相册
- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker isDefaultAssetsGroup:(ALAssetsGroup *)group
{
    return ([[group valueForProperty:ALAssetsGroupPropertyType] integerValue] == ALAssetsGroupSavedPhotos);
}

#pragma mark - UIImagePickerControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //    [navigationController.navigationBar setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor blackColor]}];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSUInteger nAttachAndImageCount = self.attachList.count;
    if (nAttachAndImageCount >= 9) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"最大允许上传照片个数为9个。"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage;
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo)
    {
        originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
        
        //保存到系统相册,然后获取ALAsset
        ALAssetsLibrary *library = [Common defaultAssetsLibrary];
        [library writeImageToSavedPhotosAlbum:[originalImage CGImage] orientation:(ALAssetOrientation)[originalImage imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
            if (error == nil)
            {
                [library assetForURL:assetURL resultBlock:^(ALAsset *asset){
                    [self addAssetToAttachmentVo:asset];
                } failureBlock:^(NSError *error ){
                    DLog(@"Error loading asset");
                }];
            }
            else
            {
                [Common tipAlert:error.localizedDescription];
            }
        }];
    }
    [picker  dismissViewControllerAnimated:YES completion: nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker  dismissViewControllerAnimated:YES completion:nil];
}

//nType,0:图片，1:附件
- (void)addAttachmentWithPath:(NSString *)path image:(UIImage *)image andType:(int)nType
{
    AttachmentVo *attachmentVo = [[AttachmentVo alloc]init];
    attachmentVo.nAttachType = nType;
    attachmentVo.strAttachLocalPath = path;
    NSUInteger count = self.attachList.count;
    [self.attachList addObject:attachmentVo];
    [self addImageToContent:image index:count target:self action:@selector(previewButton:)];
}

- (void)previewButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    self.previewButton = button;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"预览", @"移除", nil];
    actionSheet.tag = button.tag;
    [actionSheet showInView:self.theSuperView];
}

#pragma mark - Action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSUInteger tag = self.previewButton.tag;
    if (actionSheet.tag == tag)
    {
        AttachmentVo *attachmentVo = [self.attachList objectAtIndex:tag];
        if (buttonIndex == 0)
        {
            //预览
            if (attachmentVo.nAttachType == 0)
            {
                //图片
                NSMutableArray *aryImageURL = [NSMutableArray array];
                for (AttachmentVo *attachmentVo  in self.attachList)
                {
                    if (attachmentVo.strAttachLocalPath == nil)
                    {
                        continue;
                    }
                    
                    NSURL *urlMax = [NSURL fileURLWithPath:attachmentVo.strAttachLocalPath];
                    NSURL *urlMin = [NSURL fileURLWithPath:attachmentVo.strAttachLocalPath];
                    
                    if (urlMax == nil || urlMin == nil)
                    {
                        continue;
                    }
                    
                    NSArray *ary = @[urlMax,urlMin];
                    [aryImageURL addObject:ary];
                }
                
                SDWebImageDataSource *dataSource = [[SDWebImageDataSource alloc] init];
                dataSource.images_ = aryImageURL;
                KTPhotoScrollViewController *photoScrollViewController = [[KTPhotoScrollViewController alloc]
                                                                          initWithDataSource:dataSource
                                                                          andStartWithPhotoAtIndex:tag];
                photoScrollViewController.bShowToolBarBtn = NO;
                UIViewController *viewController = (UIViewController *)self.delegateFaceToolBar;
                [viewController.navigationController pushViewController:photoScrollViewController animated:YES];
            }
            else
            {
                //other attachment
            }
        }
        else if (buttonIndex == 1)
        {
            //移除
            if (attachmentVo.strAttachLocalPath)
            {
                NSFileManager *fileManager = [NSFileManager defaultManager];
                BOOL fileExists = [fileManager fileExistsAtPath:attachmentVo.strAttachLocalPath];
                if (fileExists)
                {
                    [fileManager removeItemAtPath:attachmentVo.strAttachLocalPath error:nil];
                }
                
                [self.attachList removeObjectAtIndex:tag];
                [self deleteSubView:tag];
                [self.aryAssets removeObjectAtIndex:tag];
            }
        }
    }
}

//重置布局
- (void)deleteSubView:(NSUInteger)index
{
    NSMutableArray *resultList = [[NSMutableArray alloc] init];
    for (UIView *subView in contentView.subviews)
    {
        if ([subView isKindOfClass:[UIButton class]])
        {
            if (subView.tag != index)
            {
                [resultList addObject:subView];
            }
        }
    }
    
    [contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for ( int i = 0 ; i < [resultList count] ; i++ )
    {
        UIView *subView = [resultList objectAtIndex:i];
        subView.frame = CGRectMake(26+((64 + 26)*i), 18, 64, 64);
        subView.tag = i;
        [contentView addSubview:subView];
    }
    [contentView setContentSize:CGSizeMake((64 + 26)*[resultList count] + 26, 64)];
}

//移除所有文件视图
- (void)deleteAllAttachView
{
    [contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

@end
