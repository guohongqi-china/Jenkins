//
//  PublicToolView.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/14.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PublicToolDelegate <NSObject>

- (void)toolButtonAction:(NSInteger)nType;

@end

@interface PublicToolView : NSObject

@property (nonatomic, weak) id<PublicToolDelegate> delegate;
@property (nonatomic, strong) IBOutlet UIView *view;

- (instancetype)initWithType:(NSString *)strType;

@end
