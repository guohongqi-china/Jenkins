//
//  MeetBookRemarkView.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/9/10.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "MeetBookRemarkView.h"
#import "UIViewExt.h"
#import "InsetsTextField.h"
#import "UserVo.h"

@interface MeetBookRemarkView ()
{
    UIView *viewContainer;
    
    UILabel *lblTitle;
    UITextField *txtTitle;
    UILabel *lblTitleStar;
    
    UILabel *lblName;
    UITextField *txtName;
    UILabel *lblNameStar;
    
    UILabel *lblContact;
    UITextField *txtContact;
    UILabel *lblContactStar;
    
    UILabel *lblRemark;
    UITextView *txtRemark;
    UIButton *btnCancel;
    UIButton *btnConfirm;
    
    MeetBookRemarkBlock _resultBlock;
}

@end

@implementation MeetBookRemarkView

- (instancetype)initWithFrame:(CGRect)frame resultBlock:(MeetBookRemarkBlock)resultlBlock
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _resultBlock = resultlBlock;
        
        self.backgroundColor = COLOR(0, 0, 0, 0.4);
        
        viewContainer = [[UIView alloc]initWithFrame:CGRectMake((kScreenWidth-290)/2, 60, 290, 400)];
        viewContainer.backgroundColor = [UIColor whiteColor];
        viewContainer.layer.cornerRadius = 4;
        viewContainer.layer.masksToBounds = YES;
        viewContainer.layer.borderWidth = 0;
        [self addSubview:viewContainer];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBackground)];
        [self addGestureRecognizer:tapGesture];
        
        //主题
        lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, 200, 28)];
        lblTitle.textAlignment = NSTextAlignmentLeft;
        lblTitle.font = [UIFont systemFontOfSize:14];
        lblTitle.textColor = COLOR(150, 150, 150, 1.0);
        lblTitle.text = @"主题";
        [viewContainer addSubview:lblTitle];
        
        txtTitle = [[InsetsTextField alloc]initWithFrame:CGRectMake(50, 20, viewContainer.width-70, 28)];
        //txtTitle.placeholder = @"主题";
        txtTitle.layer.cornerRadius = 5;
        txtTitle.layer.masksToBounds = YES;
        txtTitle.layer.borderWidth = 0.5;
        txtTitle.layer.borderColor = COLOR(204, 204, 204, 1.0).CGColor;
        txtTitle.font = [UIFont systemFontOfSize:14];
        [viewContainer addSubview:txtTitle];
        
        lblTitleStar = [[UILabel alloc]initWithFrame:CGRectMake(txtTitle.right, txtTitle.top, 20, txtTitle.height)];
        lblTitleStar.textColor = [UIColor redColor];
        lblTitleStar.textAlignment = NSTextAlignmentCenter;
        lblTitleStar.text = @"*";
        [viewContainer addSubview:lblTitleStar];
        
        //姓名
        lblName = [[UILabel alloc]initWithFrame:CGRectMake(10, txtTitle.bottom+10, viewContainer.width-70, 28)];
        lblName.textAlignment = NSTextAlignmentLeft;
        lblName.font = [UIFont systemFontOfSize:14];
        lblName.textColor = COLOR(150, 150, 150, 1.0);
        lblName.text = @"姓名";
        [viewContainer addSubview:lblName];
        
        txtName = [[InsetsTextField alloc]initWithFrame:CGRectMake(50, txtTitle.bottom+10, viewContainer.width-70, 28)];
        //txtName.placeholder = @"姓名";
        txtName.layer.cornerRadius = 5;
        txtName.layer.masksToBounds = YES;
        txtName.layer.borderWidth = 0.5;
        txtName.layer.borderColor = COLOR(204, 204, 204, 1.0).CGColor;
        txtName.font = [UIFont systemFontOfSize:14];
        txtName.text = [Common getCurrentUserVo].strRealName;
        [viewContainer addSubview:txtName];
        
        lblNameStar = [[UILabel alloc]initWithFrame:CGRectMake(txtName.right, txtName.top, 20, txtName.height)];
        lblNameStar.textColor = [UIColor redColor];
        lblNameStar.textAlignment = NSTextAlignmentCenter;
        lblNameStar.text = @"*";
        [viewContainer addSubview:lblNameStar];
        
        //电话
        lblContact = [[UILabel alloc]initWithFrame:CGRectMake(10, txtName.bottom+10, 200, 28)];
        lblContact.textAlignment = NSTextAlignmentLeft;
        lblContact.font = [UIFont systemFontOfSize:14];
        lblContact.textColor = COLOR(150, 150, 150, 1.0);
        lblContact.text = @"电话";
        [viewContainer addSubview:lblContact];
        
        txtContact = [[InsetsTextField alloc]initWithFrame:CGRectMake(50, txtName.bottom+10, viewContainer.width-70, 28)];
        //txtContact.placeholder = @"电话";
        txtContact.layer.cornerRadius = 5;
        txtContact.layer.masksToBounds = YES;
        txtContact.layer.borderWidth = 0.5;
        txtContact.layer.borderColor = COLOR(204, 204, 204, 1.0).CGColor;
        txtContact.font = [UIFont systemFontOfSize:14];
        txtContact.keyboardType = UIKeyboardTypePhonePad;
        txtContact.text = [Common getCurrentUserVo].strPhoneNumber;
        [viewContainer addSubview:txtContact];
        
        lblContactStar = [[UILabel alloc]initWithFrame:CGRectMake(txtContact.right, txtContact.top, 20, txtContact.height)];
        lblContactStar.textColor = [UIColor redColor];
        lblContactStar.textAlignment = NSTextAlignmentCenter;
        lblContactStar.text = @"*";
        [viewContainer addSubview:lblContactStar];
        
        //备注
        lblRemark = [[UILabel alloc]initWithFrame:CGRectMake(10, txtContact.bottom+10, 200, 28)];
        lblRemark.textAlignment = NSTextAlignmentLeft;
        lblRemark.font = [UIFont systemFontOfSize:14];
        lblRemark.textColor = COLOR(150, 150, 150, 1.0);
        lblRemark.text = @"备注";
        [viewContainer addSubview:lblRemark];
        
        txtRemark = [[UITextView alloc]initWithFrame:CGRectMake(50, txtContact.bottom+10, viewContainer.width-70, 45)];
        txtRemark.layer.cornerRadius = 5;
        txtRemark.layer.masksToBounds = YES;
        txtRemark.layer.borderWidth = 0.5;
        txtRemark.layer.borderColor = COLOR(204, 204, 204, 1.0).CGColor;
        txtRemark.font = [UIFont systemFontOfSize:14];
        [viewContainer addSubview:txtRemark];
        
        //bottom button
        btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        btnCancel.layer.cornerRadius = 4;
        btnCancel.layer.borderWidth = 0;
        btnCancel.layer.masksToBounds = YES;
        btnCancel.frame = CGRectMake((viewContainer.width-90*2-20)/2, txtRemark.bottom+17, 90, 36);
        [btnCancel setBackgroundImage:[Common getImageWithColor:COLOR(153, 153, 153, 1.0)] forState:UIControlStateNormal];
        [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnCancel addTarget:self action:@selector(verifyAction:) forControlEvents:UIControlEventTouchUpInside];
        [viewContainer addSubview:btnCancel];
        
        btnConfirm = [UIButton buttonWithType:UIButtonTypeCustom];
        btnConfirm.layer.cornerRadius = 4;
        btnConfirm.layer.borderWidth = 0;
        btnConfirm.layer.masksToBounds = YES;
        btnConfirm.frame = CGRectMake(btnCancel.right+20, txtRemark.bottom+17, 90, 36);
        [btnConfirm setBackgroundImage:[Common getImageWithColor:[SkinManage skinColor]] forState:UIControlStateNormal];
        [btnConfirm setTitle:@"确认" forState:UIControlStateNormal];
        [btnConfirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnConfirm addTarget:self action:@selector(verifyAction:) forControlEvents:UIControlEventTouchUpInside];
        [viewContainer addSubview:btnConfirm];
        
        viewContainer.frame = CGRectMake((kScreenWidth-290)/2, 60, 290, btnCancel.bottom+17);
    }
    
    return self;
}

- (void)verifyAction:(UIButton *)sender
{
    if (sender == btnCancel)
    {
        _resultBlock(self,0,nil,nil,nil,nil);
    }
    else
    {
        if (txtTitle.text.length == 0)
        {
            [Common tipAlert:@"主题不能为空"];
        }
        else if (txtName.text.length == 0)
        {
            [Common tipAlert:@"姓名不能为空"];
        }
        else if (txtContact.text.length == 0)
        {
            [Common tipAlert:@"电话不能为空"];
        }
        else
        {
            _resultBlock(self,1,txtTitle.text,txtName.text,txtContact.text,txtRemark.text);
        }
    }
}

- (void)tapBackground
{
    [txtTitle resignFirstResponder];
    [txtName resignFirstResponder];
    [txtContact resignFirstResponder];
    [txtRemark resignFirstResponder];
}

@end
