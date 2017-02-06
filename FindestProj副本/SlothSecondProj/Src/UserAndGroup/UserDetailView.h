//
//  UserDetailView.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/15.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDetailView : NSObject

@property (strong, nonatomic) IBOutlet UIView *view;

- (instancetype)initWithFrame:(CGRect)frame user:(UserVo *)userData;
- (void)showWithAnimation;

@end
