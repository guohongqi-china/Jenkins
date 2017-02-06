//
//  HMWaterflowLayout.h
//  CustomWaterFlow
//
//  Created by DYS on 15/12/12.
//  Copyright © 2015年 DYS. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HMWaterflowLayout;

@protocol HMWaterflowLayoutDelegate <NSObject>
- (CGFloat)waterflowLayout:(HMWaterflowLayout *)waterflowLayout heightForWidth:(CGFloat)width atIndexPath:(NSIndexPath *)indexPath;
@end


@interface HMWaterflowLayout : UICollectionViewFlowLayout


@property (nonatomic, assign) NSInteger  colCount;
@property (nonatomic, weak) id<HMWaterflowLayoutDelegate> delegate;

@end
