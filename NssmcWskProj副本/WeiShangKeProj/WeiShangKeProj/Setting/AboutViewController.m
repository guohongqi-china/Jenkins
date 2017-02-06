//
//  AboutViewController.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-3-22.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "AboutViewController.h"
#import "Utils.h"
#import "EditPasswordViewController.h"

@interface AboutViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lblVersion;

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

-(void)initView
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setTopNavBarTitle:@"关于"];

    //左边按钮
    UIButton *btnBack = [Utils buttonWithImageName:[UIImage imageNamed:@"nav_setting"] frame:[Utils getNavLeftBtnFrame:CGSizeMake(100,76)] target:self action:@selector(showSideMenu)];
    [self setLeftBarButton:btnBack];
    
//    UIButton *btnRight = [Utils buttonWithTitle:@"TODO" frame:[Utils getNavRightBtnFrame:CGSizeMake(100,76)] target:self action:@selector(doOther)];
//    [self setRightBarButton:btnRight];
    
    //notice num view
    NoticeNumView *noticeNumView = [[NoticeNumView alloc]initWithFrame:CGRectMake(25.5, 6+kStatusBarHeight, 18, 18)];
    [self.view addSubview:noticeNumView];
    
    self.lblVersion.text = [NSString stringWithFormat:@" %@  V%@",@"iPhone版",@"菱信工单"];
}

- (void)showSideMenu
{
    [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerOpenLeftSide object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerAddPanGesture object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerRemovePanGesture object:nil];
}

- (void)doOther
{
    EditPasswordViewController *editPasswordViewController = [[EditPasswordViewController alloc]initWithNibName:@"EditPasswordViewController" bundle:nil];
    [self.navigationController pushViewController:editPasswordViewController animated:YES];
}

@end
