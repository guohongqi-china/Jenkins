//
//  CommonBarButtonItem.m
//  SNFramework
//
//  Created by  liukun on 13-12-27.
//  Copyright (c) 2013年 liukun. All rights reserved.
//

#import "SNUIBarButtonItem.h"
#import "UIColor+SNFoundation.h"
#import "SkinManage.h"

@implementation SNUIBarButtonItem

+ (instancetype)itemWithTitle:(NSString *)title
                        Style:(SNNavItemStyle)style
                       target:(id)target
                       action:(SEL)action
{
    if (style == SNNavItemStyleBack)
    {
        //返回
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.backgroundColor = [UIColor clearColor];
        [btn setImage:[SkinManage imageNamed:@"nav_back_white"] forState:UIControlStateNormal];
        btn.frame = CGRectMake(0, 0, 44, 44);
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 30);
        btn.tintColor = [SkinManage colorNamed:@"Nav_Btn_Tint_Color"];
        [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        SNUIBarButtonItem *item = [[SNUIBarButtonItem alloc] initWithCustomView:btn];
        return item;
    }
    else if (style == SNNavItemStyleDone)
    {
        SNUIBarButtonItem *item = [[SNUIBarButtonItem alloc]
                                   initWithTitle:title
                                   style:UIBarButtonItemStylePlain
                                   target:target
                                   action:action];
        item.tintColor = [SkinManage colorNamed:@"Nav_Btn_Tint_Color"];
        return item;
    }
    else
    {
        return nil;
    }
}

+ (instancetype)itemWithImage:(NSString *)strImageName style:(SNNavItemStyle)style target:(id)target action:(SEL)action
{
    UIImage *image = [SkinManage imageNamed:strImageName];
    if (image == nil)
    {
        image = [UIImage imageNamed:strImageName];
    }
    
    SNUIBarButtonItem *item = [[SNUIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:target action:action];
    item.tintColor = [SkinManage colorNamed:@"Nav_Btn_Tint_Color"];
    
    return item;
}

+ (instancetype)backItemWithImage:(NSString *)strImageName
                           target:(id)target
                           action:(SEL)action
{
    //返回
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor clearColor];
    [btn setImage:[UIImage imageNamed:strImageName] forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 44, 44);
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 30);
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    SNUIBarButtonItem *item = [[SNUIBarButtonItem alloc] initWithCustomView:btn];
    return item;
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    if ([self.customView isKindOfClass:[UIControl class]])
    {
        UIControl *ctrl = (UIControl *)self.customView;
        ctrl.enabled = enabled;
    }
}

@end
