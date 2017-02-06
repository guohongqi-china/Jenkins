//
//  GrayView.h
//  NssmcWskProj
//
//  Created by MacBook on 16/5/27.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GrayView;
@class addAlertView;
@protocol GrayViewDelegate <NSObject>
@optional
- (void)dropdownMenuDidDismiss:(GrayView *)menu;
- (void)dropdownMenuDidShow:(GrayView *)menu;
@end
@interface GrayView : UIView
@property (nonatomic, weak) id<GrayViewDelegate> delegate;

@property (nonatomic, strong) UIWindow *baseWindow;/** <#注释#> */

@property (nonatomic, strong) addAlertView *addLERT;/** <#注释#> */
- (void)showFrom:(UIView *)from;
+ (instancetype)Stutedent;



@end
