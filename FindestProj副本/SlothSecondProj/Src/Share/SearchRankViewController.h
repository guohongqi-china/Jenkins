//
//  SearchRankViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/26.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonViewController.h"

@interface SearchRankViewController : CommonViewController

@property (nonatomic, strong) NSString *strPageType;    //hotSearch,hotTag
@property (nonatomic, strong) NSMutableArray *aryData;

@end
