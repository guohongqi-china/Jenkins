//
//  SkinViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 12/5/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import "QNavigationViewController.h"

@interface SkinViewController : QNavigationViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic)SkinType nCurrSkin;
@property(nonatomic,strong)NSMutableArray *arySkin;
@property(nonatomic,strong)UITableView *tableViewSkin;
@property(nonatomic,strong)UIImageView *imgViewBK;

@end
