//
//  PolicyViewController.m
//  Sloth
//
//  Created by 焱 孙 on 13-3-8.
//
//

#import "PolicyViewController.h"
#import "UIColor+HexColors.h"

@interface PolicyViewController ()<UIWebViewDelegate>

@end

@implementation PolicyViewController
@synthesize webView;

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
    self.view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.title = @"使用条款和隐私政策";
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    NSString *strPolicy = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sloth_policy" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
    
    self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth,kScreenHeight-NAV_BAR_HEIGHT)];
    [webView loadHTMLString:strPolicy baseURL:nil];
    self.webView.delegate = self;
    [self.webView setAutoresizesSubviews:YES];
    [self.webView setAutoresizingMask:UIViewAutoresizingNone];
    [self.webView setUserInteractionEnabled:YES];
    self.webView.opaque = NO; //不设置这个值 页面背景始终是白色
    self.webView.backgroundColor=[UIColor clearColor];
    self.webView.scalesPageToFit = YES;
    self.webView.frame = CGRectMake(10, 0, kScreenWidth-20,kScreenHeight-NAV_BAR_HEIGHT);
    [self.view addSubview:self.webView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextFillColor='#%@'",[UIColor hexValuesFromUIColor:[SkinManage colorNamed:@"Menu_Title_Color"]]];
    [self.webView stringByEvaluatingJavaScriptFromString:jsString];
}

@end
