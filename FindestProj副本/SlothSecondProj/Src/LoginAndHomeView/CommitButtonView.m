//
//  CommitButtonView.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/12/26.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import "CommitButtonView.h"
#import "Constants+OC.h"

@interface CommitButtonView ()
{
    NSString *strLeftTitle;
    NSString *strRightTitle;
    
    UIButton *btnLeft;
    UIButton *btnRight;
    
    CommitButtonViewBlock buttonBlock;
}

@end

@implementation CommitButtonView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (instancetype)initWithLeftTitle:(NSString *)strLTitle right:(NSString *)strRTitle action:(CommitButtonViewBlock)actionBlock
{
    self = [super init];
    if (self)
    {
        strLeftTitle = strLTitle;
        strRightTitle = strRTitle;
        buttonBlock = actionBlock;
        
        [self initView];
        
        [self registerForKeyboardNotifications];
    }
    return self;
}

- (void)initView
{
    //line
    UIView *viewLine = [[UIView alloc]init];
    viewLine.backgroundColor = COLOR(221, 208, 204, 1.0);
    [self addSubview:viewLine];
    [viewLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(0);
        make.height.equalTo(0.5);
    }];
    
    //left button
    if (strLeftTitle)
    {
        btnLeft = [UIButton buttonWithType:UIButtonTypeCustom];
        btnLeft.tag = 0;
        [btnLeft setTitle:[NSString stringWithFormat:@"　%@　",strLeftTitle] forState:UIControlStateNormal];
        [btnLeft setTitleColor:THEME_COLOR forState:UIControlStateNormal];
        btnLeft.titleLabel.font = [UIFont systemFontOfSize:14];
        [btnLeft addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnLeft];
        
        [btnLeft mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(7.5);
            make.leading.equalTo(self.mas_leading).offset(10);
            make.height.equalTo(30);
        }];
    }
    
    //right button
    if (strRightTitle)
    {
        btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
        btnRight.tag = 1;
        [btnRight setTitle:[NSString stringWithFormat:@"　%@　",strRightTitle] forState:UIControlStateNormal];
        [btnRight setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnRight setTitleColor:THEME_COLOR forState:UIControlStateDisabled];
        [btnRight setBackgroundImage:[Common getImageWithColor:THEME_COLOR] forState:UIControlStateNormal];
        [btnRight setBackgroundImage:[Common getImageWithColor:[UIColor clearColor]] forState:UIControlStateDisabled];
        btnRight.titleLabel.font = [UIFont systemFontOfSize:14];
        btnRight.layer.cornerRadius = 5;
        btnRight.layer.borderColor = COLOR(221, 208, 204, 1.0).CGColor;
        btnRight.layer.masksToBounds = YES;
        [btnRight addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnRight];
        [self setRightButtonEnable:NO];
        
        [btnRight mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(7.5);
            make.trailing.equalTo(self.mas_trailing).offset(-10);
            make.height.equalTo(30);
        }];
    }
    
}

- (void)buttonAction:(UIButton *)sender
{
    buttonBlock(sender);
}

- (void)setLeftButtonEnable:(BOOL)enable
{
    
}

- (void)setRightButtonEnable:(BOOL)enable
{
    btnRight.enabled = enable;
    
    if (enable)
    {
        btnRight.layer.borderWidth = 0;
    }
    else
    {
        btnRight.layer.borderWidth = 1;
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
    NSDictionary* info = [aNotification userInfo];
    CGSize sizeKeyboard = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(-sizeKeyboard.height);
    }];
    [self.superview layoutIfNeeded];
}

- (void)keyboardWillBeHidden:(NSNotification *)aNotification
{
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(0);
    }];
    [self.superview layoutIfNeeded];
}

@end
