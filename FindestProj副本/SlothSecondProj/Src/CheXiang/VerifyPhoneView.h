//
//  VerifyPhoneView.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/9/6.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>

//参数：0表示取消，1表示确认,
typedef void(^VerifyBlock)(NSInteger nType,NSString* strPhone);

@interface VerifyPhoneView : UIView

- (instancetype)initWithFrame:(CGRect)frame resultBlock:(VerifyBlock)resultlBlock;

@end
