//
//  ActivitySuccessViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/18.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "ActivitySuccessViewController.h"
#import "UIIMageView+WebCache.h"
#import "ShareDetailViewController.h"

@interface ActivitySuccessViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imgViewPoster;
@property (weak, nonatomic) IBOutlet UIView *viewShadow;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIView *viewProjectContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblProjectTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblSuccessTip;
@property (weak, nonatomic) IBOutlet UILabel *lblTipInfo;
@property (weak, nonatomic) IBOutlet UIView *viewSep;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *topView;

@property (weak, nonatomic) IBOutlet UIButton *btnShare;

@end

@implementation ActivitySuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    self.title = @"报名成功";
    
    self.view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    self.viewShadow.layer.shadowColor = [UIColor blackColor].CGColor;         //设置阴影的颜色
    self.viewShadow.layer.shadowOffset = CGSizeMake(0, 2);                   //设置阴影的偏移量，也可以设置成负数
    self.viewShadow.layer.shadowOpacity = 0.3;//设置阴影的不透明度
    self.viewShadow.layer.shadowRadius = 4.0;//设置阴影的模糊半径（blur radius）
    
    [self.imgViewPoster sd_setImageWithURL:[NSURL URLWithString:self.m_blogVo.strPictureUrl] placeholderImage:[UIImage imageNamed:@"default_image"]];
    
    self.lblTitle.font = [Common fontWithName:@"PingFangSC-Medium" size:18];
    self.lblTitle.text = self.m_blogVo.strTitle;
    
    self.lblProjectTitle.font = [Common fontWithName:@"PingFangSC-Medium" size:16];
    self.lblProjectTitle.text = self.m_activityProjectVo.strProjectName;
    
    self.lblSuccessTip.font = [Common fontWithName:@"PingFangSC-Medium" size:24];
    
    [self.btnShare setBackgroundImage:[Common getImageWithColor:COLOR(239, 111, 88, 1.0)] forState:UIControlStateNormal];
    [self.btnShare setTitleColor:COLOR(255, 255, 255, 0.35) forState:UIControlStateHighlighted];
    self.lblTitle.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.topView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.viewSep.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    _viewProjectContainer.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.lblProjectTitle.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.lblTipInfo.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
}

- (IBAction)shareToOther:(UIButton *)sender
{
    
}

- (void)backForePage
{
    //直接回退到分享详情
    for (UIViewController *viewController in self.navigationController.viewControllers)
    {
        if ([viewController isKindOfClass:[ShareDetailViewController class]])
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"RefreshShareDetailNotification" object:nil];
            [self.navigationController popToViewController:viewController animated:YES];
            break;
        }
    }
}

@end
