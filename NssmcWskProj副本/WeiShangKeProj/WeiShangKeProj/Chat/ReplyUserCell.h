//
//  ReplyUserCell.h
//  FindestMeetingProj
//
//  Created by 焱 孙 on 12/30/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserVo.h"

@interface ReplyUserCell : UITableViewCell

@property(nonatomic,strong)UIImageView *imgViewHead;
@property(nonatomic,strong)UILabel *lblName;
@property(nonatomic,strong)UILabel *lblRoomNum;
@property(nonatomic,strong)UILabel *lblGroup;
@property(nonatomic,strong)UILabel *lblPosition;        //职位

- (void)initWithUserVo:(UserVo*)userVo;
+ (CGFloat)calculateCellHeight:(UserVo*)userVo;

@end
