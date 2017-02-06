//
//  popView.m
//  FindestProj
//
//  Created by MacBook on 16/7/22.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "popView.h"
#import "alertView.h"
#import "VNetworkFramework.h"
#import "ServerURL.h"
#import "MBProgressHUD+GHQ.h"
#import "UIView+Extension.h"
@interface popView ()
{
    alertView *VE;
    UIWindow *WIN;
}
@end
@implementation popView
- (void)awakeFromNib{
    baseView = [[cengView alloc]initWithFrame:CGRectMake(0,0, KscreenWidth, KscreenHeight - 64)];
    baseView.backgroundColor = [UIColor clearColor];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeAction) name:@"cengViwe" object:nil];
    VE = [[NSBundle mainBundle]loadNibNamed:@"alertView" owner:nil options:nil].lastObject;
    VE.frame = CGRectMake(0, KscreenHeight, KscreenWidth, 240);
  
    WIN = [UIApplication sharedApplication].windows.lastObject;
    WIN.backgroundColor = [UIColor clearColor];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"removewAction" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeAction) name:@"removewAction" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeType:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeKeyBoard) name:@"removeKeyBoard" object:nil];
}
- (void)changeType:(NSNotification *)notification{
    CGRect kbEndFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat kbEndH = kbEndFrame.size.height;
    CGFloat kbEndY = kbEndFrame.origin.y;
    if (kbEndY == KscreenHeight - kbEndH ) {
        [UIView animateWithDuration:0.3 delay:0 options:(UIViewAnimationOptionCurveEaseOut) animations:^{
            VE.frame = CGRectMake(0, KscreenHeight - 240 - kbEndH, KscreenWidth, 240);
        } completion:^(BOOL finished) {
            
        }];
 
    }
}
- (void)removeKeyBoard{
   
    [UIView animateWithDuration:0.3 delay:0 options:(UIViewAnimationOptionTransitionNone) animations:^{
        VE.frame = CGRectMake(0, KscreenHeight - 240 , KscreenWidth, 240);
    } completion:^(BOOL finished) {
        
    }];

}
- (void)setStrID:(NSString *)strID{
    _strID = strID;
    VE.strId = strID;
}
- (void)removeAction{
    [UIView animateWithDuration:0.3 delay:0 options:(UIViewAnimationOptionCurveEaseOut) animations:^{
        VE.frame = CGRectMake(0, KscreenHeight, KscreenWidth, 240);
    } completion:^(BOOL finished) {
        WIN.backgroundColor = [UIColor clearColor];
        [baseView removeFromSuperview];
    }];
}
- (IBAction)sender:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"审核通过"]) {
        VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:[NSString stringWithFormat:@"%@%@",[ServerURL Judgeshenhe],_strID]];
        [framework startRequestToServer:@"GET" parameter:nil result:^(id responseObject, NSError *error) {
            if (error) {
                [MBProgressHUD showSuccess:@"审核失败" toView:nil];
                
            }else{
                [MBProgressHUD showSuccess:@"审核通过" toView:nil];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"removePoP" object:nil];
            }
            
        }];

    }else{
        [WIN addSubview:baseView];
        [WIN addSubview:VE];
        [UIView animateWithDuration:0.3 delay:0 options:(UIViewAnimationOptionCurveEaseOut) animations:^{
            WIN.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 delay:0 options:(UIViewAnimationOptionCurveEaseOut) animations:^{
                VE.frame = CGRectMake(0, KscreenHeight - 240, KscreenWidth, 240);
            } completion:^(BOOL finished) {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"removePoP" object:nil];
            }];
        }];
    }
    
}

@end
