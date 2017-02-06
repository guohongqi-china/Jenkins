//
//  ShareCoverFlowView.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/16.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "ShareCoverFlowView.h"
#import "HJCarouselViewCell.h"
#import "HJCarouselViewLayout.h"
#import "BlogVo.h"
#import "ShareCoverFlowCell.h"
#import "ShareListViewController.h"
#import "ShareDetailViewController.h"
#import "ShareHomeViewController.h"

@interface ShareCoverFlowView ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSMutableArray *aryHotShare;
    
    UICollectionView *collectionViewShare;
    HJCarouselViewLayout *carouselViewLayout;
}

@end

@implementation ShareCoverFlowView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initView];
        [self initData];
    }
    return self;
}

- (void)initView
{
    carouselViewLayout = [[HJCarouselViewLayout alloc]initWithAnim:HJCarouselAnimCarousel];
    carouselViewLayout.itemSize = CGSizeMake(kScreenWidth-54, 184);
    
    collectionViewShare = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 208) collectionViewLayout:carouselViewLayout];
    collectionViewShare.scrollsToTop = NO;
    collectionViewShare.backgroundColor = [SkinManage colorNamed:@"Share_Flow_BK"];
    collectionViewShare.delegate = self;
    collectionViewShare.dataSource = self;
    [self addSubview:collectionViewShare];
    
    [collectionViewShare registerNib:[UINib nibWithNibName:@"ShareCoverFlowCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"ShareCoverFlowCell"];
}

- (void)initData
{
    aryHotShare = [NSMutableArray array];
    
    [ServerProvider getTopShareList:^(ServerReturnInfo *retInfo) {
        if (retInfo.bSuccess)
        {
            NSMutableArray *aryData = retInfo.data;
            //下拉刷新
            if (aryData != nil && aryData.count>0)
            {
                [aryHotShare removeAllObjects];
                [aryHotShare addObjectsFromArray:aryData];
            }
            [collectionViewShare reloadData];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

- (NSIndexPath *)curIndexPath
{
    NSArray *indexPaths = [collectionViewShare indexPathsForVisibleItems];
    NSIndexPath *curIndexPath = nil;
    NSInteger curzIndex = 0;
    for (NSIndexPath *path in indexPaths.objectEnumerator)
    {
        UICollectionViewLayoutAttributes *attributes = [collectionViewShare layoutAttributesForItemAtIndexPath:path];
        if (!curIndexPath)
        {
            curIndexPath = path;
            curzIndex = attributes.zIndex;
            continue;
        }
        
        if (attributes.zIndex > curzIndex)
        {
            curIndexPath = path;
            curzIndex = attributes.zIndex;
        }
    }
    return curIndexPath;
}

- (void)refreshSkin
{
    collectionViewShare.backgroundColor = [SkinManage colorNamed:@"Share_Flow_BK"];
    [collectionViewShare reloadData];
}

#pragma mark <UICollectionViewDataSource>
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *curIndexPath = [self curIndexPath];
    if (indexPath.row == curIndexPath.row) {
        return YES;
    }
    
    //[collectionViewShare scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    
    HJCarouselViewLayout *layout = (HJCarouselViewLayout *)collectionView.collectionViewLayout;
    CGFloat cellWidth = layout.itemSize.width;
    CGRect visibleRect = CGRectZero;
    if (indexPath.row > curIndexPath.row) {
        visibleRect = CGRectMake(cellWidth * indexPath.row + cellWidth / 2, 0, cellWidth / 2,CGRectGetHeight(collectionView.frame));
    } else {
        visibleRect = CGRectMake(cellWidth * indexPath.row, 0, CGRectGetWidth(collectionView.frame), CGRectGetHeight(collectionView.frame));
    }
    [collectionViewShare scrollRectToVisible:visibleRect animated:YES];
    
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ShareDetailViewController *shareDetailViewController = [[ShareDetailViewController alloc] init];
    BlogVo *blog = [aryHotShare objectAtIndex:[indexPath row]];
    shareDetailViewController.m_originalBlogVo = blog;
    if (blog.streamId.length == 0)
    {
        [Common tipAlert:@"数据异常，请求失败"];
        return;
    }
    [self.shareListViewController.shareHomeViewController hideBottomWhenPushed];
    [self.shareListViewController.shareHomeViewController.navigationController pushViewController:shareDetailViewController animated:YES];
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return aryHotShare.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ShareCoverFlowCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ShareCoverFlowCell" forIndexPath:indexPath];
    cell.entity = aryHotShare[indexPath.row];
    return cell;
}


@end
