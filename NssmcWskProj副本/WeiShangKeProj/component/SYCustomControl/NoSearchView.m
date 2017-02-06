//
//  NoSearchView.m
//  DYRSProj
//
//  Created by 焱 孙 on 9/16/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import "NoSearchView.h"

@implementation NoSearchView

- (id)initWithFrame:(CGRect)frame andDes:(NSString*)strDescription
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.imgViewIcon = [[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth-172)/2, 180, 172, 30.5)];
        self.imgViewIcon.image = [UIImage imageNamed:@"no_search_icon"];
        self.imgViewIcon.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.imgViewIcon];
        
        self.lblDescription = [[UILabel alloc] initWithFrame:CGRectMake(0, 228+15, kScreenWidth, 20)];
        self.lblDescription.backgroundColor = [UIColor clearColor];
        self.lblDescription.textAlignment = NSTextAlignmentCenter;
        self.lblDescription.font = [UIFont systemFontOfSize:15];
        self.lblDescription.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblDescription.textColor = COLOR(204,204,204,1);
        self.lblDescription.text = strDescription;
        [self addSubview:self.lblDescription];
    }
    return self;
}



@end
