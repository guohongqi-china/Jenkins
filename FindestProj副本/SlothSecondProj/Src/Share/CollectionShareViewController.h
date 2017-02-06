//
//  CollectionShareViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/2.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ShareHomeViewController;

@interface CollectionShareViewController : UIViewController

@property (nonatomic, weak)ShareHomeViewController *shareHomeViewController;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewStore;

@end
