//
//  ChooseUserViewController.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-3-9.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "QNavigationViewController.h"

typedef enum _ChooseUserType
{
    GroupEditChooseUserType=0,                      //群组增加和编辑选择成员
    GroupChatChooseUserType                         //群聊选择成员
}ChooseUserType;

@protocol ChooseUserViewControllerDelegate <NSObject>
@optional
-(void)completeChooseUserAction:(NSMutableArray*)aryChoosedUser;
@end

@interface ChooseUserViewController : QNavigationViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>

@property(nonatomic)id<ChooseUserViewControllerDelegate> delegate;
@property(nonatomic)ChooseUserType chooseUserType;
@property (nonatomic, strong) NSString *strSearchText;
//群组编辑，选择成员，用于判断群主不能选择
@property (nonatomic, strong) NSString *strGroupCreateID;

@property(nonatomic)BOOL bIsAllTab;              //处于全部tab，还是已选tab
@property(nonatomic)NSUInteger nChooseUserNumber;               //用户已选数量

//User Data///////////////////////////////////////////////////////////////
@property (nonatomic, strong) NSMutableArray *aryUserDBData;                //原始数据
@property (nonatomic, strong) NSMutableArray *aryUserChoosed;               //用户已选数据

@property (nonatomic, strong) NSMutableArray *aryUserDBFirstLetter;         //DB 初始化的数据
@property (nonatomic, strong) NSMutableDictionary *dicUserDBData;           //DB 初始化的数据

@property (nonatomic, strong) NSMutableArray *aryUserTableFirstLetter;      //绑定tableView data
@property (nonatomic, strong) NSMutableDictionary *dicUserTableData;        //绑定tableView data

@property (nonatomic, strong) NSMutableArray *aryUserFilteredObject;        //筛选的数据

@property(nonatomic,strong)NSMutableArray *aryUserPreChoosed;     //之前选中的数据

//UISearchBar
@property(nonatomic,strong)UISearchDisplayController *searchDisplayControllerData;
@property(nonatomic,strong)UISearchBar *searchBarData;

//
@property(nonatomic,strong)UIButton *btnChooseAllPersons;

//用户列表
@property(nonatomic,strong)UITableView *tableViewUserList;

//全部和已选
@property(nonatomic,strong)UIImageView *imgViewBottomTabBK;
@property(nonatomic,strong)UIButton *btnAllTab;
@property(nonatomic,strong)UIButton *btnAlreadyChooseTab;

@end
