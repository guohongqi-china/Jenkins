//
//  TableNoDataView.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/4/6.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "TableNoDataView.h"
#import "UIViewExt.h"

@interface TableNoDataView ()
{
    UIView *viewTop;
    UILabel *lblTip;
    UIImageView *imgViewLogo;
}

@end

@implementation TableNoDataView

- (instancetype)initWithFrame:(CGRect)frame tip:(NSString *)strTip
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initView:strTip];
    }
    return self;
}

- (void)initView:(NSString *)strTip
{
    self.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    viewTop = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 150)];
    viewTop.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    [self addSubview:viewTop];
    
    lblTip = [[UILabel alloc]initWithFrame:CGRectMake(0, 65, kScreenWidth, 20)];
    lblTip.textAlignment = NSTextAlignmentCenter;
    lblTip.textColor = [SkinManage colorNamed:@"NoSearch_Text_Color"];
    lblTip.font = [UIFont systemFontOfSize:14];
    lblTip.text = strTip;
    [self addSubview:lblTip];
    
    imgViewLogo = [[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth-58)/2, viewTop.bottom+30, 58, 23)];
    imgViewLogo.image = [SkinManage imageNamed:@"logo_bottom"];
    [self addSubview:imgViewLogo];
}

- (void)setTipText:(NSString *)strTip
{
    lblTip.text = strTip;
}

@end
