//
//  ChooseChatGroupViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/2/25.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonViewController.h"

@protocol ChooseChatGroupDelegate <NSObject>
@optional
-(void)completeChooseChatGroup:(GroupVo *)groupVo;
@end

@interface ChooseChatGroupViewController : CommonViewController

@property (nonatomic,weak) id<ChooseChatGroupDelegate> delegate;

@end
