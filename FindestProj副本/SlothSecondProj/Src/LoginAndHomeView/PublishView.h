//
//  PublishView.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 5/7/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HomeViewController;

@interface PublishView : UIView<UIGestureRecognizerDelegate>

@property(nonatomic,strong)UIView *visualEffectView;//毛玻璃效果
@property(nonatomic,strong)UIImageView *imgViewText;

@property(nonatomic,weak)UIButton *btnHomePop;  //主界面加按钮

@property(nonatomic) NSInteger mainTabType;
@property(nonatomic) BOOL bShow;    //是否已经显示本视图

//分享
@property(nonatomic,strong)UIView *viewShare;
@property(nonatomic,strong)UIImageView *imgViewShare;
@property(nonatomic,strong)UILabel *lblShare;
@property(nonatomic,strong)UIButton *btnShare;

//投票
@property(nonatomic,strong)UIView *viewVote;
@property(nonatomic,strong)UIImageView *imgViewVote;
@property(nonatomic,strong)UILabel *lblVote;
@property(nonatomic,strong)UIButton *btnVote;

//问答
@property(nonatomic,strong)UIView *viewQA;
@property(nonatomic,strong)UIImageView *imgViewQA;
@property(nonatomic,strong)UILabel *lblQA;
@property(nonatomic,strong)UIButton *btnQA;


@property(nonatomic,weak)HomeViewController *homeViewController;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)beginningAnimation;
- (void)closeView:(BOOL)bAnimation;

@end
