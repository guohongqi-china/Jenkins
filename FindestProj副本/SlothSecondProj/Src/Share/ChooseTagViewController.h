//
//  ChooseTagViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 12/24/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import "QNavigationViewController.h"

@protocol ChooseTagViewControllerDelegate <NSObject>
@optional
-(void)completeChooseTagAction:(NSMutableArray*)aryChoosedTag;
@end

@interface ChooseTagViewController : QNavigationViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,weak) id<ChooseTagViewControllerDelegate> delegate;
@property(nonatomic,strong) NSMutableArray *aryTag;
@property(nonatomic,strong) UITableView *tableViewTag;

-(void)initBindChoosedData:(NSMutableArray *)aryChoosedTag;

@end
