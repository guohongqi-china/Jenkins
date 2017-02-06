//
//  DropDownListView.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/2/27.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuVo.h"

@protocol DropDownListViewDelegate <NSObject>

- (void)completedChooseMenu:(MenuVo *)menuVo;
- (void)cancelChooseMenu;

@end

@interface DropDownListView : UIView

@property (nonatomic,weak) id<DropDownListViewDelegate> delegate;
@property (nonatomic) BOOL bShow;       //是否显示

- (instancetype)initWithFrame:(CGRect)frame menu:(NSArray*)aryData;

- (void)showWithAnimation;
- (void)cancelChooseAnimated:(BOOL)animated;

@end
