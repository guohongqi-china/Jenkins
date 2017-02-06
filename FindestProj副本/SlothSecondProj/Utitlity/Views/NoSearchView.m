//
//  NoSearchView.m
//  DYRSProj
//
//  Created by 焱 孙 on 9/16/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import "NoSearchView.h"
#import "UIViewExt.h"

@implementation NoSearchView

- (id)initWithFrame:(CGRect)frame andDes:(NSString*)strDescription
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
        
        self.lblDescription = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, kScreenWidth, 24)];
        self.lblDescription.backgroundColor = [UIColor clearColor];
        self.lblDescription.textAlignment = NSTextAlignmentCenter;
        self.lblDescription.font = [UIFont systemFontOfSize:17];
        self.lblDescription.textColor = [SkinManage colorNamed:@"NoSearch_Text_Color"];
        self.lblDescription.text = strDescription;
        [self addSubview:self.lblDescription];
        
        self.imgViewIcon = [[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth-58)/2, frame.size.height-96, 58, 23)];
        self.imgViewIcon.image = [SkinManage imageNamed:@"logo_bottom"];
        self.imgViewIcon.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.imgViewIcon];
    }
    return self;
}

@end
