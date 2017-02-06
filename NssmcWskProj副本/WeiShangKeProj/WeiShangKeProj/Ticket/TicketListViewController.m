//
//  TicketListViewController.m
//  WeiShangKeProj
//
//  Created by 焱 孙 on 15/5/28.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "TicketListViewController.h"
#import "Utils.h"
#import "HopeModel.h"
#import "TicketVo.h"
#import "TicketListCell.h"
#import "TicketDetailViewController.h"
#import "UIViewExt.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "CustomPicker.h"
#import "KeyValueVo.h"
#import "ServerURL.h"
#import "TichetServise.h"
#import "SNUIBarButtonItem.h"
#import "MBProgressHUD+GHQ.h"
#import "WorkOrderDetailsViewControll.h"
#import "QiangOrderTicketListController.h"
#import "shareModel.h"
@interface TicketListViewController ()<UIPickerViewDataSource,UIPickerViewDelegate,CustomPickerDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>
{
    NSString *strSearchText;
    NoSearchView *noSearchView;
    NSMutableArray *aryTicketList;          //全部工单
    NSMutableArray *aryFilteredObject;        //筛选的数据
    
    UISearchDisplayController *_searchDisplayController;
    
      CustomPicker *pickerClass;                  //分类
      CustomPicker *pickerDifficulty;
    NSMutableArray *aryTicketClass;             //工单分类
    NSMutableArray *aryTicketDifficulty;        //工单难易度
    NSString *strClassKey;
    NSString *strDifficultyKey;
    NSString *strStatus;                    //当前状态
    
    CGFloat fScrollOffsetY;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBarTicket;
@property (weak, nonatomic) IBOutlet UITableView *tableViewTicket;
@property (weak, nonatomic) IBOutlet UIButton *btnTicketType;
@property (weak, nonatomic) IBOutlet UIButton *btnDifficulty;

@property (weak, nonatomic) IBOutlet UIView *viewClassView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintClassView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintViewH;

@property (nonatomic, strong) shareModel *modell;/** <#注释#> */
@end

@implementation TicketListViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UpdateTicketList" object:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerAddPanGesture object:nil];
}
- (void)HadAction{
    [aryTicketList removeAllObjects];
    [self loadNewData:@""];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(HadAction) name:@"HadReceiveNotification" object: nil];
    self.navigationController.navigationBar.translucent = NO;
    [self initData];
    [self initView];
    self.modell = [shareModel sharedManager];
    self.modell.locationBool = shareModelLocationYes;
    [self.modell shareModelStartToLocation];

   
}



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerRemovePanGesture object:nil];
    [_searchDisplayController setActive:NO animated:YES];
}

-(void)initView
{
    self.view.backgroundColor = [UIColor whiteColor];
    
       //标题
    if (self.ticketListType == TicketListTryType)
    {
        //[self setTopNavBarTitle:@"可抢工单"];
        self.title = @"可抢工单";
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.tableViewTicket.tableHeaderView  = nil;

    }
    else if(self.ticketListType == TicketListMyType)
    {
        //[self setTopNavBarTitle:@"我的工单"];
        self.title = @"我的工单";

    }
    else if(self.ticketListType == TicketListUnresolveType)
    {
        self.title = @"未解决工单";
        
        
        
    }
    else if(self.ticketListType == TicketListResolveType)
    {
        //[self setTopNavBarTitle:@"已解决工单"];
        self.title = @"已解决工单";
    }
    [self setTitleColor:[UIColor whiteColor]];
    __weak typeof(self) weakSelf = self;
    self.tableViewTicket.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
           _nCurrPage = 1;
        self.refreshing = YES;
        [weakSelf loadNewData:@""];
    }];
    self.tableViewTicket.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
     
        _nCurrPage++;
        self.refreshing = NO;
        [weakSelf loadNewData:@""];
    }];
//    self.tableViewTicket.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];


    //if (self.ticketListType == TicketListAllType)
    {

        
        self.isNeedBackItem = NO;
        SNUIBarButtonItem *leftItem = [SNUIBarButtonItem backItemWithImage:@"nav_setting" target:self action:@selector(showSideMenu)];
//        leftItem.tintColor = COLOR(112, 84, 81, 1.0);
        self.navigationItem.leftBarButtonItem = leftItem;
        

    }

    
    self.searchBarTicket.backgroundColor = COLOR(199, 199, 204, 1.0);
    
    _searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBarTicket contentsController:self];
    _searchDisplayController.searchResultsDataSource = self;
    _searchDisplayController.searchResultsDelegate = self;
    _searchDisplayController.delegate = self;
    _searchDisplayController.searchResultsTableView.showsVerticalScrollIndicator = NO;
  
    
    [self.tableViewTicket registerNib:[UINib nibWithNibName:@"ticketCell" bundle:nil] forCellReuseIdentifier:@"TicketListCell"];
    [ _searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"ticketCell" bundle:nil] forCellReuseIdentifier:@"TicketListCell"] ;

    
    //no search view
    noSearchView = [[NoSearchView alloc]initWithFrame:CGRectMake(0, self.tableViewTicket.top, kScreenWidth, self.tableViewTicket.height) andDes:nil];
    self.tableViewTicket.separatorStyle = UITableViewCellSeparatorStyleNone;
 
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateList) name:@"UpdateTicketList" object:nil];
    
    //class button content align
    [Common setButtonImageRightTitleLeft:self.btnTicketType spacing:5];
    [Common setButtonImageRightTitleLeft:self.btnDifficulty spacing:5];
//    if ([self.title isEqualToString:@"可抢工单"]) {
//        [self.searchBarTicket removeFromSuperview];
//    }
    //picker View(抢工单不显示)
    if (self.ticketListType == TicketListTryType)
    {
        self.viewClassView.hidden = YES;
    }
    else
    {
        self.viewClassView.hidden = NO;

        pickerClass = [[CustomPicker alloc] initWithFrame:CGRectZero andDelegate:self];
        [self.view addSubview:pickerClass];
        
        [pickerClass mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.and.trailing.and.bottom.equalTo(@0);
            make.height.equalTo(@0);
        }];
        
        pickerDifficulty = [[CustomPicker alloc] initWithFrame:CGRectZero andDelegate:self];
        [self.view addSubview:pickerDifficulty];
        
        [pickerDifficulty mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.and.trailing.and.bottom.equalTo(@0);
            make.height.equalTo(@0);
        }];
    }
}
- (void)loadNewData{
    _nCurrPage = 1;
            self.refreshing = NO;
            [self loadNewData:@""];
}
-(void)initData
{
    fScrollOffsetY = 0;
    aryTicketList = [NSMutableArray array];
    aryFilteredObject = [NSMutableArray array];
    
    BOOL bGrabTicket = NO;
    if (self.ticketListType == TicketListTryType)
    {
        bGrabTicket = YES;
    }
    else if (self.ticketListType == TicketListMyType)
    {
        strStatus = @"";
    }
    else if (self.ticketListType == TicketListUnresolveType)
    {
        strStatus = @"0";//未结束
    }
    else if (self.ticketListType == TicketListResolveType)
    {
        strStatus = @"1";//已结束
    }
    //分类
    aryTicketClass = [NSMutableArray array];
    KeyValueVo *keyValueVo = [[KeyValueVo alloc]init];
    keyValueVo.strKey = @"";
    keyValueVo.strValue = @"全部";
    [aryTicketClass addObject:keyValueVo];
    
    keyValueVo = [[KeyValueVo alloc]init];
    keyValueVo.strKey = @"";
    keyValueVo.strValue = @"网络";
    [aryTicketClass addObject:keyValueVo];
    
    keyValueVo = [[KeyValueVo alloc]init];
    keyValueVo.strKey = @"HardWare";
    keyValueVo.strValue = @"服务器";
    [aryTicketClass addObject:keyValueVo];
    
    keyValueVo = [[KeyValueVo alloc]init];
    keyValueVo.strKey = @"SoftWare";
    keyValueVo.strValue = @"PC机";
    [aryTicketClass addObject:keyValueVo];
    
    keyValueVo = [[KeyValueVo alloc]init];
    keyValueVo.strKey = @"";
    keyValueVo.strValue = @"综合布线";
    [aryTicketClass addObject:keyValueVo];
    
    keyValueVo = [[KeyValueVo alloc]init];
    keyValueVo.strKey = @"other";
    keyValueVo.strValue = @"其他";
    [aryTicketClass addObject:keyValueVo];
    

    
    //难易度
    aryTicketDifficulty = [NSMutableArray array];
    keyValueVo = [[KeyValueVo alloc]init];
    keyValueVo.strKey = @"";
    keyValueVo.strValue = @"全部";
    [aryTicketDifficulty addObject:keyValueVo];
    
    keyValueVo = [[KeyValueVo alloc]init];
    keyValueVo.strKey = @"hard";
    keyValueVo.strValue = @"难";
    [aryTicketDifficulty addObject:keyValueVo];
    
    keyValueVo = [[KeyValueVo alloc]init];
    keyValueVo.strKey = @"normal";
    keyValueVo.strValue = @"中";
    [aryTicketDifficulty addObject:keyValueVo];
    
    keyValueVo = [[KeyValueVo alloc]init];
    keyValueVo.strKey = @"easy";
    keyValueVo.strValue = @"易";
    [aryTicketDifficulty addObject:keyValueVo];

    
    self.nCurrPage = 1;
    strSearchText = @"";
    [self loadNewData:@""];
}

-(void)updateList
{
    self.nCurrPage = 1;
    self.refreshing = YES;
    [self loadNewData:@""];
}

- (void)loadNewData:(NSString *)searchContent
{
     
    dispatch_async(dispatch_get_global_queue(0,0),^{
        if (aryTicketList.count > 0)
        {
            if (self.refreshing)
            {
                //下拉刷新
//                self.nCurrPage +=1;
            }
            else
            {
                //上拖加载
            
            }
        }
        
        
        
        ServerReturnInfo *retInfo;
        if (self.ticketListType == TicketListTryType)
        {
            //可抢工单

            NSDictionary *bodyDic = @{@"pageNo":[NSString stringWithFormat:@"%ld",(long)self.nCurrPage],@"lines":@"20"};
            [TichetServise sendRequest:bodyDic result:^(ServerReturnInfo *retInfo) {
                [self.tableViewTicket.mj_header endRefreshing];
                [self.tableViewTicket.mj_footer endRefreshing];

                if (retInfo.bSuccess) {
                    
                    NSMutableArray *dataArray = retInfo.data;
                    
                    //上拖加载
                    if (_refreshing) {
                        [aryTicketList removeAllObjects];
                    }
                    
                    for (NSDictionary *ddd in dataArray) {
                        TicketVo *mode = [[TicketVo alloc]init];
                        [mode setValuesForKeysWithDictionary:ddd];
                        
                        [aryTicketList addObject:mode];
                    }
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableViewTicket reloadData];
                    });

                    
                   
                    
                }else{
                    [self.tableViewTicket.mj_header endRefreshing];
                    [self.tableViewTicket.mj_footer endRefreshing];
                    [MBProgressHUD showSuccess:retInfo.strErrorMsg toView:nil];
                }
                
                
            }];
            
            
        }
        else
        {
            retInfo = [ServerProvider getTicketList:searchContent page:self.nCurrPage pageSize:15 status:strStatus type:strClassKey difficulty:strDifficultyKey title:self.title];
        }
        if (retInfo.bSuccess)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableViewTicket.mj_header endRefreshing];
                [self.tableViewTicket.mj_footer endRefreshing];
                NSMutableArray *dataArray = retInfo.data;
                if ( strClassKey != nil || strDifficultyKey != nil) {
                    [aryTicketList removeAllObjects];
                    
                }
                if (_refreshing) {
                    [aryTicketList removeAllObjects];
                }
                        //上拖加载
                        
                        for (NSDictionary *ddd in dataArray) {
                            TicketVo *mode = [[TicketVo alloc]init];
                            [mode setValuesForKeysWithDictionary:ddd];
//                            NSMutableArray *arr = [NSMutableArray array];
                            
                            [aryTicketList addObject:mode];
                        }
                
                
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableViewTicket reloadData];
                        });

                
                NSNumber *numberTotal = retInfo.data2;
                if (numberTotal != nil && numberTotal.integerValue<=aryTicketList.count)
                {
                    //已经加载完毕
//                    self.tableViewTicketList.reachedTheEnd = YES;
                }
                else
                {
                    //没有全部加载完毕
//                    self.tableViewTicketList.reachedTheEnd = NO;
                }
                

            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableViewTicket.mj_header endRefreshing];
                [self.tableViewTicket.mj_footer endRefreshing];
//                [self.tableViewTicketList tableViewDidFinishedLoading];
            });
        }
    });
     
}

- (void)showSideMenu
{
    [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerOpenLeftSide object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doSearch
{

    //1.Condition Check
    if (strSearchText == nil || strSearchText.length<=0)
    {
        return;
    }
    
    [Common showProgressView:nil view:self.view modal:NO];
    dispatch_async(dispatch_get_global_queue(0,0),^{
        [aryFilteredObject removeAllObjects];
        //暂时只能搜索前30条记录
        ServerReturnInfo *retInfo = [ServerProvider getTicketList:strSearchText page:1 pageSize:30 status:strStatus type:strClassKey difficulty:strDifficultyKey title:self.title];
        if (retInfo.bSuccess)
        {
            NSMutableArray *aryTemp = (NSMutableArray *)retInfo.data;
            dispatch_async(dispatch_get_main_queue(),^{
                if (aryTemp != nil && [aryTemp count] > 0)
                {
                    
                    for (NSDictionary *ddd in aryTemp) {
                        TicketVo *mode = [[TicketVo alloc]init];
                        [mode setValuesForKeysWithDictionary:ddd];
                        [aryFilteredObject addObject:mode];
                        
                    }
                
                    [self.searchDisplayController.searchResultsTableView reloadData];
                }
                [Common hideProgressView:self.view];
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [Common hideProgressView:self.view];
            });
        }
    });
}

//增加工单
- (void)addTicket
{
//    TicketDetailViewController *ticketDetailViewController = [[TicketDetailViewController alloc]init];
//    ticketDetailViewController.ticketDetailType = TicketDetailAddType;
//    TicketVo *ticketVo = [[TicketVo alloc]init];
//    ticketVo.strSessionID = self.m_chatObjectVo.strID;
//    ticketDetailViewController.m_ticketVo = ticketVo;
//    ticketDetailViewController.aryOutTicket = self.aryTicketList;
//    ticketDetailViewController.refreshTicketBlock = ^(){[self updateList];};
//    [self.navigationController pushViewController:ticketDetailViewController animated:YES];
}

- (void)configureCell:(TicketListCell *)cell withTicketVo:(TicketVo *)ticketVo
{
    cell.fd_enforceFrameLayout = NO; // Enable to use "-sizeThatFits:"
    [cell setEntity:ticketVo];
}

- (IBAction)filterAction:(id)sender
{
    if(sender == self.btnTicketType)
    {
        [self setPickerHidden:pickerClass andHide:NO];
    }
    else
    {
        [self setPickerHidden:pickerDifficulty andHide:NO];
    }
}

//显示隐藏弹出控件
- (void)setPickerHidden:(UIView*)pickerViewCtrl andHide:(BOOL)hidden
{
    CGFloat fFirstH=0,fSecondH=260;
    if (hidden)
    {
        fFirstH = 260;
        fSecondH = 0;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        [pickerViewCtrl mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(fSecondH);
        }];
        [self.view layoutIfNeeded];
    } completion:nil];
}

#pragma mark Table View
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableViewTicket)
    {
        //客户列表
        return  [aryTicketList count];
    }
    else
    {
        //搜索结果
        return aryFilteredObject.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //采用自动计算高度，并且带有缓存机制
    TicketVo *ticketVo = nil;
    if (tableView == self.tableViewTicket)
    {
        //列表
        ticketVo = aryTicketList[indexPath.row];
    }
    else
    {
        //搜索结果
        ticketVo = aryFilteredObject[indexPath.row];
//        return 130;
    }

    return [tableView fd_heightForCellWithIdentifier:@"TicketListCell" cacheByIndexPath:indexPath configuration:^(TicketListCell *cell) {
        [self configureCell:cell withTicketVo:ticketVo];
    }];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TicketVo *ticketVo = nil;
    if (tableView == self.tableViewTicket)
    {
        //列表
        ticketVo = aryTicketList[indexPath.row];
        if (self.ticketListType == TicketListTryType) {
            ticketVo.isQiang = NO;
        }else{
            ticketVo.isQiang = YES;
        }
        TicketListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TicketListCell" forIndexPath:indexPath];
        [self configureCell:cell withTicketVo:ticketVo];
        return  cell;
    }
    else
    {
        //搜索结果
        ticketVo = aryFilteredObject[indexPath.row];
        TicketListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TicketListCell" forIndexPath:indexPath];
        [self configureCell:cell withTicketVo:ticketVo];
        return  cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TicketVo *ticketVo;
    if (tableView == self.tableViewTicket)
    {
        //客户列表
        ticketVo = aryTicketList[indexPath.row];
        ticketVo.isQiang = YES;
    }
    else
    {
        //搜索结果
        if (aryFilteredObject.count == 0)
        {
            return;
        }
        
        ticketVo = aryTicketList[indexPath.row];
    }
    if ([self.title isEqualToString:@"可抢工单"]) {

        
        QiangOrderTicketListController *controller = [[QiangOrderTicketListController alloc]init];
        
        controller.model = ticketVo;
        controller.modelArray = ticketVo.hopeTime;
        controller.malfunctionId = ticketVo.malfunctionId;
        controller.detailId = ticketVo.detailId;
        [self.navigationController pushViewController:controller animated:YES];
    }else{
        WorkOrderDetailsViewControll *control = [[WorkOrderDetailsViewControll alloc]init];
        control.malfunctionId = ticketVo.malfunctionId;
        control.detailId = ticketVo.detailId;
        control.ENDid = ticketVo.engId;
        control.modelArray = ticketVo.hopeTime;
         control.judgeController = noIsOk;
        [self.navigationController pushViewController:control animated:YES];

    }
   
    

}

#pragma mark - ScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    fScrollOffsetY = scrollView.contentOffset.y;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //滚动弹出底部筛选按钮
    if (scrollView.contentOffset.y<fScrollOffsetY)
    {
        //显示
        if(self.constraintViewH.constant < 35)//当已经显示就不用再执行动画显示了
        {
            self.constraintViewH.constant = 0;
            [self.viewClassView layoutIfNeeded];
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.constraintViewH.constant = 35;
                [self.viewClassView layoutIfNeeded];
            } completion:nil];
        }
    }
    else if (scrollView.contentOffset.y>fScrollOffsetY)
    {
        if(self.constraintViewH.constant > 0)
        {
            self.constraintViewH.constant = 35;
            [self.viewClassView layoutIfNeeded];
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.constraintViewH.constant = 0;
                [self.viewClassView layoutIfNeeded];
            } completion:nil];
        }
    }
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //文字改变
    strSearchText = searchText;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    //恢复初始状态 （恢复原来数据）
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    //要进行实时搜索
    [self doSearch];
    [self.searchDisplayController.searchResultsTableView reloadData];
    return YES;
}

-(void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView
{
    //tableView.frame = CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT-20);
}

#pragma mark - CustomPickerDelegate
- (void)donePickerButtonClick:(CustomPicker*)pickerViewCtrl
{
    [self setPickerHidden:pickerViewCtrl andHide:YES];
    if (pickerViewCtrl == pickerClass)
    {
        if (aryTicketClass.count>0)
        {
            KeyValueVo *keyValueVo = [aryTicketClass objectAtIndex:[pickerViewCtrl getSelectedRowNum]];
            strClassKey = keyValueVo.strKey;
            NSString *strName = keyValueVo.strValue;

            if ([strName isEqualToString:@"服务器"]) {
                strClassKey = @"commonLevel2";
            }
            if ([strName isEqualToString:@"网络"]) {
                strClassKey = @"commonLevel1";
            }
            if ([strName isEqualToString:@"PC机"]) {
                strClassKey = @"commonLevel3";
            }
            if ([strName isEqualToString:@"综合布线"]) {
                strClassKey = @"commonLevel4";
            }
            if ([strName isEqualToString:@"其他"]) {
                strClassKey = @"commonLevel5";
            }
            if ([strName isEqualToString:@"全部"]) {
                strClassKey = @"";
            }

            [self.btnTicketType setTitle:strName forState:UIControlStateNormal];
            [Common setButtonImageRightTitleLeft:_btnTicketType spacing:5];
        }
    }
    else if (pickerViewCtrl == pickerDifficulty)
    {
        KeyValueVo *keyValueVo = [aryTicketDifficulty objectAtIndex:[pickerViewCtrl getSelectedRowNum]];
        strDifficultyKey = keyValueVo.strKey;
        NSString *strName = keyValueVo.strValue;
        if (keyValueVo.strKey.length == 0)
        {
            strName = @"难易度";
        }
        if ([strName isEqualToString:@"难"]) {
            strDifficultyKey = @"30";
        }
        if ([strName isEqualToString:@"中"]) {
            strDifficultyKey = @"20";
        }
        if ([strName isEqualToString:@"易"]) {
            strDifficultyKey = @"10";
        }
        [self.btnDifficulty setTitle:strName forState:UIControlStateNormal];
        [Common setButtonImageRightTitleLeft:_btnDifficulty spacing:5];
    }
    self.nCurrPage = 1;
    self.refreshing = YES;
 
    [self loadNewData:@""];
}

- (void)cancelPickerButtonClick:(CustomPicker*)pickerViewCtrl
{
    [self setPickerHidden:pickerViewCtrl andHide:YES];
}

#pragma mark Picker Data Source Methods
//1 选取器组件的个数，也就是滚轮的个数
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

//2 每个组件的行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger nRowNum = 0;
    if (pickerView == pickerClass.pickerView)
    {
        nRowNum = aryTicketClass.count;
    }
    else if (pickerView == pickerDifficulty.pickerView)
    {
        nRowNum = aryTicketDifficulty.count;
    }
    return nRowNum;
}

//3 绑定选取器上面的数据，主要是文本
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *strText = @"";
    if (pickerView == pickerClass.pickerView)
    {
        KeyValueVo *keyValueVo = [aryTicketClass objectAtIndex:row];
        strText = keyValueVo.strValue;
    }
    else if(pickerView == pickerDifficulty.pickerView)
    {
        KeyValueVo *keyValueVo = [aryTicketDifficulty objectAtIndex:row];
        strText = keyValueVo.strValue;
    }
    return strText;
}

@end
