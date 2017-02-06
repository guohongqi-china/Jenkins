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
    
    [self setTopNavBarTitle:[Common localStr:@"Common_Page_Loading" value:@"页面载入中"]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSURLRequest *request =[NSURLRequest requestWithURL:self.urlFile];
    self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth,kScreenHeight-NAV_BAR_HEIGHT)];
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
    
@end
