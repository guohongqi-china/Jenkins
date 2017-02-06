//
//  MemberListViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/2/24.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "QNavigationViewController.h"

@interface MemberListViewController : QNavigationViewController

@property (nonatomic, strong)ChatObjectVo *m_chatObjectVo;

@property (nonatomic, retain) NSMutableArray *aryObject;            //tableView data
@property (nonatomic, retain) NSMutableArray *aryFilteredObject;    //筛选的数据
@property (nonatomic, retain) NSMutableArray *aryOrignData;         //初始数据

@end
