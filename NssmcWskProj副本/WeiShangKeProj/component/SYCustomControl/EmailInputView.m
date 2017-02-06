//
//  EmailInputView.m
//  WeiShangKeProj
//
//  Created by 焱 孙 on 15/6/3.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "EmailInputView.h"
#import "UIViewExt.h"

@implementation EmailInputView

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = COLOR(0,0,0,0.5);
        self.aryData = [NSMutableArray array];
    }
    return self;
}

-(void)initView
{
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight)];
    self.bgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_bgView];
    
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelBtn.frame = CGRectMake(0, 5.5, 50, 31);
    [self.cancelBtn setTitleColor:COLOR(56, 57, 61, 1.0) forState:UIControlStateNormal];
    [self.cancelBtn.titleLabel setFont:[UIFont fontWithName:APP_FONT_NAME size:16.0]];
    self.cancelBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.cancelBtn setTitle:[Common localStr:@"Common_Cancel" value:@"取消"] forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(doCancel) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:self.cancelBtn];
    
    self.titleLab = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, kScreenWidth-120, 40)];
    self.titleLab.backgroundColor = [UIColor clearColor];
    self.titleLab.font = [UIFont systemFontOfSize:19];
    self.titleLab.textAlignment = NSTextAlignmentCenter;
    self.titleLab.text = self.titleStr;
    self.titleLab.textColor = COLOR(19, 19, 19, 1.0);
    [self.bgView addSubview:_titleLab];
    
    self.sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendBtn.frame = CGRectMake(kScreenWidth-50, 5.5, 50, 31);
    [self.sendBtn setTitleColor:COLOR(56, 57, 61, 1.0) forState:UIControlStateNormal];
    [self.sendBtn.titleLabel setFont:[UIFont fontWithName:APP_FONT_NAME size:16.0]];
    self.sendBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.sendBtn setTitle:[Common localStr:@"Common_NAV_Send" value:@"发送"] forState:UIControlStateNormal];
    [self.sendBtn addTarget:self action:@selector(doSend) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:self.sendBtn];
    
    self.scrollViewText = [[UIScrollView alloc]initWithFrame:CGRectMake(9, 40, kScreenWidth-18, 87)];
    self.scrollViewText.backgroundColor = COLOR(230, 230, 230, 1.0);
    self.scrollViewText.clipsToBounds = YES;
    [self.bgView addSubview:self.scrollViewText];
    
    self.inputTextView = [[JSTokenField alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth-18, 31)];
    self.inputTextView.backgroundColor = [UIColor clearColor];
    [[self.inputTextView label] setText:@""];
    [self.inputTextView setDelegate:self];
    [self.scrollViewText addSubview:self.inputTextView];
    
    //注册键盘侦听事件
    [self registerForKeyboardNotifications];
}

-(void)initInputViewControlValue
{
    [self.inputTextView.textField becomeFirstResponder];
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification *)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    self.bgView.frame = CGRectMake(0, kScreenHeight-137-kbSize.height, kScreenWidth, 400);
    [UIView commitAnimations];
}

-(void)doCancel
{
    if([self.delegate respondsToSelector:@selector(cancelEditEmail:)])
    {
        [self.delegate cancelEditEmail:self];
    }
}

-(void)doSend
{
    if (self.aryData.count == 0)
    {
        NSString *strEmail = self.inputTextView.textField.text;
        if (strEmail.length>0)
        {
            [self.delegate completeEditEmail:self email:[@[strEmail] mutableCopy]];
        }
        else
        {
            [Common tipAlert:@"内容不能为空"];
        }
    }
    else
    {
        [self.delegate completeEditEmail:self email:self.aryData];
    }
}

-(void)dismissEmailView
{
    [self removeFromSuperview];
}

#pragma mark JSTokenFieldDelegate
- (void)tokenField:(JSTokenField *)tokenField didAddToken:(NSString *)title representedObject:(id)obj
{
    [self.aryData addObject:obj];
    
    [self.scrollViewText setContentSize:CGSizeMake(kScreenWidth-18, tokenField.height)];
    if (tokenField.frame.size.height > self.scrollViewText.height)
    {
        [self.scrollViewText setContentOffset:CGPointMake(0, tokenField.height-self.scrollViewText.height) animated:YES];
    }
}

- (void)tokenField:(JSTokenField *)tokenField didRemoveToken:(NSString *)title representedObject:(id)obj
{
    [self.aryData removeObject:obj];
    [self.scrollViewText setContentSize:CGSizeMake(kScreenWidth-18, tokenField.frame.size.height)];
}

- (BOOL)tokenFieldShouldReturn:(JSTokenField *)tokenField {
    NSMutableString *recipient = [NSMutableString string];
    
    NSMutableCharacterSet *charSet = [[NSCharacterSet whitespaceCharacterSet] mutableCopy];
    [charSet formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
    
    NSString *rawStr = [[tokenField textField] text];
    for (int i = 0; i < [rawStr length]; i++)
    {
        if (![charSet characterIsMember:[rawStr characterAtIndex:i]])
        {
            [recipient appendFormat:@"%@",[NSString stringWithFormat:@"%c", [rawStr characterAtIndex:i]]];
        }
    }
    
    if ([rawStr length])
    {
        [tokenField addTokenWithTitle:rawStr representedObject:recipient];
    }
    
    [[tokenField textField] setText:@""];
    
    return NO;
}

@end
