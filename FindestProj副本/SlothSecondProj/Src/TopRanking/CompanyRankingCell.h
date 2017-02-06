//
//  CompanyRankingCell.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/6/19.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CompanyRankingVo.h"

@interface CompanyRankingCell : UITableViewCell

@property(nonatomic,strong) UILabel *lblIndex;
@property(nonatomic,strong) UILabel *lblCompanyName;

//人均积分
@property(nonatomic,strong) UILabel *lblAvgIntegral;

//总积分
@property(nonatomic,strong) UILabel *lblSumIntegral;

-(void)initWithData:(CompanyRankingVo*)dataVo;

@end
