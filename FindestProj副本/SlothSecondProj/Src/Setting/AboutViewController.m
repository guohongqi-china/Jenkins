//
//  AboutViewController.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-3-22.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "AboutViewController.h"
#import "UIImage+UIImageScale.h"
#import "FindestProj-Swift.h"
#import "PolicyViewController.h"

@interface AboutViewController ()

@property(nonatomic,strong) IBOutlet UILabel *lblVersionNum;
@property (weak, nonatomic) IBOutlet UILabel *copyrighLab;

@end

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    self.view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
//    self.title = [NSString stringWithFormat:@"关于%@",Constants.strAppName];
    self.title = @"关于博睿";

    self.lblVersionNum.textColor = [SkinManage colorNamed:@"metting_Tite_color"];
    self.lblVersionNum.text = [NSString stringWithFormat:@"%@ iPhone %@",@"博睿",[Common getAppVersion]];
    
    self.copyrighLab.textColor = [SkinManage colorNamed:@"date_title"];
    self.copyrighLab.text = [NSString stringWithFormat:@"Copyrigh © 2015-2016 %@.All Rights Reserved.",@"博睿"];
}

- (IBAction)checkPolicy:(UIButton *)sender {
    PolicyViewController *policyViewController = [[PolicyViewController alloc]init];
    [self.navigationController pushViewController:policyViewController animated:YES];
}

@end
