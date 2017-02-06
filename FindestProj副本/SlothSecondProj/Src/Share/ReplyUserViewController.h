//
//  ReplyUserViewController.h
//  FindestMeetingProj
//
//  Created by 焱 孙 on 12/30/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "PullingRefreshTableView.h"
#import "ChatObjectVo.h"

@protocol ReplyUserDelegate <NSObject>
@optional
-(void)completeChooseUserAction:(UserVo*)userVo;
-(void)cancelChooseUserAction:(BOOL)bClickAtButton;
-(void)showKeyboard;
@end

@interface ReplyUserViewController : QNavigationViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,PullingRefreshTableViewDelegate>

@property(nonatomic,weak)id<ReplyUserDelegate> delegate;
@property (nonatomic,strong) NSString *strSearchText;
@property(nonatomic)NSUInteger nChooseUserNumber;               //用户已选数量
@property(nonatomic,strong)ChatObjectVo *chatObjectVo;

//User Data///////////////////////////////////////////////////////////////
@property (nonatomic,strong) NSMutableArray *aryUserOrignalData;                //原始数据
@property (nonatomic,strong) NSMutableArray *aryUserTableData;             //绑定tableView data
@property (nonatomic,strong) NSMutableArray *aryUserFilteredObject;        //筛选的数据

//search
@property(nonatomic,strong) UITextField *txtSearch;
@property(nonatomic,strong) UIButton *btnSearch;
@property(nonatomic,strong) UIImageView *imgViewSearch;
@property(nonatomic,strong) PullingRefreshTableView *tableViewSearchResult; //tableVew search result

@property (nonatomic) BOOL bClickAtButtonEnter; //是否为点击@button进入（用于判断是否追加@字符）
@property (nonatomic) BOOL bOnLineSearch;   //是否在线搜索(避免本地search 刷新)
@property (nonatomic) BOOL refreshing;
@property (nonatomic) NSInteger m_curPageNum;

//用户列表
@property(nonatomic,strong)UITableView *tableViewUserList;

-(void)refreshData;

@end
