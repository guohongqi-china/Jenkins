//
//  ShareCoverFlowView.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/16.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShareListViewController;
@interface ShareCoverFlowView : UIView

@property (nonatomic, weak) ShareListViewController *shareListViewController;

- (void)refreshSkin;

@end
