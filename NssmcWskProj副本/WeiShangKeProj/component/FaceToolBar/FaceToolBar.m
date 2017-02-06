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

@implementation FaceToolBar
@synthesize theSuperView;
@synthesize delegateFaceToolBar;
@synthesize toolBar;            
@synthesize textView; 
@synthesize btnKnowledge;
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
        self.theSuperView=superView;
        self.rcSuperView = rcView;
        
        //默认toolBar在视图最下方ChatToolBar
        self.toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f,rcSuperView.size.height - toolBarHeight,rcSuperView.size.width,toolBarHeight)];
        toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        toolBar.barStyle = UIBarStyleDefault;
        toolBar.translucent = YES;
        UIImage *gradientImage44 = [[[UIImage imageNamed:@"chat_tool_bk"]stretchableImageWithLeftCapWidth:160 topCapHeight:0] resizableImageWithCapInsets:UIEdgeInsetsMake(44, 0, 44, 0)];
        [toolBar setBackgroundImage:gradientImage44 forToolbarPosition:0 barMetrics:UIBarMetricsDefault];
        
        CGFloat fLeftOffset = 5;
        //更多按钮
        self.btnSessionMore = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnSessionMore.tag = 0;//当tag=1时处于键盘图标状态，tag=0时处于普通状态
        self.btnSessionMore.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        [self.btnSessionMore setBackgroundImage:[UIImage imageNamed:@"chat_bottom_more_nor"] forState:UIControlStateNormal];
        [self.btnSessionMore addTarget:self action:@selector(clickMoreButton:) forControlEvents:UIControlEventTouchDown];
        self.btnSessionMore.frame = CGRectMake(fLeftOffset,toolBar.bounds.size.height-38.0f,buttonWh,buttonWh);
        [toolBar addSubview:self.btnSessionMore];
        fLeftOffset += buttonWh + 5;

        //可以自适应高度的文本输入框40, 5, 220, 0
        self.textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(fLeftOffset, 6, kScreenWidth-fLeftOffset-2*(buttonWh+5)-3, 30)];
        textView.isScrollable = NO;
        //textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);//(0, 5, 0, 5)
        textView.minNumberOfLines = 1;
        textView.maxNumberOfLines = 5;
        textView.returnKeyType = UIReturnKeySend;
        textView.font = [UIFont fontWithName:@"Helvetica" size:15];
        textView.delegate = self;
        textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
        textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;// | UIViewAutoresizingFlexibleTopMargin;
        textView.internalTextView.layer.borderWidth = 0.5;
        textView.internalTextView.layer.borderColor = COLOR(203, 203, 203, 1.0).CGColor;
        textView.internalTextView.layer.cornerRadius = 4.5;
        textView.internalTextView.layer.masksToBounds = YES;
        [toolBar addSubview:textView];
        fLeftOffset += self.textView.frame.size.width+5;
        
        //知识库按钮
        self.btnKnowledge = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnKnowledge.tag = 0;//当tag=1时处于键盘图标状态，tag=0时处于普通状态
        btnKnowledge.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        [btnKnowledge setBackgroundImage:[UIImage imageNamed:@"chat_bottom_up_nor"] forState:UIControlStateNormal];
        [btnKnowledge addTarget:self action:@selector(clickMoreButton:) forControlEvents:UIControlEventTouchUpInside];
        btnKnowledge.frame = CGRectMake(fLeftOffset,toolBar.bounds.size.height-38.0f,buttonWh,buttonWh);
        [toolBar addSubview:btnKnowledge];
        fLeftOffset += buttonWh+5;
        
        //表情按钮
        self.btnFacial = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnFacial.tag = 0;//当tag=1时处于键盘图标状态，tag=0时处于普通状态
        self.btnFacial.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        [self.btnFacial setBackgroundImage:[UIImage imageNamed:@"chat_bottom_smile_nor"] forState:UIControlStateNormal];
        [self.btnFacial addTarget:self action:@selector(clickMoreButton:) forControlEvents:UIControlEventTouchUpInside];
        self.btnFacial.frame = CGRectMake(fLeftOffset,toolBar.bounds.size.height-38.0f,buttonWh,buttonWh);
        [toolBar addSubview:self.btnFacial];
        
        //给键盘注册通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
      
        //创建更多键盘
        self.viewContainer=[[UIView alloc] initWithFrame:CGRectMake(0, superView.frame.size.height, superView.frame.size.width, keyboardHeight)];
        self.viewContainer.backgroundColor = COLOR(235, 236, 238, 1.0);
        
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
        CGFloat fOffsetW = 9+(kScreenWidth-320)/2;
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
                btnFaceIcon.frame = CGRectMake(self.nPage*kScreenWidth+fX, fY, fFaceW, fFaceH);
                [btnFaceIcon setBackgroundImage:[UIImage imageNamed:[dicFace objectForKey:@"image"]] forState:UIControlStateNormal];
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
                btnDelete.frame = CGRectMake(self.nPage*kScreenWidth+fX, fY, 30, 30);
                [btnDelete setBackgroundImage:[UIImage imageNamed:@"aio_face_delete"] forState:UIControlStateNormal];
                [btnDelete addTarget:self action:@selector(selectFace:) forControlEvents:UIControlEventTouchUpInside];
                [self.scrollViewFacial addSubview:btnDelete];
                
                //2.绘制第二页中第一个元素
                self.nPage++;//页码
                UIButton *btnFaceIcon = [UIButton buttonWithType:UIButtonTypeCustom];
                btnFaceIcon.tag = i;
                btnFaceIcon.frame = CGRectMake(self.nPage*kScreenWidth+fOffsetW, fOffsetH, fFaceW, fFaceH);
                [btnFaceIcon setBackgroundImage:[UIImage imageNamed:[dicFace objectForKey:@"image"]] forState:UIControlStateNormal];
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
            btnDelete.frame = CGRectMake(self.nPage*kScreenWidth+fX, fY, 30, 30);
            [btnDelete setBackgroundImage:[UIImage imageNamed:@"aio_face_delete"] forState:UIControlStateNormal];
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
        [self.btnSenderFacial setBackgroundImage:[Common getImageWithColor:THEME_COLOR] forState:UIControlStateNormal];
        self.btnSenderFacial.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [self.btnSenderFacial setTitle:[Common localStr:@"Common_NAV_Send" value:@"发  送"] forState:UIControlStateNormal];
        [self.btnSenderFacial setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btnSenderFacial addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
        self.btnSenderFacial.frame = CGRectMake(0,176,kScreenWidth,40);
        self.btnSenderFacial.enabled = NO;
        [self.viewContainer addSubview:self.btnSenderFacial];
        
        self.scrollViewFacial.contentSize=CGSizeMake(kScreenWidth*(self.nPage+1), keyboardHeight);
        
        //更多视图
        self.scrollViewMore = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0,superView.frame.size.width, keyboardHeight)];
        self.scrollViewMore.backgroundColor = COLOR(235, 236, 238, 1.0);
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
        lblPic.text = [Common localStr:@"Common_Btn_Photos" value:@"照片"];
        lblPic.textColor = COLOR(51, 51, 51, 1);
        lblPic.font = [UIFont fontWithName:@"Helvetica" size:14.0];
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
        lblCamera.text = [Common localStr:@"Common_Btn_Camera" value:@"拍照"];
        lblCamera.textColor = COLOR(51, 51, 51, 1);
        lblCamera.font = [UIFont fontWithName:@"Helvetica" size:14.0];
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
    if (iOSPlatform>=7)
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
    }
    else
    {
        //支持iOS 6
        if (sender.tag == 10000)
        {
            //删除按钮
            NSMutableString *strText = [NSMutableString stringWithString:self.textView.internalTextView.text];
            if (strText.length>0)
            {
                [strText deleteCharactersInRange:NSMakeRange(strText.length-1, 1)];
                self.textView.internalTextView.text = strText;
            }
        }
        else
        {
            //点击表情
            NSArray *aryFace = [AppDelegate getSlothAppDelegate].aryFace;
            NSDictionary *dicFace = [aryFace objectAtIndex:sender.tag];
            
            NSMutableString *strText = [NSMutableString stringWithString:self.textView.internalTextView.text];
            [strText appendString:[dicFace objectForKey:@"chs"]];
            self.textView.internalTextView.text = strText;
        }
    }
    
    [self.textView textViewDidChange:self.textView.internalTextView];
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
    [self.btnKnowledge setBackgroundImage:[UIImage imageNamed:@"chat_bottom_up_nor"] forState:UIControlStateNormal];
    self.btnFacial.tag = 0;
    self.btnKnowledge.tag = 0;
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

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
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
    [btnKnowledge setBackgroundImage:[UIImage imageNamed:@"chat_bottom_up_nor"] forState:UIControlStateNormal];
    
    self.btnFacial.tag = 0;
    self.btnKnowledge.tag = 0;
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
    if (sender == self.btnSessionMore)
    {
        //1.更多按钮，弹出UIActionSheet
        if ([self.delegateFaceToolBar respondsToSelector:@selector(clickSessionAction)])
        {
            [self.delegateFaceToolBar clickSessionAction];
        }
    }
    else if (sender == self.btnKnowledge)
    {
        //2.知识库按钮
        if ([self.delegateFaceToolBar respondsToSelector:@selector(clickFAQAction)])
        {
            [self.delegateFaceToolBar clickFAQAction];
        }
    }
    else
    {
        //3.表情按钮
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
        self.btnSessionMore.tag = 0;
        self.btnFacial.tag = 0;
        self.btnKnowledge.tag = 0;
    }
    else
    {
        if (sender == self.btnFacial)
        {
            //表情视图
            self.textView.hidden = NO;
            self.scrollViewFacial.hidden = NO;
            self.scrollViewMore.hidden = YES;
            
            [self.btnSessionMore setBackgroundImage:[UIImage imageNamed:@"chat_bottom_more_nor"] forState:UIControlStateNormal];
            [self.btnFacial setBackgroundImage:[UIImage imageNamed:@"chat_bottom_keyboard_nor"] forState:UIControlStateNormal];
            [self.btnKnowledge setBackgroundImage:[UIImage imageNamed:@"chat_bottom_up_nor"] forState:UIControlStateNormal];
            
            self.btnSessionMore.tag = 0;
            self.btnFacial.tag = 1;
            self.btnKnowledge.tag = 0;
        }
    }
}

//more button action
-(void)clickMore:(UIButton*)sender
{
    [self.delegateFaceToolBar clickMoreBtnAction:sender];
}

@end