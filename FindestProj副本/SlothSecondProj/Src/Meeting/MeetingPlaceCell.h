//
//  MeetingPlaceCell.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/18.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeetingPlaceVo.h"

@interface MeetingPlaceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgViewCheck;
@property (nonatomic, strong) MeetingPlaceVo *entity;

@end
