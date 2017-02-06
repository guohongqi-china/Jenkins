//
//  ActivityHomeViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/17.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "ActivityHomeViewController.h"
#import "ActivityListCell.h"
#import "ActivityHistoryCell.h"
#import "ActivityService.h"
#import "ActivityListViewController.h"
#import "ShareDetailViewController.h"

#import "ActivityDetailOldViewController.h"

@interface ActivityHomeViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *aryNewActivity; //最新活动
    NSMutableArray *aryReviewActivity; //活动回顾
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewActivity;

@end

@implementation ActivityHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    [self initData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    
    [MobAnalytics beginLogPageView:@"activityPage"];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear: animated];
    
    [MobAnalytics endLogPageView:@"activityPage"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    self.title = @"活动";
    
    self.view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    self.tableViewActivity.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewActivity.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    
    [_tableViewActivity registerNib:[UINib nibWithNibName:@"ActivityListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ActivityListCell"];
    [_tableViewActivity registerNib:[UINib nibWithNibName:@"ActivityHistoryCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ActivityHistoryCell"];
}

- (void)initData
{
    aryNewActivity = [NSMutableArray array];
    aryReviewActivity = [NSMutableArray array];
    
    [self loadData];
}

- (void)loadData
{
    [Common showProgressView:nil view:self.view modal:NO];
    [ActivityService getHomeActivityList:^(ServerReturnInfo *retInfo){
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            [aryNewActivity addObjectsFromArray:retInfo.data];
            [aryNewActivity sortUsingComparator:^NSComparisonResult(BlogVo *obj1, BlogVo *obj2) {
                
                return [obj2.strCreateDate compare:obj1.strCreateDate];
            }];
            [aryReviewActivity addObjectsFromArray:retInfo.data2];
            [self.tableViewActivity reloadData];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

- (void)getMoreActivity
{
    ActivityListViewController *activityListViewController = [[UIStoryboard storyboardWithName:@"ActivityModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ActivityListViewController"];
    activityListViewController.activityListType = ActivityListHistoryType;
    [self.navigationController pushViewController:activityListViewController animated:YES];
}

#pragma mark - UITableViewDataSource,UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return aryNewActivity.count;
    }
    else
    {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0)
    {
        ActivityListCell *cellActivity = [tableView dequeueReusableCellWithIdentifier:@"ActivityListCell" forIndexPath:indexPath];
        cellActivity.entity = aryNewActivity[indexPath.row];
        cell = cellActivity;
    }
    else
    {
        ActivityHistoryCell *cellActivity = [tableView dequeueReusableCellWithIdentifier:@"ActivityHistoryCell" forIndexPath:indexPath];
        cellActivity.parentController = self;
        cellActivity.entity = aryReviewActivity;
        cell = cellActivity;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 152;
    }
    else
    {
        return 200;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *header = @"ActivitySectionHeader";
    UITableViewHeaderFooterView *viewHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:header];
    if (viewHeader == nil)
    {
        viewHeader = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:header];
        viewHeader.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
        
        CGFloat fHeight = 0;
        UIView *viewSep = [[UIView alloc]initWithFrame:CGRectMake(-0.5, fHeight-0.5, kScreenWidth+1, 10)];
        viewSep.tag = 1000;
        viewSep.layer.masksToBounds = YES;
        viewSep.layer.borderColor = [SkinManage colorNamed:@"Wire_Frame_Color"].CGColor;
        viewSep.layer.borderWidth = 0.5;
        viewSep.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
        [viewHeader addSubview:viewSep];
        
        fHeight += 10;
        
        UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(12, fHeight, kScreenWidth-24, 44)];
        lblTitle.tag = 1001;
        lblTitle.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
        lblTitle.font = [UIFont systemFontOfSize:16];
        lblTitle.textAlignment = NSTextAlignmentLeft;
        [viewHeader addSubview:lblTitle];
        
        UIButton *btnAction = [UIButton buttonWithType:UIButtonTypeSystem];
        btnAction.tag = 1002;
        btnAction.frame = CGRectMake(kScreenWidth-85, fHeight, 85, 45);
        btnAction.tintColor = [SkinManage colorNamed:@"Tab_Item_Color"];
        btnAction.titleLabel.font = [UIFont systemFontOfSize:14];
        [btnAction setTitle:@"更多" forState:UIControlStateNormal];
        [btnAction setImage:[UIImage imageNamed:@"table_accessory"] forState:UIControlStateNormal];
        [btnAction addTarget:self action:@selector(getMoreActivity) forControlEvents:UIControlEventTouchUpInside];
        [viewHeader addSubview:btnAction];
        [Common setButtonImageRightTitleLeft:btnAction spacing:5];
    }
    
    CGFloat fHeight = 0;
    UIView *viewSep = [viewHeader viewWithTag:1000];
    UILabel *lblTitle = [viewHeader viewWithTag:1001];
    UIButton *btnAction = [viewHeader viewWithTag:1002];
    if (section == 0)
    {
        lblTitle.text = @"最新活动";
        viewSep.hidden = YES;
        btnAction.hidden = YES;
        fHeight = 0;
    }
    else
    {
        lblTitle.text = @"活动回顾";
        viewSep.hidden = NO;
        btnAction.hidden = NO;
        fHeight = 10;
    }
    
    viewSep.frame= CGRectMake(-0.5, -0.5, kScreenWidth+1, 10);
    lblTitle.frame = CGRectMake(12, fHeight, kScreenWidth-24, 44);
    btnAction.frame = CGRectMake(kScreenWidth-65, fHeight, 65, 44);
    
    return viewHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //section头部高度
    if (section == 0)
    {
        return 44;
    }
    else
    {
        return 44+10;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0)
    {
        ShareDetailViewController *shareDetailViewController = [[ShareDetailViewController alloc] init];
        BlogVo *blog = aryNewActivity[indexPath.row];
        shareDetailViewController.m_originalBlogVo = blog;
        if (blog.streamId.length == 0)
        {
            [Common tipAlert:@"数据异常，请求失败"];
            return;
        }
        [self.navigationController pushViewController:shareDetailViewController animated:YES];
    }
    
}




@end
