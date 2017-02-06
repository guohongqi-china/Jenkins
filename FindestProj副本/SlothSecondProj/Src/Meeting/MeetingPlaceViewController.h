//
//  MeetingPlaceViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/18.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonViewController.h"
#import "MeetingPlaceVo.h"

@protocol MeetingPlaceViewDelegate <NSObject>

- (void)completedMeetingPlace:(MeetingPlaceVo *)placeVo;

@end

@interface MeetingPlaceViewController : CommonViewController

@property (nonatomic,weak) id<MeetingPlaceViewDelegate> delegate;

- (void)refreshView;

@end
