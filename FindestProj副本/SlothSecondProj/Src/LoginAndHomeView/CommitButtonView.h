//
//  CommitButtonView.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/12/26.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>

//left tag:0,right tag:1
typedef void(^CommitButtonViewBlock)(UIButton *);

@interface CommitButtonView : UIView

- (instancetype)initWithLeftTitle:(NSString *)strLTitle right:(NSString *)strRTitle action:(CommitButtonViewBlock)actionBlock;
- (void)setRightButtonEnable:(BOOL)enable;

@end
