//
//  FullScreenWebViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 2/10/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import "FullScreenWebViewController.h"
#import "Utils.h"

@interface FullScreenWebViewController ()

@end

@implementation FullScreenWebViewController
@synthesize webView;
@synthesize urlFile;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.imgViewTopBar.image = [Common getImageWithColor:[UIColor clearColor]];
    self.view.backgroundColor = COLOR(46, 49, 50, 1.0);
    [self setLeftBarButton:nil];
    
    NSURLRequest *request =[NSURLRequest requestWithURL:self.urlFile];
    self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, kStatusBarHeight, kScreenWidth,kScreenHeight-kStatusBarHeight)];
    [self.webView loadRequest:request];
    [self.webView setAutoresizesSubviews:YES];
    [self.webView setAutoresizingMask:UIViewAutoresizingNone];
    [self.webView setUserInteractionEnabled: YES ];
    [self.webView setOpaque:YES ];
    self.webView.delegate = self;
    self.webView.backgroundColor=[UIColor clearColor];
    self.webView.scalesPageToFit = YES;
    [self.view addSubview:self.webView];
    
    //返回按钮
    self.btnReturn = [Utils leftButtonWithTitle:@"返回" frame:[Utils getNavLeftBtnFrame:CGSizeMake(110,60)] target:self action:@selector(backButtonClicked)];
    [self.btnReturn setBackgroundImage:[Common getImageWithColor:COLOR(0, 0, 0, 0.5)] forState:UIControlStateNormal];//[SkinManage skinColor]
    [self.btnReturn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnReturn.layer setBorderWidth:1.0];
    [self.btnReturn.layer setCornerRadius:3];
    self.btnReturn.layer.borderColor = [[UIColor clearColor] CGColor];
    [self.btnReturn.layer setMasksToBounds:YES];
    [self.view addSubview:self.btnReturn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

////设置status bar 颜色
//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleDefault;
//}

//返回上一层
- (void)backButtonClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UIWebView delegate methods
- (void) webViewDidStartLoad:(UIWebView *)webView
{
    [self isHideActivity:NO];
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self isHideActivity:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webViewTemp
{
    [self isHideActivity:YES];
}

@end
