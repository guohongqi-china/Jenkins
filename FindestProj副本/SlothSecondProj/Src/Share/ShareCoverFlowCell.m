//
//  ShareCoverFlowCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/16.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "ShareCoverFlowCell.h"
#import "UIImageView+WebCache.h"
#import "TipNumLabel.h"
#import "UIViewExt.h"

@interface ShareCoverFlowCell ()
{
    TipNumLabel *lblPicNum;     //图片的数量
    BlogVo *_blogVo;
}

@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewTimeIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UIView *viewSepLine;

@property (weak, nonatomic) IBOutlet UIView *viewBottomContainer;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewSharePic;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewPraiseIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblPraiseNum;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewCommentIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblCommentNum;

@property (weak, nonatomic) IBOutlet UIView *viewLinkCotainer;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewLinkIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblLinkText;

@end

@implementation ShareCoverFlowCell

- (void)awakeFromNib {
    // Initialization code
    // Initialization code
    lblPicNum = [[TipNumLabel alloc]init];
    lblPicNum.textColor = COLOR(255, 255, 255, 0.5);
    lblPicNum.backgroundColor = COLOR(63, 63, 63, 0.6);
    lblPicNum.layer.masksToBounds = YES;
    lblPicNum.layer.cornerRadius = 5;
    lblPicNum.font = [UIFont systemFontOfSize:10];
    lblPicNum.textAlignment = NSTextAlignmentCenter;
    [_imgViewSharePic addSubview:lblPicNum];
    
    [lblPicNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.equalTo(0);
        make.height.equalTo(14);
        make.width.greaterThanOrEqualTo(14);
    }];
    
    [_viewBottomContainer removeConstraints:_viewBottomContainer.constraints];
    _viewBottomContainer.backgroundColor = [UIColor clearColor];
    
    [_imgViewSharePic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(110);
        make.leading.equalTo(10);
        make.top.equalTo(8.5);
    }];
    
    //title
    [_lblTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_imgViewSharePic.mas_right).offset(10);
        make.top.equalTo(10);
        make.right.equalTo(-10);
    }];
    
    //content
    [_lblContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_imgViewSharePic.mas_right).offset(10);
        make.top.equalTo(_lblTitle.mas_bottom).offset(9);
        make.right.equalTo(-10);
    }];
    
    //praise
    [_imgViewPraiseIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(-11);
        make.right.equalTo(-119);
    }];
    [_lblPraiseNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_imgViewPraiseIcon.mas_right).offset(6.5);
        make.centerY.equalTo(_imgViewPraiseIcon);
    }];
    
    //comment
    [_imgViewCommentIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(-11);
        make.right.equalTo(-40);
    }];
    [_lblCommentNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_imgViewCommentIcon.mas_right).offset(6.5);
        make.centerY.equalTo(_imgViewCommentIcon);
    }];
    
    //Link info
    [_viewLinkCotainer removeConstraints:_viewLinkCotainer.constraints];
    [_viewLinkCotainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_imgViewSharePic.mas_trailing).offset(10);
        make.top.equalTo(_lblTitle.mas_bottom).offset(9);
        make.trailing.equalTo(-10);
        make.height.equalTo(32);
    }];
    
    [_imgViewLinkIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(28);
        make.leading.top.equalTo(2);
    }];
    
    [_lblLinkText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(_viewLinkCotainer).insets(UIEdgeInsetsMake(5, 0, 5, 10));
        make.leading.equalTo(_imgViewLinkIcon.mas_trailing).offset(10);
    }];
}

- (void)setEntity:(BlogVo *)blogVo
{
    self.viewContainer.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    
    //header image
    [_imgViewHeader sd_setImageWithURL:[NSURL URLWithString:blogVo.vestImg] placeholderImage:[UIImage imageNamed:@"default_m"]];
    
    //name
    _lblName.text = blogVo.strCreateByName;
    _lblName.textColor = [SkinManage colorNamed:@"Share_Title_Color"];
    
    //time
    _lblTime.text = [Common getDateTimeStrStyle2:blogVo.strCreateDate andFormatStr:@"yy-MM-dd HH:mm"];
    _lblTime.textColor = [SkinManage colorNamed:@"Share_Time"];
    _imgViewTimeIcon.image = [SkinManage imageNamed:@"share_time_icon"];
    
    _viewSepLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    
    
    //title
    _lblTitle.text = blogVo.strTitle;
    _lblTitle.textColor = [SkinManage colorNamed:@"Share_Title_Color"];
    
    //content
    _lblContent.text = blogVo.strText;
    _lblContent.textColor = [SkinManage colorNamed:@"Share_Content_Color"];
    
    //share pic
    if (blogVo.aryPictureUrl.count > 0)
    {
        _imgViewSharePic.hidden = NO;
        if (blogVo.aryPictureUrl.count>0)
        {
            lblPicNum.hidden = NO;
            lblPicNum.text = [NSString stringWithFormat:@"%lu",(unsigned long)blogVo.aryPictureUrl.count];
        }
        else
        {
            lblPicNum.hidden = YES;
        }
        
        [_imgViewSharePic sd_setImageWithURL:[NSURL URLWithString:blogVo.aryPictureUrl[0]] placeholderImage:[UIImage imageNamed:@"default_image"]];
        
        [_imgViewSharePic mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(110);
        }];
        
        [_lblTitle mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_imgViewSharePic.mas_right).offset(10);
        }];
        
        //link
        if (blogVo.strShareLink != nil && blogVo.strShareLink.length>0)
        {
            _lblLinkText.text = blogVo.strLinkTitle;
            
            _viewLinkCotainer.hidden = NO;
            _lblContent.hidden = YES;
            [_viewLinkCotainer mas_updateConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(_imgViewSharePic.mas_trailing).offset(10);
            }];
        }
        else
        {
            _viewLinkCotainer.hidden = YES;
            _lblContent.hidden = NO;
            [_lblContent mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_imgViewSharePic.mas_right).offset(10);
            }];
        }
    }
    else
    {
        _imgViewSharePic.hidden = YES;
        
        [_imgViewSharePic mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(0);
        }];
        
        [_lblTitle mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_imgViewSharePic.mas_right).offset(0);
        }];
        
        //link
        if (blogVo.strShareLink != nil && blogVo.strShareLink.length>0)
        {
            _lblLinkText.text = blogVo.strLinkTitle;
            
            _viewLinkCotainer.hidden = NO;
            _lblContent.hidden = YES;
            [_viewLinkCotainer mas_updateConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(_imgViewSharePic.mas_trailing).offset(0);
            }];
        }
        else
        {
            _viewLinkCotainer.hidden = YES;
            _lblContent.hidden = NO;
            [_lblContent mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_imgViewSharePic.mas_right).offset(0);
            }];
        }
    }
    
    //title
    _lblTitle.text = blogVo.strTitle;
    _lblTitle.textColor = [SkinManage colorNamed:@"Share_Title_Color"];
    
    //content
    _lblContent.text = blogVo.strText;
    _lblContent.textColor = [SkinManage colorNamed:@"Share_Content_Color"];
    
    //praise num
    _lblPraiseNum.text = [NSString stringWithFormat:@"%li",(long)blogVo.nPraiseCount];
    _lblPraiseNum.textColor = [SkinManage colorNamed:@"Share_Praise_Txt_Color"];
    _imgViewPraiseIcon.image = [SkinManage imageNamed:@"praise_icon"];
    
    //comment num
    _lblCommentNum.text = [NSString stringWithFormat:@"%li",(long)blogVo.nCommentCount];
    _lblCommentNum.textColor = [SkinManage colorNamed:@"Share_Praise_Txt_Color"];
    _imgViewCommentIcon.image = [SkinManage imageNamed:@"comment_icon"];
}

@end
