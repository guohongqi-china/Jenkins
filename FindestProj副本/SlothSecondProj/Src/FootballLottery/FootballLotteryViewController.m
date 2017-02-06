//
//  FootballLotteryViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/9.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "FootballLotteryViewController.h"
#import "MJRefresh.h"
#import "LeagueVo.h"
#import "FootballService.h"
#import "FootballLotteryCell.h"
#import "LotteryCommitViewController.h"
#import "MyLotteryViewController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "NoSearchView.h"

#import "PublishShareViewController.h"

@interface FootballLotteryViewController ()<UITableViewDataSource,UITableViewDelegate,footballLotteryCellDelegate>
{
    NSMutableArray *aryOriginalData;
    NSMutableArray *aryData;
    NSMutableArray *aryBet;
    NoSearchView *noSearchView;
}

@property (weak, nonatomic) IBOutlet UIButton *btnClear;
@property (weak, nonatomic) IBOutlet UIButton *btnConfirm;
@property (weak, nonatomic) IBOutlet UILabel *lblSelectedNum;
@property (weak, nonatomic) IBOutlet UITableView *tableViewLottery;
@property (weak, nonatomic) IBOutlet UIView *viewBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottomH;
@property (weak, nonatomic) IBOutlet UIView *sepView;

@end

@implementation FootballLotteryViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LotterySuccessNotification" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initData];
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    
    [MobAnalytics beginLogPageView:@"guessPage"];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear: animated];
    
    [MobAnalytics endLogPageView:@"guessPage"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    self.title = @"竞猜";
    self.navigationItem.rightBarButtonItem = [self rightBtnItemWithImage:@"nav_football_record"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadLotteryAfterSuccess) name:@"LotterySuccessNotification" object:nil];
    
    self.tableViewLottery.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewLottery.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    
    self.viewBottom.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.sepView.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [self.btnClear setTitleColor:[SkinManage colorNamed:@"Tab_Item_Color"] forState:UIControlStateNormal];
    [self.btnConfirm setBackgroundImage:[Common getImageWithColor:COLOR(239, 111, 88, 1.0)] forState:UIControlStateNormal];
    
    noSearchView = [[NoSearchView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT) andDes:@"还没有竞猜数据"];
    
    //下拉刷新
    @weakify(self)
    self.tableViewLottery.mj_header =  [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self loadNewData];
    }];
    
    [self updateSelectNum];
}

- (void)initData
{
    aryOriginalData = [NSMutableArray array];
    aryData = [NSMutableArray array];
    aryBet = [NSMutableArray array];
    self.leagueSelectVo = [[LeagueSelectVo alloc]init];
    self.leagueSelectVo.nLeagueNum = 0;
    self.leagueSelectVo.fIntegralSum = 0;
    
    [self loadNewData];
}

//配置数组套数组的分组表数据源
- (void)configureData
{
    [aryData removeAllObjects];
    
    NSInteger nEffectiveNum = 0;
    NSMutableArray *aryTemp;
    LeagueVo *lastLeagueVo = nil;
    for (LeagueVo *leagueVo in aryOriginalData)
    {
        if(lastLeagueVo != nil && [lastLeagueVo.strDate isEqualToString:leagueVo.strDate])
        {
            [aryTemp addObject:leagueVo];
        }
        else
        {
            //新开辟数组
            aryTemp = [NSMutableArray array];
            [aryTemp addObject:leagueVo];
            [aryData addObject:aryTemp];
        }
        lastLeagueVo = leagueVo;
        
        if(leagueVo.nCurrGuess == 0)
        {
            nEffectiveNum++;
        }
    }
    
    if (nEffectiveNum > 0)
    {
        self.viewBottom.hidden = NO;
        self.constraintBottomH.constant = 49;
    }
    else
    {
        self.constraintBottomH.constant = 0;
        self.viewBottom.hidden = YES;
    }
    
    [self.tableViewLottery reloadData];
}

- (void)loadNewData
{
    [Common showProgressView:nil view:self.view modal:NO];
    [FootballService getLeagueList:10 result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            NSMutableArray *aryTempData = retInfo.data;
            if (aryTempData != nil && aryTempData.count>0)
            {
                [aryOriginalData removeAllObjects];
                [aryOriginalData addObjectsFromArray:aryTempData];
                
                self.tableViewLottery.mj_header = nil;
                [self configureData];
                
                if (aryOriginalData.count == 0)
                {
                    [self.view addSubview:noSearchView];
                }
                else
                {
                    [noSearchView removeFromSuperview];
                }
            }
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
        
        //停止刷新
        [self.tableViewLottery.mj_header endRefreshing];
    }];
}

- (void)reloadLotteryAfterSuccess
{
    [self loadNewData];
    
    [self touchBottomButton:self.btnClear];
}

- (void)righBarClick
{
    MyLotteryViewController *myLotteryViewController = [[UIStoryboard storyboardWithName:@"FootballModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MyLotteryViewController"];
    [self.navigationController pushViewController:myLotteryViewController animated:YES];
}

- (void)updateSelectNum
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"已选择%li场",(unsigned long)self.leagueSelectVo.nLeagueNum]];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[SkinManage colorNamed:@"Menu_Title_Color"] range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:COLOR(239, 111, 88, 1.0) range:NSMakeRange(3, attributedString.length-4)];
    self.lblSelectedNum.attributedText = attributedString;
    
    if(self.leagueSelectVo.nLeagueNum <= 0)
    {
        self.btnClear.enabled = NO;
        self.btnConfirm.enabled = NO;
    }
    else
    {
        self.btnClear.enabled = YES;
        self.btnConfirm.enabled = YES;
    }
}

- (IBAction)touchBottomButton:(UIButton *)sender
{
    if(sender == self.btnClear)
    {
        //clear
        for (LeagueVo *leagueVo in aryOriginalData)
        {
            leagueVo.nCommitGuess = 0;
        }
        
        self.leagueSelectVo.nLeagueNum = 0;
        self.leagueSelectVo.fIntegralSum = 0;
        [self updateSelectNum];
        [self.tableViewLottery reloadData];
    }
    else
    {
        self.leagueSelectVo.aryLeague = [NSMutableArray array];
        for (LeagueVo *leagueVo in aryOriginalData)
        {
            if (leagueVo.nCommitGuess > 0)
            {
                [self.leagueSelectVo.aryLeague addObject:leagueVo];
            }
        }
        
        if (aryBet.count > 0)
        {
            LotteryCommitViewController *lotteryCommitViewController = [[UIStoryboard storyboardWithName:@"FootballModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"LotteryCommitViewController"];
            lotteryCommitViewController.leagueSelectVo = self.leagueSelectVo;
            lotteryCommitViewController.aryBet = aryBet;
            [self.navigationController pushViewController:lotteryCommitViewController animated:YES];
        }
        else
        {
            [Common showProgressView:nil view:self.view modal:NO];
            [FootballService getBetList:^(ServerReturnInfo *retInfo) {
                [Common hideProgressView:self.view];
                if (retInfo.bSuccess)
                {
                    NSMutableArray *aryTempData = retInfo.data;
                    if (aryTempData.count > 0)
                    {
                        [aryBet addObjectsFromArray:aryTempData];
                        
                        LotteryCommitViewController *lotteryCommitViewController = [[UIStoryboard storyboardWithName:@"FootballModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"LotteryCommitViewController"];
                        lotteryCommitViewController.leagueSelectVo = self.leagueSelectVo;
                        lotteryCommitViewController.aryBet = aryBet;
                        [self.navigationController pushViewController:lotteryCommitViewController animated:YES];
                    }
                    else
                    {
                        [Common tipAlert:@"获取投注积分失败，不能参与竞猜"];
                    }
                }
                else
                {
                    [Common tipAlert:@"获取投注积分失败，不能参与竞猜"];
                }
            }];
        }
    }
}

- (void)configureCell:(FootballLotteryCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.fd_enforceFrameLayout = NO; // Enable to use "-sizeThatFits:"
    
    NSMutableArray *aryTemp = aryData[indexPath.section];
    
    BOOL bLastRow = NO;
    if (indexPath.row == (aryTemp.count-1))
    {
        bLastRow = YES;
    }
    
    LeagueVo *leagueVo = aryTemp[indexPath.row];
    [cell setEntity:leagueVo last:bLastRow];
}

#pragma mark - UITableViewDataSource,UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return aryData.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *aryTemp = aryData[section];
    return aryTemp.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FootballLotteryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FootballLotteryCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.parentController = self;
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //采用自动计算高度，并且带有缓存机制
    return [tableView fd_heightForCellWithIdentifier:@"FootballLotteryCell" cacheByIndexPath:indexPath configuration:^(FootballLotteryCell *cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *header = @"LeagueSectionHeader";
    UITableViewHeaderFooterView *viewHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:header];
    if (viewHeader == nil)
    {
        viewHeader = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:header];
        viewHeader.contentView.backgroundColor = [UIColor clearColor];
        
        UILabel *lblLeagueDate = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, kScreenWidth-24, 36)];
        lblLeagueDate.tag = 1000;
        lblLeagueDate.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
        lblLeagueDate.font = [UIFont systemFontOfSize:12];
        lblLeagueDate.textAlignment = NSTextAlignmentLeft;
        [viewHeader addSubview:lblLeagueDate];
    }
    
    NSMutableArray *arySectionData = aryData[section];
    LeagueVo *leagueVo = arySectionData[0];
    
    UILabel *lblLeagueDate = [viewHeader viewWithTag:1000];
    lblLeagueDate.text = [NSString stringWithFormat:@"%@，共%li场比赛",leagueVo.strDate,(unsigned long)arySectionData.count];
    
    return viewHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //section头部高度
    return 36;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    //section尾部高度
    CGFloat fHeight = CGFLOAT_MIN;
    return fHeight;
}


//guessingJumpLink
//#warning ..................复制链接去分享

#pragma mark - <FootballLotteryCellDelegate>
- (void)footballLotteryCell:(FootballLotteryCell *)cell copyLinkSharingWithLeagueVo:(LeagueVo *)leagueVo
{
    PublishShareViewController *publishShareViewController = [[UIStoryboard storyboardWithName:@"ShareModule" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"PublishShareViewController"];
    publishShareViewController.nPublicType = 0;
    publishShareViewController.linkStr = [NSString stringWithFormat:GuessingJumpLink];
    [self.navigationController pushViewController:publishShareViewController animated:YES];

}


@end
