//
//  PublishView.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 5/7/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import "PublishView.h"
#import "HomeViewController.h"
#import "AddSuggestionViewController.h"
#import "PublishVoteViewController.h"
#import "PublishMessageViewController.h"
#import "PublishScheduleViewController.h"
#import "ResizeImage.h"
#import "CommonNavigationController.h"
#import "UIViewExt.h"
#import "PublishShareViewController.h"
#import "PublishQuestionViewController.h"

#define P_CIRCLE_D 48       //圆的直径
#define DIAMETER_OFFSET 10  //直径偏移量
#define DIAMETER_MULTIPLE 1.5  //直径放大倍数
#define PUBLISH_X_OFFSET ((kScreenWidth-320)/2)     //针对多屏幕的适配

@interface PublishView ()
{
    UITapGestureRecognizer *gestureTapBK;
    UIView *viewContainer;
    UIView *viewLine1;
    UIView *viewLine2;
    
    CGFloat fTabWdith;
    CGSize sizeBound;
}

@end

@implementation PublishView

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
        [self initView];
    }
    return self;
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
    
    viewContainer = [[UIView alloc]initWithFrame:CGRectMake(0, sizeBound.height, kScreenWidth, 118)];
    viewContainer.backgroundColor = [SkinManage colorNamed:@"PublishView_BK_Color"];
    [self addSubview:viewContainer];
    
    //分享
    self.viewShare = [[UIView alloc]initWithFrame:CGRectMake(0, 0, fTabWdith, 118)];
    [viewContainer addSubview:self.viewShare];
    
    self.imgViewShare = [[UIImageView alloc]initWithFrame:CGRectMake((self.viewShare.width-48)/2, 21, 48, 48)];
    self.imgViewShare.image = [UIImage imageNamed:@"btn_public_share"];
    [self.viewShare addSubview:self.imgViewShare];
    
    self.lblShare = [[UILabel alloc]initWithFrame:CGRectMake(0, self.imgViewShare.bottom+12, self.viewShare.width, 16)];
    self.lblShare.backgroundColor = [UIColor clearColor];
    self.lblShare.text = @"分享";
    self.lblShare.textAlignment = NSTextAlignmentCenter;
    self.lblShare.textColor = [SkinManage colorNamed:@"PublishView_Title_Color"];
    self.lblShare.font = [UIFont systemFontOfSize:12];
    [self.viewShare addSubview:self.lblShare];
    
    self.btnShare = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnShare.frame = CGRectMake(0, 0, self.viewShare.width, self.viewShare.height);
    [self.btnShare addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    [self.btnShare addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnShare addTarget:self action:@selector(touchCancel:) forControlEvents:UIControlEventTouchUpOutside];
    [self.btnShare addTarget:self action:@selector(touchCancel:) forControlEvents:UIControlEventTouchDragOutside];
    [self.viewShare addSubview:self.btnShare];
    
    viewLine1 = [[UIView alloc]initWithFrame:CGRectMake(self.viewShare.right, 14, 0.5, 90)];
    viewLine1.backgroundColor = [SkinManage colorNamed:@"PublishView_Sep_Color"];
    [viewContainer addSubview:viewLine1];
    
    //投票
    self.viewVote = [[UIView alloc]initWithFrame:CGRectMake(self.viewShare.right, 0, fTabWdith, 118)];
    [viewContainer addSubview:self.viewVote];
    
    self.imgViewVote = [[UIImageView alloc]initWithFrame:CGRectMake((self.viewVote.width-48)/2, 21, 48, 48)];
    self.imgViewVote.image = [UIImage imageNamed:@"btn_public_vote"];
    [self.viewVote addSubview:self.imgViewVote];
    
    self.lblVote = [[UILabel alloc]initWithFrame:CGRectMake(0, self.imgViewVote.bottom+12, self.viewVote.width, 16)];
    self.lblVote.backgroundColor = [UIColor clearColor];
    self.lblVote.text = @"投票";
    self.lblVote.textAlignment = NSTextAlignmentCenter;
    self.lblVote.textColor = [SkinManage colorNamed:@"PublishView_Title_Color"];
    self.lblVote.font = [UIFont systemFontOfSize:12];
    [self.viewVote addSubview:self.lblVote];
    
    self.btnVote = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnVote.frame = CGRectMake(0, 0, self.viewVote.width, self.viewVote.height);
    [self.btnVote addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    [self.btnVote addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnVote addTarget:self action:@selector(touchCancel:) forControlEvents:UIControlEventTouchUpOutside];
    [self.btnVote addTarget:self action:@selector(touchCancel:) forControlEvents:UIControlEventTouchDragOutside];
    [self.viewVote addSubview:self.btnVote];
    
    viewLine2 = [[UIView alloc]initWithFrame:CGRectMake(self.viewVote.right, 14, 0.5, 90)];
    viewLine2.backgroundColor = [SkinManage colorNamed:@"PublishView_Sep_Color"];
    [viewContainer addSubview:viewLine2];
    
    //问答
    self.viewQA = [[UIView alloc]initWithFrame:CGRectMake(self.viewVote.right, 0, fTabWdith, 118)];
    [viewContainer addSubview:self.viewQA];
    
    self.imgViewQA = [[UIImageView alloc]initWithFrame:CGRectMake((self.viewQA.width-48)/2, 21, 48, 48)];
    self.imgViewQA.image = [UIImage imageNamed:@"btn_public_qa"];
    [self.viewQA addSubview:self.imgViewQA];
    
    self.lblQA = [[UILabel alloc]initWithFrame:CGRectMake(0, self.imgViewQA.bottom+12, self.viewQA.width, 16)];
    self.lblQA.backgroundColor = [UIColor clearColor];
    self.lblQA.text = @"问答";
    self.lblQA.textAlignment = NSTextAlignmentCenter;
    self.lblQA.textColor = [SkinManage colorNamed:@"PublishView_Title_Color"];
    self.lblQA.font = [UIFont systemFontOfSize:12];
    [self.viewQA addSubview:self.lblQA];
    
    self.btnQA = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnQA.frame = CGRectMake(0, 0, self.viewQA.width, self.viewQA.height);
    [self.btnQA addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    [self.btnQA addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnQA addTarget:self action:@selector(touchCancel:) forControlEvents:UIControlEventTouchUpOutside];
    [self.btnQA addTarget:self action:@selector(touchCancel:) forControlEvents:UIControlEventTouchDragOutside];
    [self.viewQA addSubview:self.btnQA];
}

- (void)refreshSkin
{
    viewContainer.backgroundColor = [SkinManage colorNamed:@"PublishView_BK_Color"];
    self.lblVote.textColor = [SkinManage colorNamed:@"PublishView_Title_Color"];
    viewLine1.backgroundColor = [SkinManage colorNamed:@"PublishView_Sep_Color"];
    self.lblShare.textColor = [SkinManage colorNamed:@"PublishView_Title_Color"];
    viewLine2.backgroundColor = [SkinManage colorNamed:@"PublishView_Sep_Color"];
    self.lblQA.textColor = [SkinManage colorNamed:@"PublishView_Title_Color"];
    
    [self.btnHomePop setImage:[SkinManage imageNamed:@"tab_item_middle"] forState:UIControlStateNormal];
}

//初始化参数
- (void)resetView
{
    self.alpha = 1;
    
    viewContainer.frame = CGRectMake(0, sizeBound.height, kScreenWidth, 118);
    
    //image view
    self.imgViewShare.frame = CGRectMake((self.viewShare.width-48)/2, 21, 48, 48);
    self.imgViewShare.alpha = 1;
    self.imgViewVote.frame = CGRectMake((self.viewVote.width-48)/2, 21, 48, 48);
    self.imgViewVote.alpha = 1;
    self.imgViewQA.frame = CGRectMake((self.viewQA.width-48)/2, 21, 48, 48);
    self.imgViewQA.alpha = 1;
    
    self.lblShare.alpha = 1.0;
    self.lblQA.alpha = 1.0;
    self.lblVote.alpha = 1.0;
}

//开场动画
- (void)beginningAnimation
{
    [self buttonAnimationWithState:YES];
    [self resetView];
    
    //container
    viewContainer.frame = CGRectMake(0, kScreenHeight-49, kScreenWidth, 118);
    [UIView animateWithDuration:0.2 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        viewContainer.frame = CGRectMake(0, kScreenHeight-49-118, kScreenWidth, 118);
    } completion:nil];
}

//关闭视图
-(void)closeView:(BOOL)bAnimation
{
    [AppDelegate getSlothAppDelegate].currentPageName = OtherPage;
    self.bShow = NO;
    [self buttonAnimationWithState:NO];
    
    if (bAnimation)
    {
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
                [self.homeViewController selectTabByType:(MainTabType)self.mainTabType];
            }];
        }];
    }
    else
    {
        //不需要结束动画
        [self removeFromSuperview];
        [self resetView];
        [self.homeViewController selectTabByType:(MainTabType)self.mainTabType];
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
    if(sender == self.btnShare)
    {
        CGRect rc =  self.imgViewShare.frame;
        CGPoint pt = self.imgViewShare.center;
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.imgViewShare.frame = CGRectMake(rc.origin.x-DIAMETER_OFFSET/2, rc.origin.y-DIAMETER_OFFSET/2, P_CIRCLE_D+DIAMETER_OFFSET, P_CIRCLE_D+DIAMETER_OFFSET);
            self.imgViewShare.center = pt;
        } completion:nil];
    }
    else if(sender == self.btnVote)
    {
        CGRect rc =  self.imgViewVote.frame;
        CGPoint pt = self.imgViewVote.center;
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.imgViewVote.frame = CGRectMake(rc.origin.x-DIAMETER_OFFSET/2, rc.origin.y-DIAMETER_OFFSET/2, P_CIRCLE_D+DIAMETER_OFFSET, P_CIRCLE_D+DIAMETER_OFFSET);
            self.imgViewVote.center = pt;
        } completion:nil];
    }
    else if(sender == self.btnQA)
    {
        CGRect rc =  self.imgViewQA.frame;
        CGPoint pt = self.imgViewQA.center;
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.imgViewQA.frame = CGRectMake(rc.origin.x-DIAMETER_OFFSET/2, rc.origin.y-DIAMETER_OFFSET/2, P_CIRCLE_D+DIAMETER_OFFSET, P_CIRCLE_D+DIAMETER_OFFSET);
            self.imgViewQA.center = pt;
        } completion:nil];
    }
}

-(void)tapButtonAnimation:(UIButton*)sender
{
    //分享
    if(sender == self.btnShare)
    {
        //放大
        self.imgViewShare.frame = CGRectMoveToCenter(CGRectMake(0, 0, P_CIRCLE_D*DIAMETER_MULTIPLE, P_CIRCLE_D*DIAMETER_MULTIPLE),self.imgViewShare.center);
    }
    else
    {
        //缩小
        self.imgViewShare.frame = CGRectMoveToCenter(CGRectMake(0, 0, P_CIRCLE_D/4, P_CIRCLE_D/4),self.imgViewShare.center);
    }
    
    //问答
    if(sender == self.btnQA)
    {
        //放大
        self.imgViewQA.frame = CGRectMoveToCenter(CGRectMake(0, 0, P_CIRCLE_D*DIAMETER_MULTIPLE, P_CIRCLE_D*DIAMETER_MULTIPLE),self.imgViewQA.center);
    }
    else
    {
        //缩小
        self.imgViewQA.frame = CGRectMoveToCenter(CGRectMake(0, 0, P_CIRCLE_D/4, P_CIRCLE_D/4),self.imgViewQA.center);
    }
    
    //投票
    if(sender == self.btnVote)
    {
        //放大
        self.imgViewVote.frame = CGRectMoveToCenter(CGRectMake(0, 0, P_CIRCLE_D*DIAMETER_MULTIPLE, P_CIRCLE_D*DIAMETER_MULTIPLE),self.imgViewVote.center);
    }
    else
    {
        //缩小
        self.imgViewVote.frame = CGRectMoveToCenter(CGRectMake(0, 0, P_CIRCLE_D/4, P_CIRCLE_D/4),self.imgViewVote.center);
    }
    
    self.imgViewShare.alpha = 0;
    self.lblShare.alpha = 0;
    
    self.imgViewQA.alpha = 0;
    self.lblQA.alpha = 0;
    
    self.imgViewVote.alpha = 0;
    self.lblVote.alpha = 0;
}

//触发跳转操作
-(void)touchUpInside:(UIButton*)sender
{
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self tapButtonAnimation:sender];
    }  completion:^(BOOL finished){
        if(sender == self.btnShare)
        {
            PublishShareViewController *publishShareViewController = [[UIStoryboard storyboardWithName:@"ShareModule" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"PublishShareViewController"];
            publishShareViewController.nPublicType = 0;
            publishShareViewController.viewControllerParent = self.homeViewController;

            CommonNavigationController *navController = [[CommonNavigationController alloc] initWithRootViewController:publishShareViewController];
            navController.navigationBarHidden = YES;
            [self.homeViewController presentViewController:navController animated:YES completion:^(void){
                [self closeView:NO];
            }];
        }
        else if(sender == self.btnVote)
        {
            PublishShareViewController *publishVoteViewController = [[UIStoryboard storyboardWithName:@"ShareModule" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"PublishShareViewController"];
            publishVoteViewController.nPublicType = 1;
            publishVoteViewController.viewControllerParent = self.homeViewController;
            
            CommonNavigationController *navController = [[CommonNavigationController alloc] initWithRootViewController:publishVoteViewController];
            navController.navigationBarHidden = YES;
            [self.homeViewController presentViewController:navController animated:YES completion:^(void){
                [self closeView:NO];
            }];
        }
        else if(sender == self.btnQA)
        {
            PublishQuestionViewController *publishQuestionViewController = [[UIStoryboard storyboardWithName:@"ShareModule" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"PublishQuestionViewController"];
            
            CommonNavigationController *navController = [[CommonNavigationController alloc] initWithRootViewController:publishQuestionViewController];
            navController.navigationBarHidden = YES;
            [self.homeViewController presentViewController:navController animated:YES completion:^(void){
                [self closeView:NO];
            }];
        }
    }];
}

//取消发表操作
-(void)touchCancel:(UIButton*)sender
{
    if(sender == self.btnShare)
    {
        CGRect rc =  self.imgViewShare.frame;
        CGPoint pt = self.imgViewShare.center;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.imgViewShare.frame = CGRectMake(rc.origin.x+5, rc.origin.y+5, P_CIRCLE_D, P_CIRCLE_D);
            self.imgViewShare.center = pt;
        } completion:nil];
    }
    else if(sender == self.btnQA)
    {
        CGRect rc =  self.imgViewQA.frame;
        CGPoint pt = self.imgViewQA.center;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.imgViewQA.frame = CGRectMake(rc.origin.x+5, rc.origin.y+5, P_CIRCLE_D, P_CIRCLE_D);
            self.imgViewQA.center = pt;
        } completion:nil];
    }
    else if(sender == self.btnVote)
    {
        CGRect rc =  self.imgViewVote.frame;
        CGPoint pt = self.imgViewVote.center;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.imgViewVote.frame = CGRectMake(rc.origin.x+5, rc.origin.y+5, P_CIRCLE_D, P_CIRCLE_D);
            self.imgViewVote.center = pt;
        } completion:nil];
    }
}

- (void)buttonAnimationWithState:(BOOL)bStart
{
    //旋转
    if(bStart)
    {
        [self.btnHomePop setImage:[UIImage imageNamed:@"tab_item_middle_h"] forState:UIControlStateNormal];
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.btnHomePop.transform = CGAffineTransformMakeRotation(45 * (M_PI / 180.0f));
        } completion:nil];
    }
    else
    {
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.btnHomePop.transform = CGAffineTransformMakeRotation(1 * (M_PI / 180.0f));
        } completion:^(BOOL finished) {
            [self.btnHomePop setImage:[SkinManage imageNamed:@"tab_item_middle"] forState:UIControlStateNormal];
        }];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint touchPoint = [touch locationInView:self.visualEffectView];
    BOOL bRes = CGRectContainsPoint(self.viewShare.frame, touchPoint) || CGRectContainsPoint(self.viewVote.frame, touchPoint) || CGRectContainsPoint(self.viewQA.frame, touchPoint);
    return !bRes;
}

@end
