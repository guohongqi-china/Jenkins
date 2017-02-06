//
//  ChatMemberCollectionCell.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-5-20.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "ChatMemberCollectionCell.h"
#import "ChatInfoViewController.h"

@implementation ChatMemberCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.btnMember = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnMember.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.btnMember.layer setBorderWidth:0];
        [self.btnMember.layer setCornerRadius:5];
        self.btnMember.layer.borderColor = [[UIColor clearColor] CGColor];
        [self.btnMember.layer setMasksToBounds:YES];
        self.btnMember.clipsToBounds = YES;
        [self.btnMember addTarget:self action:@selector(buttonClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnMember setContentHorizontalAlignment:UIControlContentHorizontalAlignmentFill];
        [self.btnMember setContentVerticalAlignment:UIControlContentVerticalAlignmentFill];
        [self addSubview:self.btnMember];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressMember:)];
        [self.btnMember addGestureRecognizer:longPress];
        
        self.btnMinus = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.btnMinus setImage:[UIImage imageNamed:@"remove_app"] forState:UIControlStateNormal];
        [self.btnMinus addTarget:self action:@selector(buttonClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.btnMinus];
        
        self.lblName = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblName.backgroundColor = [UIColor clearColor];
        self.lblName.font = [UIFont systemFontOfSize:12];
        self.lblName.textColor = COLOR(51,43,41,1);
        self.lblName.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.lblName];
    }
    return self;
}

- (void)initUserVo:(UserVo *)userVo
{
    self.m_userVo = userVo;
    
    //head button
    if ([self.m_userVo.strUserID isEqualToString:@"+"])
    {
        [self.btnMember setImage:[UIImage imageNamed:@"AddGroupMemberBtn"] forState:UIControlStateNormal];
//        [self.btnMember setImage:[UIImage imageNamed:@"AddGroupMemberBtnHL"] forState:UIControlStateHighlighted];
        
        self.btnMinus.frame = CGRectZero;
    }
    else if ([self.m_userVo.strUserID isEqualToString:@"-"])
    {
        [self.btnMember setImage:[UIImage imageNamed:@"RemoveGroupMemberBtn"] forState:UIControlStateNormal];
//        [self.btnMember setImage:[UIImage imageNamed:@"RemoveGroupMemberBtnHL"] forState:UIControlStateHighlighted];
        
        self.btnMinus.frame = CGRectZero;
    }
    else
    {
        //set head image
        if (userVo.imgHeadBuffer != nil)
        {
            [self.btnMember setImage:userVo.imgHeadBuffer forState:UIControlStateNormal];
        }
        else
        {
            UIImage *imgDefault = [UIImage imageNamed:@"default_m"];
            [self.btnMember setImage:imgDefault forState:UIControlStateNormal];
            dispatch_async(dispatch_get_global_queue(0,0),^{
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:userVo.strHeadImageURL]];
                UIImage *imgTemp = [UIImage imageWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (imgTemp == nil || ![imgTemp isKindOfClass:[UIImage class]])
                    {
                        [self.btnMember setImage:imgDefault forState:UIControlStateNormal];
                    }
                    else
                    {
                        userVo.imgHeadBuffer = imgTemp;
                        [self.btnMember setImage:imgTemp forState:UIControlStateNormal];
                    }
                    
                });
            });
        }
        [self.btnMember setImage:nil forState:UIControlStateHighlighted];
        
        if(userVo.bGroupFounder)
        {
            self.btnMinus.frame = CGRectZero;//群主
        }
        else
        {
            if (self.bShowDeleteBtn)//需要显示删除按钮
            {
                self.btnMinus.frame = CGRectMake(-2.5, -0.5, 30, 30);
            }
            else
            {
                self.btnMinus.frame = CGRectZero;
            }
        }
    }
    
    self.btnMember.frame = CGRectMake(7.5, 10, 58, 58);
    
    //user name
    self.lblName.frame = CGRectMake(0, 68, 73, 27);
    self.lblName.text = userVo.strUserName;
}

-(void)buttonClickAction:(UIButton*)btnSender
{
    if(btnSender == self.btnMember)
    {
        //click member
        [self.parentViewController clickMemberAction:self.m_userVo];
    }
    else
    {
        //click minus button
        [self.parentViewController clickMinusAction:self.m_userVo];
    }
}

- (void)longPressMember:(UILongPressGestureRecognizer*)gesture
{
    if ( gesture.state == UIGestureRecognizerStateBegan )
    {
        [self.parentViewController longPressMemberAction:self.m_userVo];
    }
}

@end
