//
//  FAQListCell.m
//  WeiShangKeProj
//
//  Created by 焱 孙 on 5/20/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import "FAQListCell.h"
#import "UIImageView+WebCache.h"
#import "ResizeImage.h"
#import "UIImage+Extras.h"
#import "UIViewExt.h"
#import "KTPhotoScrollViewController.h"
#import "SDWebImageDataSource.h"
#import "CustomWebViewController.h"

@implementation FAQListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.viewLineTop = [[UIView alloc]init];
        self.viewLineTop.backgroundColor = COLOR(203, 203, 203, 1.0);
        [self.contentView addSubview:self.viewLineTop];
        
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblTitle.numberOfLines = 0;
        self.lblTitle.backgroundColor = [UIColor clearColor];
        self.lblTitle.font = [UIFont boldSystemFontOfSize:15];
        self.lblTitle.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblTitle.textColor = COLOR(49,49,49,1);
        [self.contentView addSubview:self.lblTitle];
        
        self.imgViewArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@""]];
        [self.contentView addSubview:self.imgViewArrow];
        
        self.viewMiddle = [[UIView alloc]init];
        self.viewMiddle.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.viewMiddle];
        
        self.viewLineMiddle = [[UIView alloc]init];
        self.viewLineMiddle.backgroundColor = COLOR(203, 203, 203, 1.0);
        [self.viewMiddle addSubview:self.viewLineMiddle];
        
        self.lblContent = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblContent.numberOfLines = 0;
        self.lblContent.backgroundColor = [UIColor clearColor];
        self.lblContent.font = [UIFont boldSystemFontOfSize:14];
        self.lblContent.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblContent.textColor = COLOR(149,149,149,1);
        [self.viewMiddle addSubview:self.lblContent];
        
        self.imgViewContent = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imgViewContent.contentMode = UIViewContentModeScaleAspectFill;
        self.imgViewContent.clipsToBounds = YES;
        [self.viewMiddle addSubview:_imgViewContent];
        self.imgViewContent.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView)];
        [self.imgViewContent addGestureRecognizer:singleTap];
        
        self.btnLink = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnLink.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [self.btnLink setTitle:@"相关链接" forState:UIControlStateNormal];
        [self.btnLink setTitleColor:THEME_COLOR forState:UIControlStateNormal];
        [self.btnLink.layer setBorderWidth:0.5];
        [self.btnLink.layer setCornerRadius:4.5];
        self.btnLink.layer.borderColor = THEME_COLOR.CGColor;
        [self.btnLink.layer setMasksToBounds:YES];
        [self.btnLink addTarget:self action:@selector(clickLink) forControlEvents:UIControlEventTouchUpInside];
        [self.viewMiddle addSubview:self.btnLink];
        
        self.viewLineBottom = [[UIView alloc]init];
        self.viewLineBottom.backgroundColor = COLOR(203, 203, 203, 1.0);
        [self.contentView addSubview:self.viewLineBottom];
        
        self.viewSeperate = [[UIView alloc]init];
        self.viewSeperate.backgroundColor = COLOR(236, 236, 236, 1.0);
        [self.contentView addSubview:self.viewSeperate];
    }
    return self;
}

-(void)initWithData:(FAQVo*)faqVo andExpandID:(NSString*)strExpandID
{
    self.m_faqVo = faqVo;
    
    CGFloat fHeight = 0;
    //1.top line
    self.viewLineTop.frame = CGRectMake(0, fHeight, kScreenWidth, 0.5);
    fHeight += 0.5;
    
    //2.title & arrow
    fHeight += 12;
    self.imgViewArrow.frame = CGRectMake(kScreenWidth-23, fHeight+3, 13, 13);
    
    CGSize size = [Common getStringSize:faqVo.strTitle font:self.lblTitle.font bound:CGSizeMake(kScreenWidth-43, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    self.lblTitle.frame = CGRectMake(13, fHeight, kScreenWidth-43, size.height);
    self.lblTitle.text = faqVo.strTitle;
    fHeight += size.height+12;
    
    //3.expand view
    if ([strExpandID isEqualToString:faqVo.strID])
    {
        //扩展视图
        CGFloat fHeightM = 0;
        //middle line
        self.viewLineMiddle.frame = CGRectMake(0, fHeightM, kScreenWidth, 1);
        fHeightM += 1;
        
        //content
        fHeightM += 12;
        size = [Common getStringSize:faqVo.strTextContent font:self.lblContent.font bound:CGSizeMake(kScreenWidth-26, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        self.lblContent.frame = CGRectMake(13, fHeightM, kScreenWidth-26, size.height);
        self.lblContent.text = faqVo.strTextContent;
        fHeightM += size.height+12;
        
        //content image
        if (faqVo.strPicUrl.length>0)
        {
            self.imgViewContent.frame = CGRectMake(13, fHeightM, 150, 100);
            [self.imgViewContent sd_setImageWithURL:[NSURL URLWithString:faqVo.strPicUrl] placeholderImage:[UIImage imageNamed:@"default_image"]];
            fHeightM +=self.imgViewContent.height+12;
        }
        else
        {
            self.imgViewContent.frame = CGRectMake(0, 0, 0, 0);
        }
        
        //line
        if (faqVo.strJumpUrl.length>0)
        {
            self.btnLink.hidden = NO;
            self.btnLink.frame = CGRectMake(13, fHeightM, kScreenWidth-26, 32);
            fHeightM +=self.btnLink.height+12;
        }
        else
        {
            self.btnLink.hidden = YES;
        }
        
        self.viewMiddle.hidden = NO;
        self.viewMiddle.frame = CGRectMake(0, fHeight, kScreenWidth, fHeightM);
        fHeight += fHeightM;
        
        self.imgViewArrow.image = [UIImage imageNamed:@"arrow_gray_up"];
    }
    else
    {
        //不扩展
        self.viewMiddle.hidden = YES;
        self.imgViewArrow.image = [UIImage imageNamed:@"arrow_gray_down"];
    }
    
    //4.bottom line
    self.viewLineBottom.frame = CGRectMake(0, fHeight, kScreenWidth, 0.5);
    fHeight += 0.5;
    
    //5.seperate view
    self.viewSeperate.frame = CGRectMake(0, fHeight, kScreenWidth, 5);
}

+ (CGFloat)calculateCellHeight:(FAQVo *)faqVo andExpandID:(NSString*)strExpandID
{
    CGFloat fHeight = 0;
    //1.top line
    fHeight += 0.5;
    
    //2.title & arrow
    fHeight += 12;
    
    CGSize size = [Common getStringSize:faqVo.strTitle font:[UIFont boldSystemFontOfSize:15] bound:CGSizeMake(kScreenWidth-26, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    fHeight += size.height+12;
    
    //3.expand view
    if ([strExpandID isEqualToString:faqVo.strID])
    {
        //扩展视图
        CGFloat fHeightM = 0;
        //middle line
        fHeightM += 1;
        
        //content
        fHeightM += 12;
        size = [Common getStringSize:faqVo.strTextContent font:[UIFont boldSystemFontOfSize:14] bound:CGSizeMake(kScreenWidth-26, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        fHeightM += size.height+12;
        
        //content image
        if (faqVo.strPicUrl.length>0)
        {
            fHeightM +=100+12;
        }
        
        //line
        if (faqVo.strJumpUrl.length>0)
        {
            fHeightM +=32+12;
        }
        
        fHeight += fHeightM;
    }
    else
    {
        //不扩展
    }
    
    //4.bottom line
    fHeight += 0.5;
    
    //5.seperate view
    fHeight += 5;
    
    return fHeight;
}

-(void)tapImageView
{
    if (self.m_faqVo.strPicUrl!= nil)
    {
        SDWebImageDataSource *dataSource = [[SDWebImageDataSource alloc] init];
        dataSource.images_ = [NSArray arrayWithObject:[NSArray arrayWithObject:[NSURL URLWithString:self.m_faqVo.strPicUrl]]];
        
        KTPhotoScrollViewController *photoScrollViewController = [[KTPhotoScrollViewController alloc]
                                                                  initWithDataSource:dataSource
                                                                  andStartWithPhotoAtIndex:0];
        photoScrollViewController.bShowToolBarBtn = NO;
        [self.parentViewController.navigationController pushViewController:photoScrollViewController animated:YES];
    }
}

-(void)clickLink
{
    if (self.m_faqVo.strJumpUrl!= nil)
    {
        CustomWebViewController *customWebViewController = [[CustomWebViewController alloc]init];
        customWebViewController.urlFile = [NSURL URLWithString:self.m_faqVo.strJumpUrl];
        [self.parentViewController.navigationController pushViewController:customWebViewController animated:YES];
    }
}

@end
