//
//  MainViewController.h
//  FindestProj
//
//  Created by MacBook on 16/7/13.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ShareHomeViewController;

typedef NS_ENUM(NSInteger,LoadDataType)
{
    LoadDataFirstType,
    LoadDataNoFirstType
};
typedef NS_ENUM(NSInteger,DataType)
{
    DataTypeAll,
    DataTypeone
};
@interface MainViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableViewShare;/** <#注释#> */

@property (nonatomic)  LoadDataType Type;/** <#注释#> */

@property (nonatomic) DataType dataTP;/** <#注释#> */
@property (nonatomic, weak)ShareHomeViewController *shareHomeViewController;

@end
