//
//  LotteryCommitViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/9.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "LotteryCommitViewController.h"
#import "LotteryCommitCell.h"
#import "FootballService.h"
#import "LotterySuccessViewController.h"

@interface LotteryCommitViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *aryData;
    NSMutableArray *aryBetButton;
    
    NSInteger nBetIndex;
    
    CGFloat fMinBet;//最小赔率
    CGFloat fSumBet;//总计赔率
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewLottery;
@property (weak, nonatomic) IBOutlet UIButton *btnCommit;
@property (weak, nonatomic) IBOutlet UILabel *lblIntegral;      //合计积分
@property (weak, nonatomic) IBOutlet UIView *middleView;
@property (weak, nonatomic) IBOutlet UILabel *lblBetting;       //投注积分
@property (weak, nonatomic) IBOutlet UILabel *lblReward;        //奖励积分

@property (weak, nonatomic) IBOutlet UIView *viewBetContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBetViewWidth;
@property (weak, nonatomic) IBOutlet UILabel *alertTipLab;
@property (weak, nonatomic) IBOutlet UILabel *alertTipTextLab;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *bottomMidView;
@end

@implementation LotteryCommitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initData];
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    
    [MobAnalytics beginLogPageView:@"guessDetailPage"];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear: animated];
    
    [MobAnalytics endLogPageView:@"guessDetailPage"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    self.title = @"竞猜详情";
    self.tableViewLottery.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewLottery.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    
    self.viewBetContainer.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.middleView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    _bottomView.backgroundColor = [SkinManage colorNamed:@"LotteryCommit_bottom_bg"];
    self.bottomMidView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    if ([SkinManage getCurrentSkin] == SkinDefaultType) {
        
    }else{
        self.middleView.layer.borderColor = [UIColor clearColor].CGColor;
    }
    self.alertTipLab.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.alertTipTextLab.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
    
    self.lblBetting.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.lblReward.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
    
    [self.tableViewLottery registerNib:[UINib nibWithNibName:@"LotteryCommitCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"LotteryCommitCell"];
    
    [self.btnCommit setBackgroundImage:[Common getImageWithColor:COLOR(239, 111, 88, 1.0)] forState:UIControlStateNormal];
    
    [self loadData];
    [self initBetView];
}

- (void)initData
{
    nBetIndex = 0;
    aryBetButton = [NSMutableArray array];
}

- (void)loadData
{
    aryData = [NSMutableArray array];
    fMinBet = MAXFLOAT;
    fSumBet = 0;
    
    NSInteger nIntegralSum = 0;
    NSMutableArray *aryTemp;
    LeagueVo *lastLeagueVo = nil;
    for (LeagueVo *leagueVo in self.leagueSelectVo.aryLeague)
    {
        nIntegralSum += leagueVo.nConsumeIntegral;
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
        
        CGFloat fGuessBet = 0;
        if (leagueVo.nCommitGuess == 1)
        {
            fGuessBet = leagueVo.fWinOdds;
        }
        else if (leagueVo.nCommitGuess == 2)
        {
            fGuessBet = leagueVo.fEqualOdds;
        }
        else
        {
            fGuessBet = leagueVo.fLoseOdds;
        }
        
        if (fGuessBet < fMinBet)
        {
            fMinBet = fGuessBet;
        }
        fSumBet += fGuessBet;
    }
    
    [self.tableViewLottery reloadData];
}

- (IBAction)commitLottery:(UIButton *)sender
{
    if (self.aryBet.count == 0)
    {
        [Common bubbleTip:@"投注积分无效" andView:self.view];
        return;
    }
    
    [MobAnalytics event:@"betButton"];
    
    NSInteger nSingleBet = ((NSNumber *)self.aryBet[nBetIndex]).integerValue;
    
    [Common showProgressView:nil view:self.view modal:NO];
    [FootballService commitLeague:self.leagueSelectVo.aryLeague singleBet:nSingleBet result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            LotterySuccessViewController *lotterySuccessViewController = [[UIStoryboard storyboardWithName:@"FootballModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"LotterySuccessViewController"];
            [self.navigationController pushViewController:lotterySuccessViewController animated:YES];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

- (void)initBetView
{
    for (int i=0;i<self.aryBet.count;i++)
    {
        NSNumber *number = self.aryBet[i];
        UIButton *btnBet = [UIButton buttonWithType:UIButtonTypeCustom];
        btnBet.tag = 1000+i;
        btnBet.frame = CGRectMake(12+95*i, 5, 65, 40);
        btnBet.layer.borderColor = [SkinManage colorNamed:@"Wire_Frame_Color"].CGColor;
        btnBet.layer.cornerRadius = 5;
        btnBet.layer.masksToBounds = YES;
        btnBet.layer.borderWidth = 0.5;
        btnBet.titleLabel.font = [UIFont systemFontOfSize:14];
        [btnBet setTitle:[NSString stringWithFormat:@"%@积分",number] forState:UIControlStateNormal];
        [btnBet setTitleColor:[SkinManage colorNamed:@"Tab_Item_Color"] forState:UIControlStateNormal];
        [btnBet setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [btnBet setBackgroundImage:nil forState:UIControlStateNormal];
        [btnBet setBackgroundImage:[Common getImageWithColor:COLOR(239, 111, 88, 1.0)] forState:UIControlStateSelected];
        [btnBet addTarget:self action:@selector(chooseBetAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.viewBetContainer addSubview:btnBet];
        
        if (i == 0)
        {
            btnBet.selected = YES;
        }
    }
    
    self.constraintBetViewWidth.constant = 12*2+65*self.aryBet.count+30*(self.aryBet.count-1);
    [self.viewBetContainer layoutIfNeeded];
    
    [self updateIntegralInfo];
}

- (void)chooseBetAction:(UIButton *)sender
{
    for (int i=0;i<_aryBet.count;i++)
    {
        UIButton *btnBet = [self.viewBetContainer viewWithTag:1000+i];
        if (btnBet == sender)
        {
            nBetIndex = i;
            btnBet.selected = YES;
        }
        else
        {
            btnBet.selected = NO;
        }
    }
    
    [self updateIntegralInfo];
}

- (void)updateIntegralInfo
{
    if (self.aryBet.count > 0)
    {
        NSInteger nBetIntegral = ((NSNumber *)self.aryBet[nBetIndex]).integerValue;
        
        //投注积分
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"投注：%li积分",(unsigned long)nBetIntegral]];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[SkinManage colorNamed:@"Menu_Title_Color"] range:NSMakeRange(0, 3)];
        [attributedString addAttribute:NSForegroundColorAttributeName value:COLOR(239, 111, 88, 1.0) range:NSMakeRange(3, attributedString.length-3)];
        self.lblBetting.attributedText = attributedString;
        
        //奖励积分
        if (fMinBet == fSumBet)
        {
            self.lblReward.text = [NSString stringWithFormat:@"猜中将获得：%g积分",nBetIntegral*fMinBet];
        }
        else
        {
            self.lblReward.text = [NSString stringWithFormat:@"猜中将获得：%g~%g积分",nBetIntegral*fMinBet,nBetIntegral*fSumBet];
        }
        
        //合计积分
        attributedString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"合计：%li积分",(unsigned long)nBetIntegral*self.leagueSelectVo.aryLeague.count]];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[SkinManage colorNamed:@"Menu_Title_Color"] range:NSMakeRange(0, 3)];
        [attributedString addAttribute:NSForegroundColorAttributeName value:COLOR(239, 111, 88, 1.0) range:NSMakeRange(3, attributedString.length-3)];
        self.lblIntegral.attributedText = attributedString;
    }
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
    LotteryCommitCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LotteryCommitCell" forIndexPath:indexPath];
    LeagueVo *leagueVo = aryData[indexPath.section][indexPath.row];
    [cell setEntity:leagueVo];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
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
    
    UILabel *lblLeagueDate = (UILabel*)[viewHeader viewWithTag:1000];
    lblLeagueDate.text = leagueVo.strDate;
    
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


@end
