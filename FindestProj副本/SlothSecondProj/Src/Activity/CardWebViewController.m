//
//  CardWebViewController.m
//  TaoZhiHuiProj
//
//  Created by fujunzhi on 16/5/10.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "CardWebViewController.h"
#import "EditCardViewController.h"
#import "UserVo.h"
#import "ServerURL.h"
#import <ShareSDK/ShareSDK.h>
#import "NoSearchView.h"

//个人名片
//#define kCardUrl @"http://mgo.chexiang.com/wxcard/show?tzhUserId="
//#define kCardUrl @"http://mgo.sit.chexiang.com/wxcard/show.htm?tzhUserId="


@interface CardWebViewController()<UIWebViewDelegate>
@property (strong, nonatomic) MBProgressHUD *HUD;
@property (weak, nonatomic) NoSearchView *noSearchView;
@end


@implementation CardWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = COLOR(46, 49, 50, 1.0);
    
    NSString *requestStr = [NSString stringWithFormat:@"%@%@",[ServerURL getViewWeixinCardURL],[[Common getCurrentUserVo] strUserID]];
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:requestStr]];
    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth,kScreenHeight - 64)];
    [webView loadRequest:request];
    [webView setAutoresizesSubviews:YES];
    [webView setAutoresizingMask:UIViewAutoresizingNone];
    [webView setUserInteractionEnabled: YES ];
    [webView setOpaque:YES ];
    webView.delegate = self;
    webView.backgroundColor=[UIColor clearColor];
    webView.scalesPageToFit = YES;
    [self.view addSubview:webView];
    self.webView = webView;
    
    //设置rightItem
    [self setUpNavigationBar];
    
    self.HUD = [[MBProgressHUD alloc] initWithFrame:self.view.bounds];
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    [self.view addSubview:self.HUD];
    
    //change by fjz
//    NoSearchView *noSearchView = [[NoSearchView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT) andDes:@"名片为空"];
//    [self.view addSubview:noSearchView];
//    self.noSearchView = noSearchView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpNavigationBar
{
    self.title = @"我的名片";
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"editCard"] style:UIBarButtonItemStyleDone target:self action:@selector(rightBarBtnClick)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    self.navigationItem.rightBarButtonItem.tintColor = [SkinManage colorNamed:@"Nav_Btn_Tint_Color"];
}

#pragma mark UIWebView delegate methods
- (void) webViewDidStartLoad:(UIWebView *)webView
{
    [self.HUD show:YES];
}


- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.HUD hide:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webViewTemp
{
    [self.HUD hide:YES];
}

#pragma mark - 名片编辑
- (void)rightBarBtnClick
{
    EditCardViewController *editCardVC = [[EditCardViewController alloc] init];
    [self.navigationController pushViewController:editCardVC animated:YES];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [self setUpNavigationBar];
    if (navigationType == UIWebViewNavigationTypeLinkClicked || navigationType == UIWebViewNavigationTypeReload || navigationType == UIWebViewNavigationTypeOther)
    {
        NSString *strURL = [request URL].absoluteString;
        if (strURL != nil && strURL.length>0)
        {
            //1.公司介绍
            NSRange range = [strURL rangeOfString:@"pageName=wx-company"];
            if(range.length > 0)
            {
                self.title = @"公司详情";
                self.navigationItem.rightBarButtonItem = nil;
                return YES;
            }
            
            //2.分享第三平台
            range = [strURL rangeOfString:@"http://wxcard.tzhapp.share.control" options:NSCaseInsensitiveSearch];
            if(range.length > 0 && range.location == 0)
            {
                [self doShareToWeixin:strURL];
                return NO;
            }
            
            //3.返回按钮
            range = [strURL rangeOfString:@"http://wxcard.tzhapp.return.control" options:NSCaseInsensitiveSearch];
            if(range.length > 0 && range.location == 0)
            {
                [self backForePage];
                return NO;
            }
        }
    }
    return YES;
}

- (void)backForePage
{
    if ([self.webView canGoBack])
    {
        [self.webView goBack];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//分享到微信
- (void)doShareToWeixin:(NSString*)strURL
{
    ShareInfoVo *shareInfoVo = [[ShareInfoVo alloc]init];
    
    NSString *strImageURL = [ServerURL getShareWeixinCardImageURL];
    NSString *strTitle = @"微信名片";
    NSString *strContent = @"微信名片";
    strURL =[strURL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSRange range = [strURL rangeOfString:@"http://wxcard.tzhapp.share.control/?infoJSON=" options:NSCaseInsensitiveSearch];
    
    if(range.length>0 && range.location == 0)
    {
        NSString *strJSON = [strURL substringFromIndex:range.length];
        NSDictionary *dicInfo= [Common getObjectFromJSONString:strJSON];
        if (dicInfo != nil && [dicInfo isKindOfClass:[NSDictionary class]])
        {
            strImageURL = [Common checkStrValue:dicInfo[@"imgUrl"]];
            strTitle = [Common checkStrValue:dicInfo[@"title"]];
            strContent = [Common checkStrValue:dicInfo[@"content"]];
        }
    }
    
    shareInfoVo.strImageURL = strImageURL;
    shareInfoVo.strTitle = strTitle;
    shareInfoVo.strContent = strContent;
    shareInfoVo.strLinkURL = [NSString stringWithFormat:@"%@%@",[ServerURL getViewWeixinCardURL],[[Common getCurrentUserVo] strUserID]];
    
    NSArray *aryShareType = [ShareSDK getShareListWithType:ShareTypeWeixiSession,ShareTypeWeixiTimeline,nil];
    [BusinessCommon shareContentToThirdPlatform:self shareVo:shareInfoVo shareList:aryShareType];
}



@end
