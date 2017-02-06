//
//  MainSearchViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/8.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "MainSearchViewController.h"
#import "HistorySearchDao.h"
#import "ContentTypeVo.h"
#import "SearchItemVo.h"
#import "UserVo.h"
#import "HistorySearchTextCell.h"
#import "SearchBlogTypeCell.h"
#import "HotSearchCell.h"
#import "FollowUserCell.h"
#import "InsetsTextField.h"
#import "NSObject+UITextField_ClearButton.h"
#import "SearchShareViewController.h"
#import "UserProfileViewController.h"
#import "ShareService.h"
#import "SearchRankViewController.h"
#import "SearchContentView.h"

@interface MainSearchViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    InsetsTextField *txtSearch;
    UIButton *btnCancel;
    
    //工作精华区/
    NSMutableArray *aryEssence;
    
    NSMutableArray *aryHistorySearch;
    BOOL bAllSearchRecord;  //标示当前是否处于显示所有历史记录的状态
    
    NSMutableArray *aryBlogType;
    
    //本周热门搜索
    NSMutableArray *aryHotSearch;
    
    //本周热门话题
    NSMutableArray *aryHotTopic;
    
    //推荐关注
    NSMutableArray *aryRecommend;
    NSInteger nRecommendPage;
    
    HistorySearchDao *searchDao;
    
    NSInteger nFlag;
    
    /////////////////////////////////////////////////////////////
    SearchContentView *searchContentView;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewContent;     //搜索前视图

@end

@implementation MainSearchViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_BACKTOHOME object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    [self initData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    
    [MobAnalytics beginLogPageView:@"searchPage"];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear: animated];
    
    [MobAnalytics endLogPageView:@"searchPage"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//设置status bar 颜色
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)initView
{
    //top nav bar
    [self setLeftBarButton:nil];
    
    txtSearch = [[InsetsTextField alloc]initWithFrame:CGRectMake(12, kStatusBarHeight+8, kScreenWidth-12-63, 28)];
    txtSearch.enablesReturnKeyAutomatically = YES;
    txtSearch.font = [UIFont systemFontOfSize:14];
    txtSearch.textColor = [UIColor whiteColor];
    txtSearch.backgroundColor = [SkinManage colorNamed:@"share_search_bg"];
    txtSearch.clearButtonMode = UITextFieldViewModeAlways;
    txtSearch.layer.cornerRadius = 5;
    txtSearch.layer.masksToBounds = YES;
    txtSearch.returnKeyType = UIReturnKeySearch;
    txtSearch.delegate = self;
    txtSearch.tintColor = [SkinManage colorNamed:@"share_search_bg_tintColor"];
    [self.viewTop addSubview:txtSearch];
    [txtSearch setBlueClearView];
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc]initWithString:@"搜索"];
    [attriString addAttribute:NSForegroundColorAttributeName value:[SkinManage colorNamed:@"share_search_placderText_color"] range:NSMakeRange(0, attriString.length)];
    txtSearch.attributedPlaceholder = attriString;
    [txtSearch becomeFirstResponder];
    
    btnCancel = [UIButton buttonWithType:UIButtonTypeSystem];
    btnCancel.titleLabel.font = [UIFont systemFontOfSize:17];
    [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    [btnCancel setTitleColor:[SkinManage colorNamed:@"share_btn_Color"] forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    btnCancel.frame = CGRectMake(kScreenWidth-60, kStatusBarHeight, 60, 44);
    [self.viewTop addSubview:btnCancel];
    
    [_tableViewContent registerNib:[UINib nibWithNibName:@"HistorySearchTextCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"HistorySearchTextCell"];
    [_tableViewContent registerNib:[UINib nibWithNibName:@"SearchBlogTypeCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SearchBlogTypeCell"];
    [_tableViewContent registerNib:[UINib nibWithNibName:@"HotSearchCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"HotSearchCell"];
    [_tableViewContent registerNib:[UINib nibWithNibName:@"FollowUserCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"FollowUserCell"];
    
    _tableViewContent.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];;
    _tableViewContent.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    searchContentView = [[SearchContentView alloc]initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, kScreenHeight) parent:self];
    searchContentView.hidden = YES;
    [self.view addSubview:searchContentView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelButtonClicked) name:NOTIFY_BACKTOHOME object:nil];
}

-(void)viewDidLayoutSubviews
{
    if ([_tableViewContent respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableViewContent setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([_tableViewContent respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tableViewContent setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

- (void)initData
{
    nFlag = 0;
    searchDao = [[HistorySearchDao alloc]init];
    
    //历史搜索
    bAllSearchRecord = NO;
    aryHistorySearch = [NSMutableArray array];
    [aryHistorySearch addObjectsFromArray:[searchDao getTopSearchRecord:bAllSearchRecord]];
    
    //内容类型
    aryBlogType = [NSMutableArray array];
    ContentTypeVo *contentTypeVo = [[ContentTypeVo alloc]init];
    contentTypeVo.nType = 1;
    contentTypeVo.strName = @"分享";
    contentTypeVo.strImageName = @"share_type_icon";
    [aryBlogType addObject:contentTypeVo];
    
    contentTypeVo = [[ContentTypeVo alloc]init];
    contentTypeVo.nType = 2;
    contentTypeVo.strName = @"投票";
    contentTypeVo.strImageName = @"vote_type_icon";
    [aryBlogType addObject:contentTypeVo];
    
    contentTypeVo = [[ContentTypeVo alloc]init];
    contentTypeVo.nType = 3;
    contentTypeVo.strName = @"问答";
    contentTypeVo.strImageName = @"qa_type_icon";
    [aryBlogType addObject:contentTypeVo];
    
    //搜索相关数据
    [self loadSearchData];
}

//换一批
- (void)changeRecommend
{
    [self loadRecommendUser:NO];
}

- (void)loadSearchData
{
    //工作精华区/
    aryEssence = [NSMutableArray array];
    
    //本周热门搜索
    aryHotSearch = [NSMutableArray array];
    
    //本周热门话题
    aryHotTopic = [NSMutableArray array];
    
    [self loadRecommendUser:YES];
    [self.tableViewContent reloadData];

    
/*
    [Common showProgressView:nil view:self.view modal:NO];
    [ShareService getHomeSearchData:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
//            [aryEssence addObjectsFromArray:retInfo.data];
//            [aryHotSearch addObjectsFromArray:retInfo.data2];
//            [aryHotTopic addObjectsFromArray:retInfo.data3];
//            
            //推荐关注
            aryRecommend = [NSMutableArray array];

            [self.tableViewContent reloadData];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
    */
}

- (void)loadRecommendUser:(BOOL)bRefresh
{
    if (bRefresh)
    {
        //下拉刷新
        nRecommendPage = 1;
    }
    else
    {
        [Common showProgressView:nil view:self.view modal:NO];
    }
    
    [ServerProvider getRecommendAttentionUserList:nRecommendPage result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            NSMutableArray *aryTempData = retInfo.data;
            if(aryTempData.count > 0) {
                if ([retInfo.data2 boolValue]) {
                    //最后一页，则循环到第一页
                    if (aryRecommend.count > 0 && nRecommendPage == 1) {
                        [Common bubbleTip:@"没有更多推荐关注" andView:self.view];
                    }
                    nRecommendPage = 1;
                } else {
                    nRecommendPage ++;
                }
                
                [aryRecommend removeAllObjects];
                aryRecommend = [NSMutableArray array];
                [aryRecommend addObjectsFromArray:aryTempData];
               
            } else {
                [Common bubbleTip:@"没有更多推荐关注" andView:self.view];
            }
            [self.tableViewContent reloadData];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

- (void)sectionHeaderBtnAction:(UIButton *)sender
{
    if (sender.tag == 1002)
    {
        SearchRankViewController *searchRankViewController = [[UIStoryboard storyboardWithName:@"ShareModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SearchRankViewController"];
        searchRankViewController.strPageType = @"hotSearch";
        searchRankViewController.aryData = aryHotSearch;
        [self.navigationController pushViewController:searchRankViewController animated:YES];
    }
    else if (sender.tag == 1003)
    {
        SearchRankViewController *searchRankViewController = [[UIStoryboard storyboardWithName:@"ShareModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SearchRankViewController"];
        searchRankViewController.strPageType = @"hotTag";
        searchRankViewController.aryData = aryHotTopic;
        [self.navigationController pushViewController:searchRankViewController animated:YES];
    }
    else if (sender.tag == 1004)
    {
        [self changeRecommend];
    }
}

//History Search Record Action
- (void)deleteSearchRecordByID:(NSInteger)nID
{
    [searchDao deleteSearchRecordByID:nID];
    [self getSearchRecord];
}

- (void)addSearchRecord:(NSString *)strText
{
    HistorySearchVo *searchVo = [[HistorySearchVo alloc]init];
    searchVo.strText = strText;
    [searchDao addSearchRecord:searchVo];
    
    [self getSearchRecord];
}

- (void)clearSearchRecord
{
    [searchDao deleteAllSearchRecord];
    [aryHistorySearch removeAllObjects];
    [_tableViewContent reloadData];
}

- (void)getSearchRecord
{
    [aryHistorySearch removeAllObjects];
    [aryHistorySearch addObjectsFromArray:[searchDao getTopSearchRecord:bAllSearchRecord]];
    
    [_tableViewContent reloadData];
}

- (void)cancelButtonClicked
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)doSearchAction:(NSString *)strSearchText
{
    if (strSearchText.length > 0)
    {
        [self addSearchRecord:strSearchText];
    }
    
    [MobAnalytics event:@"searchButton" attributes:@{@"searchContent":strSearchText}];
    
    //弹出搜索结果页面
    searchContentView.hidden = NO;
    [searchContentView refreshSearchResult:strSearchText];
    
    [txtSearch resignFirstResponder];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger nCount;
    if (section == 0)
    {
        nCount = aryHistorySearch.count;
    }
    else if (section == 1)
    {
        nCount = aryEssence.count;
    }
    else if (section == 2)
    {
        nCount = aryBlogType.count;
    }
    else if (section == 3)
    {
        nCount = 0;
    }
    else if (section == 4)
    {
        nCount = 0;
    }
    else
    {
        nCount = aryRecommend.count;
    }
    
    if (section == 1 || section == 3 || section == 4)
    {
        if (nCount % 2 == 1)
        {
            nCount = nCount/2+1;
        }
        else
        {
            nCount = nCount/2;
        }
        
        if(nCount > 2)
        {
            nCount = 2;
        }
    }
    
    return nCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        HistorySearchTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistorySearchTextCell" forIndexPath:indexPath];
        cell.mainSearchViewController = self;
        cell.entity = aryHistorySearch[indexPath.row];
        return cell;
    }
    else if (indexPath.section == 2)
    {
        SearchBlogTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchBlogTypeCell" forIndexPath:indexPath];
        cell.entity = aryBlogType[indexPath.row];
        return cell;
    }
    else if (indexPath.section == 1 || indexPath.section == 3 || indexPath.section == 4)
    {
        HotSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HotSearchCell" forIndexPath:indexPath];
        cell.parentController = self;
        NSMutableArray *aryData;
        if (indexPath.section == 1)
        {
            aryData = aryEssence;
        }
        else if (indexPath.section == 3)
        {
            aryData = aryHotSearch;
        }
        else
        {
            aryData = aryHotTopic;
        }
        
        if (indexPath.row*2+1 < aryData.count)
        {
            [cell setFirstData:aryData[indexPath.row*2] second:aryData[indexPath.row*2+1]];
        }
        else
        {
            [cell setFirstData:aryData[indexPath.row*2] second:nil];
        }
        return cell;
    }
    else
    {
        FollowUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FollowUserCell" forIndexPath:indexPath];
        cell.parentController = self;
        cell.entity = aryRecommend[indexPath.row];
        return cell;
    }
    FollowUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FollowUserCell" forIndexPath:indexPath];
    cell.parentController = self;
    cell.entity = aryRecommend[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 44;
    }
    else if (indexPath.section == 1)
    {
        return 45;
    }
    else if (indexPath.section == 2)
    {
        return 44;
    }
    else if (indexPath.section == 3)
    {
        return 45;
    }
    else if (indexPath.section == 4)
    {
        return 45;
    }
    else
    {
        return 60;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *header = @"MainSearchSectionHeader";//静态变量第一次赋值后，再次运行不会运行初始声明和赋值操作
    if (section == 3)
    {
        header = @"HotSearchSectionHeader";
    }
    else if (section == 4)
    {
        header = @"HotTopicSectionHeader";
    }
    else if (section == 5)
    {
        header = @"RecommendSectionHeader";
    }
    
    UITableViewHeaderFooterView *viewHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:header];
    if (viewHeader == nil)
    {
        viewHeader = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:header];
        viewHeader.tag = section;
        viewHeader.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
        
        UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 0.5)];
        viewLine.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
        viewLine.layer.borderColor = [SkinManage colorNamed:@"Wire_Frame_Color"].CGColor;
        viewLine.layer.borderWidth = 0.5;
        viewLine.layer.masksToBounds = YES;
        [viewHeader addSubview:viewLine];
        
        UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, kScreenWidth-100, 45)];
        lblTitle.tag = 1001;
        lblTitle.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
        lblTitle.font = [UIFont systemFontOfSize:16];
        [viewHeader addSubview:lblTitle];
        
        UIButton *btnAction = [UIButton buttonWithType:UIButtonTypeSystem];
        btnAction.frame = CGRectMake(kScreenWidth-85, 0, 85, 45);
        btnAction.titleLabel.font = [UIFont systemFontOfSize:14];
        [btnAction addTarget:self action:@selector(sectionHeaderBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [viewHeader addSubview:btnAction];
        
        if (section == 0 || section == 1 || section == 2)
        {
            viewHeader.hidden = YES;
        }
        else if (section == 3)
        {
            lblTitle.text = @"本周热门搜索";
            
            btnAction.tag = 1002;
            [btnAction setImage:[SkinManage imageNamed:@"table_accessory"] forState:UIControlStateNormal];
            btnAction.imageEdgeInsets = UIEdgeInsetsMake(0, 53, 0, 0);
            btnAction.tintColor = [SkinManage colorNamed:@"share_cellArrow_color"];
        }
        else if (section == 4)
        {
            lblTitle.text = @"本周热门话题";
            
            btnAction.tag = 1003;
            [btnAction setImage:[SkinManage imageNamed:@"table_accessory"] forState:UIControlStateNormal];
            btnAction.imageEdgeInsets = UIEdgeInsetsMake(0, 53, 0, 0);
            btnAction.tintColor = [SkinManage colorNamed:@"share_cellArrow_color"];
        }
        else if (section == 5)
        {
            lblTitle.text = @"推荐关注";
            
            btnAction.tag = 1004;
            [btnAction setTitle:@"换一批" forState:UIControlStateNormal];
            [btnAction setImage:[UIImage imageNamed:@"refresh_icon"] forState:UIControlStateNormal];
            btnAction.tintColor = [SkinManage colorNamed:@"Tab_Item_Color"];
            [Common setButtonImageLeftTitleRight:btnAction spacing:5];
        }
    }
    
    return viewHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0  || section == 1 || section == 2)
    {
        return CGFLOAT_MIN;
    }
    else if (section == 3)
    {
        if(aryHotSearch.count == 0)
        {
            return CGFLOAT_MIN;
        }
        else
        {
            return 45;
        }
    }
    else if (section == 4)
    {
        if(aryHotTopic.count == 0)
        {
            return CGFLOAT_MIN;
        }
        else
        {
            return 45;
        }
    }
    else
    {
        return 45;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 3)
    {
        if(aryHotSearch.count == 0)
        {
            return CGFLOAT_MIN;
        }
        else
        {
            return 9;
        }
    }
    else if (section == 4)
    {
        if(aryHotTopic.count == 0)
        {
            return CGFLOAT_MIN;
        }
        else
        {
            return 9;
        }
    }
    else
    {
        return 9;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        HistorySearchVo *searchRecordVo = aryHistorySearch[indexPath.row];
        if(searchRecordVo.nColType == 0)
        {
            //正常的列，再次点击搜索，将该搜索排在前面 & 进行搜索操作
            txtSearch.text = searchRecordVo.strText;
            [self doSearchAction:searchRecordVo.strText];
        }
        else if (searchRecordVo.nColType == 1)
        {
            //清除搜索记录
            bAllSearchRecord = NO;
            [self clearSearchRecord];
        }
        else
        {
            //查询全部搜索记录
            bAllSearchRecord = YES;
            [self getSearchRecord];
        }
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            //分享
            SearchShareViewController *searchShareViewController = [[UIStoryboard storyboardWithName:@"ShareModule" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"SearchShareViewController"];
            searchShareViewController.strPageType = @"categoryBlog";
            
            TagVo *tagVo = [[TagVo alloc]init];
            tagVo.strTagName = @"分享";
            tagVo.strSearchType = @"blog";
            searchShareViewController.tagVo = tagVo;
            [self.navigationController pushViewController:searchShareViewController animated:YES];
        }
        else if (indexPath.row == 1)
        {
            //投票
            SearchShareViewController *searchShareViewController = [[UIStoryboard storyboardWithName:@"ShareModule" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"SearchShareViewController"];
            searchShareViewController.strPageType = @"categoryBlog";
            
            TagVo *tagVo = [[TagVo alloc]init];
            tagVo.strTagName = @"投票";
            tagVo.strSearchType = @"vote";
            searchShareViewController.tagVo = tagVo;
            [self.navigationController pushViewController:searchShareViewController animated:YES];
        }
        else
        {
            //问答
            SearchShareViewController *searchShareViewController = [[UIStoryboard storyboardWithName:@"ShareModule" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"SearchShareViewController"];
            searchShareViewController.strPageType = @"categoryBlog";
            
            TagVo *tagVo = [[TagVo alloc]init];
            tagVo.strTagName = @"问答";
            tagVo.strSearchType = @"qa";
            searchShareViewController.tagVo = tagVo;
            [self.navigationController pushViewController:searchShareViewController animated:YES];
        }
    }
    else if (indexPath.section == 3)
    {
        
    }
    else if (indexPath.section == 4)
    {
        
    }
    else
    {
        //推荐关注
        UserVo *userVo = aryRecommend[indexPath.row];
        
        UserProfileViewController *userProfileViewController = [[UserProfileViewController alloc]init];
        userProfileViewController.strUserID = userVo.strUserID;
        [self.navigationController pushViewController:userProfileViewController animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self doSearchAction:textField.text];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    searchContentView.hidden = YES;
}


@end
