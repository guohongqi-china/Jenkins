//
//  TheCountdownButton.h
//  倒计时
//
//  Created by MacBook on 16/7/29.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^TheCountdownButtonBlock)();
@interface TheCountdownButton : UIButton

@property (nonatomic, copy) TheCountdownButtonBlock block;/** <#注释#> */
- (instancetype)initWithFrame:(CGRect)frame timeCount:(NSInteger)timeCount title:(NSString *)buttonTitle target:(id)target action:(SEL)action actionBlock:(TheCountdownButtonBlock)block;










@end
