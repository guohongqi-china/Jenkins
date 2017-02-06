//
//  MeetingDialViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/22.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonViewController.h"
#import "MeetingRoomVo.h"

@interface MeetingDialViewController : CommonViewController

@property (nonatomic, strong) MeetingBookVo *bookVo;
@property (nonatomic, strong) NSMutableArray *aryRoom;

@end
