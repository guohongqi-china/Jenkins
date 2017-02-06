//
//  DocViewController.m
//  NewWeiBO
//
//  Created by 焱 孙 on 12-12-3.
//
//

#import "DocViewController.h"
#import "Utils.h"


@interface DocViewController ()

@end

@implementation DocViewController
@synthesize webViewDoc;
@synthesize playerViewController;
@synthesize docType;
@synthesize strDocName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *strFilePath = self.urlFile.absoluteString.lowercaseString;
    [self setTopNavBarTitle:strDocName];

    //1.check the file is video or audio,then use the MPMoviePlayerViewController open
    if ([strFilePath hasSuffix:@".mp4"] || [strFilePath hasSuffix:@".mov"] || [strFilePath hasSuffix:@".mp3"] || [strFilePath hasSuffix:@".caf"]) 
    {
        docType = DocMediaType;
        [self openMediaPlay];
    }
    else
    {
        self.webViewDoc = [[UIWebView alloc]initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth,kScreenHeight-NAV_BAR_HEIGHT)];
        [self.view addSubview:self.webViewDoc];
        //[self.view sendSubviewToBack:self.webViewDoc];
        //NSURLRequest *request =[NSURLRequest requestWithURL:self.urlFile cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60]; 
        NSURLRequest *request =[NSURLRequest requestWithURL:self.urlFile];
        [self.webViewDoc loadRequest:request];
                
        [self.webViewDoc setAutoresizesSubviews:YES];
        [self.webViewDoc setAutoresizingMask:UIViewAutoresizingNone];
        [self.webViewDoc setUserInteractionEnabled: YES ];
        [self.webViewDoc setOpaque:YES ];
        self.webViewDoc.delegate = self;
        self.webViewDoc.backgroundColor=[UIColor clearColor];
        self.webViewDoc.scalesPageToFit = YES;
    }
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

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
	[self isHideActivity:YES];
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[self isHideActivity:YES];
}

//音视频播放
-(void)openMediaPlay
{    
    //1.create MPMoviePlayerViewController  
    self.playerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:self.urlFile];    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:playerViewController.moviePlayer];    
    
    //3.play movie   
    playerViewController.moviePlayer.scalingMode = MPMovieScalingModeAspectFit; 
    playerViewController.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;    
    playerViewController.moviePlayer.shouldAutoplay = NO;
    playerViewController.moviePlayer.repeatMode = MPMovieRepeatModeNone;
    
    [playerViewController.moviePlayer setFullscreen:YES animated:YES];    
    [playerViewController.moviePlayer play]; 
    
    //2.add to view  
    [self.view addSubview:playerViewController.view];
}

-(void)movieFinish:(NSNotification*)notification
{
    NSNumber* reason = [[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    switch ([reason intValue]) {
        case MPMovieFinishReasonPlaybackEnded:
            //playbackFinished. Reason: Playback Ended
            break;
        case MPMovieFinishReasonPlaybackError:
            //playbackFinished. Reason: Playback Error
            break;
        case MPMovieFinishReasonUserExited:
        {
            //playbackFinished. Reason: User Exited
            MPMoviePlayerController *playerController = [notification object];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:playerController];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        default:
            break;
    }
    
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (docType == DocMediaType)
    {
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
    }
    else
    {
        return UIInterfaceOrientationMaskPortrait;
    }
}

@end
