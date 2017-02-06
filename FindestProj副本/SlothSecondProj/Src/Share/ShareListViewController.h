//
//  ShareListViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/2.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShareHomeViewController;

typedef NS_ENUM(NSUInteger,ShareListType)
{
    ShareListAllType,
    ShareListAttentionType
};

@interface ShareListViewController : UIViewController

@property (nonatomic, assign)   BOOL isPush;/** <#注释#> */
@property (nonatomic, strong)UITableView *tableViewShare;
@property (nonatomic) ShareListType shareListType;
@property (nonatomic, weak)ShareHomeViewController *shareHomeViewController;

@end
