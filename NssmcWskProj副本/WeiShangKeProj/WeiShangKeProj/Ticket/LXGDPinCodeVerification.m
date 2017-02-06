//
//  LXGDPinCodeVerification.m
//  NssmcWskProj
//
//  Created by MacBook on 16/11/24.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "LXGDPinCodeVerification.h"

@interface LXGDPinCodeVerification ()<UITextFieldDelegate>
/** 确定按钮 */
@property (strong, nonatomic) IBOutlet UIButton *affirmButton;
/** 取消按钮 */
@property (strong, nonatomic) IBOutlet UIButton *cancleButton;
/** 输入框 */
@property (strong, nonatomic) IBOutlet UITextField *codeField;
/** 保存代码块block */
@property (nonatomic, copy) void(^textBlock)(NSString *text);
/** grayView */
@property (nonatomic, strong) UIView *grayView;
@end

@implementation LXGDPinCodeVerification

- (void)awakeFromNib{
    [super awakeFromNib];
    /** 监听键盘高度的变化 */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];//在这里注册通知
    
    /** 设置尺寸 */
    self.width = 260;
    self.height = 210;
    self.centerX = kScreenWidth / 2;
    self.centerY = kScreenHeight / 2;
    
    /** grayView */
    _grayView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    _grayView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.2];

}
/**
 * 键盘的frame发生改变时调用（显示、隐藏等）
 */
- (void)keyboardWillChangeFrame:(NSNotification *)notification
{

    NSDictionary *userInfo = notification.userInfo;
    
    // 动画的持续时间
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // 键盘的frame
    CGRect keyboardF = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // 执行动画

    [UIView animateWithDuration:0.25 delay:0 options:(UIViewAnimationOptionCurveEaseOut) animations:^{
        self.centerY = keyboardF.origin.y - 210 / 2;
        self.centerY = (self.centerY > kScreenHeight / 2) ? kScreenHeight / 2 : keyboardF.origin.y - 210 / 2;
    } completion:^(BOOL finished) {
        
    }];
}
- (void)show:(void (^)(NSString *text))finshedInput{
    _textBlock = finshedInput;
    
    [UIView animateWithDuration:0.5 animations:^{
        [[UIApplication sharedApplication].windows.lastObject addSubview:_grayView];

    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication].windows.lastObject addSubview:self];
    }];
    
}

/** 点击事件 */
- (IBAction)sender:(UIButton *)sender {

    if (sender == _affirmButton) {
        _textBlock(_codeField.text);
    }else{
   
    /** 移除视图 */
        [self hidden];
    }
}
- (void)hidden{
    [self removeFromSuperview];
    
    [UIView animateWithDuration:0.25 animations:^{
        [_grayView removeFromSuperview];
    } completion:^(BOOL finished) {
    }];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return  YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}

@end
