//
//  LanguageViewController.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 7/4/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import "QNavigationViewController.h"

@interface LanguageViewController : QNavigationViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic)NSInteger nCurLanguage;
@property(nonatomic,strong)NSMutableArray *aryLanguage;
@property(nonatomic,strong)UITableView *tableViewLanguage;

@end
