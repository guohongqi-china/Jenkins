//
//  ChooseUserAndGroupViewController.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-28.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "PullingRefreshTableView.h"
#import "ChooseUserOldCell.h"

@protocol ChooseUserAndGroupDelegate;

@interface ChooseUserAndGroupViewController : QNavigationViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,PullingRefreshTableViewDelegate,ChooseUserOldCellDelegate>

@property(nonatomic,assign)id<ChooseUserAndGroupDelegate> delegate;
@property(nonatomic,assign)FromViewToChooseType fromViewType;   //来自的页面类型

@property (nonatomic, strong)ChatObjectVo *m_chatObjectVo;

@property (nonatomic, strong) NSString *strSearchText;

//User Data///////////////////////////////////////////////////////////////
@property (nonatomic, strong) NSMutableArray *aryUserDBData;                //原始数据
@property (nonatomic, strong) NSMutableArray *aryUserChoosed;               //用户已选数据

@property (nonatomic, strong) NSMutableArray *aryUserDBFirstLetter;         //DB 初始化的数据
@property (nonatomic, strong) NSMutableDictionary *dicUserDBData;           //DB 初始化的数据

@property (nonatomic, strong) NSMutableArray *aryUserTableFirstLetter;      //绑定tableView data
@property (nonatomic, strong) NSMutableDictionary *dicUserTableData;        //绑定tableView data

@property (nonatomic, strong) NSMutableArray *aryUserFilteredObject;        //筛选的数据
//Group Data//////////////////////////////////////////////////////////////
@property (nonatomic, strong) NSMutableArray *aryGroupDBData;                   //DB 初始化的数据
@property (nonatomic, strong) NSMutableArray *aryGroupChoosed;                  //用户已选数据
@property (nonatomic, retain) NSMutableArray *aryGroupTableData;                //tableView data
@property (nonatomic, strong) NSMutableArray *aryGroupFilteredObject;           //筛选的数据
/////////////////////////////////////////////////////////////////////////

@property (nonatomic, retain) NSMutableArray *aryOutGroup;  //外部传入的收件群组
@property (nonatomic, assign) NSInteger nOutGroupValidNum;  //有效的群组（能与选择列表id匹配）
@property (nonatomic, retain) NSMutableArray *aryOutUser;   //外部传入的收件用户
@property (nonatomic, assign) NSInteger nOutUserValidNum;   //有效的用户（能与选择列表id匹配）

@property(nonatomic)BOOL bIsAllTab;                                     //处于全部tab，还是已选tab
@property(nonatomic)BOOL bIsUserTab;                                    //处于用户还是群组

@property(nonatomic)NSInteger nChooseUserNumber;               //用户已选数量
@property(nonatomic)NSInteger nChooseGroupNumber;              //群组已选数量
@property(nonatomic)BOOL bChooseAllPeople;

///////////////////////////////////////////////////////////////////////
//用户和群组切换、全部和已选切换
@property(nonatomic,strong)UIButton *btnSwitchUserAndGroup;
@property(nonatomic,strong)UIButton *btnSwitchSelect;

//search
@property(nonatomic,strong) UITextField *txtSearch;
@property(nonatomic,strong) UIButton *btnSearch;
@property(nonatomic,strong) UIImageView *imgViewSearch;
@property(nonatomic,strong) PullingRefreshTableView *tableViewSearchResult; //tableVew search result

@property (nonatomic) BOOL bOnLineSearch;   //是否在线搜索(避免本地search 刷新)
@property (nonatomic) BOOL refreshing;
@property (nonatomic) NSInteger m_curPageNum;

//Choose all persons or all groups
@property(nonatomic,strong)UIButton *btnChooseAllPersons;

//UserList and GroupList
@property(nonatomic,strong)UITableView *tableViewUserList;

@property(nonatomic,strong)UITableView *tableViewGroupList;

@end

@protocol ChooseUserAndGroupDelegate <NSObject>
@optional
-(void)completeChooseUserAndGroupAction:(ChooseUserAndGroupViewController*)chooseController andGroupList:(NSMutableArray*)aryChoosedGroup
                            andUserList:(NSMutableArray*)aryChoosedUser;
@end




