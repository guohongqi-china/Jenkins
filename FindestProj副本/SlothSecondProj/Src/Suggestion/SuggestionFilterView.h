//
//  SuggestionFilterView.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/2/29.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropDownDataVo.h"

@protocol SuggestionFilterViewDelegate <NSObject>

- (void)completedChooseState:(DropDownDataVo *)stateData department:(DropDownDataVo *)departmentData;
- (void)cancelChooseFilter;

@end

@interface SuggestionFilterView : NSObject

@property (strong, nonatomic) IBOutlet UIView *view;
@property (nonatomic,weak) id<SuggestionFilterViewDelegate> delegate;
@property (nonatomic) BOOL bShow;       //是否显示

- (instancetype)initWithFrame:(CGRect)frame state:(NSArray*)aryStateData department:(NSArray*)aryDepartmentData;
- (void)refreshViewState:(DropDownDataVo *)stateData department:(DropDownDataVo *)departmentData;

- (void)showWithAnimation;
- (void)cancelChooseAnimated:(BOOL)animated;

@end
