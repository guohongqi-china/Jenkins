//
//  EditIntegralView.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 4/14/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import "EditIntegralView.h"
#import "UIViewExt.h"

@implementation EditIntegralView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = COLOR(0, 0, 0, 0.5);
        
        UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backgroundTap)];
        [self addGestureRecognizer:tapGestureRecognizer1];
        
        self.viewContainer = [[UIView alloc]initWithFrame:CGRectMake(15, 100, kScreenWidth-30, 350)];
        self.viewContainer.backgroundColor = [UIColor whiteColor];
        [self.viewContainer.layer setBorderWidth:1.0];
        [self.viewContainer.layer setCornerRadius:5];
        self.viewContainer.layer.borderColor = COLOR(204, 204, 204, 1.0).CGColor;
        [self.viewContainer.layer setMasksToBounds:YES];
        [self addSubview:self.viewContainer];
        
        CGFloat width = self.viewContainer.width;
        CGFloat fHeight = 10;
        
        self.btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnCancel.frame = CGRectMake(5, fHeight, 65, 32);
        [self.btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btnCancel.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14.0]];
        [self.btnCancel setBackgroundImage:[Common getImageWithColor:COLOR(153, 153, 153, 1.0)] forState:UIControlStateNormal];
        [self.btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        [self.btnCancel addTarget:self action:@selector(doCancel) forControlEvents:UIControlEventTouchUpInside];
        [self.btnCancel.layer setBorderWidth:1.0];
        [self.btnCancel.layer setCornerRadius:4];
        self.btnCancel.layer.borderColor = [[UIColor clearColor] CGColor];
        [self.btnCancel.layer setMasksToBounds:YES];
        [self.viewContainer addSubview:self.btnCancel];
        
        self.lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, fHeight, width, 32)];
        self.lblTitle.font = [UIFont boldSystemFontOfSize:16.0];
        self.lblTitle.text = @"积分编辑";
        self.lblTitle.textColor = COLOR(41, 41, 41, 1.0);
        self.lblTitle.textAlignment = NSTextAlignmentCenter;
        [self.viewContainer addSubview:self.lblTitle];
        
        self.btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnSave.frame = CGRectMake(width-65-5, fHeight, 65, 32);
        [self.btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btnSave.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14.0]];
        [self.btnSave setBackgroundImage:[Common getImageWithColor:COLOR(1, 204, 0, 1.0)] forState:UIControlStateNormal];
        [self.btnSave setTitle:@"保存" forState:UIControlStateNormal];
        [self.btnSave addTarget:self action:@selector(doSave) forControlEvents:UIControlEventTouchUpInside];
        [self.btnSave.layer setBorderWidth:1.0];
        [self.btnSave.layer setCornerRadius:4];
        self.btnSave.layer.borderColor = [[UIColor clearColor] CGColor];
        [self.btnSave.layer setMasksToBounds:YES];
        [self.viewContainer addSubview:self.btnSave];
        fHeight += 32 + 8;
        
        //signal check
        self.btnAdd = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnAdd.frame = CGRectMake(width/2-80, fHeight, 80, 33);
        [self.btnAdd setImage:[UIImage imageNamed:@"suggestion_uncheck"] forState:UIControlStateNormal];
        [self.btnAdd setImage:[UIImage imageNamed:@"suggestion_check"] forState:UIControlStateSelected];
        [self.btnAdd setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self.btnAdd setTitle:@"+" forState:UIControlStateNormal];
        [self.btnAdd.titleLabel setFont:[UIFont boldSystemFontOfSize:30.0]];
        [self.btnAdd setTitleColor:COLOR(246, 98, 0, 1.0) forState:UIControlStateNormal];
        [self.btnAdd addTarget:self action:@selector(signalCheck:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnAdd setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        self.btnAdd.tag = 101;
        self.btnAdd.selected = YES;
        [self.viewContainer addSubview:self.btnAdd];
        self.nSelectedTag = self.btnAdd.tag;
        
        self.btnMinus = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnMinus.frame = CGRectMake(width/2+45, fHeight, 80, 33);
        [self.btnMinus setImage:[UIImage imageNamed:@"suggestion_uncheck"] forState:UIControlStateNormal];
        [self.btnMinus setImage:[UIImage imageNamed:@"suggestion_check"] forState:UIControlStateSelected];
        [self.btnMinus setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self.btnMinus setTitle:@"-" forState:UIControlStateNormal];
        [self.btnMinus.titleLabel setFont:[UIFont boldSystemFontOfSize:30.0]];
        [self.btnMinus setTitleColor:COLOR(1, 204, 0, 1.0) forState:UIControlStateNormal];
        [self.btnMinus addTarget:self action:@selector(signalCheck:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnMinus setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        self.btnMinus.tag = 102;
        self.btnMinus.selected = NO;
        [self.viewContainer addSubview:self.btnMinus];
        fHeight += 40;
        
        self.viewLine = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight, width, 0.5)];
        self.viewLine.backgroundColor = COLOR(205, 205, 205, 1.0);
        [self.viewContainer addSubview:self.viewLine];
        fHeight += 20;
        
        //integral
        self.txtIntegral = [[InsetsTextField alloc]initWithFrame:CGRectMake(17, fHeight, width-34,33)];
        self.txtIntegral.background = [[UIImage imageNamed:@"txt_bk"]stretchableImageWithLeftCapWidth:30 topCapHeight:10];
        self.txtIntegral.font = [UIFont fontWithName:APP_FONT_NAME size:16];
        self.txtIntegral.textColor = COLOR(0, 0, 0, 1.0);
        self.txtIntegral.delegate = self;
        self.txtIntegral.placeholder = @"请输入积分数";
        self.txtIntegral.keyboardType = UIKeyboardTypeNumberPad;
        self.txtIntegral.tag = 103;
        [self.txtIntegral becomeFirstResponder];
        [self.viewContainer addSubview:self.txtIntegral];
        fHeight += 38;
        
        self.lblTip = [[UILabel alloc]initWithFrame:CGRectMake(0, fHeight, width, 20)];
        self.lblTip.font = [UIFont boldSystemFontOfSize:12.0];
        self.lblTip.text = @"请输入积分数范围在大于 0，小于或等于100";
        self.lblTip.textColor = COLOR(192, 192, 192, 1.0);
        self.lblTip.textAlignment = NSTextAlignmentCenter;
        [self.viewContainer addSubview:self.lblTip];
        fHeight += 20;
        
        //remark
        self.lblRemark = [[UILabel alloc]initWithFrame:CGRectMake(15, fHeight, width-15, 20)];
        self.lblRemark.font = [UIFont boldSystemFontOfSize:14.0];
        self.lblRemark.text = @"备注：";
        self.lblRemark.textColor = COLOR(45, 45, 45, 1.0);
        self.lblRemark.textAlignment = NSTextAlignmentLeft;
        [self.viewContainer addSubview:self.lblRemark];
        fHeight += 20;
        
        self.txtViewRemark = [[UITextView alloc]initWithFrame:CGRectMake(15, fHeight, width-30,54 )];
        self.txtViewRemark.layer.borderColor = COLOR(204, 204, 204, 1.0).CGColor;
        self.txtViewRemark.layer.borderWidth = 0.5;
        self.txtViewRemark.layer.cornerRadius = 5;
        self.txtViewRemark.layer.masksToBounds = YES;
        self.txtViewRemark.font = [UIFont fontWithName:APP_FONT_NAME size:16];
        self.txtViewRemark.textColor = COLOR(0, 0, 0, 1.0);
        self.txtViewRemark.delegate = self;
        self.txtViewRemark.tag = 104;
        [self.viewContainer addSubview:self.txtViewRemark];
        fHeight += 54;
        fHeight += 20;
        
        self.viewContainer.frame = CGRectMake(15, 100, kScreenWidth-30, fHeight);
    }
    return self;
}

//隐藏本视图
-(void)hideView
{
    [self removeFromSuperview];
}

- (void)doCancel
{
    [self hideView];
}

- (void)doSave
{
    NSString *strNum = self.txtIntegral.text;
    if (strNum.length == 0)
    {
        [Common tipAlert:@"积分数量不能为空"];
        return;
    }
    else if (self.txtViewRemark.text.length == 0)
    {
        [Common tipAlert:@"备注不能为空"];
        return;
    }
    else
    {
        NSInteger nNum = [strNum integerValue];
        if(nNum == 0 || nNum>100)
        {
            [Common tipAlert:@"积分数量应该大于0，小于或等于100"];
            return;
        }
        
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(changeIntegralAction:integral:user:)])
        {
            if (self.nSelectedTag == 102)
            {
                nNum *=-1;
            }
            NSString *strValue = [NSString stringWithFormat:@"%li",(long)nNum];
            [self.delegate changeIntegralAction:self integral:strValue user:self.userVo];
        }
    }
}

- (void)signalCheck:(UIButton*)sender
{
    sender.selected = YES;
    if (self.nSelectedTag == sender.tag)
    {
        return;
    }
    else
    {
        UIButton *btnTemp = (UIButton *)[self.viewContainer viewWithTag:self.nSelectedTag];
        btnTemp.selected = NO;
        
        sender.selected = YES;
        self.nSelectedTag = sender.tag;
    }
}

- (void)backgroundTap
{
    [self.txtIntegral resignFirstResponder];
    [self.txtViewRemark resignFirstResponder];
}

@end
