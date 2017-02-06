//
//  AlbumFolderListViewController.m
//  ChinaMobileSocialProj
//
//  Created by Yuson Xing on 14-3-11.
//
//

#import "AlbumFolderListViewController.h"
#import "ServerProvider.h"
#import "AlbumFolderListCell.h"
#import "Utils.h"
#import "CreateAlbumViewController.h"
#import "AlbumImageListViewController.h"
#import "PhotoAlbumViewController.h"

@interface AlbumFolderListViewController ()

@end

@implementation AlbumFolderListViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RefreshAlbumListData" object:nil];
}

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
    self.view.backgroundColor = [UIColor whiteColor];
    
    //1.标题和右导航按钮设置
    if (self.nAlbumType == ALBUM_MINE_TYPE)
    {
        //只有我的相册才有“创建相册”的功能
        UIButton *rigthBtn = [Utils buttonWithTitle:[Common localStr:@"Albums_Create" value:@"创建相册"] frame:[Utils getNavRightBtnFrame:CGSizeMake(140,76)] target:self action:@selector(CreateFolderBtnClick)];
        [self setRightBarButton:rigthBtn andKey:@"Albums_Create"];
    }
    else if (self.nAlbumType == ALBUM_OTHER_USER_TYPE)
    {
        self.albumTitle = [NSString stringWithFormat:@"%@%@",self.userVo.strUserName,[Common localStr:@"Albums_SomeOne" value:@"的相册"]];
        self.strKey = @"Albums_SomeOne";
    }
    [self setTopNavBarTitle:self.albumTitle andKey:self.strKey];
    
    //2.collection view
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize=CGSizeMake(160,160);
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    self.collectionViewAlbumList = [[UICollectionView alloc]initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT+5, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT-50) collectionViewLayout:flowLayout];
    self.collectionViewAlbumList.dataSource = self;
    self.collectionViewAlbumList.delegate = self;
    self.collectionViewAlbumList.backgroundColor = [UIColor clearColor];
    self.collectionViewAlbumList.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.collectionViewAlbumList];
    [self.collectionViewAlbumList registerClass:[AlbumFolderListCell class] forCellWithReuseIdentifier:@"AlbumFolderListCell"];

    //3.获取数据
    [self isHideActivity:NO];
    [NSThread detachNewThreadSelector:@selector(ObtainFolderInfoProc) toTarget:self withObject:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshData) name:@"RefreshAlbumListData" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshAlbumFoldList:) name:@"RefreshAlbumFoldList" object:nil];
    
    //4.左导航设置
    if ((self.nAlbumType == ALBUM_MINE_TYPE || self.nAlbumType == ALBUM_PUBLIC_TYPE) && self.fromViewToAlbumType != FromUserCenterToAlbumType)
    {
        //左边按钮
        UIButton *btnBack = [Utils buttonWithImageName:[UIImage imageNamed:@"nav_setting"] frame:[Utils getNavLeftBtnFrame:CGSizeMake(100,76)] target:self action:nil];
        [btnBack addTarget:self action:@selector(showSideMenu) forControlEvents:UIControlEventTouchUpInside];
        [self setLeftBarButton:btnBack];
        //notice num view
        NoticeNumView *noticeNumView = [[NoticeNumView alloc]initWithFrame:CGRectMake(25.5, 6+kStatusBarHeight, 18, 18)];
        [self.view addSubview:noticeNumView];
        
        self.collectionViewAlbumList.frame = CGRectMake(0, NAV_BAR_HEIGHT+5, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT-50-5);
    }
    else
    {
        self.collectionViewAlbumList.frame = CGRectMake(0, NAV_BAR_HEIGHT+5, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT-5);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.nAlbumType == ALBUM_MINE_TYPE || self.nAlbumType == ALBUM_PUBLIC_TYPE)
    {
        [self showBottomTab];
        [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerAddPanGesture object:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.nAlbumType == ALBUM_MINE_TYPE || self.nAlbumType == ALBUM_PUBLIC_TYPE)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerRemovePanGesture object:nil];
    }
}

-(void)hideBottomWhenPushed
{
    self.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    [self.homeViewController hideBottomTabBar:YES];
}

-(void)showBottomTab
{
    self.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight-50);
    [self.homeViewController hideBottomTabBar:NO];
}

- (void)showSideMenu
{
    [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerOpenLeftSide object:nil];
}

- (id) initWithAlbumType:(int)nType
{
    self = [super init];
    
    if (self)
    {
        self.nAlbumType = nType;
        switch (nType)
        {
            case ALBUM_MINE_TYPE:
                self.albumTitle = [Common localStr:@"Albums_My" value:@"我的相册"];
                self.strKey = @"Albums_My";
                break;
            case ALBUM_PUBLIC_TYPE:
                self.albumTitle = [Common localStr:@"Albums_Common" value:@"公共相册"];
                self.strKey = @"Albums_Common";
                break;
            case ALBUM_OTHER_USER_TYPE:
                self.albumTitle = [Common localStr:@"Menu_Album" value:@"相册"];
                self.strKey = @"Menu_Album";
                break;
            default:
                break;
        }
    }
    
    return self;
}

- (id) initGroupAlbumWithID:(NSString *)gID
{
    self = [super init];
    
    if (self)
    {
        self.nAlbumType = ALBUM_GROUP_TYPE;
        self.groupID    = gID;
        self.albumTitle = [Common localStr:@"Albums_Group" value:@"群组相册"];
        self.strKey = @"Albums_Group";
    }
    
    return self;
}

- (void) CreateFolderBtnClick
{
    [self hideBottomWhenPushed];
    CreateAlbumViewController *createAlbumViewController = [[CreateAlbumViewController alloc]init];
    createAlbumViewController.editAlbumType = CreateAlbumType;
    [self.navigationController pushViewController:createAlbumViewController animated:YES];
}

- (void) initView:(id)folderInfo
{
    self.folderArray = folderInfo;
    
    [self.collectionViewAlbumList reloadData];
    [self isHideActivity:YES];
}

- (void) ObtainFolderInfoProc
{
    @autoreleasepool
    {
        ServerReturnInfo *resInfo = nil;
        switch (self.nAlbumType)
        {
            case ALBUM_MINE_TYPE:
                resInfo = [ServerProvider getMyAlbumInfo];
                break;
            case ALBUM_PUBLIC_TYPE:
                resInfo = [ServerProvider getPublicAlbumInfo];
                break;
            case ALBUM_OTHER_USER_TYPE:
                resInfo = [ServerProvider getAlbumInfoByID:self.userVo.strUserID];
                break;
            default:
                break;
        }
        
        if (resInfo.bSuccess)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self initView:resInfo.data];
                [self isHideActivity:YES];
        	});
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [Common tipAlert:resInfo.strErrorMsg];
                [self isHideActivity:YES];
        	});
        }
    }
}

//refreshData
-(void)refreshData
{
    [self isHideActivity:NO];
    [NSThread detachNewThreadSelector:@selector(ObtainFolderInfoProc) toTarget:self withObject:nil];
}

//上传照片后刷新数据（刷新相册的封面图片）
-(void)refreshAlbumFoldList:(NSNotification*)notification
{
    NSMutableDictionary* dicNotifyData = [notification object];
    int nType = [[dicNotifyData objectForKey:@"NotifyData"] intValue];
    if (nType == self.nAlbumType)
    {
        [self refreshData];
    }
}

#pragma mark - UICollectionViewDataSource UICollectionViewDelegate
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"AlbumFolderListCell";
    AlbumFolderListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    AlbumInfoVO *albumInfoVO = [self.folderArray objectAtIndex:[indexPath row]];
    cell.parentViewController = self;
    [cell initWithAlbumInfo:albumInfoVO];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.folderArray.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    AlbumInfoVO *albumInfoVO = [self.folderArray objectAtIndex:indexPath.row];
    AlbumImageListViewController *albumImageListViewController = [[AlbumImageListViewController alloc]init];
    albumImageListViewController.m_albumInfoVO = albumInfoVO;
    albumImageListViewController.nAlbumType = self.nAlbumType;
    [self hideBottomWhenPushed];
    [self.navigationController pushViewController:albumImageListViewController animated:YES];
}

@end
