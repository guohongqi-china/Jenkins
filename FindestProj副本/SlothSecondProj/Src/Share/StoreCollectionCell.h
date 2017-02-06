//
//  StoreCollectionCell.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/5.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlogVo.h"
#import "UIImageView+WebCache.h"

@protocol StoreCollectionCellDelegate <NSObject>

- (void)cancelStoreCollection:(BlogVo *)blogVo;

@end

@interface StoreCollectionCell : UICollectionViewCell

@property (nonatomic) BOOL isHideClearButton;
@property (nonatomic, strong) BlogVo *entity;
@property (nonatomic, weak) id<StoreCollectionCellDelegate> delegate;

@end
