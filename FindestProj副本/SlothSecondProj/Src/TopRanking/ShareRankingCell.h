//
//  ShareRankingCell.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/6/15.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonHeaderView.h"
#import "BlogVo.h"
#import "StrokeLabel.h"

@interface ShareRankingCell : UITableViewCell

@property(nonatomic,strong) UIView *viewBK;

@property(nonatomic,strong) UILabel *lblIndex;
@property(nonatomic,strong) UILabel *lblTitle;
@property(nonatomic,strong) CommonHeaderView *commonHeaderView;
@property(nonatomic,retain) UILabel *lblName;

@property(nonatomic,retain) UIImageView *imgViewShare;

-(void)initWithData:(BlogVo*)blogVo;

@end
