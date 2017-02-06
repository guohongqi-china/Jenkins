//
//  PhotoAlbumViewController.m
//  ChinaMobileSocialProj
//
//  Created by 焱 孙 on 13-10-28.
//
//

#import "PhotoAlbumViewController.h"
#import "ServerURL.h"
#import "ServerProvider.h"
#import "Utils.h"

@interface PhotoAlbumViewController ()

@end

@implementation PhotoAlbumViewController

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
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initTabBar];
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

- (void)showSideMenu
{
    [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerOpenLeftSide object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initTabBar
{
    self.viewTab = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight-50, kScreenWidth, 50)];
    self.viewTab.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_viewTab];
    
    CGFloat fTabW = kScreenWidth/2;
    //我的相册
    self.myAlbumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.myAlbumBtn.frame = CGRectMake(0, 0, fTabW, 50);
    [self.myAlbumBtn setTitle:[Common localStr:@"Albums_My" value:@"我的相册"] forState:UIControlStateNormal];
    [self.myAlbumBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.myAlbumBtn setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
    [self.myAlbumBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15.0]];
    [self.myAlbumBtn setBackgroundImage:[Common getImageWithColor:COLOR(38, 38, 38, 1.0)] forState:UIControlStateNormal];
    [self.myAlbumBtn addTarget:self action:@selector(selectTab:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewTab addSubview:_myAlbumBtn];
    
    //公共相册
    self.publicAlbumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.publicAlbumBtn.frame = CGRectMake(fTabW, 0, kScreenWidth-fTabW, 50);
    [self.publicAlbumBtn setTitle:[Common localStr:@"Albums_Common" value:@"公共相册"] forState:UIControlStateNormal];
    [self.publicAlbumBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.publicAlbumBtn setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
    [self.publicAlbumBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15.0]];
    [self.publicAlbumBtn setBackgroundImage:[Common getImageWithColor:COLOR(38, 38, 38, 1.0)] forState:UIControlStateNormal];
    [self.publicAlbumBtn addTarget:self action:@selector(selectTab:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewTab addSubview:_publicAlbumBtn];
    
    //view controller
    self.myAlbumListViewController = [[AlbumFolderListViewController alloc] initWithAlbumType:ALBUM_MINE_TYPE];
    self.myAlbumListViewController.homeViewController = self;
    self.myAlbumListViewController.fromViewToAlbumType = FromMainAlbumToAlbumType;
    self.myAlbumNavigationController = [[UINavigationController alloc]initWithRootViewController:self.myAlbumListViewController];
    self.myAlbumNavigationController.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    self.myAlbumNavigationController.navigationBarHidden = YES;
    
    self.publicAlbumListViewController = [[AlbumFolderListViewController alloc] initWithAlbumType:ALBUM_PUBLIC_TYPE];
    self.publicAlbumListViewController.homeViewController = self;
    self.publicAlbumListViewController.fromViewToAlbumType = FromMainAlbumToAlbumType;
    self.publicAlbumNavigationController = [[UINavigationController alloc]initWithRootViewController:self.publicAlbumListViewController];
    self.publicAlbumNavigationController.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    self.publicAlbumNavigationController.navigationBarHidden = YES;
    
    self.mainTabType = PhotoAlbumPublicType;
    [self selectTab:self.myAlbumBtn];
}

-(void)hideBottomTabBar:(BOOL)bHide
{
    self.viewTab.hidden = bHide;
}

-(void)selectTab:(UIButton*)sender
{
    if (sender == self.myAlbumBtn)
    {
        //我的相册
        if (self.mainTabType != PhotoAlbumMyType)
        {
            self.mainTabType = PhotoAlbumMyType;
            [self.myAlbumBtn setBackgroundImage:[Common getImageWithColor:COLOR(0, 0, 0, 1.0)] forState:UIControlStateNormal];
            [self.publicAlbumBtn setBackgroundImage:[Common getImageWithColor:COLOR(38, 38, 38, 1.0)] forState:UIControlStateNormal];
            
            [self switchViewController];
        }
    }
    else if (sender == self.publicAlbumBtn)
    {
        //公共相册
        if (self.mainTabType != PhotoAlbumPublicType)
        {
            self.mainTabType = PhotoAlbumPublicType;
            [self.myAlbumBtn setBackgroundImage:[Common getImageWithColor:COLOR(38, 38, 38, 1.0)] forState:UIControlStateNormal];
            [self.publicAlbumBtn setBackgroundImage:[Common getImageWithColor:COLOR(0, 0, 0, 1.0)] forState:UIControlStateNormal];
            [self switchViewController];
        }
    }
}

-(void)switchViewController
{
    if (self.mainTabType == PhotoAlbumMyType)
    {
        [self.view addSubview:self.myAlbumNavigationController.view];
    }
    else if (self.mainTabType == PhotoAlbumPublicType)
    {
        [self.view addSubview:self.publicAlbumNavigationController.view];
    }
    [self.view bringSubviewToFront:self.viewTab];
}

@end
