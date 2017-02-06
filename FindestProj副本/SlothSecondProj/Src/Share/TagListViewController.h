//
//  TagListViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/14.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonViewController.h"

@protocol TagListViewDelegate <NSObject>
@optional
-(void)completeChooseTagAction:(NSMutableArray*)aryChoosedTag;
@end

@interface TagListViewController : CommonViewController

@property(nonatomic,weak) id<TagListViewDelegate> delegate;

-(void)initBindChoosedData:(NSMutableArray *)aryChoosedTag;

@end
