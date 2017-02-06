//
//  MyIntegrationViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/8.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "MyIntegrationViewController.h"
#import "MenuVo.h"
#import "MyIntegrationCell.h"
#import "UserVo.h"
#import "IntegralInfoVo.h"

@interface MyIntegrationViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *aryLevel;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewIntegral;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewLastLevel;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewNextLevel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressIntegral;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentIntegral;
@property (weak, nonatomic) IBOutlet UILabel *lblLastLevel;
@property (weak, nonatomic) IBOutlet UILabel *lblNextLevel;

@property (weak, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet UIView *sep2View;

@property (weak, nonatomic) IBOutlet UILabel *vipLabel;

@property (weak, nonatomic) IBOutlet UILabel *rangeLabel;

@property (weak, nonatomic) IBOutlet UILabel *rangeMemLabel;
@property (weak, nonatomic) IBOutlet UILabel *needIntLabel;
@property (weak, nonatomic) IBOutlet UILabel *alerLabel;

@property (weak, nonatomic) IBOutlet UILabel *alertTextLabel;


@property (weak, nonatomic) IBOutlet UIView *footerSepView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLastImageRight;

@end

@implementation MyIntegrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initData];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)dealloc{
    NSLog(@"-----");
}
- (void)initView
{
    
    self.title = @"积分详情";
    
    self.tableViewIntegral.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    
    double fCurrentIntegral = [Common getCurrentUserVo].fIntegrationCount;
    //设置固定不变的控价的颜色
    _headerView.backgroundColor = [SkinManage colorNamed:@"IntegrationCell_BK"];
    
    
    _sep2View.backgroundColor  = [SkinManage colorNamed:@"IntegrationCurrent_BK"];
    
    _sep2View.layer.borderColor = [UIColor clearColor].CGColor;
    
    _footerSepView.backgroundColor = [SkinManage colorNamed:@"IntegrationFooter_BK"];
    ;
    
    _vipLabel.textColor = [SkinManage colorNamed:@"Integration_Title_Color"];
    _rangeLabel.textColor = [SkinManage colorNamed:@"IntegrationTitleOther_color"];
    _rangeMemLabel.textColor = [SkinManage colorNamed:@"IntegrationTitleOther_color"];
    _needIntLabel.textColor = [SkinManage colorNamed:@"IntegrationTitleOther_color"];
    _alerLabel.textColor = [SkinManage colorNamed:@"Integration_Title_Color"];
    _alertTextLabel.textColor = [SkinManage colorNamed:@"IntegrationTitleOther_color"];
    
    _lblCurrentIntegral.textColor = [SkinManage colorNamed:@"Integration_Title_Color"];
    
    
    
    _lblLastLevel.textColor = [SkinManage colorNamed:@"IntegrationTitleOther_color"];
    
    
    _lblNextLevel.textColor = [SkinManage colorNamed:@"IntegrationTitleOther_color"];
    
    NSMutableAttributedString *attriInegral = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%g 积分",fCurrentIntegral]];
    [attriInegral addAttribute:NSForegroundColorAttributeName value:COLOR(239, 111, 88, 1.0) range:NSMakeRange(0, attriInegral.length-2)];
    [attriInegral addAttribute:NSForegroundColorAttributeName value:COLOR(181, 161, 154, 1.0) range:NSMakeRange(attriInegral.length-2, 2)];
    self.lblCurrentIntegral.attributedText = attriInegral;
    
    IntegralInfoVo *integralLast = [BusinessCommon getIntegralInfo:fCurrentIntegral];
    
    self.imgViewLastLevel.image = [UIImage imageNamed: integralLast.strLevelImage];
    self.lblLastLevel.text = integralLast.strLevelName;
    
    if (integralLast.bTopLevel)
    {
        //已经为最大等级
        self.imgViewNextLevel.hidden = YES;
        self.lblNextLevel.hidden = YES;
        self.progressIntegral.hidden = YES;
        self.lblCurrentIntegral.hidden = YES;
        
        self.constraintLastImageRight.constant = -91.5;
    }
    else
    {
        IntegralInfoVo *integralNext = [BusinessCommon getIntegralInfo:integralLast.fMaxIntegral];
        self.imgViewNextLevel.image = [UIImage imageNamed: integralNext.strLevelImage];
        self.lblNextLevel.text = integralNext.strLevelName;
        
        //progress view
        self.progressIntegral.progressTintColor = COLOR(239, 111, 88, 1.0);      //进度条颜色
        self.progressIntegral.trackTintColor = COLOR(221, 208, 204, 1.0);	//背景颜色
        self.progressIntegral.transform = CGAffineTransformMakeScale(1, 2);
        self.progressIntegral.progress = (fCurrentIntegral-integralLast.fMinIntegral)/(integralLast.fMaxIntegral-integralLast.fMinIntegral);
    }
}

- (void)initData
{
    aryLevel = [NSMutableArray array];
    MenuVo *menuVo = [[MenuVo alloc]init];
    menuVo.strName = @"滑板车";
    menuVo.strImageName = @"inte_1";
    menuVo.strRemark = @"0";
    [aryLevel addObject:menuVo];
    
    menuVo = [[MenuVo alloc]init];
    menuVo.strName = @"自行车";
    menuVo.strImageName = @"inte_2";
    menuVo.strRemark = @"500";
    [aryLevel addObject:menuVo];
    
    menuVo = [[MenuVo alloc]init];
    menuVo.strName = @"电动车";
    menuVo.strImageName = @"inte_3";
    menuVo.strRemark = @"2,000";
    [aryLevel addObject:menuVo];
    
    menuVo = [[MenuVo alloc]init];
    menuVo.strName = @"摩托车";
    menuVo.strImageName = @"inte_4";
    menuVo.strRemark = @"10,000";
    [aryLevel addObject:menuVo];
    
    menuVo = [[MenuVo alloc]init];
    menuVo.strName = @"轿车";
    menuVo.strImageName = @"inte_5";
    menuVo.strRemark = @"30,000";
    [aryLevel addObject:menuVo];
    
    menuVo = [[MenuVo alloc]init];
    menuVo.strName = @"跑车";
    menuVo.strImageName = @"inte_6";
    menuVo.strRemark = @"80,000";
    [aryLevel addObject:menuVo];
    
    menuVo = [[MenuVo alloc]init];
    menuVo.strName = @"赛车";
    menuVo.strImageName = @"inte_7";
    menuVo.strRemark = @"150,000";
    [aryLevel addObject:menuVo];
    
    menuVo = [[MenuVo alloc]init];
    menuVo.strName = @"直升机";
    menuVo.strImageName = @"inte_8";
    menuVo.strRemark = @"300,000";
    [aryLevel addObject:menuVo];
    
    menuVo = [[MenuVo alloc]init];
    menuVo.strName = @"喷气飞机";
    menuVo.strImageName = @"inte_9";
    menuVo.strRemark = @"500,000";
    [aryLevel addObject:menuVo];
    
    menuVo = [[MenuVo alloc]init];
    menuVo.strName = @"火箭";
    menuVo.strImageName = @"inte_10";
    menuVo.strRemark = @"1,000,000";
    [aryLevel addObject:menuVo];
}

#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return aryLevel.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyIntegrationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIntegrationCell" forIndexPath:indexPath];
    [cell setEntity:aryLevel[indexPath.row] row:indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

@end
