//
//  NSObject+UITextField_ClearButton.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/12.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "NSObject+UITextField_ClearButton.h"

@implementation UITextField (UITextField_ClearButton)

- (void)setBlueClearView
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"textfield_clear"] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0.0f, 0.0f, 30.0f, 15.0f)]; // Required for iOS7
    self.rightView = button;
    self.rightViewMode = UITextFieldViewModeWhileEditing;
    [button addTarget:self action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
}

- (void)clear
{
    self.text = @"";
}

@end
