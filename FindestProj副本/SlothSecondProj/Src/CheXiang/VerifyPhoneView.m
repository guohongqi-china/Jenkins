//
//  VerifyPhoneView.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/9/6.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "VerifyPhoneView.h"
#import "UIViewExt.h"
#import "UserVo.h"
#import "InsetsTextField.h"
#import "Constants+OC.h"

@interface VerifyPhoneView ()
{
    UIView *viewContainer;

    UILabel *lblTitle;
    UITextField *txtPhone;
    UIButton *btnCancel;
    UIButton *btnConfirm;
    
    VerifyBlock _resultBlock;
}

@end

@implementation VerifyPhoneView

- (instancetype)initWithFrame:(CGRect)frame resultBlock:(VerifyBlock)resultlBlock
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _resultBlock = resultlBlock;
        
        self.backgroundColor = COLOR(0, 0, 0, 0.4);
        
        viewContainer = [[UIView alloc]initWithFrame:CGRectMake((kScreenWidth-260)/2, 150, 260, 160)];
        viewContainer.backgroundColor = [UIColor whiteColor];
        viewContainer.layer.cornerRadius = 4;
        viewContainer.layer.masksToBounds = YES;
        viewContainer.layer.borderWidth = 0;
        [self addSubview:viewContainer];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBackground)];
        [self addGestureRecognizer:tapGesture];
        
        lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(20, 15, 200, 25)];
        lblTitle.font = [UIFont systemFontOfSize:14];
        lblTitle.textColor = COLOR(150, 150, 150, 1.0);
        lblTitle.text = @"请输入手机号码";
        [viewContainer addSubview:lblTitle];
        
        txtPhone = [[InsetsTextField alloc]initWithFrame:CGRectMake(20, lblTitle.bottom+10, 220, 36)];
        txtPhone.text = [Common getCurrentUserVo].strPhoneNumber;
        txtPhone.layer.cornerRadius = 4;
        txtPhone.layer.masksToBounds = YES;
        txtPhone.layer.borderWidth = 0.5;
        txtPhone.layer.borderColor = COLOR(204, 204, 204, 1.0).CGColor;
        txtPhone.clearButtonMode = UITextFieldViewModeWhileEditing;
        txtPhone.keyboardType = UIKeyboardTypeNumberPad;
        [viewContainer addSubview:txtPhone];
        
        btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        btnCancel.layer.cornerRadius = 4;
        btnCancel.layer.borderWidth = 0;
        btnCancel.layer.masksToBounds = YES;
        btnCancel.frame = CGRectMake(30, txtPhone.bottom+17, 90, 36);
        [btnCancel setBackgroundImage:[Common getImageWithColor:COLOR(153, 153, 153, 1.0)] forState:UIControlStateNormal];
        [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnCancel addTarget:self action:@selector(verifyAction:) forControlEvents:UIControlEventTouchUpInside];
        [viewContainer addSubview:btnCancel];
        
        btnConfirm = [UIButton buttonWithType:UIButtonTypeCustom];
        btnConfirm.layer.cornerRadius = 4;
        btnConfirm.layer.borderWidth = 0;
        btnConfirm.layer.masksToBounds = YES;
        btnConfirm.frame = CGRectMake(btnCancel.right+9.5+10, txtPhone.bottom+17, 90, 36);
        [btnConfirm setBackgroundImage:[Common getImageWithColor:[SkinManage skinColor]] forState:UIControlStateNormal];
        [btnConfirm setTitle:@"确认" forState:UIControlStateNormal];
        [btnConfirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnConfirm addTarget:self action:@selector(verifyAction:) forControlEvents:UIControlEventTouchUpInside];
        [viewContainer addSubview:btnConfirm];
    }
    
    return self;
}

- (void)verifyAction:(UIButton *)sender
{
    if (sender == btnCancel)
    {
        _resultBlock(0,nil);
    }
    else
    {
        if(txtPhone.text.length == 0)
        {
            [Common tipAlert:@"请输入手机号码"];
        }
        else
        {
            _resultBlock(1,txtPhone.text);
        }
    }
}

- (void)tapBackground
{
    [txtPhone resignFirstResponder];
}

@end
