//
//  TheTableViewForTitle.h
//  FindestProj
//
//  Created by MacBook on 16/7/12.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TheTableViewForTitle;
@class Model;
@protocol  TheTableViewForTitleDelegate<NSObject>
- (void)changeButtonStatus:(Model *)titlName;

@end

@interface TheTableViewForTitle : UITableView<UITableViewDelegate,UITableViewDataSource>


@property (nonatomic, assign) id<TheTableViewForTitleDelegate> BTdelagate;/** <#注释#> */
@property (nonatomic, strong) UIWindow *keyWin;/** <#注释#> */
- (void)show;
- (void)hidden;
@end
