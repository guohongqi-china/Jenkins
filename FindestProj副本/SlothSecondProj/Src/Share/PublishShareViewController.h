//
//  PublishShareViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/13.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonViewController.h"
#import "PublishVo.h"

@class HomeViewController;

@interface PublishShareViewController : CommonViewController

@property (nonatomic, weak) HomeViewController *viewControllerParent;
@property (nonatomic) NSInteger nPublicType;        //0:分享,1:投票,2:问答

//add by fjz
@property (copy, nonatomic) NSString *linkStr;      //复制的链接


@end
