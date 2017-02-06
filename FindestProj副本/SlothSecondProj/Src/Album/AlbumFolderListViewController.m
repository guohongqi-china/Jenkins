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
        UIButton *rigthBtn = [Utils buttonWithTitle:@"创建相册" frame:[Utils getNavRightBtnFrame:CGSizeMake(140,76)] target:self action:@selector(CreateFolderBtnClick)];
        [self setRightBarButton:rigthBtn];
    }
    else if (self.nAlbumType == ALBUM_OTHER_USER_TYPE)
    {
        self.albumTitle = [NSString stringWithFormat:@"%@的相册",self.userVo.strUserName];
    }
    [self setTopNavBarTitle:self.albumTitle];
    
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

- (id) initWithAlbumType:(int)nType
{
    self = [super init];
    
    if (self)
    {
        self.nAlbumType = nType;
        switch (nType)
        {
            case ALBUM_MINE_TYPE:
                self.albumTitle = @"我的相册";
                break;
            case ALBUM_PUBLIC_TYPE:
                self.albumTitle = @"公共相册";
                break;
            case ALBUM_OTHER_USER_TYPE:
                self.albumTitle = @"相册";
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
        self.albumTitle = @"群组相册";
    }
    
    return self;
}

- (void) CreateFolderBtnClick
{
    CreateAlbumViewController *createAlbumViewController = [[CreateAlbumViewController alloc]init];
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
    if (self.nAlbumType == ALBUM_MINE_TYPE)
    {
        [self isHideActivity:NO];
        [ServerProvider getMyAlbumInfo:^(ServerReturnInfo *retInfo) {
            [self isHideActivity:YES];
            if (retInfo.bSuccess)
            {
                [self initView:retInfo.data];
            }
            else
            {
                [Common tipAlert:retInfo.strErrorMsg];
            }
        }];
    }
    else if (self.nAlbumType == ALBUM_PUBLIC_TYPE)
    {
        [self isHideActivity:NO];
        [ServerProvider getPublicAlbumInfo:^(ServerReturnInfo *retInfo) {
            [self isHideActivity:YES];
            if (retInfo.bSuccess)
            {
                [self initView:retInfo.data];
            }
            else
            {
                [Common tipAlert:retInfo.strErrorMsg];
            }
        }];
    }
    else if (self.nAlbumType == ALBUM_OTHER_USER_TYPE)
    {
        [self isHideActivity:NO];
        [ServerProvider getAlbumInfoByID:self.userVo.strUserID result:^(ServerReturnInfo *retInfo) {
            [self isHideActivity:YES];
            if (retInfo.bSuccess)
            {
                [self initView:retInfo.data];
            }
            else
            {
                [Common tipAlert:retInfo.strErrorMsg];
            }
        }];
    }
}

//重写返回按钮
- (void)backButtonClicked
{
    if ((self.nAlbumType == ALBUM_MINE_TYPE || self.nAlbumType == ALBUM_PUBLIC_TYPE) && self.fromViewToAlbumType != FromUserCenterToAlbumType)
    {
        [self.homeViewController.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [super backButtonClicked];
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
