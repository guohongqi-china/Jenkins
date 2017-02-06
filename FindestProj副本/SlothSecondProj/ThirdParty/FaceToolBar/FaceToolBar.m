//
//  FaceToolBar.m
//  TestKeyboard
//
//  Created by wangjianle on 13-2-26.
//  Copyright (c) 2013年 wangjianle. All rights reserved.
//

#import "FaceToolBar.h"
#import "SYTextAttachment.h"
#import "Utils.h"
#import "VoiceConverter.h"
#import "Common.h"
#import "SkinManage.h"

@implementation FaceToolBar
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
    
    [self.timerAudio invalidate];
    self.timerAudio = nil;
}

-(id)init:(CGRect)rcView superView:(UIView *)superView
{
    self = [super init];
    if (self) 
    {
        //初始化为NO
        keyboardIsShow=NO;
        bBottomShow = NO;
        self.bTouchFunctionButton = NO;
        self.bRecording = NO;
        self.theSuperView=superView;
        self.rcSuperView = rcView;
        
        self.toolBar = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f,rcSuperView.size.height - toolBarHeight,rcSuperView.size.width,toolBarHeight)];
        self.toolBar.image = [[UIImage imageNamed:@"chat_tool_bk"]stretchableImageWithLeftCapWidth:160 topCapHeight:0];
        self.toolBar.userInteractionEnabled = YES;
        
        CGFloat fLeftOffset = 5;
        //语音按钮
        self.btnAudio = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnAudio.tag = 0;//当tag=1时处于键盘图标状态，tag=0时处于普通状态
        self.btnAudio.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        [self.btnAudio setBackgroundImage:[UIImage imageNamed:@"chat_bottom_voice_nor"] forState:UIControlStateNormal];
        [self.btnAudio setBackgroundImage:[UIImage imageNamed:@"chat_bottom_voice_press"] forState:UIControlStateHighlighted];
        [self.btnAudio addTarget:self action:@selector(clickMoreButton:) forControlEvents:UIControlEventTouchUpInside];
        self.btnAudio.frame = CGRectMake(fLeftOffset,toolBar.bounds.size.height-38.0f,buttonWh,buttonWh);
        [toolBar addSubview:self.btnAudio];
        fLeftOffset += buttonWh + 5;

        //可以自适应高度的文本输入框40, 5, 220, 0
        self.textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(fLeftOffset, 6, kScreenWidth-fLeftOffset-2*(buttonWh+5)-3, 34)];
        textView.isScrollable = NO;
        textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);//(0, 5, 0, 5)
        textView.minNumberOfLines = 1;
        textView.maxNumberOfLines = 5;
        textView.returnKeyType = UIReturnKeySend;
        textView.enablesReturnKeyAutomatically = YES;
        textView.font = [UIFont fontWithName:@"Helvetica" size:15];
        textView.delegate = self;
        textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
        textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;// | UIViewAutoresizingFlexibleTopMargin;
        [toolBar addSubview:textView];
        fLeftOffset += self.textView.frame.size.width+5;
        
        //录音按钮
        self.btnRecord = [UIButton buttonWithType:UIButtonTypeCustom];//UIButtonTypeCustom
        self.btnRecord.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [self.btnRecord setTitle:@"按住 说话" forState:UIControlStateNormal];
        [self.btnRecord setTitle:@"松开 结束" forState:UIControlStateHighlighted];
        [self.btnRecord setTitleColor:COLOR(86, 86, 86, 1.0) forState:UIControlStateNormal];
        [self.btnRecord setTitleColor:COLOR(68, 68, 68, 1.0) forState:UIControlStateHighlighted];
        [self.btnRecord setBackgroundImage:[[UIImage imageNamed:@"VoiceBtn_Black"]stretchableImageWithLeftCapWidth:28 topCapHeight:20] forState:UIControlStateNormal];
        [self.btnRecord setBackgroundImage:[[UIImage imageNamed:@"VoiceBtn_BlackHL"]stretchableImageWithLeftCapWidth:28 topCapHeight:20] forState:UIControlStateHighlighted];
        [self.btnRecord addTarget:self action:@selector(recordStart) forControlEvents:UIControlEventTouchDown];//开始录音（显示手指上滑，取消发送）
        [self.btnRecord addTarget:self action:@selector(recordStop) forControlEvents:UIControlEventTouchUpInside];//录音结束
        [self.btnRecord addTarget:self action:@selector(recordCancel) forControlEvents:UIControlEventTouchUpOutside];//取消录音
        [self.btnRecord addTarget:self action:@selector(dragExit) forControlEvents:UIControlEventTouchDragExit];//触摸拖动到录音按钮外面（显示松开手指，取消发送）
        [self.btnRecord addTarget:self action:@selector(dragEnter) forControlEvents:UIControlEventTouchDragEnter];//触摸拖动到录音按钮里面（显示手指上滑，取消发送）
        self.btnRecord.frame = CGRectMake(self.textView.frame.origin.x,3,self.textView.frame.size.width,40);
        self.btnRecord.hidden = YES;
        [toolBar addSubview:self.btnRecord];
        
        //表情按钮
        self.btnFacial = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnFacial.tag = 0;//当tag=1时处于键盘图标状态，tag=0时处于普通状态
        self.btnFacial.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        [self.btnFacial setBackgroundImage:[UIImage imageNamed:@"chat_bottom_smile_nor"] forState:UIControlStateNormal];
        [self.btnFacial setBackgroundImage:[UIImage imageNamed:@"chat_bottom_smile_press"] forState:UIControlStateHighlighted];
        [self.btnFacial addTarget:self action:@selector(clickMoreButton:) forControlEvents:UIControlEventTouchUpInside];
        self.btnFacial.frame = CGRectMake(fLeftOffset,toolBar.bounds.size.height-38.0f,buttonWh,buttonWh);
        [toolBar addSubview:self.btnFacial];
        fLeftOffset += buttonWh+5;
        
        //更多功能按钮
        self.btnMore = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnMore.tag = 0;//当tag=1时处于键盘图标状态，tag=0时处于普通状态
        btnMore.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        [btnMore setBackgroundImage:[UIImage imageNamed:@"chat_bottom_up_nor"] forState:UIControlStateNormal];
        [btnMore setBackgroundImage:[UIImage imageNamed:@"chat_bottom_up_press"] forState:UIControlStateHighlighted];
        [btnMore addTarget:self action:@selector(clickMoreButton:) forControlEvents:UIControlEventTouchUpInside];
        btnMore.frame = CGRectMake(fLeftOffset,toolBar.bounds.size.height-38.0f,buttonWh,buttonWh);
        [toolBar addSubview:btnMore];
        
        //给键盘注册通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
      
        //创建更多键盘
        self.viewContainer=[[UIView alloc] initWithFrame:CGRectMake(0, superView.frame.size.height, superView.frame.size.width, keyboardHeight)];
        self.viewContainer.backgroundColor = COLOR(255, 255, 255, 1.0);
        
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
        
        //更多视图
        self.scrollViewMore = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0,superView.frame.size.width, keyboardHeight)];
        self.scrollViewMore.backgroundColor = COLOR(255, 255, 255, 1.0);
        [self.scrollViewMore setShowsVerticalScrollIndicator:NO];
        [self.scrollViewMore setShowsHorizontalScrollIndicator:NO];
        self.scrollViewMore.contentSize=CGSizeMake(kScreenWidth+0.5, keyboardHeight);
        self.scrollViewMore.pagingEnabled=YES;
        self.scrollViewMore.delegate=self;
        self.scrollViewMore.scrollsToTop = NO;
        [self.viewContainer addSubview:self.scrollViewMore];
        
        //a:photo picture
        UIButton *btnPic = [UIButton buttonWithType:UIButtonTypeCustom];
        btnPic.frame = CGRectMake(16, 16, 55, 55);
        btnPic.tag = 5001;
        [btnPic setBackgroundImage:[UIImage imageNamed:@"chat_pic"] forState:UIControlStateNormal];
        [btnPic addTarget:self action:@selector(clickMore:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollViewMore addSubview:btnPic];
        
        UILabel *lblPic = [[UILabel alloc]initWithFrame:CGRectMake(16, 76, 55, 15)];
        lblPic.text = @"照片";
        lblPic.textColor = COLOR(166, 143, 136, 1);
        lblPic.font = [UIFont fontWithName:@"Helvetica" size:12.0];
        lblPic.backgroundColor = [UIColor clearColor];
        lblPic.textAlignment = NSTextAlignmentCenter;
        [self.scrollViewMore addSubview:lblPic];
        
        //b:camera
        UIButton *btnCamera = [UIButton buttonWithType:UIButtonTypeCustom];
        btnCamera.frame = CGRectMake(93, 16, 55, 55);
        btnCamera.tag = 5002;
        [btnCamera setBackgroundImage:[UIImage imageNamed:@"chat_camera"] forState:UIControlStateNormal];
        [btnCamera addTarget:self action:@selector(clickMore:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollViewMore addSubview:btnCamera];
        
        UILabel *lblCamera = [[UILabel alloc]initWithFrame:CGRectMake(93, 76, 55, 15)];
        lblCamera.text = @"拍照";
        lblCamera.textColor = COLOR(166, 143, 136, 1);
        lblCamera.font = [UIFont fontWithName:@"Helvetica" size:12.0];
        lblCamera.backgroundColor = [UIColor clearColor];
        lblCamera.textAlignment = NSTextAlignmentCenter;
        [self.scrollViewMore addSubview:lblCamera];
        
        [superView addSubview:self.viewContainer];
        [superView addSubview:toolBar];
        
        //录音提示
        self.audioTipView  = [[AudioTipView alloc]initWithFrame:CGRectMake((kScreenWidth-150)/2, (kScreenHeight-150)/2, 150, 150)];
        [superView addSubview:self.audioTipView];
        self.audioTipView.hidden = YES;
    }
    return self;
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
        [strMutable addAttributes:@{NSFontAttributeName:self.textView.font} range:NSMakeRange(0, strMutable.length)];
        self.textView.internalTextView.attributedText = strMutable;
        [self.textView textViewDidChange:self.textView.internalTextView];
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
        NSRange rangeSelect = self.textView.internalTextView.selectedRange;
        [strMutable insertAttributedString:imageStr atIndex:rangeSelect.location+rangeSelect.length];
        
        //添加字体
        [strMutable addAttributes:@{NSFontAttributeName:self.textView.font} range:NSMakeRange(0, strMutable.length)];
        self.textView.internalTextView.attributedText = strMutable;
        
        //设置光标位置+1
        self.textView.internalTextView.selectedRange = NSMakeRange(rangeSelect.location + 1, 0);
        [self.textView textViewDidChange:self.textView.internalTextView];
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
	CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.theSuperView convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
	CGRect containerFrame = toolBar.frame;
    containerFrame.origin.y = self.theSuperView.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
	toolBar.frame = containerFrame;
    
	// commit animations
	[UIView commitAnimations];
    
    //////////////////////////////////////////////////////
    [self.btnFacial setBackgroundImage:[UIImage imageNamed:@"chat_bottom_smile_nor"] forState:UIControlStateNormal];
    [self.btnFacial setBackgroundImage:[UIImage imageNamed:@"chat_bottom_smile_press"] forState:UIControlStateHighlighted];
    self.btnFacial.tag = 0;
    self.btnMore.tag = 0;
    keyboardIsShow=YES;
    bBottomShow = YES;
    
    //notify the main view about the toolbar height
    [self changeChatViewHeight];
}

-(void)inputKeyboardWillHide:(NSNotification *)notification
{
    ///////////////////////////////////////////////////////////////////////////////
    keyboardIsShow=NO;
    
    if(self.bTouchFunctionButton)
    {
        //点击toolbar 功能键，则不做处理
    }
    else
    {
        bBottomShow = YES;
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
    if (textView.text.length>0)
    {
        if ([delegateFaceToolBar respondsToSelector:@selector(sendTextAction:)])
        {
            [delegateFaceToolBar sendTextAction:textView.internalTextView.attributedText];
        }
    }
    return YES;
}

#pragma mark ActionMethods  发送sendAction
-(void)sendAction
{
    if (textView.text.length>0)
    {
        if ([delegateFaceToolBar respondsToSelector:@selector(sendTextAction:)])
        {
            [delegateFaceToolBar sendTextAction:textView.internalTextView.attributedText];
        }
    }
}

/////////////////////////////////////////////////////////////////
#pragma mark 隐藏键盘
-(void)dismissKeyBoard
{
    //判断键盘是否已经隐藏 toolBar.frame.origin.y < (kScreenHeight-toolBarHeight)
    if (bBottomShow)
    {
        //键盘显示的时候，toolbar需要还原到正常位置，并显示表情
        [UIView animateWithDuration:Time animations:^{
            toolBar.frame = CGRectMake(0, self.rcSuperView.size.height-toolBar.frame.size.height,  self.rcSuperView.size.width,toolBar.frame.size.height);
        }];
        
        [UIView animateWithDuration:Time animations:^{
            [self.viewContainer setFrame:CGRectMake(0, self.rcSuperView.size.height,self.rcSuperView.size.width, keyboardHeight)];
        }];
        [textView resignFirstResponder];
        
        //notify the main view about the toolbar height
        [self changeChatViewHeight];
        bBottomShow = NO;
    }
    
    //更新按钮图标
    [self.btnFacial setBackgroundImage:[UIImage imageNamed:@"chat_bottom_smile_nor"] forState:UIControlStateNormal];
    [self.btnFacial setBackgroundImage:[UIImage imageNamed:@"chat_bottom_smile_press"] forState:UIControlStateHighlighted];
    
    self.btnFacial.tag = 0;
    self.btnMore.tag = 0;
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
    if(self.bRecording)
    {
        //正在录音，则不响应
        return;
    }
        
    //更新状态
    bBottomShow = YES;
    if (sender == self.btnAudio)
    {
        //点击音频按钮
        if(sender.tag == 0)
        {
            //进行音频操作，隐藏键盘，将toolBar移到底部
            keyboardIsShow = NO;
            
            [textView resignFirstResponder];
            
            [UIView animateWithDuration:Time animations:^{
                toolBar.frame = CGRectMake(0, self.rcSuperView.size.height-toolBar.frame.size.height,  self.rcSuperView.size.width,toolBar.frame.size.height);
            }];
            //隐藏viewContainer
            [UIView animateWithDuration:Time animations:^{
                [self.viewContainer setFrame:CGRectMake(0, self.rcSuperView.size.height, self.rcSuperView.size.width, keyboardHeight)];
            }];
            
            //notify the main view about the toolbar height
            [self changeChatViewHeight];
        }
        else
        {
            //弹出键盘操作，音频按钮恢复
            keyboardIsShow = YES;
            
            [textView becomeFirstResponder];
            
            [self.btnAudio setBackgroundImage:[UIImage imageNamed:@"chat_bottom_voice_nor"] forState:UIControlStateNormal];
            [self.btnAudio setBackgroundImage:[UIImage imageNamed:@"chat_bottom_voice_press"] forState:UIControlStateHighlighted];
            self.btnAudio.tag = 0;

            self.textView.hidden = NO;
            self.btnRecord.hidden = YES;
        }
    }
    else
    {
        //点击表情或者更多按钮
        if (toolBar.frame.origin.y== (self.rcSuperView.size.height - toolBarHeight) && toolBar.frame.size.height==toolBarHeight)
        {
            //如果直接点击表情，通过toolbar的位置来判断
            [UIView animateWithDuration:Time animations:^{
                toolBar.frame = CGRectMake(0, self.rcSuperView.size.height-keyboardHeight-toolBarHeight,  self.rcSuperView.size.width,toolBarHeight);
            }];
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
                
                self.bTouchFunctionButton = YES;
                [textView resignFirstResponder];
                self.bTouchFunctionButton = NO;
            }
        }
    }
    
    if(keyboardIsShow)
    {
        //键盘已经显示
        self.btnAudio.tag = 0;
        self.btnFacial.tag = 0;
        self.btnMore.tag = 0;
    }
    else
    {
        if (sender == self.btnFacial)
        {
            //表情视图
            self.textView.hidden = NO;
            self.btnRecord.hidden = YES;
            self.scrollViewFacial.hidden = NO;
            self.scrollViewMore.hidden = YES;
            
            [self.btnAudio setBackgroundImage:[UIImage imageNamed:@"chat_bottom_voice_nor"] forState:UIControlStateNormal];
            [self.btnAudio setBackgroundImage:[UIImage imageNamed:@"chat_bottom_voice_press"] forState:UIControlStateHighlighted];
            [self.btnFacial setBackgroundImage:[UIImage imageNamed:@"chat_bottom_keyboard_nor"] forState:UIControlStateNormal];
            [self.btnFacial setBackgroundImage:[UIImage imageNamed:@"chat_bottom_keyboard_press"] forState:UIControlStateHighlighted];
            
            self.btnAudio.tag = 0;
            self.btnFacial.tag = 1;
            self.btnMore.tag = 0;
        }
        else if (sender == self.btnMore)
        {
            //更多视图
            self.textView.hidden = NO;
            self.btnRecord.hidden = YES;
            self.scrollViewFacial.hidden = YES;
            self.scrollViewMore.hidden = NO;
            
            [self.btnAudio setBackgroundImage:[UIImage imageNamed:@"chat_bottom_voice_nor"] forState:UIControlStateNormal];
            [self.btnAudio setBackgroundImage:[UIImage imageNamed:@"chat_bottom_voice_press"] forState:UIControlStateHighlighted];
            [self.btnFacial setBackgroundImage:[UIImage imageNamed:@"chat_bottom_smile_nor"] forState:UIControlStateNormal];
            [self.btnFacial setBackgroundImage:[UIImage imageNamed:@"chat_bottom_smile_press"] forState:UIControlStateHighlighted];
            
            self.btnAudio.tag = 0;
            self.btnFacial.tag = 0;
            self.btnMore.tag = 1;
        }
        else if (sender == self.btnAudio)
        {
            //语音
            self.textView.hidden = YES;
            self.btnRecord.hidden = NO;
            self.scrollViewFacial.hidden = YES;
            self.scrollViewMore.hidden = YES;
            
            [self.btnAudio setBackgroundImage:[UIImage imageNamed:@"chat_bottom_keyboard_nor"] forState:UIControlStateNormal];
            [self.btnAudio setBackgroundImage:[UIImage imageNamed:@"chat_bottom_keyboard_press"] forState:UIControlStateHighlighted];
            [self.btnFacial setBackgroundImage:[UIImage imageNamed:@"chat_bottom_smile_nor"] forState:UIControlStateNormal];
            [self.btnFacial setBackgroundImage:[UIImage imageNamed:@"chat_bottom_smile_press"] forState:UIControlStateHighlighted];
            
            self.btnAudio.tag = 1;
            self.btnFacial.tag = 0;
            self.btnMore.tag = 0;
        }
    }
}

//录音操作///////////////////////////////////////////////////////////////
//a:开始录音
-(void)recordStart
{
    //判断隐私中相册是否启用
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (authStatus != AVAuthorizationStatusAuthorized && authStatus != AVAuthorizationStatusNotDetermined)
    {
        [Common tipAlert:[NSString stringWithFormat:@"请在iPhone的“设置-隐私-麦克风”选项中，允许%@访问你的手机麦克风。",APP_NAME]];
        return;
    }
    
    if (self.bRecording)
    {
        return;
    }
    
    //显示录音提示
    self.audioTipView.hidden = NO;
    [self.audioTipView updateView:2 andValue:0];
    
    self.bRecording = YES;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    //语音录制目标文件
    self.strCurrPath = [[Utils getTempPath] stringByAppendingPathComponent:[Common createFileNameByDateTime:@"wav"]];
    NSURL *audioRecordUrl = [[NSURL alloc] initFileURLWithPath:self.strCurrPath];
    
    //录音设置
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    //录音格式
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey: AVFormatIDKey];
    //采样率
    [recordSetting setValue :[NSNumber numberWithFloat:8000] forKey: AVSampleRateKey];//
    //通道数
    [recordSetting setValue :[NSNumber numberWithInt:1] forKey: AVNumberOfChannelsKey];//1
    //线性采样位数
    [recordSetting setValue :[NSNumber numberWithInt:16] forKey: AVLinearPCMBitDepthKey];//16
    [recordSetting setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordSetting setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    //实例化AVAudioRecorder
    self.recorder = nil;
    NSError *error;
    self.recorder = [[AVAudioRecorder alloc] initWithURL:audioRecordUrl settings:recordSetting error:&error];
    self.recorder.meteringEnabled = YES;//开启音量检测
    //创建录音文件,准备录音
    if ([self.recorder prepareToRecord])
    {
        //开始录音停止播音操作以及其他点击
        if (self.delegateFaceToolBar != nil && [self.delegateFaceToolBar respondsToSelector:@selector(recordAudioStateChanged:)])
        {
            [self.delegateFaceToolBar recordAudioStateChanged:YES];
        }
        
        //开始录音
        self.timerAudio = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(timerAudioSignal) userInfo:nil repeats:YES];
        [self.recorder record];
    }
    else
    {
        [Common tipAlert:[NSString stringWithFormat:@"录音失败，请重新尝试.%@",error]];
        self.bRecording = NO;
    }
}

//b:录音结束,发送到后台
-(void)recordStop
{
    [self.btnRecord setBackgroundImage:[[UIImage imageNamed:@"VoiceBtn_Black"]stretchableImageWithLeftCapWidth:28 topCapHeight:20] forState:UIControlStateNormal];
    //从录制开始到现在的时间，该时间一直在增加（设断点调试会导致时间不一致）
    NSInteger nLength = floor(self.recorder.currentTime);
    //处理录音结束
    [self tackleRecordFinished];
    
    //将wav文件 转为 amr文件
    NSString *strAmrPath = [VoiceConverter wavToAmr:self.strCurrPath];
    if (nLength>0)
    {
        //发送到服务器端
        self.audioTipView.hidden = YES;
        NSString *strDuration = [NSString stringWithFormat:@"%li",(long)nLength];
        [self.delegateFaceToolBar sendAudioAction:strAmrPath andDuration:strDuration];
    }
    else
    {
        //说话时间太短
        self.audioTipView.hidden = NO;
        [self.audioTipView updateView:1 andValue:0];
    }
}

//c:取消录音
-(void)recordCancel
{
    [self tackleRecordFinished];
    [self.btnRecord setBackgroundImage:[[UIImage imageNamed:@"VoiceBtn_Black"]stretchableImageWithLeftCapWidth:28 topCapHeight:20] forState:UIControlStateNormal];
}

//d:触摸拖动到录音按钮外面（显示松开手指，取消发送）
-(void)dragExit
{
    //显示录音提示
    self.audioTipView.hidden = NO;
    [self.audioTipView updateView:3 andValue:0];
    
    [self.btnRecord setBackgroundImage:[[UIImage imageNamed:@"VoiceBtn_BlackHL"]stretchableImageWithLeftCapWidth:28 topCapHeight:20] forState:UIControlStateNormal];
}

//e:触摸拖动到录音按钮里面（显示手指上滑，取消发送）
-(void)dragEnter
{
    //显示录音提示
    self.audioTipView.hidden = NO;
    [self updateAudioSignal:2];
}

//处理录音结束的操作
-(void)tackleRecordFinished
{
    //clear timer
    [self.timerAudio invalidate];
    self.timerAudio = nil;
    
    self.audioTipView.hidden = YES;
    [self.recorder stop];
    self.recorder = nil;
    self.bRecording = NO;
    
    //录音结束，恢复状态
    if (self.delegateFaceToolBar != nil && [self.delegateFaceToolBar respondsToSelector:@selector(recordAudioStateChanged:)])
    {
        [self.delegateFaceToolBar recordAudioStateChanged:NO];
    }
    
    //临时文件放在登录的时候清理
}

//刷新音量大小的定时函数
-(void)timerAudioSignal
{
    [self updateAudioSignal:-1];
}

//刷新音量大小以及10秒倒计时
-(void)updateAudioSignal:(NSInteger)nType
{
    NSTimeInterval timeInterval = self.recorder.currentTime;
    if (timeInterval>60)
    {
        //当大于60秒停止录音
        [self recordStop];
    }
    
    [self.recorder updateMeters];
    //获取音量的值,然后转化到0~1的值
    float vol = pow(10, (0.05 * [self.recorder peakPowerForChannel:0]));
    if (timeInterval>50)
    {
        [self.audioTipView updateView:nType andValue:60-timeInterval];//倒数计时
    }
    else
    {
        if(vol>=1)
        {
            vol = 0.99999;//防止与倒计时冲突，音量值会超过1
        }
        [self.audioTipView updateView:nType andValue:vol];//更新音量大小
    }
}

//more button action
-(void)clickMore:(UIButton*)sender
{
    [self.delegateFaceToolBar clickMoreBtnAction:sender];
}

@end