//
//  CollectionShareViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/2.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "CollectionShareViewController.h"
#import "HMWaterflowLayout.h"
#import "StoreCollectionCell.h"
#import "BlogVo.h"
#import "MJRefresh.h"
#import "ExtScope.h"
#import "ShareDetailViewController.h"
#import "ShareHomeViewController.h"

@interface CollectionShareViewController ()<StoreCollectionCellDelegate,HMWaterflowLayoutDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
{
    NSMutableArray *aryShare;
    CGFloat fCellWidth;
    
    NSInteger nPage;
}

@property (weak, nonatomic) IBOutlet HMWaterflowLayout *waterFlowLayout;

@end

@implementation CollectionShareViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFY_REFRESH_SKIN object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshSkin) name:NOTIFY_REFRESH_SKIN object:nil];
    
    self.waterFlowLayout.colCount = 2;
    self.waterFlowLayout.delegate = self;
    self.view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    self.collectionViewStore.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    [self.collectionViewStore registerNib:[UINib nibWithNibName:@"StoreCollectionCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"StoreCollectionCell"];
    
    fCellWidth = (kScreenWidth-12*2-7)/2;
    
    //下拉刷新
    @weakify(self)
    self.collectionViewStore.mj_header =  [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self loadNewData:YES];
    }];
    
    //上拉加载更多
    self.collectionViewStore.mj_footer =  [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        [self loadNewData:NO];
    }];
}

- (void)initData
{
    nPage = 1;
    aryShare = [NSMutableArray array];
    
    [self loadNewData:YES];
}

//分页数据
-(void)loadNewData:(BOOL)bRefresh
{
    if (bRefresh)
    {
        //下拉刷新
        nPage = 1;
    }
    
    [ServerProvider getCollectionBlog:nPage create:[Common getCurrentUserVo].strUserID result:^(ServerReturnInfo *retInfo) {
        if (retInfo.bSuccess)
        {
            NSMutableArray *aryData = retInfo.data;
            if (bRefresh)
            {
                //下拉刷新
                if (aryData != nil && aryData.count>0)
                {
                    [aryShare removeAllObjects];
                    [aryShare addObjectsFromArray:aryData];
                }
            }
            else
            {
                //上拖加载
                [aryShare addObjectsFromArray:aryData];
            }
            
            if (aryData != nil && aryData.count>0)
            {
                nPage ++;
            }
            [self.collectionViewStore reloadData];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
        
        //停止刷新
        if (bRefresh)
        {
            [self.collectionViewStore.mj_header endRefreshing];
        }
        
        if([retInfo.data2 boolValue])
        {
            [self.collectionViewStore.mj_footer endRefreshingWithNoMoreData];   //最后一页
        }
        else
        {
            [self.collectionViewStore.mj_footer endRefreshing];
        }
    }];
}

- (void)refreshSkin
{
    self.view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.collectionViewStore.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    [_collectionViewStore reloadData];
}

#pragma mark - StoreCollectionCellDelegate
- (void)cancelStoreCollection:(BlogVo *)blogVo
{
    [aryShare removeObject:blogVo];
    [self.collectionViewStore reloadData];
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return aryShare.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    StoreCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"StoreCollectionCell" forIndexPath:indexPath];
    cell.entity = aryShare[indexPath.row];
    cell.isHideClearButton = NO;
    cell.delegate = self;
    return cell;
}

- (CGFloat)waterflowLayout:(HMWaterflowLayout *)waterflowLayout heightForWidth:(CGFloat)width atIndexPath:(NSIndexPath *)indexPath
{
    BlogVo *blogVo = aryShare[indexPath.row];
    CGFloat fHeight = 0;
    if (blogVo.aryPictureUrl.count > 0)
    {
        fHeight += fCellWidth+12;
    }
    else
    {
        fHeight += 41;
    }
    
    //title
    CGSize sizeLbl = [Common getStringSize:blogVo.strTitle font:[Common fontWithName:@"PingFangSC-Medium" size:14] bound:CGSizeMake(fCellWidth-20, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    if(sizeLbl.height > 31.5)
    {
        sizeLbl.height = 31.5;
    }
    fHeight += sizeLbl.height;
    
    //content
    fHeight += 10;
    sizeLbl = [Common getStringSize:blogVo.strText font:[Common fontWithName:@"PingFangSC-Light" size:13] bound:CGSizeMake(fCellWidth-20, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    if(sizeLbl.height > 31.5)
    {
        sizeLbl.height = 31.5;
    }
    fHeight += sizeLbl.height;
    fHeight += 9.5;
    
    //bottom
    fHeight += 54;
    
    return fHeight;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    ShareDetailViewController *shareDetailViewController = [[ShareDetailViewController alloc] init];
    BlogVo *blog = [aryShare objectAtIndex:[indexPath row]];
    shareDetailViewController.m_originalBlogVo = blog;
    if (blog.streamId.length == 0)
    {
        [Common tipAlert:@"数据异常，请求失败"];
        return;
    }
    
    if(self.shareHomeViewController != nil)
    {
        [self.shareHomeViewController hideBottomWhenPushed];
    }
    [self.shareHomeViewController.navigationController pushViewController:shareDetailViewController animated:YES];
}

@end
