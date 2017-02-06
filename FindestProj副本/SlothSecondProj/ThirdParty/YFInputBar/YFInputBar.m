//
//  YFInputBar.m
//  test
//
//  Created by 杨峰 on 13-11-10.
//  Copyright (c) 2013年 杨峰. All rights reserved.
//

#import "YFInputBar.h"
#import "AppDelegate.h"
#import "UIViewExt.h"
#import "Utils.h"

@implementation YFInputBar{
    UIImageView *inputTextFieldBgView;//输入框背景
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        self.frame = CGRectMake(0, CGRectGetMinY(frame), kScreenWidth, CGRectGetHeight(frame));
       
        UIImageView *imgViewBK = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth,44)];
        imgViewBK.backgroundColor = [UIColor whiteColor];
        inputTextFieldBgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, self.height-15, kScreenWidth-65, 10)];
        inputTextFieldBgView.image = [UIImage imageNamed:@"inputTextFieldBg"];
        [self addSubview:inputTextFieldBgView];
        UIImageView *lineImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 0.5)];
        lineImage.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:lineImage];
        [self sendSubviewToBack:inputTextFieldBgView];
        
        self.textField.tag = 10000;
        self.sendBtn.tag = 10001;
        
//        //注册键盘通知
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        ///////////////////////////////////////////////////////////////////////////////
        //attach view and tool view
//        self.attachView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-45, kScreenWidth, 45)];
//        self.attachView.backgroundColor = [UIColor clearColor];
//        [self addSubview:self.attachView];
        
//        self.btnAttach = [UIButton buttonWithType:UIButtonTypeCustom];
//        [self.btnAttach.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:15.0]];
//        self.btnAttach.frame = CGRectMake(kScreenWidth-60, 10, 50, 25);
//        [self.btnAttach setBackgroundImage:[[UIImage imageNamed:@"btn_attach_bk"] stretchableImageWithLeftCapWidth:16 topCapHeight:9] forState:UIControlStateNormal];
//        [self.btnAttach setTitle:@"照片" forState:UIControlStateNormal];
//        [self.btnAttach addTarget:self action:@selector(clickToolViewBtn:) forControlEvents:UIControlEventTouchUpInside];
//        [self.attachView addSubview:self.btnAttach];
        
        //表情按钮
        self.btnFace = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.btnFace setImage:[UIImage imageNamed:@"chat_bottom_smile_nor"] forState:UIControlStateNormal];
        [self.btnFace addTarget:self action:@selector(clickToolViewBtn:) forControlEvents:UIControlEventTouchUpInside];
        self.btnFace.frame = CGRectMake(kScreenWidth-110, 5, 70, 34);//kScreenWidth-60-50
        [self addSubview:self.btnFace];
        
        //工具栏
        self.toolView = [[ToolView alloc] initWithFrame:CGRectMake(0, 44, kScreenWidth, TOOL_VIEW_HEIGHT)];
        //self.toolView.textView = self.textField;
        self.toolView.toolViewDelegate = self;
        [self addSubview:self.toolView];
        
        //注册键盘侦听事件
        [self registerForKeyboardNotifications];
    }
    return self;
}

////////////////////////////////////////////////////////////////
//tool view button
- (void)clickToolViewBtn:(UIButton*)sender
{
    if (self.keyboardIsShow || self.toolView.frame.origin.y == kScreenHeight
        || (sender == self.btnAttach && self.toolView.viewAttach.hidden == YES)         //若是附件按钮点击，但是当前没有显示附件视图
        || (sender == self.btnFace && self.toolView.scrollViewFacial.hidden == YES))    //若是表情按钮点击，但是当前没有显示表情视图
    {
        [[Utils findFirstResponderBeneathView:self] resignFirstResponder];
        
        [UIView animateWithDuration:0.25 animations:^{
//            self.toolView.frame = CGRectMake(0, kScreenHeight-TOOL_VIEW_HEIGHT, kScreenWidth, TOOL_VIEW_HEIGHT);
//            self.frame = CGRectMake(0, self.toolView.top-44, kScreenWidth, 44);
            [self.textField resignFirstResponder];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.25 animations:^{
            //self.toolView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, KEYBOARD_HEIGHT);
            [self.textField becomeFirstResponder];
        }];
    }
    
    //更新ToolView显示状态
    if (sender == self.btnAttach)
    {
        self.toolView.viewAttach.hidden = NO;
        self.toolView.scrollViewFacial.hidden = YES;
        self.toolView.pageControlFace.hidden = YES;
    }
    else
    {
        self.toolView.viewAttach.hidden = YES;
        self.toolView.scrollViewFacial.hidden = NO;
        self.toolView.pageControlFace.hidden = NO;
    }
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification *)aNotification
{
    [self keyboardWillShow:aNotification];
    
//    NSDictionary* info = [aNotification userInfo];
//    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.25];
//    self.toolView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, TOOL_VIEW_HEIGHT);
//    self.attachView.frame = CGRectMake(0, kScreenHeight-kbSize.height-self.attachView.frame.size.height, kScreenWidth, self.attachView.frame.size.height);
//    self.frame = CGRectMake(0, self.attachView.frame.origin.y-131, kScreenWidth, 44);
//    [UIView commitAnimations];
//    
//    self.keyboardIsShow = YES;
}

- (void)keyboardWillBeHidden:(NSNotification *)aNotification
{
    [self keyboardWillHide:aNotification];
    
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.25];
//    self.attachView.frame = CGRectMake(0, kScreenHeight-self.attachView.frame.size.height, kScreenWidth, self.attachView.frame.size.height);
//    self.frame = CGRectMake(0, self.attachView.frame.origin.y-131, kScreenWidth, 44);
//    [UIView commitAnimations];
//    self.keyboardIsShow = NO;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _originalFrame = frame;
}

//_originalFrame的set方法  因为会调用setFrame  所以就不在此做赋值；
-(void)setOriginalFrame:(CGRect)originalFrame
{
    self.frame = CGRectMake(0, CGRectGetMinY(originalFrame), kScreenWidth, CGRectGetHeight(originalFrame));
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark get方法实例化输入框／btn
-(HPGrowingTextView *)textField
{
    if (!_textField) 
    {
        CGFloat fLeftOffset = 16;
        _textField = [[HPGrowingTextView alloc]initWithFrame:CGRectMake(fLeftOffset, 6, kScreenWidth-fLeftOffset-52, 15)];
        _textField.backgroundColor = [UIColor clearColor];
        //可以自适应高度的文本输入框40, 5, 220, 0
        _textField.isScrollable = NO;
        _textField.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);//(0, 5, 0, 5)
        _textField.minNumberOfLines = 1;
        _textField.maxNumberOfLines = 3;
        _textField.returnKeyType = UIReturnKeySend;
        _textField.font = [UIFont fontWithName:@"Helvetica" size:15];
        _textField.delegate = self;
        _textField.placeholder = @"评论";
        _textField.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
        _textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;// | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_textField];
        _textField.internalTextView.layer.backgroundColor = [[UIColor clearColor] CGColor];
        _textField.internalTextView.layer.borderColor = [[UIColor clearColor]CGColor];
        [self addSubview:_textField];
    }
    return _textField;
}

-(UIButton *)sendBtn
{
    if (!_sendBtn) {
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendBtn setFrame:CGRectMake(kScreenWidth-50, 0, 51, 44)];
        [_sendBtn setImage:[UIImage imageNamed:@"send_btn"] forState:UIControlStateNormal];
        [_sendBtn addTarget:self action:@selector(sendBtnPress:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_sendBtn];
    }
    return _sendBtn;
}

#pragma mark HPGrowingTextViewDelegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
    CGRect r = self.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    self.frame = r;
    inputTextFieldBgView.bottom = self.height-5;
    _sendBtn.bottom = self.height -5;
}

- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView{
    [self sendBtnPress:_sendBtn];
    return  YES;
}

#pragma mark selfDelegate method
-(void)sendBtnPress:(UIButton*)sender
{
    if (self.textField.text.length == 0)
    {
        [Common tipAlert:[Common localStr:@"Common_Check_ContentEmpty" value:@"内容不能为空"]];
    }
    else
    {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(inputBar:sendBtnPress:withInputString:)])
        {
            [self.delegate inputBar:self sendBtnPress:sender withInputString:self.textField.text];
        }
        if (self.clearInputWhenSend)
        {
            self.textField.text = @"";
        }
        if (self.resignFirstResponderWhenSend)
        {
            [self resignFirstResponder];
        }
    }
}

#pragma mark keyboardNotification
- (void)keyboardWillShow:(NSNotification*)notification
{
    CGRect _keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //如果self在键盘之下 才做偏移
    if ([self convertYToWindow:CGRectGetMaxY(self.originalFrame)]>=_keyboardRect.origin.y)
    {
        //没有偏移 就说明键盘没出来，使用动画
        if (self.frame.origin.y== self.originalFrame.origin.y) {
            
            [UIView animateWithDuration:0.3
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.transform = CGAffineTransformMakeTranslation(0, -_keyboardRect.size.height+[self getHeighOfWindow]-CGRectGetMaxY(self.originalFrame));
                             } completion:nil];
        }
        else
        {
            self.transform = CGAffineTransformMakeTranslation(0, -_keyboardRect.size.height+[self getHeighOfWindow]-CGRectGetMaxY(self.originalFrame));
        }
    }
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.transform = CGAffineTransformMakeTranslation(0, 0);
                     } completion:nil];
}
#pragma  mark ConvertPoint
//将坐标点y 在window和superview转化  方便和键盘的坐标比对
-(float)convertYFromWindow:(float)Y
{
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    CGPoint o = [appDelegate.window convertPoint:CGPointMake(0, Y) toView:self.superview];
    return o.y;
    
}

-(float)convertYToWindow:(float)Y
{
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    CGPoint o = [self.superview convertPoint:CGPointMake(0, Y) toView:appDelegate.window];
    return o.y;
    
}

-(float)getHeighOfWindow
{
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    return appDelegate.window.frame.size.height;
}

-(BOOL)resignFirstResponder
{
    [self.textField resignFirstResponder];
    return [super resignFirstResponder];
}
@end
