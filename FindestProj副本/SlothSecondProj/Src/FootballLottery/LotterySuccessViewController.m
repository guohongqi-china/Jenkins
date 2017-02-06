//
//  LotterySuccessViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/9.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "LotterySuccessViewController.h"
#import "FootballLotteryViewController.h"

@interface LotterySuccessViewController ()

@property (weak, nonatomic) IBOutlet UIView *viewContainerView;
@property (weak, nonatomic) IBOutlet UIView *viewTop;
@property (weak, nonatomic) IBOutlet UIView *viewLine;
@property (weak, nonatomic) IBOutlet UILabel *footballResultLabel;
@end

@implementation LotterySuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.viewTop.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.viewContainerView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.viewLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    self.footballResultLabel.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backForePage
{
    //直接回退到竞猜列表页
    for (UIViewController *viewController in self.navigationController.viewControllers)
    {
        if ([viewController isKindOfClass:[FootballLotteryViewController class]])
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"LotterySuccessNotification" object:nil];
            [self.navigationController popToViewController:viewController animated:YES];
            break;
        }
    }
}

@end
