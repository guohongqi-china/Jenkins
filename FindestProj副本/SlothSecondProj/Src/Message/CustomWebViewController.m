//
//  CustomWebViewController.m
//  Sloth
//
//  Created by 焱 孙 on 13-3-5.
//
//

#import "CustomWebViewController.h"

@interface CustomWebViewController ()

@end

@implementation CustomWebViewController
@synthesize webView;
@synthesize urlFile;

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
    // Do any additional setup after loading the view from its nib.
    
    [self setTopNavBarTitle:@"页面载入中"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSMutableURLRequest *request =[[NSMutableURLRequest alloc] initWithURL:self.urlFile];
    self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth,kScreenHeight-NAV_BAR_HEIGHT)];

    //设置保存在Cookie里面的sessionId
    NSArray * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    [request setAllHTTPHeaderFields:headers];
    
    [self.webView loadRequest:request];
    [self.webView setAutoresizesSubviews:YES];
    [self.webView setAutoresizingMask:UIViewAutoresizingNone];
    [self.webView setUserInteractionEnabled: YES ];
    [self.webView setOpaque:YES ]; 
    self.webView.delegate = self;
    self.webView.backgroundColor=[UIColor clearColor];
    self.webView.scalesPageToFit = YES;
    [self.view addSubview:self.webView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backButtonClicked
{
    if (self.bNeedFresh)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"RefreshCustomWebViewParent" object:nil];
    }
    [super backButtonClicked];
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
    [self setTopNavBarTitle:[webViewTemp stringByEvaluatingJavaScriptFromString:@"document.title"]];
    [self isHideActivity:YES];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked || navigationType == UIWebViewNavigationTypeReload || navigationType == UIWebViewNavigationTypeOther)
    {
        NSString *strURL = [request URL].absoluteString;
        if (strURL != nil && strURL.length>0)
        {
            NSRange range = [strURL rangeOfString:@"http://i.am.mobile/"];
            if(range.length>0 && range.location == 0)
            {
                [self backButtonClicked];
                return NO;
            }
            else
            {
                return YES;
            }
        }
    }
    return YES;
}
    
@end
