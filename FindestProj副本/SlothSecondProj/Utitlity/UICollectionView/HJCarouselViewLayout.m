//
//  HJCarouselViewLayout.m
//  HJCarouselDemo
//
//  Created by haijiao on 15/8/20.
//  Copyright (c) 2015年 olinone. All rights reserved.
//

#import "HJCarouselViewLayout.h"
#import "ShareCoverFlowCell.h"

#define INTERSPACEPARAM  0.145

@interface HJCarouselViewLayout () {
    CGFloat _viewWidth;
    CGFloat _itemWidth;
}

@property (nonatomic) HJCarouselAnim carouselAnim;

@end

@implementation HJCarouselViewLayout

- (instancetype)initWithAnim:(HJCarouselAnim)anim
{
    if (self = [super init])
    {
        self.carouselAnim = anim;
    }
    return self;
}

//一般在该方法中设定一些必要的layout的结构和初始需要的参数等。
- (void)prepareLayout
{
    [super prepareLayout];
    if (self.visibleCount < 1)
    {
        self.visibleCount = 5;
    }
    
    _viewWidth = CGRectGetWidth(self.collectionView.frame);
    _itemWidth = self.itemSize.width;
    self.collectionView.contentInset = UIEdgeInsetsMake(0, (_viewWidth - _itemWidth) / 2, 0, (_viewWidth - _itemWidth) / 2);
}

#pragma - mark UISubclassingHooks 四个必须重写的方法
//1.返回collectionView的内容的尺寸(应该是所有内容所占的尺寸)
- (CGSize)collectionViewContentSize
{
    NSInteger cellCount = [self.collectionView numberOfItemsInSection:0];
    return CGSizeMake(cellCount * _itemWidth , CGRectGetHeight(self.collectionView.frame));
}

//2.返回rect中的所有的元素的布局属性,返回的是包含UICollectionViewLayoutAttributes的NSArray
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSInteger cellCount = [self.collectionView numberOfItemsInSection:0];
    CGFloat centerX = self.collectionView.contentOffset.x + _viewWidth / 2;
    NSInteger index = centerX / _itemWidth;
    NSInteger count = (self.visibleCount - 1) / 2;
    NSInteger minIndex = MAX(0, (index - count));
    NSInteger maxIndex = MIN((cellCount - 1), (index + count));
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = minIndex; i <= maxIndex; i++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
        [array addObject:attributes];
    }
    return array;
}

//3.返回对应于indexPath的位置的cell的布局属性
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    //设置Item的size
    attributes.size = self.itemSize;
    
    CGFloat fSuperCenterX = self.collectionView.contentOffset.x + _viewWidth / 2;   //当前父CollectionView的可见frame的center'X
    CGFloat fItemCenterX = _itemWidth * indexPath.row + _itemWidth / 2;     //当前Item中心的X值
    CGFloat fOffset = ABS(fItemCenterX - fSuperCenterX);
    CGFloat fMaxOffset = 2*_itemSize.width;
    
    //设置当前View的层次关系,使用负数原理，离中心越远的item，层次越排在下层
    attributes.zIndex = -ABS(fItemCenterX - fSuperCenterX);
    
    //设置当前View的alpha值（离中心越远的item，alpha越低）
    if (fOffset > fMaxOffset)
    {
        //超过最大有效距离
        attributes.alpha = 0.0;
    }
    else
    {
        attributes.alpha = (1-fOffset*1.0/fMaxOffset)*1.0; //公式：(1-fOffset/fMaxOffset)*1.0
    }
    
//    ShareCoverFlowCell *cell = (ShareCoverFlowCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
//    if (fOffset > fMaxOffset)
//    {
//        //超过最大有效距离
//        attributes.alpha = 0.0;
//    }
//    else
//    {
//        attributes.alpha = 1.0;
//        //cell.viewCover.alpha = (fOffset*1.0/fMaxOffset)*1.0; //公式：(1-fOffset/fMaxOffset)*1.0
//        cell.viewCover.backgroundColor = COLOR(0, 0, 0, (fOffset*1.0/fMaxOffset)*1.0); //公式：(1-fOffset/fMaxOffset)*1.0
//    }
    
    //1.旋转木马的效果
    //设置过渡效果
    CGFloat delta = fSuperCenterX - fItemCenterX;
    CGFloat ratio =  - delta / (_itemWidth * 2);//比率
    CGFloat scale = 1 - ABS(delta) / (_itemWidth * 12.0) * cos(ratio * M_PI_4);//缩放比例
    attributes.transform = CGAffineTransformMakeScale(scale, scale);
    
    //设置中心位置
    CGFloat centerX = fItemCenterX;
    centerX = fSuperCenterX + sin(ratio * M_PI_2) * _itemWidth * INTERSPACEPARAM;
    attributes.center = CGPointMake(centerX, CGRectGetHeight(self.collectionView.frame) / 2);
    
//    //2.cover flow 效果
//    CGFloat delta = fSuperCenterX - fItemCenterX;
//    CGFloat ratio =  - delta / (_itemWidth * 5);//比率
//
//    CATransform3D transform = CATransform3DIdentity;
//    transform.m34 = 1.0/200.0f;
//    //CATransform3D CATransform3DRotate (CATransform3D t, CGFloat angle,CGFloat x, CGFloat y, CGFloat z)
//    transform = CATransform3DRotate(transform, ratio * M_PI_4, 0, 1, 0);
//    attributes.transform3D = transform;
//
//    CGFloat centerX = fItemCenterX;
//    attributes.center = CGPointMake(centerX, CGRectGetHeight(self.collectionView.frame)/ 2);
    
    return attributes;
}

//4.当边界发生改变时，是否应该刷新布局。如果YES则在边界变化（一般是scroll到其他地方）时，将重新计算需要的布局信息。
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds
{
    return YES;
}

//proposedContentOffset是没有对齐到网格时本来应该停下的位置【类似于scrollview的scrollViewWillEndDragging】
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGFloat index = roundf((proposedContentOffset.x + _viewWidth / 2 - _itemWidth / 2) / _itemWidth);
    proposedContentOffset.x = _itemWidth * index + _itemWidth / 2 - _viewWidth / 2;
    return proposedContentOffset;
}

@end
