//
//  SuggestionListViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/3/16.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "SuggestionListViewController.h"
#import "Utils.h"
#import "SuggestionListCell.h"
#import "SuggestionVo.h"
#import "AddSuggestionViewController.h"
#import "SuggestionDetailViewController.h"
#import "SkinManage.h"
#import "DropDownDataVo.h"
#import "UserVo.h"
#import "DepartmentVo.h"
#import "UIViewExt.h"
#import "KeyValueVo.h"
#import "CommonNavigationController.h"
#import "MJRefresh.h"
#import "DropDownListView.h"
#import "SuggestionFilterView.h"
#import "NoSearchView.h"

@interface SuggestionListViewController ()<DropDownListViewDelegate,SuggestionFilterViewDelegate>
{
    UIView *viewFilterContainer;
    UIButton *btnFilter1;
    UIButton *btnFilter2;
    
    DropDownListView *dropDownListView;
    SuggestionFilterView *suggestionFilterView;
    
    //临时存储
    DropDownDataVo *dataVoState;
    DropDownDataVo *dataVoDepartment;
    NoSearchView *noSearchView;
}

@end

@implementation SuggestionListViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"RefreshSuggestionList" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    [self initData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initView
{
    self.view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    //筛选视图
    viewFilterContainer = [[UIView alloc]initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, 44)];
    viewFilterContainer.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    [self.view addSubview:viewFilterContainer];
    
    UIView *viewLineTopH = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 0.5)];
    viewLineTopH.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [viewFilterContainer addSubview:viewLineTopH];
    
    UIView *viewLineBottomH = [[UIView alloc]initWithFrame:CGRectMake(0, 43.5, kScreenWidth, 0.5)];
    viewLineBottomH.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [viewFilterContainer addSubview:viewLineBottomH];
    
    UIView *viewLineMidV = [[UIView alloc]initWithFrame:CGRectMake(kScreenWidth/2, 7, 0.5, 30)];
    viewLineMidV.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [viewFilterContainer addSubview:viewLineMidV];
    
    btnFilter1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btnFilter1.frame = CGRectMake(0, 0.5, kScreenWidth/2, 43);
    btnFilter1.titleLabel.font = [UIFont systemFontOfSize:16];
    [btnFilter1 setTitle:@"全部" forState:UIControlStateNormal];
    [btnFilter1 setTitleColor:[SkinManage colorNamed:@"Menu_Title_Color"] forState:UIControlStateNormal];
    [btnFilter1 setImage:[UIImage imageNamed:@"filter_arrow_down"] forState:UIControlStateNormal];
    [btnFilter1 setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"suggestion_Btn_select"]] forState:UIControlStateHighlighted];
    [btnFilter1 addTarget:self action:@selector(filterButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [Common setButtonImageRightTitleLeft:btnFilter1 spacing:10];
    [viewFilterContainer addSubview:btnFilter1];
    
    btnFilter2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btnFilter2.frame = CGRectMake(btnFilter1.right+0.5, 0.5, kScreenWidth/2, 43);
    btnFilter2.titleLabel.font = [UIFont systemFontOfSize:16];
    [btnFilter2 setTitle:@"筛选" forState:UIControlStateNormal];
    [btnFilter2 setTitleColor:[SkinManage colorNamed:@"Menu_Title_Color"] forState:UIControlStateNormal];
    [btnFilter2 setImage:[UIImage imageNamed:@"filter_arrow_down"] forState:UIControlStateNormal];
    [btnFilter2 setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"suggestion_Btn_select"]] forState:UIControlStateHighlighted];
    [btnFilter2 addTarget:self action:@selector(filterButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [Common setButtonImageRightTitleLeft:btnFilter2 spacing:10];
    [viewFilterContainer addSubview:btnFilter2];
    
    //    //创建搜索栏
    //    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    //    self.searchBar.placeholder = @"搜索";
    //    self.searchBar.delegate = self;
    //    self.searchBar.frame = CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, 44);
    //    [self.view addSubview:self.searchBar];
    //    
    //    self.suggestionSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    //    self.suggestionSearchDisplayController.searchResultsDataSource = self;
    //    self.suggestionSearchDisplayController.searchResultsDelegate = self;
    //    self.suggestionSearchDisplayController.delegate = self;
    //    self.suggestionSearchDisplayController.searchResultsTableView.backgroundColor = COLOR(248, 248, 248, 1.0);
    //    self.suggestionSearchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //    self.suggestionSearchDisplayController.searchResultsTableView.scrollsToTop = NO;
    
    self.tableViewSuggestion = [[UITableView alloc]initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT+44, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT-44)];
    self.tableViewSuggestion.dataSource = self;
    self.tableViewSuggestion.delegate = self;
    self.tableViewSuggestion.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewSuggestion.contentOffset = CGPointMake(0,0);
    self.tableViewSuggestion.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableViewSuggestion.scrollsToTop = YES;
    [self.view addSubview:self.tableViewSuggestion];
    
    //下拉刷新
    @weakify(self)
    self.tableViewSuggestion.mj_header =  [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self loadNewData:YES];
    }];
    
    //上拉加载更多
    self.tableViewSuggestion.mj_footer =  [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        [self loadNewData:NO];
    }];
    
    if (self.suggestionListType == SuggestionListAllType)
    {
        [self setTopNavBarTitle:@"合理化建议"];
        
        UIButton *btnNavRight = [Utils buttonWithImage:[SkinManage imageNamed:@"nav_write_suggestion"] frame:[Utils getNavRightBtnFrame:CGSizeMake(106,76)] target:self action:@selector(addSuggestion)];
        [self setRightBarButton:btnNavRight];
        
        self.tableViewSuggestion.frame = CGRectMake(0, NAV_BAR_HEIGHT+44, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT-44);
    }
    else
    {
        [self setTopNavBarTitle:@"我的建议"];
        viewFilterContainer.hidden = YES;
        self.tableViewSuggestion.frame = CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT);
    }
    
    noSearchView = [[NoSearchView alloc]initWithFrame:self.tableViewSuggestion.frame andDes:[NSString stringWithFormat:@"还没有%@",self.lblTitle.text]];
}

-(void)initData
{
    self.nViewMenu = 0;
    self.nCurrPage = 1;
    
    if (self.suggestionListType == SuggestionListAllType)
    {
        self.strRelateID = @"0";
    }
    else
    {
        //我的建议
        self.strRelateID = @"C";
    }
    
    self.aryObject = [[NSMutableArray alloc]init];
    self.aryFilteredObject = [[NSMutableArray alloc]init];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshData) name:@"RefreshSuggestionList" object:nil];
    
    [self getSuggestionBaseData];
    
    //分公司菜单数据
    self.aryDepartmentMenu = [NSMutableArray array];
    DropDownDataVo *dropDownDataVo = [[DropDownDataVo alloc]init];
    dropDownDataVo.strID = @"0";
    dropDownDataVo.strName = @"全部";
    dropDownDataVo.nIndex = 2000;
    [self.aryDepartmentMenu addObject:dropDownDataVo];
    
    NSMutableArray *aryDepartment = [Common getCurrentUserVo].aryDepartmentList;
    for (DepartmentVo *departmentVo in aryDepartment)
    {
        DropDownDataVo *dropDownDataVo = [[DropDownDataVo alloc]init];
        dropDownDataVo.strID = departmentVo.strDepartmentID;
        dropDownDataVo.strName = departmentVo.strDepartmentName;
        [self.aryDepartmentMenu addObject:dropDownDataVo];
    }
    dataVoDepartment = self.aryDepartmentMenu[0];
    
    //状态数据
    [self initStatusMenuData];
    
    //有关我的筛选数据
    [self initAboutMenuData];
    
    //加载建议列表数据
    [self loadNewData:YES];
}

//状态数据
-(void)initStatusMenuData
{
    self.aryStatusMenu = [NSMutableArray array];
    DropDownDataVo *dropDownDataVo = [[DropDownDataVo alloc]init];
    dropDownDataVo.strID = @"0";
    dropDownDataVo.strName = @"全部";
    dropDownDataVo.nIndex = 1000;
    [self.aryStatusMenu addObject:dropDownDataVo];
    
    dropDownDataVo = [[DropDownDataVo alloc]init];
    dropDownDataVo.strID = @"1";
    dropDownDataVo.strName = @"初评";
    [self.aryStatusMenu addObject:dropDownDataVo];
    
    dropDownDataVo = [[DropDownDataVo alloc]init];
    dropDownDataVo.strID = @"13";
    dropDownDataVo.strName = @"非合理化建议";
    [self.aryStatusMenu addObject:dropDownDataVo];
    
    dropDownDataVo = [[DropDownDataVo alloc]init];
    dropDownDataVo.strID = @"3";
    dropDownDataVo.strName = @"初评退回";
    [self.aryStatusMenu addObject:dropDownDataVo];
    
    dropDownDataVo = [[DropDownDataVo alloc]init];
    dropDownDataVo.strID = @"2";
    dropDownDataVo.strName = @"审核";
    [self.aryStatusMenu addObject:dropDownDataVo];
    
    dropDownDataVo = [[DropDownDataVo alloc]init];
    dropDownDataVo.strID = @"4";
    dropDownDataVo.strName = @"实施";
    [self.aryStatusMenu addObject:dropDownDataVo];
    
    dropDownDataVo = [[DropDownDataVo alloc]init];
    dropDownDataVo.strID = @"5";
    dropDownDataVo.strName = @"暂不实施";
    [self.aryStatusMenu addObject:dropDownDataVo];
    
    dropDownDataVo = [[DropDownDataVo alloc]init];
    dropDownDataVo.strID = @"6";
    dropDownDataVo.strName = @"不实施";
    [self.aryStatusMenu addObject:dropDownDataVo];
    
    dropDownDataVo = [[DropDownDataVo alloc]init];
    dropDownDataVo.strID = @"8";
    dropDownDataVo.strName = @"评审";
    [self.aryStatusMenu addObject:dropDownDataVo];
    
    dropDownDataVo = [[DropDownDataVo alloc]init];
    dropDownDataVo.strID = @"9";
    dropDownDataVo.strName = @"子公司评奖";
    [self.aryStatusMenu addObject:dropDownDataVo];
    
    dropDownDataVo = [[DropDownDataVo alloc]init];
    dropDownDataVo.strID = @"7";
    dropDownDataVo.strName = @"子公司评奖结果";
    [self.aryStatusMenu addObject:dropDownDataVo];
    
    dropDownDataVo = [[DropDownDataVo alloc]init];
    dropDownDataVo.strID = @"12";
    dropDownDataVo.strName = @"子公司不评奖";
    [self.aryStatusMenu addObject:dropDownDataVo];
    
    dropDownDataVo = [[DropDownDataVo alloc]init];
    dropDownDataVo.strID = @"10";
    dropDownDataVo.strName = @"总公司评奖";
    [self.aryStatusMenu addObject:dropDownDataVo];
    
    dropDownDataVo = [[DropDownDataVo alloc]init];
    dropDownDataVo.strID = @"11";
    dropDownDataVo.strName = @"总公司评奖结果";
    [self.aryStatusMenu addObject:dropDownDataVo];
    
    dataVoState = self.aryStatusMenu[0];
}

//有关我的筛选数据
-(void)initAboutMenuData
{
    self.aryAboutMeMenu = [NSMutableArray array];
    KeyValueVo *keyValueVo = [[KeyValueVo alloc]init];
    keyValueVo.strKey = @"0";
    keyValueVo.strValue = @"全部";
    [self.aryAboutMeMenu addObject:keyValueVo];
    
    keyValueVo = [[KeyValueVo alloc]init];
    keyValueVo.strKey = @"C";
    keyValueVo.strValue = @"已提交";
    [self.aryAboutMeMenu addObject:keyValueVo];
    
    keyValueVo = [[KeyValueVo alloc]init];
    keyValueVo.strKey = @"A";
    keyValueVo.strValue = @"已办";
    [self.aryAboutMeMenu addObject:keyValueVo];
}

- (void)showSideMenu
{
    [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerOpenLeftSide object:nil];
}

-(void)loadNewData:(BOOL)bRefresh
{
    if (bRefresh)
    {
        //下拉刷新
        self.nCurrPage = 1;
    }
    
    [ServerProvider getSuggestionList:self.strSearchText deparment:dataVoDepartment.strID status:dataVoState.strID relate:self.strRelateID page:self.nCurrPage pageSize:10 result:^(ServerReturnInfo *retInfo) {
        if (retInfo.bSuccess)
        {
            NSMutableArray *aryData = retInfo.data;
            if (bRefresh)
            {
                //下拉刷新
                [self.aryObject removeAllObjects];
                if (aryData != nil && aryData.count>0)
                {
                    [self.aryObject addObjectsFromArray:aryData];
                }
            }
            else
            {
                //上拖加载
                [self.aryObject addObjectsFromArray:aryData];
            }
            
            if (aryData != nil && aryData.count>0)
            {
                self.nCurrPage ++;
            }
            
            if (self.aryObject.count == 0)
            {
                [self.view addSubview:noSearchView];
            }
            else
            {
                [noSearchView removeFromSuperview];
            }
            
            [self.tableViewSuggestion reloadData];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
        
        //停止刷新
        if (bRefresh)
        {
            [self.tableViewSuggestion.mj_header endRefreshing];
        }
        
        if([retInfo.data2 boolValue])
        {
            [self.tableViewSuggestion.mj_footer endRefreshingWithNoMoreData];   //最后一页
        }
        else
        {
            [self.tableViewSuggestion.mj_footer endRefreshing];
        }
        
        [Common hideProgressView:self.view];
    }];
}

-(void)refreshData
{
    [self loadNewData:YES];
}

- (void)segmentedAction:(UISegmentedControl*)segmentedControl
{
    if (segmentedControl.selectedSegmentIndex == 0)
    {
        //全部
        self.strRelateID = @"0";
        [self.btnAboutMeFilter setTitleColor:COLOR(90, 90, 90, 1.0) forState:UIControlStateNormal];
    }
    else
    {
        //待办
        self.strRelateID = @"B";
        //相关筛选 恢复到全部状态
        [self.btnAboutMeFilter setTitle:@"相关筛选 ▲" forState:UIControlStateNormal];
        [self.btnAboutMeFilter setTitleColor:COLOR(170, 170, 170, 1.0) forState:UIControlStateNormal];
        [self.pickerAboutMe.pickerView selectRow:0 inComponent:0 animated:YES];
    }
    self.nCurrPage = 1;
    [self loadNewData:YES];
}

//筛选菜单
- (void)tapFilterButton:(UIButton*)sender
{
    if (sender == self.btnCompanyFilter)
    {
        //分公司
        [self setPickerHidden:self.pickerCompany andHide:NO];
        
        [self.btnCompanyFilter setTitleColor:[SkinManage skinColor] forState:UIControlStateNormal];
        [self.btnStatusFilter setTitleColor:COLOR(90, 90, 90, 1.0) forState:UIControlStateNormal];
        //        if (self.segmentedControl.selectedSegmentIndex == 0)
        //        {
        //            [self.btnAboutMeFilter setTitleColor:COLOR(90, 90, 90, 1.0) forState:UIControlStateNormal];
        //        }
    }
    else if (sender == self.btnStatusFilter)
    {
        //状态
        [self setPickerHidden:self.pickerStatus andHide:NO];
        
        [self.btnCompanyFilter setTitleColor:COLOR(90, 90, 90, 1.0) forState:UIControlStateNormal];
        [self.btnStatusFilter setTitleColor:[SkinManage skinColor] forState:UIControlStateNormal];
        //        if (self.segmentedControl.selectedSegmentIndex == 0)
        //        {
        //            [self.btnAboutMeFilter setTitleColor:COLOR(90, 90, 90, 1.0) forState:UIControlStateNormal];
        //        }
    }
    else if (sender == self.btnAboutMeFilter)
    {
        //相关筛选
        if([self.strRelateID isEqualToString:@"B"])
        {
            //处于代办tab下不能选择相关筛选
            [Common bubbleTip:@"待办情况下不能操作“相关筛选”菜单" andView:self.view];
        }
        else
        {
            [self setPickerHidden:self.pickerAboutMe andHide:NO];
            
            [self.btnCompanyFilter setTitleColor:COLOR(90, 90, 90, 1.0) forState:UIControlStateNormal];
            [self.btnStatusFilter setTitleColor:COLOR(90, 90, 90, 1.0) forState:UIControlStateNormal];
            [self.btnAboutMeFilter setTitleColor:[SkinManage skinColor] forState:UIControlStateNormal];
        }
    }
}

//获取基础数据
-(void)getSuggestionBaseData
{
    [self isHideActivity:NO];
    [ServerProvider getSuggestionBaseDataList:^(ServerReturnInfo *retInfo) {
        [self isHideActivity:YES];
        if (retInfo.bSuccess)
        {
            self.m_suggestionBaseVo = retInfo.data;
        }
    }];
}

//添加建议
-(void)addSuggestion
{
    AddSuggestionViewController *addSuggestionViewController = [[AddSuggestionViewController alloc]init];
    addSuggestionViewController.suggestionViewType = SuggestionViewAddType;
    addSuggestionViewController.suggestionBaseVo = self.m_suggestionBaseVo;
    
    CommonNavigationController *navController = [[CommonNavigationController alloc] initWithRootViewController:addSuggestionViewController];
    navController.navigationBarHidden = YES;
    [self presentViewController:navController animated:YES completion:nil];
}

//显示隐藏时间控件
- (void)setPickerHidden:(UIView*)pickerViewCtrl andHide:(BOOL)hidden
{
    if (hidden)
    {
        //显示底部Tab控件
        self.viewContainer.hidden = NO;
    }
    else
    {
        //隐藏底部Tab控件
        self.viewContainer.hidden = YES;
    }
    
    int nHeight = pickerViewCtrl.frame.size.height * (-1);
    CGAffineTransform transform = hidden ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0, nHeight);
    pickerViewCtrl.transform = transform;
    if (!hidden)
    {
        self.view.backgroundColor = [UIColor whiteColor];
        //self.tableViewSuggestion.frame = CGRectMake(0, NAV_BAR_HEIGHT, self.view.bounds.size.width, (kScreenHeight-NAV_BAR_HEIGHT-260+44));
    }
    else
    {
        //self.tableViewSuggestion.frame = CGRectMake(0, NAV_BAR_HEIGHT, self.view.bounds.size.width, kScreenHeight-NAV_BAR_HEIGHT);
    }
}

- (void)filterButtonAction:(UIButton *)sender
{
    if(sender == btnFilter1)
    {
        if (dropDownListView != nil && dropDownListView.bShow)
        {
            //隐藏
            [dropDownListView cancelChooseAnimated:YES];
        }
        else
        {
            //先隐藏其他的筛选视图
            [suggestionFilterView cancelChooseAnimated:YES];
            
            //显示
            if(dropDownListView == nil)
            {
                NSMutableArray *aryMenu = [NSMutableArray array];
                
                MenuVo *menuVo = [[MenuVo alloc]init];
                menuVo.strID = @"0";
                menuVo.strName = @"全部";
                [aryMenu addObject:menuVo];
                
                menuVo = [[MenuVo alloc]init];
                menuVo.strID = @"B";
                menuVo.strName = @"代办";
                [aryMenu addObject:menuVo];
                
                menuVo = [[MenuVo alloc]init];
                menuVo.strID = @"C";
                menuVo.strName = @"已提交";
                [aryMenu addObject:menuVo];
                
                menuVo = [[MenuVo alloc]init];
                menuVo.strID = @"A";
                menuVo.strName = @"已办";
                [aryMenu addObject:menuVo];
                
                dropDownListView = [[DropDownListView alloc]initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT+44, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT-44) menu:aryMenu];
                dropDownListView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
                dropDownListView.delegate = self;
            }
            [self.view addSubview:dropDownListView];
            [dropDownListView showWithAnimation];
            
            //改变筛选按钮状态
            [btnFilter1 setTitleColor:[SkinManage colorNamed:@"Tab_Item_Color_H"] forState:UIControlStateNormal];
            [btnFilter1 setImage:[UIImage imageNamed:@"filter_arrow_up"] forState:UIControlStateNormal];
        }
    }
    else
    {
        if (suggestionFilterView != nil && suggestionFilterView.bShow)
        {
            //隐藏
            [suggestionFilterView cancelChooseAnimated:YES];
        }
        else
        {
            //先隐藏其他的筛选视图
            [dropDownListView cancelChooseAnimated:NO];
            
            if(suggestionFilterView == nil)
            {
                suggestionFilterView = [[SuggestionFilterView alloc]initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT+44, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT-44) state:self.aryStatusMenu department:self.aryDepartmentMenu];
                suggestionFilterView.view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
                suggestionFilterView.delegate = self;
            }
            else
            {
                [suggestionFilterView refreshViewState:dataVoState department:dataVoDepartment];
            }
            [self.view addSubview:suggestionFilterView.view];
            [suggestionFilterView showWithAnimation];
            
            //改变筛选按钮状态
            [btnFilter2 setTitleColor:[SkinManage colorNamed:@"Tab_Item_Color_H"] forState:UIControlStateNormal];
            [btnFilter2 setImage:[UIImage imageNamed:@"filter_arrow_up"] forState:UIControlStateNormal];
        }
    }
}

#pragma mark - SuggestionFilterViewDelegate
- (void)completedChooseState:(DropDownDataVo *)stateData department:(DropDownDataVo *)departmentData
{
    //改变筛选按钮状态
    dataVoState = stateData;
    dataVoDepartment = departmentData;
    
    NSString *strTitle;
    if (stateData.nIndex == 1000)
    {
        if (departmentData.nIndex == 2000)
        {
            strTitle = @"筛选";
        }
        else
        {
            strTitle = departmentData.strName;
        }
    }
    else
    {
        if (departmentData.nIndex == 2000)
        {
            strTitle = stateData.strName;
        }
        else
        {
            strTitle = [NSString stringWithFormat:@"%@/%@",stateData.strName,departmentData.strName];
        }
    }
    
    [btnFilter2 setTitle:strTitle forState:UIControlStateNormal];
    [btnFilter2 setTitleColor:[SkinManage colorNamed:@"Menu_Title_Color"] forState:UIControlStateNormal];
    [btnFilter2 setImage:[UIImage imageNamed:@"filter_arrow_down"] forState:UIControlStateNormal];
    [Common setButtonImageRightTitleLeft:btnFilter2 spacing:10];
    
    //刷新接口
    self.nCurrPage = 1;
    [Common showProgressView:nil view:self.view modal:NO];
    [self loadNewData:YES];
}

- (void)cancelChooseFilter
{
    [btnFilter2 setTitleColor:[SkinManage colorNamed:@"Menu_Title_Color"] forState:UIControlStateNormal];
    [btnFilter2 setImage:[UIImage imageNamed:@"filter_arrow_down"] forState:UIControlStateNormal];
}

#pragma mark - DropDownListViewDelegate
- (void)completedChooseMenu:(MenuVo *)menuVo
{
    //改变筛选按钮状态
    self.strRelateID = menuVo.strID;
    
    [btnFilter1 setTitle:menuVo.strName forState:UIControlStateNormal];
    [btnFilter1 setTitleColor:[SkinManage colorNamed:@"Menu_Title_Color"] forState:UIControlStateNormal];
    [btnFilter1 setImage:[UIImage imageNamed:@"filter_arrow_down"] forState:UIControlStateNormal];
    [Common setButtonImageRightTitleLeft:btnFilter1 spacing:10];
    
    //刷新接口
    self.nCurrPage = 1;
    [Common showProgressView:nil view:self.view modal:NO];
    [self loadNewData:YES];
}

- (void)cancelChooseMenu
{
    //改变筛选按钮状态
    [btnFilter1 setTitleColor:[SkinManage colorNamed:@"Menu_Title_Color"] forState:UIControlStateNormal];
    [btnFilter1 setImage:[UIImage imageNamed:@"filter_arrow_down"] forState:UIControlStateNormal];
}

#pragma mark - Table view data source and delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableViewSuggestion)
    {
        return [self.aryObject count];
    }
    else
    {
        return [self.aryFilteredObject count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"SuggestionListCell";
    SuggestionListCell *cell = (SuggestionListCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[SuggestionListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        
        //        //改变选中背景色
        //        UIView *viewSelected = [[UIView alloc] initWithFrame:cell.frame];
        //        viewSelected.backgroundColor =TABLEVIEW_SELECTED_COLOR;
        //        cell.selectedBackgroundView = viewSelected;
    }
    
    NSUInteger row = [indexPath row];
    SuggestionVo *suggestionVo = nil;
    if (tableView == self.tableViewSuggestion)
    {
        suggestionVo = [self.aryObject objectAtIndex:row];
    }
    else
    {
        suggestionVo = [self.aryFilteredObject objectAtIndex:row];
    }
    [cell initWithDataVo:suggestionVo];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SuggestionVo *suggestionVo = nil;
    if (tableView == self.tableViewSuggestion)
    {
        suggestionVo = [self.aryObject objectAtIndex:[indexPath row]];
    }
    else
    {
        suggestionVo = [self.aryFilteredObject objectAtIndex:[indexPath row]];
    }
    return [SuggestionListCell calculateCellHeight:suggestionVo];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SuggestionVo *suggestionVo = nil;
    if (tableView == self.tableViewSuggestion)
    {
        suggestionVo = [self.aryObject objectAtIndex:[indexPath row]];
    }
    else
    {
        suggestionVo = [self.aryFilteredObject objectAtIndex:[indexPath row]];
    }
    SuggestionDetailViewController *suggestionDetailViewController = [[SuggestionDetailViewController alloc]init];
    suggestionDetailViewController.suggestionBaseVo = self.m_suggestionBaseVo;
    suggestionDetailViewController.m_suggestionVo = suggestionVo;
    [self.navigationController pushViewController:suggestionDetailViewController animated:YES];
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.aryFilteredObject removeAllObjects];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.strSearchText = searchBar.text;
    [self doSearch];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.strSearchText = @"";
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return YES;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    [self.searchDisplayController.searchResultsTableView setDelegate:self];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    for (UIView *subview in tableView.subviews)
    {
        if ([subview isKindOfClass:[UILabel class]])
        {
            [(UILabel *)subview setText:@""];
        }
    }
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView
{
    for (UIView *subview in tableView.subviews)
    {
        if ([subview isKindOfClass:[UILabel class]])
        {
            [(UILabel *)subview setText:@"无结果"];
        }
    }
}

-(void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView
{
    tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
}

- (void)doSearch
{
    //1.Condition Check
    if (self.strSearchText == nil || self.strSearchText.length<=0)
    {
        return;
    }
    
    [self isHideActivity:NO];
    [ServerProvider getSuggestionList:self.strSearchText deparment:dataVoDepartment.strID status:dataVoState.strID relate:self.strRelateID page:1 pageSize:50 result:^(ServerReturnInfo *retInfo) {
        [self isHideActivity:YES];
        NSMutableArray *aryTemp;
        if (retInfo.bSuccess)
        {
            aryTemp = (NSMutableArray *)retInfo.data;
        }
        
        if (aryTemp != nil && aryTemp.count > 0)
        {
            self.aryFilteredObject = [NSMutableArray arrayWithArray:aryTemp];
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
    }];
}

@end
