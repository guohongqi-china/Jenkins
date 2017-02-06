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
#import "UIViewExt.h"

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

//-(void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:YES];
//    [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerAddPanGesture object:nil];
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:YES];
//    [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerRemovePanGesture object:nil];
//}
//
//- (void)showSideMenu
//{
//    [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerOpenLeftSide object:nil];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initTabBar
{
    self.viewTab = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight-50, kScreenWidth, 50)];
    self.viewTab.backgroundColor = COLOR(249, 249, 249, 1.0);
    [self.view addSubview:_viewTab];
    
    self.imgViewTabLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 1.5)];
    self.imgViewTabLine.image = [[UIImage imageNamed:@"tab_line"]stretchableImageWithLeftCapWidth:10 topCapHeight:0];
    [self.viewTab addSubview:self.imgViewTabLine];
    
    CGFloat fWidth = kScreenWidth/2;
    //我的相册
    self.myAlbumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.myAlbumBtn.frame = CGRectMake(0, 0, fWidth, 50);
    [self.myAlbumBtn setTitleColor:COLOR(93, 93, 93, 1.0) forState:UIControlStateNormal];
    [self.myAlbumBtn setTitleColor:COLOR(226, 136, 46, 1.0) forState:UIControlStateHighlighted];
    self.myAlbumBtn.titleEdgeInsets = UIEdgeInsetsMake(22,0,0,0);
    [self.myAlbumBtn.titleLabel setFont:[UIFont fontWithName:APP_FONT_NAME size:14.0]];
    self.myAlbumBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.myAlbumBtn setTitle:@"我的相册" forState:UIControlStateNormal];
    [self.myAlbumBtn setImage:[UIImage imageNamed:@"tab_my_album"] forState:UIControlStateNormal];
    [self.myAlbumBtn setImage:[UIImage imageNamed:@"tab_my_album_h"] forState:UIControlStateHighlighted];
    [self.myAlbumBtn addTarget:self action:@selector(selectTab:) forControlEvents:UIControlEventTouchUpInside];
    [Common setButtonImageTitlePosition:self.myAlbumBtn spacing:3];
    [self.viewTab addSubview:self.myAlbumBtn];
    
    UIView *viewSeparate = [[UIView alloc]initWithFrame:CGRectMake(self.myAlbumBtn.right, 15, 0.5, 20)];
    viewSeparate.backgroundColor = COLOR(188, 188, 188, 1.0);
    [self.viewTab addSubview:viewSeparate];
    
    //公共相册
    self.publicAlbumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.publicAlbumBtn.frame = CGRectMake(fWidth, 0, kScreenWidth-fWidth, 50);
    [self.publicAlbumBtn setTitleColor:COLOR(93, 93, 93, 1.0) forState:UIControlStateNormal];
    [self.publicAlbumBtn setTitleColor:COLOR(226, 136, 46, 1.0) forState:UIControlStateHighlighted];
    self.publicAlbumBtn.titleEdgeInsets = UIEdgeInsetsMake(22,0,0,0);
    [self.publicAlbumBtn.titleLabel setFont:[UIFont fontWithName:APP_FONT_NAME size:14.0]];
    self.publicAlbumBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.publicAlbumBtn setTitle:@"公共相册" forState:UIControlStateNormal];
    [self.publicAlbumBtn setImage:[UIImage imageNamed:@"tab_public_album"] forState:UIControlStateNormal];
    [self.publicAlbumBtn setImage:[UIImage imageNamed:@"tab_public_album_h"] forState:UIControlStateHighlighted];
    [self.publicAlbumBtn addTarget:self action:@selector(selectTab:) forControlEvents:UIControlEventTouchUpInside];
    [Common setButtonImageTitlePosition:self.publicAlbumBtn spacing:3];
    [self.viewTab addSubview:self.publicAlbumBtn];
    
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
            [self.myAlbumBtn setTitleColor:COLOR(226, 136, 46, 1.0) forState:UIControlStateNormal];
            [self.publicAlbumBtn setTitleColor:COLOR(93, 93, 93, 1.0) forState:UIControlStateNormal];
            
            [self.myAlbumBtn setImage:[UIImage imageNamed:@"tab_my_album_h"] forState:UIControlStateNormal];
            [self.publicAlbumBtn setImage:[UIImage imageNamed:@"tab_public_album"] forState:UIControlStateNormal];
            [self switchViewController];
        }
    }
    else if (sender == self.publicAlbumBtn)
    {
        //公共相册
        if (self.mainTabType != PhotoAlbumPublicType)
        {
            self.mainTabType = PhotoAlbumPublicType;
            [self.myAlbumBtn setTitleColor:COLOR(93, 93, 93, 1.0) forState:UIControlStateNormal];
            [self.publicAlbumBtn setTitleColor:COLOR(226, 136, 46, 1.0) forState:UIControlStateNormal];
            
            [self.myAlbumBtn setImage:[UIImage imageNamed:@"tab_my_album"] forState:UIControlStateNormal];
            [self.publicAlbumBtn setImage:[UIImage imageNamed:@"tab_public_album_h"] forState:UIControlStateNormal];
            [self switchViewController];
        }
    }
}

-(void)switchViewController
{
    self.myAlbumListViewController.collectionViewAlbumList.scrollsToTop = NO;
    self.publicAlbumListViewController.collectionViewAlbumList.scrollsToTop = NO;
    
    if (self.mainTabType == PhotoAlbumMyType)
    {
        [self.view addSubview:self.myAlbumNavigationController.view];
        self.myAlbumListViewController.collectionViewAlbumList.scrollsToTop = YES;
    }
    else if (self.mainTabType == PhotoAlbumPublicType)
    {
        [self.view addSubview:self.publicAlbumNavigationController.view];
        self.publicAlbumListViewController.collectionViewAlbumList.scrollsToTop = YES;
    }
    [self.view bringSubviewToFront:self.viewTab];
}

@end
