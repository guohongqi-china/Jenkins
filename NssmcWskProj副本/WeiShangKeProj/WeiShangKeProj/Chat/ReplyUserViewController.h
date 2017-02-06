//
//  ReplyUserViewController.h
//  FindestMeetingProj
//
//  Created by 焱 孙 on 12/30/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "ChatObjectVo.h"

@protocol ReplyUserDelegate <NSObject>
@optional
-(void)completeChooseUserAction:(UserVo*)userVo;
@end

@interface ReplyUserViewController : QNavigationViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>

@property(nonatomic,weak)id<ReplyUserDelegate> delegate;
@property (nonatomic,strong) NSString *strSearchText;
@property(nonatomic)NSUInteger nChooseUserNumber;               //用户已选数量
@property(nonatomic,strong)ChatObjectVo *chatObjectVo;

//User Data///////////////////////////////////////////////////////////////
@property (nonatomic,strong) NSMutableArray *aryUserOrignalData;                //原始数据
@property (nonatomic,strong) NSMutableArray *aryUserTableData;             //绑定tableView data
@property (nonatomic,strong) NSMutableArray *aryUserFilteredObject;        //筛选的数据

//UISearchBar
@property(nonatomic,strong)UISearchDisplayController *searchDisplayControllerData;
@property(nonatomic,strong)UISearchBar *searchBarData;

//用户列表
@property(nonatomic,strong)UITableView *tableViewUserList;

-(void)refreshData;

@end
