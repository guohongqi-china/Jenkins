//
//  CustomTicketViewController.m
//  MerieuxWskProj
//
//  Created by 焱 孙 on 15/12/2.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import "CustomTicketViewController.h"
#import "Utils.h"
#import "BarCodeScanViewController.h"

@interface CustomTicketViewController ()<UIWebViewDelegate>
{
    UIView *viewBK;
    UIWebView *webViewTicket;
    NSURL *urlLocation;
    UIButton *btnReturn;
}

@end

@implementation CustomTicketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.fd_prefersNavigationBarHidden = YES;
    
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    [self setTopNavBarTitle:@"页面载入中"];
    if ([self checkIsFromScanView:nil])
    {
        //如果从扫码页面过来，则返回时禁用滑动返回
        self.fd_interactivePopDisabled = YES;
    }
    
    UIButton *btnBack = [Utils buttonWithImageName:[UIImage imageNamed:@"nav_left_close"] frame:[Utils getNavLeftBtnFrame:CGSizeMake(100,76)] target:self action:@selector(backButtonClicked)];
    [self setLeftBarButton:btnBack];
    
    self.view.backgroundColor = [UIColor whiteColor];
    viewBK = [[UIView alloc]initWithFrame:CGRectMake(0, kStatusBarHeight, kScreenWidth, kScreenHeight-kStatusBarHeight)];
    viewBK.backgroundColor = COLOR(46, 49, 50, 1.0);
    [self.view addSubview:viewBK];
    [self.view sendSubviewToBack:viewBK];
    
    //中文编码
    urlLocation = [NSURL URLWithString:[self.strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    webViewTicket = [[UIWebView alloc]initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth,kScreenHeight-NAV_BAR_HEIGHT)];
    
    //做Cookie(Server Session)同步
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:urlLocation];
    NSArray * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    [request setAllHTTPHeaderFields:headers];
    
    [webViewTicket loadRequest:request];
    [webViewTicket setAutoresizesSubviews:YES];
    [webViewTicket setAutoresizingMask:UIViewAutoresizingNone];
    [webViewTicket setUserInteractionEnabled: YES ];
    [webViewTicket setOpaque:YES ];
    webViewTicket.delegate = self;
    webViewTicket.backgroundColor=[UIColor clearColor];
    webViewTicket.scalesPageToFit = YES;
    [self.view addSubview:webViewTicket];
}

//检查是否从扫码页面过来
- (BOOL)checkIsFromScanView:(UIViewController **)viewController
{
    BOOL bResult = NO;
    NSArray *aryController = self.navigationController.viewControllers;
    if (aryController.count >= 3 && [aryController[aryController.count-2] isKindOfClass:[BarCodeScanViewController class]])
    {
        if (viewController != nil)
        {
            *viewController = aryController[aryController.count-3];
        }
        bResult = YES;
    }
    return bResult;
}

//返回上一层
- (void)backButtonClicked
{
    //如果从扫码页面过来，则返回时跳过扫码页面
    UIViewController *viewController = nil;
    if ([self checkIsFromScanView:&viewController])
    {
       [self.navigationController popToViewController:viewController animated:YES];
    }
    else
    {
        [super backButtonClicked];
    }
}

#pragma mark UIWebView delegate methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked || navigationType == UIWebViewNavigationTypeReload || navigationType == UIWebViewNavigationTypeOther)
    {
        NSString *strURL = [request URL].absoluteString;
        if (strURL != nil && strURL.length>0)
        {
//            //1.上传头像照片
//            NSRange range = [strURL rangeOfString:@"http://wxcard.tzhapp.upload.control" options:NSCaseInsensitiveSearch];
//            if(range.length>0 && range.location == 0)
//            {
//                return NO;
//            }
//            
//            //2.分享第三平台
//            range = [strURL rangeOfString:@"http://wxcard.tzhapp.share.control" options:NSCaseInsensitiveSearch];
//            if(range.length>0 && range.location == 0)
//            {
//                return NO;
//            }
//            
//            //3.返回按钮
//            range = [strURL rangeOfString:@"http://wxcard.tzhapp.return.control" options:NSCaseInsensitiveSearch];
//            if(range.length>0 && range.location == 0)
//            {
//                return NO;
//            }
        }
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webViewTemp
{
    [self setTopNavBarTitle:[webViewTemp stringByEvaluatingJavaScriptFromString:@"document.title"]];
}

@end
