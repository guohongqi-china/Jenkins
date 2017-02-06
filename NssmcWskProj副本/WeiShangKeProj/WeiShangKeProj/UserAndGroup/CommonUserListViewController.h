//
//  CommonUserListViewController.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-3-13.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
typedef enum _CommonUserListType{
    CommonUserListChatType=0,                        //全部用户
    CommonTransferGroupType                     //转让群组
}CommonUserListType;

@protocol CommonUserListDelegate <NSObject>
@optional
-(void)completeChooseUserForTransferGroup:(UserVo*)userVo;
@end

@interface CommonUserListViewController : QNavigationViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>

@property (nonatomic) CommonUserListType commonUserListType;

@property (nonatomic) id<CommonUserListDelegate> delegate;

@property (nonatomic, strong) NSString *strExpandUserID;        //当前展开的UserID
@property (nonatomic, strong) NSString *strSearchExpandUserID;  //当前搜索展开的UserID

@property (nonatomic, strong) NSString *strSearchText;
@property (nonatomic, strong) NSMutableArray *aryDBData;
@property (nonatomic, strong) NSMutableArray *aryFirstLetter;
@property (nonatomic, strong) NSMutableArray *aryFilteredObject;    //筛选的数据
@property (nonatomic, strong) NSMutableDictionary *dicTableData;

@property (nonatomic, strong) UISearchDisplayController *userSearchDisplayController;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableViewUserList;

//current choose
@property (nonatomic, strong) UserVo *userVoCurrentChoose;

//群组成员数据
@property (nonatomic, strong) NSMutableArray *aryGroupMemData;

@end
