//
//  ShareCoverFlowCell.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/16.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlogVo.h"

@interface ShareCoverFlowCell : UICollectionViewCell

@property (nonatomic, strong) BlogVo *entity;
@property (weak, nonatomic) IBOutlet UIView *viewCover;

@end
