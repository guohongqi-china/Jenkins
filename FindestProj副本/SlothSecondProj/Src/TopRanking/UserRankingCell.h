//
//  UserRankingCell.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/6/15.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserVo.h"
#import "CommonHeaderView.h"

@interface UserRankingCell : UITableViewCell

@property(nonatomic,strong) UIView *viewBK;

@property(nonatomic,strong) UILabel *lblIndex;
@property(nonatomic,strong) CommonHeaderView *commonHeaderView;
@property(nonatomic,retain) UILabel *lblName;

@property(nonatomic,retain) UILabel *lblIntegralTip;
@property(nonatomic,retain) UILabel *lblIntegral;
@property(nonatomic,strong) UIView *viewLine;

@property(nonatomic) NSInteger nPageType;//1:积分排行榜,2:风云人物榜,3:我的排名
@property(nonatomic,strong) NSIndexPath *indexPath;



-(void)initWithData:(UserVo*)userVo;

@end
