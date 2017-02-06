//
//  RewardView.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 5/7/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShareDetailViewController;
typedef NS_ENUM(NSInteger,RewardViewType)
{
    RewardViewIS,
    RewardViewNO,
};
@interface RewardView : UIView<UIGestureRecognizerDelegate>

@property (nonatomic, assign) RewardViewType statusType;/** <#注释#> */
@property(nonatomic,strong)UIView *visualEffectView;//毛玻璃效果
@property(nonatomic,strong)UIImageView *imgViewText;

@property(nonatomic) NSInteger mainTabType;
@property(nonatomic) BOOL bShow;    //是否已经显示本视图

//打赏积分1
@property(nonatomic,strong)UIView *viewFirst;
@property(nonatomic,strong)UIImageView *imgViewFirst;
@property(nonatomic,strong)UILabel *lblFirst;
@property(nonatomic,strong)UIButton *btnFirst;

//打赏积分2
@property(nonatomic,strong)UIView *viewSecond;
@property(nonatomic,strong)UIImageView *imgViewSecond;
@property(nonatomic,strong)UILabel *lblSecond;
@property(nonatomic,strong)UIButton *btnSecond;

//打赏积分3
@property(nonatomic,strong)UIView *viewThird;
@property(nonatomic,strong)UIImageView *imgViewThird;
@property(nonatomic,strong)UILabel *lblThird;
@property(nonatomic,strong)UIButton *btnThird;




@property (nonatomic, strong) NSString *stringID;/** <#注释#> */


@property(nonatomic,weak)ShareDetailViewController *homeViewController;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)beginningAnimation;
- (void)closeView:(BOOL)bAnimation;

@end
