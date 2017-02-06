//
//  JobWebViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/22.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "JobWebViewController.h"
#import "CheXiangService.h"

@interface JobWebViewController ()<UIWebViewDelegate,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webViewContent;

@end

@implementation JobWebViewController

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
    self.title = self.jobVo.strName;
    
    if (self.nFlag == 0)
    {
        //解绑按钮
        self.navigationItem.rightBarButtonItem = [self rightBtnItemWithTitle:@"移除"];
    }
    
    self.view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    self.webViewContent.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    NSMutableURLRequest *request =[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[self.jobVo.strJobURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    //设置保存在Cookie里面的sessionId
    NSArray * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    [request setAllHTTPHeaderFields:headers];
    
    [self.webViewContent loadRequest:request];
    [self.webViewContent setAutoresizesSubviews:YES];
    [self.webViewContent setAutoresizingMask:UIViewAutoresizingNone];
    [self.webViewContent setUserInteractionEnabled: YES ];
    [self.webViewContent setOpaque:YES ];
    self.webViewContent.backgroundColor=[UIColor clearColor];
    self.webViewContent.scalesPageToFit = YES;
}

- (void)righBarClick
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"您确定要移除该工作？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

//返回
- (void)backForePage
{
    if ([self.webViewContent canGoBack])
    {
        [self.webViewContent goBack];
    }
    else
    {
        [super backForePage];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [Common showProgressView:@"移除中..." view:self.view modal:NO];
        [CheXiangService editChexiangJob:self.jobVo.strID type:2 result:^(ServerReturnInfo *retInfo) {
            [Common hideProgressView:self.view];
            if (retInfo.bSuccess)
            {
                //移除则退出去，并且刷新我的工作
                [self backForePage];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"CheXiangRefreshJobNotification" object:nil];
            }
            else
            {
                [Common tipAlert:retInfo.strErrorMsg];
            }
        }];
    }
}

#pragma mark UIWebView delegate methods
- (void) webViewDidStartLoad:(UIWebView *)webView
{
    [Common showProgressView:@"加载中..." view:self.view modal:NO];
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [Common hideProgressView:self.view];
    [Common bubbleTip:@"加载失败" andView:self.view];
}

- (void)webViewDidFinishLoad:(UIWebView *)webViewTemp
{
    [Common hideProgressView:self.view];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //    if (navigationType == UIWebViewNavigationTypeLinkClicked || navigationType == UIWebViewNavigationTypeReload || navigationType == UIWebViewNavigationTypeOther)
    //    {
    //        NSString *strURL = [request URL].absoluteString;
    //        if (strURL != nil && strURL.length>0)
    //        {
    //            NSRange range = [strURL rangeOfString:@"http://i.am.mobile/"];
    //            if(range.length>0 && range.location == 0)
    //            {
    //                [self backButtonClicked];
    //                return NO;
    //            }
    //            else
    //            {
    //                return YES;
    //            }
    //        }
    //    }
    return YES;
}

@end
