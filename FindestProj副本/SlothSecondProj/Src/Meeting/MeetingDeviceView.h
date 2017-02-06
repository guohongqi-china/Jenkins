//
//  MeetingDeviceView.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/19.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MeetingDeviceDelegate <NSObject>

- (void)completedChooseDevice:(NSString *)strDevice name:(NSString *)strName;

@end

@interface MeetingDeviceView : NSObject

@property (strong, nonatomic) IBOutlet UIView *view;

@property (nonatomic, strong) id<MeetingDeviceDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)showWithAnimation;
- (void)refreshView;

@end
