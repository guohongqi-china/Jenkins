//
//  ActivityProjectViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/18.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityProjectVo.h"
#import "BlogVo.h"
#import "CommonViewController.h"

@interface ActivityProjectViewController : CommonViewController

@property(nonatomic,strong)ActivityProjectVo *m_activityProjectVo;
@property(nonatomic,strong)BlogVo *m_blogVo;

@end
