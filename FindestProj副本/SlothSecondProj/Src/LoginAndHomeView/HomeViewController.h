//
//  HomeViewController.h
//  Sloth
//
//  Created by Ann Yao on 12-9-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonalViewController.h"
#import "CommonTipNumView.h"
#import "PublishView.h"
#import "CommonNavigationController.h"
#import "DiscoveryViewController.h"
#import "MessageViewController.h"
#import "ShareHomeViewController.h"

typedef enum _MainTabType{
    TabItemType1 = 0,                      //item1
    TabItemType2,                            //item2
    TabItemType3,                           //item3
    TabItemType4                           //item4
}MainTabType;

@interface HomeViewController : UIViewController<UITabBarControllerDelegate>

@property(nonatomic,strong)UIView *viewTab;
@property(nonatomic,strong)UIButton *btnItem1;
@property(nonatomic,strong)UIButton *btnItem2;
@property(nonatomic,strong)UIButton *btnItem3;
@property(nonatomic,strong)UIButton *btnItem4;
@property(nonatomic,strong)UIButton *btnMiddle;

@property(nonatomic,strong)CommonTipNumView *tipNumViewChat;

@property(nonatomic)MainTabType mainTabType;

@property(nonatomic,strong)CommonNavigationController *itemFirstNavigationController;
@property(nonatomic,strong)CommonNavigationController *itemSecondNavigationController;
@property(nonatomic,strong)CommonNavigationController *itemThirdNavigationController;
@property(nonatomic,strong)CommonNavigationController *itemFourthNavigationController;

@property(nonatomic,strong)ShareHomeViewController *itemFirstViewController;
@property(nonatomic,strong)DiscoveryViewController *itemSecondViewController;
@property(nonatomic,strong)MessageViewController *itemThirdViewController;
@property(nonatomic,strong)PersonalViewController *itemFourthViewController;

@property(nonatomic,strong)PublishView *publishView;

-(void)hideBottomTabBar:(BOOL)bHide;
-(void)selectTab:(UIButton*)sender;
- (void)selectTabByType:(MainTabType)type;
-(void)switchViewController;
- (void)setTabItemStyle:(UIButton *)btnItem;
@end
