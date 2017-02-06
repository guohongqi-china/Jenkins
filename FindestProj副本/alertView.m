//
//  alertView.m
//  FindestProj
//
//  Created by MacBook on 16/7/20.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "alertView.h"
#import "UIView+Extension.h"
#import "VNetworkFramework.h"
#import "ServerURL.h"
#import "MBProgressHUD+GHQ.h"
@implementation alertView
- (UIWindow *)keyWin{
    _keyWin.hidden = NO;
    if (_keyWin == nil) {
        //将表视图添加到最上层windows上面去
        _keyWin = [UIApplication sharedApplication].windows.lastObject;
        //在这里我们可以设置windows的背景色半透明，而不是设置windows的alpha半透明，alpha半透明会导致加在它上面的视图也半透明
        _keyWin.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];

    }
    return _keyWin;
}
- (void)awakeFromNib{
    _textFieldLabel.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    baseView = [[cengView alloc]initWithFrame:CGRectMake(0,0, KscreenWidth, KscreenHeight - 64)];
    baseView.backgroundColor = [UIColor redColor];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeCemg) name:@"cengViwe" object:nil];

}
- (void)removeCemg{
    [self hidden];
}
- (IBAction)sender:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"remove" object:nil];
    if ([sender.titleLabel.text isEqualToString:@"确定"]) {
        if (_textFieldLabel.text.length == 0 || _textFieldLabel.text == nil ) {
            [MBProgressHUD showSuccess:@"退回原因不能为空" toView:nil];
            return;
        }
        VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:[ServerURL  rejectURL]];

        [[NSNotificationCenter defaultCenter]postNotificationName:@"removewAction" object:nil];
        [_textFieldLabel resignFirstResponder];

        [framework startRequestToServer:@"POST" parameter:@{@"id":_strId,@"reason":_textFieldLabel.text} result:^(id responseObject, NSError *error) {
            if (error) {
                NSLog(@"%@",error);
                [MBProgressHUD showSuccess:@"操作失败" toView:nil];

            }else{
                NSLog(@"%@",responseObject);
                [MBProgressHUD showSuccess:@"操作成功" toView:nil];
            }
        }];

    }else{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"removewAction" object:nil];
        [_textFieldLabel resignFirstResponder];

    }
}
- (void)show{
    [_keyWin addSubview:baseView];
    [self.keyWin addSubview:self];

    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:10 initialSpringVelocity:10 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
        self.centerY = KscreenHeight / 2;
    } completion:^(BOOL finished) {
        
    }];

}
- (void)hidden{
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:10 initialSpringVelocity:10 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
       self.y = KscreenHeight;
    
    } completion:^(BOOL finished) {
        self.keyWin.hidden = YES;
//        [self removeFromSuperview];
//        [self.keyWin removeFromSuperview];
    }];

}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"removeKeyBoard" object:nil];
    [_textFieldLabel resignFirstResponder];
    return YES;
}

- (void)sdddd{
//    [self.keyWin removeFromSuperview];
}

@end
