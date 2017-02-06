//
//  RewardView.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 5/7/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import "RewardView.h"
#import "ShareDetailViewController.h"
#import "ResizeImage.h"
#import "CommonNavigationController.h"
#import "UIViewExt.h"
#import "alertView.h"
#define P_CIRCLE_D 48       //圆的直径
#define DIAMETER_OFFSET 10  //直径偏移量
#define DIAMETER_MULTIPLE 1.5  //直径放大倍数
#define PUBLISH_X_OFFSET ((kScreenWidth-320)/2)     //针对多屏幕的适配

@interface RewardView ()
{
    UITapGestureRecognizer *gestureTapBK;
    alertView *viewContainer22;
    UIView *viewContainer;

    UIView *viewLine1;
    UIView *viewLine2;
    
    CGFloat fTabWdith;
    CGSize sizeBound;
}

@end

@implementation RewardView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFY_REFRESH_SKIN object:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        sizeBound = frame.size;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        self.bShow = NO;
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removewAction) name:@"removewAction" object:nil];
    }
    return self;
}
- (void)removewAction{
    [self closeView:YES];
}
- (void)setStringID:(NSString *)stringID{
    _stringID = stringID;
    [self initView];
}
-(void)initView
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshSkin) name:NOTIFY_REFRESH_SKIN object:nil];
    
    fTabWdith = kScreenWidth/3;
    
    self.visualEffectView = [[UIView alloc] init];
    self.visualEffectView.backgroundColor = COLOR(0, 0, 0, 0.4);
    self.visualEffectView.frame = CGRectMake(0, 0, kScreenWidth, sizeBound.height);
    [self addSubview:self.visualEffectView];
    
    gestureTapBK = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBackground:)];
    gestureTapBK.numberOfTapsRequired = 1;
    gestureTapBK.delegate = self;
    [self.visualEffectView addGestureRecognizer:gestureTapBK];
    if (_statusType == RewardViewIS) {
        viewContainer22  = [[NSBundle mainBundle]loadNibNamed:@"alertView" owner:nil options:nil].lastObject;
        viewContainer22.frame = CGRectMake(0, sizeBound.height, kScreenWidth, 250);
        viewContainer22.backgroundColor = [SkinManage colorNamed:@"PublishView_BK_Color"];
        [self addSubview:viewContainer22];

    }else{
        viewContainer = [[UIView alloc]initWithFrame:CGRectMake(0, sizeBound.height, kScreenWidth, 118)];
        viewContainer.backgroundColor = [SkinManage colorNamed:@"PublishView_BK_Color"];
        [self addSubview:viewContainer];

    }
       //10 积分
    self.viewFirst = [[UIView alloc]initWithFrame:CGRectMake(0, 0, fTabWdith, 118)];
    
    self.imgViewFirst = [[UIImageView alloc]initWithFrame:CGRectMake((self.viewFirst.width-48)/2, 21, 48, 48)];
    self.imgViewFirst.image = [UIImage imageNamed:@"reward_10"];
    [self.viewFirst addSubview:self.imgViewFirst];
    
    self.lblFirst = [[UILabel alloc]initWithFrame:CGRectMake(0, self.imgViewFirst.bottom+12, self.viewFirst.width, 16)];
    self.lblFirst.backgroundColor = [UIColor clearColor];
    self.lblFirst.text = @"10 积分";
    self.lblFirst.textAlignment = NSTextAlignmentCenter;
    self.lblFirst.textColor = [SkinManage colorNamed:@"PublishView_Title_Color"];
    self.lblFirst.font = [UIFont systemFontOfSize:12];
    [self.viewFirst addSubview:self.lblFirst];
    
    self.btnFirst = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnFirst.frame = CGRectMake(0, 0, self.viewFirst.width, self.viewFirst.height);
    [self.btnFirst addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    [self.btnFirst addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnFirst addTarget:self action:@selector(touchCancel:) forControlEvents:UIControlEventTouchUpOutside];
    [self.btnFirst addTarget:self action:@selector(touchCancel:) forControlEvents:UIControlEventTouchDragOutside];
    [self.viewFirst addSubview:self.btnFirst];
    
    viewLine1 = [[UIView alloc]initWithFrame:CGRectMake(self.viewFirst.right, 14, 0.5, 90)];
    viewLine1.backgroundColor = [SkinManage colorNamed:@"PublishView_Sep_Color"];
    
    //20 积分
    self.viewSecond = [[UIView alloc]initWithFrame:CGRectMake(self.viewFirst.right, 0, fTabWdith, 118)];
    
    self.imgViewSecond = [[UIImageView alloc]initWithFrame:CGRectMake((self.viewSecond.width-48)/2, 21, 48, 48)];
    self.imgViewSecond.image = [UIImage imageNamed:@"reward_20"];
    [self.viewSecond addSubview:self.imgViewSecond];
    
    self.lblSecond = [[UILabel alloc]initWithFrame:CGRectMake(0, self.imgViewSecond.bottom+12, self.viewSecond.width, 16)];
    self.lblSecond.backgroundColor = [UIColor clearColor];
    self.lblSecond.text = @"20 积分";
    self.lblSecond.textAlignment = NSTextAlignmentCenter;
    self.lblSecond.textColor = [SkinManage colorNamed:@"PublishView_Title_Color"];
    self.lblSecond.font = [UIFont systemFontOfSize:12];
    [self.viewSecond addSubview:self.lblSecond];
    
    self.btnSecond = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnSecond.frame = CGRectMake(0, 0, self.viewSecond.width, self.viewSecond.height);
    [self.btnSecond addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    [self.btnSecond addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnSecond addTarget:self action:@selector(touchCancel:) forControlEvents:UIControlEventTouchUpOutside];
    [self.btnSecond addTarget:self action:@selector(touchCancel:) forControlEvents:UIControlEventTouchDragOutside];
    [self.viewSecond addSubview:self.btnSecond];
    
    viewLine2 = [[UIView alloc]initWithFrame:CGRectMake(self.viewSecond.right, 14, 0.5, 90)];
    viewLine2.backgroundColor = [SkinManage colorNamed:@"PublishView_Sep_Color"];
//    [viewContainer22 addSubview:viewLine2];
    
    //30 积分
    self.viewThird = [[UIView alloc]initWithFrame:CGRectMake(self.viewSecond.right, 0, fTabWdith, 118)];
//    [viewContainer22 addSubview:self.viewThird];
    if (_statusType != RewardViewIS) {
       [viewContainer addSubview:self.viewFirst];
        [viewContainer addSubview:viewLine1];
        [viewContainer addSubview:self.viewSecond];
        [viewContainer addSubview:viewLine2];
        [viewContainer addSubview:self.viewThird];
    }
    
    self.imgViewThird = [[UIImageView alloc]initWithFrame:CGRectMake((self.viewThird.width-48)/2, 21, 48, 48)];
    self.imgViewThird.image = [UIImage imageNamed:@"reward_50"];
    [self.viewThird addSubview:self.imgViewThird];
    
    self.lblThird = [[UILabel alloc]initWithFrame:CGRectMake(0, self.imgViewThird.bottom+12, self.viewThird.width, 16)];
    self.lblThird.backgroundColor = [UIColor clearColor];
    self.lblThird.text = @"50 积分";
    self.lblThird.textAlignment = NSTextAlignmentCenter;
    self.lblThird.textColor = [SkinManage colorNamed:@"PublishView_Title_Color"];
    self.lblThird.font = [UIFont systemFontOfSize:12];
    [self.viewThird addSubview:self.lblThird];
    
    self.btnThird = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnThird.frame = CGRectMake(0, 0, self.viewThird.width, self.viewThird.height);
    [self.btnThird addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    [self.btnThird addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnThird addTarget:self action:@selector(touchCancel:) forControlEvents:UIControlEventTouchUpOutside];
    [self.btnThird addTarget:self action:@selector(touchCancel:) forControlEvents:UIControlEventTouchDragOutside];
    [self.viewThird addSubview:self.btnThird];
}

- (void)refreshSkin
{
    viewContainer22.backgroundColor = [SkinManage colorNamed:@"PublishView_BK_Color"];
    viewContainer.backgroundColor = [SkinManage colorNamed:@"PublishView_BK_Color"];

    self.lblSecond.textColor = [SkinManage colorNamed:@"PublishView_Title_Color"];
    viewLine1.backgroundColor = [SkinManage colorNamed:@"PublishView_Sep_Color"];
    self.lblFirst.textColor = [SkinManage colorNamed:@"PublishView_Title_Color"];
    viewLine2.backgroundColor = [SkinManage colorNamed:@"PublishView_Sep_Color"];
    self.lblThird.textColor = [SkinManage colorNamed:@"PublishView_Title_Color"];
}

//初始化参数
- (void)resetView
{
    self.alpha = 1;
    
    viewContainer22.frame = CGRectMake(0, sizeBound.height, kScreenWidth, 250);
    viewContainer.frame = CGRectMake(0, sizeBound.height, kScreenWidth, 118);

    //image view
    self.imgViewFirst.frame = CGRectMake((self.viewFirst.width-48)/2, 21, 48, 48);
    self.imgViewFirst.alpha = 1;
    self.imgViewSecond.frame = CGRectMake((self.viewSecond.width-48)/2, 21, 48, 48);
    self.imgViewSecond.alpha = 1;
    self.imgViewThird.frame = CGRectMake((self.viewThird.width-48)/2, 21, 48, 48);
    self.imgViewThird.alpha = 1;
    
    self.lblFirst.alpha = 1.0;
    self.lblThird.alpha = 1.0;
    self.lblSecond.alpha = 1.0;
}

//开场动画
- (void)beginningAnimation
{
    [self resetView];
    
    if (_statusType == RewardViewIS) {
        viewContainer22.strId = _stringID  ;
        //container
        viewContainer22.frame = CGRectMake(0, kScreenHeight-49, kScreenWidth, 250);
        [UIView animateWithDuration:0.2 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
            viewContainer22.frame = CGRectMake(0, kScreenHeight-49-250, kScreenWidth, 250);
        } completion:nil];
    }else{
        viewContainer.frame = CGRectMake(0, kScreenHeight-49, kScreenWidth, 118);
        [UIView animateWithDuration:0.2 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
            viewContainer.frame = CGRectMake(0, kScreenHeight-49-118, kScreenWidth, 118);
        } completion:nil];

    }
    
    
}

//关闭视图
-(void)closeView:(BOOL)bAnimation
{
    [AppDelegate getSlothAppDelegate].currentPageName = OtherPage;
    self.bShow = NO;
    
    if (bAnimation)
    {
        if (_statusType == RewardViewIS) {
            //需要结束动画
            viewContainer22.frame = CGRectMake(0, kScreenHeight-49-250, kScreenWidth, 250);
            [UIView animateWithDuration:0.2 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
                viewContainer22.frame = CGRectMake(0, kScreenHeight-49, kScreenWidth, 250);
            } completion:^(BOOL finished){
                self.alpha = 1.0;
                [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    self.alpha = 0.0;
                } completion:^(BOOL finished){
                    [self removeFromSuperview];
                    [self resetView];
                    //                [self.homeViewController selectTabByType:(MainTabType)self.mainTabType];
                }];
            }];

        }else{
            //需要结束动画
            viewContainer.frame = CGRectMake(0, kScreenHeight-49-118, kScreenWidth, 118);
            [UIView animateWithDuration:0.2 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
                viewContainer.frame = CGRectMake(0, kScreenHeight-49, kScreenWidth, 118);
            } completion:^(BOOL finished){
                self.alpha = 1.0;
                [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    self.alpha = 0.0;
                } completion:^(BOOL finished){
                    [self removeFromSuperview];
                    [self resetView];
                    //                [self.homeViewController selectTabByType:(MainTabType)self.mainTabType];
                }];
            }];

        }
        }
    else
    {
        //不需要结束动画
        [self removeFromSuperview];
        [self resetView];
//        [self.homeViewController selectTabByType:(MainTabType)self.mainTabType];
    }
}

//轻触背景，close view
-(void)tapBackground:(UITapGestureRecognizer*)gesture
{
    [self closeView:YES];
}

//touchDown 放大ImageView
-(void)touchDown:(UIButton*)sender
{
    if(sender == self.btnFirst)
    {
        CGRect rc =  self.imgViewFirst.frame;
        CGPoint pt = self.imgViewFirst.center;
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.imgViewFirst.frame = CGRectMake(rc.origin.x-DIAMETER_OFFSET/2, rc.origin.y-DIAMETER_OFFSET/2, P_CIRCLE_D+DIAMETER_OFFSET, P_CIRCLE_D+DIAMETER_OFFSET);
            self.imgViewFirst.center = pt;
        } completion:nil];
    }
    else if(sender == self.btnSecond)
    {
        CGRect rc =  self.imgViewSecond.frame;
        CGPoint pt = self.imgViewSecond.center;
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.imgViewSecond.frame = CGRectMake(rc.origin.x-DIAMETER_OFFSET/2, rc.origin.y-DIAMETER_OFFSET/2, P_CIRCLE_D+DIAMETER_OFFSET, P_CIRCLE_D+DIAMETER_OFFSET);
            self.imgViewSecond.center = pt;
        } completion:nil];
    }
    else if(sender == self.btnThird)
    {
        CGRect rc =  self.imgViewThird.frame;
        CGPoint pt = self.imgViewThird.center;
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.imgViewThird.frame = CGRectMake(rc.origin.x-DIAMETER_OFFSET/2, rc.origin.y-DIAMETER_OFFSET/2, P_CIRCLE_D+DIAMETER_OFFSET, P_CIRCLE_D+DIAMETER_OFFSET);
            self.imgViewThird.center = pt;
        } completion:nil];
    }
}

-(void)tapButtonAnimation:(UIButton*)sender
{
    //分享
    if(sender == self.btnFirst)
    {
        //放大
        self.imgViewFirst.frame = CGRectMoveToCenter(CGRectMake(0, 0, P_CIRCLE_D*DIAMETER_MULTIPLE, P_CIRCLE_D*DIAMETER_MULTIPLE),self.imgViewFirst.center);
    }
    else
    {
        //缩小
        self.imgViewFirst.frame = CGRectMoveToCenter(CGRectMake(0, 0, P_CIRCLE_D/4, P_CIRCLE_D/4),self.imgViewFirst.center);
    }
    
    //问答
    if(sender == self.btnThird)
    {
        //放大
        self.imgViewThird.frame = CGRectMoveToCenter(CGRectMake(0, 0, P_CIRCLE_D*DIAMETER_MULTIPLE, P_CIRCLE_D*DIAMETER_MULTIPLE),self.imgViewThird.center);
    }
    else
    {
        //缩小
        self.imgViewThird.frame = CGRectMoveToCenter(CGRectMake(0, 0, P_CIRCLE_D/4, P_CIRCLE_D/4),self.imgViewThird.center);
    }
    
    //投票
    if(sender == self.btnSecond)
    {
        //放大
        self.imgViewSecond.frame = CGRectMoveToCenter(CGRectMake(0, 0, P_CIRCLE_D*DIAMETER_MULTIPLE, P_CIRCLE_D*DIAMETER_MULTIPLE),self.imgViewSecond.center);
    }
    else
    {
        //缩小
        self.imgViewSecond.frame = CGRectMoveToCenter(CGRectMake(0, 0, P_CIRCLE_D/4, P_CIRCLE_D/4),self.imgViewSecond.center);
    }
    
    self.imgViewFirst.alpha = 0;
    self.lblFirst.alpha = 0;
    
    self.imgViewThird.alpha = 0;
    self.lblThird.alpha = 0;
    
    self.imgViewSecond.alpha = 0;
    self.lblSecond.alpha = 0;
}

//触发跳转操作
-(void)touchUpInside:(UIButton*)sender
{
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self tapButtonAnimation:sender];
    }  completion:^(BOOL finished){
        if(sender == self.btnFirst)
        {
            [self doReward:@"10"];
        }
        else if(sender == self.btnSecond)
        {
            [self doReward:@"20"];
        }
        else if(sender == self.btnThird)
        {
            [self doReward:@"50"];
        }
    }];
}

//取消发表操作
-(void)touchCancel:(UIButton*)sender
{
    if(sender == self.btnFirst)
    {
        CGRect rc =  self.imgViewFirst.frame;
        CGPoint pt = self.imgViewFirst.center;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.imgViewFirst.frame = CGRectMake(rc.origin.x+5, rc.origin.y+5, P_CIRCLE_D, P_CIRCLE_D);
            self.imgViewFirst.center = pt;
        } completion:nil];
    }
    else if(sender == self.btnThird)
    {
        CGRect rc =  self.imgViewThird.frame;
        CGPoint pt = self.imgViewThird.center;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.imgViewThird.frame = CGRectMake(rc.origin.x+5, rc.origin.y+5, P_CIRCLE_D, P_CIRCLE_D);
            self.imgViewThird.center = pt;
        } completion:nil];
    }
    else if(sender == self.btnSecond)
    {
        CGRect rc =  self.imgViewSecond.frame;
        CGPoint pt = self.imgViewSecond.center;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.imgViewSecond.frame = CGRectMake(rc.origin.x+5, rc.origin.y+5, P_CIRCLE_D, P_CIRCLE_D);
            self.imgViewSecond.center = pt;
        } completion:nil];
    }
}

//打赏操作
- (void)doReward:(NSString *)strIntegral
{
    [Common showProgressView:nil view:self.homeViewController.view modal:NO];
    [ServerProvider integrationOperation:self.homeViewController.m_blogVo.strCreateBy intergral:strIntegral blogId:self.homeViewController.m_blogVo.streamId remark:nil result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.homeViewController.view];
        if (retInfo.bSuccess)
        {
            [Common bubbleTip:@"打赏成功" andView:self.homeViewController.view];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
        [self closeView:YES];
    }];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint touchPoint = [touch locationInView:self.visualEffectView];
    BOOL bRes = CGRectContainsPoint(self.viewFirst.frame, touchPoint) || CGRectContainsPoint(self.viewSecond.frame, touchPoint) || CGRectContainsPoint(self.viewThird.frame, touchPoint);
    return !bRes;
}

@end
