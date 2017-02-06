//
//  CompanyRankingVo.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/6/18.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

//子公司积分排名
@interface CompanyRankingVo : NSObject

@property(nonatomic)NSInteger nIndex;
@property(nonatomic,strong)NSString *strID;
@property(nonatomic,strong)NSString *strName;//company name
@property(nonatomic)double fSum;//总积分
@property(nonatomic)double fAvg;//平均积分

@end
