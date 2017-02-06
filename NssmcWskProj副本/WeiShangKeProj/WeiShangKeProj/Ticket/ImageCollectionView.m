//
//  ImageCollectionView.m
//  NssmcWskProj
//
//  Created by MacBook on 16/5/24.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "ImageCollectionView.h"
#import "ImageViewForPickImage.h"
#import <UIImageView+WebCache.h>
#import "topModel.h"

@interface ImageCollectionView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@end
@implementation ImageCollectionView

- (NSMutableArray *)itemsArrayt{
    if (_itemsArrayt == nil) {
        _itemsArrayt = [[NSMutableArray alloc]init];
        
    }
    return _itemsArrayt;
}
- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        self.dataSource = self;
        self.delegate = self;
        //collectionCell的注册
        [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"myheheIdentifier"];
        self.showsHorizontalScrollIndicator = NO;
    }
    return self;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _itemsArrayt.count;
}
//构建单元格
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    topModel *modelf = _itemsArrayt[indexPath.row];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"myheheIdentifier" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor grayColor];
    UIImageView *IAMGEView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, (kScreenWidth - 20)/3,(kScreenWidth - 20)/3)];
    [IAMGEView sd_setImageWithURL:[NSURL URLWithString:modelf.path] placeholderImage:[UIImage imageNamed:@"picf"]];
    IAMGEView.tag = 1000 + indexPath.row;
    [cell.contentView addSubview:IAMGEView];
        return cell;
    
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    ImageViewForPickImage *imageView = [[ImageViewForPickImage alloc]init];
    imageView.tagImage = indexPath.row;
    NSMutableArray *imagearr = [NSMutableArray array];
    for (topModel *model in _itemsArrayt) {
        [imagearr addObject:model.path];
    }
    imageView.itemsArray = [imagearr copy];
   
}








@end
