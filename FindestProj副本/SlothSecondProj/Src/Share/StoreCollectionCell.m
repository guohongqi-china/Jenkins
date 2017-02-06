//
//  StoreCollectionCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/5.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "StoreCollectionCell.h"
#import "TipNumLabel.h"
#import "UIViewExt.h"

@interface StoreCollectionCell ()
{
    BlogVo *_blogVo;
}

@property (weak, nonatomic) IBOutlet UIImageView *imgViewPic;
@property (weak, nonatomic) IBOutlet TipNumLabel *lblPicNum;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewType;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet UIView *viewSeperate;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIButton *btnClear;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewBK;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTitleTop;
@end

@implementation StoreCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Fix the bug in iOS7 - initial constraints warning
    //self.contentView.bounds = [UIScreen mainScreen].bounds;
}

- (void)setEntity:(BlogVo *)blogVo
{
    _blogVo = blogVo;
    
    //cell image bk
    _imgViewBK.image = [[SkinManage imageNamed:@"collection_bk"] stretchableImageWithLeftCapWidth:50 topCapHeight:40];
    
    //type
    if (blogVo.nBlogType == 0)
    {
        //分享
        _imgViewType.image = [UIImage imageNamed:@"collection_share_type"];
    }
    else if (blogVo.nBlogType == 1)
    {
        //投票
        _imgViewType.image = [UIImage imageNamed:@"collection_vote_type"];
    }
    else if (blogVo.nBlogType == 2)
    {
        //问答
        _imgViewType.image = [UIImage imageNamed:@"collection_qa_type"];
    }
    
    if ([blogVo.strBlogType isEqualToString:@"vote"])
    {
        _imgViewType.image = [UIImage imageNamed:@"collection_vote_type"];
    }
    else if ([blogVo.strBlogType isEqualToString:@"blog"])
    {
        _imgViewType.image = [UIImage imageNamed:@"collection_share_type"];
    }
    else if([blogVo.strBlogType isEqualToString:@"qa"])
    {
        _imgViewType.image = [UIImage imageNamed:@"collection_qa_type"];
    }
    else
    {
        _imgViewType.image = [UIImage imageNamed:@"collection_share_type"];
    }
    
    //share pic
    if (blogVo.aryPictureUrl.count > 0)
    {
        _imgViewPic.hidden = NO;
        if (blogVo.aryPictureUrl.count>0)
        {
            _lblPicNum.hidden = NO;
            _lblPicNum.text = [NSString stringWithFormat:@"%lu",(unsigned long)blogVo.aryPictureUrl.count];
        }
        else
        {
            _lblPicNum.hidden = YES;
        }
        
        [_imgViewPic sd_setImageWithURL:[NSURL URLWithString:blogVo.aryPictureUrl[0]] placeholderImage:[UIImage imageNamed:@"default_image"]];
    }
    else
    {
        _lblPicNum.hidden = YES;
        _imgViewPic.hidden = YES;
    }
    
    //title
    _lblTitle.text = blogVo.strTitle;
    _lblTitle.textColor = [SkinManage colorNamed:@"Share_Title_Color"];
    
    //content
    _lblContent.text = blogVo.strText;
    _lblContent.textColor = [SkinManage colorNamed:@"Share_Content_Color"];
    
    _viewSeperate.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    
    //header image
    [_imgViewHeader sd_setImageWithURL:[NSURL URLWithString:blogVo.vestImg] placeholderImage:[UIImage imageNamed:@"default_m"]];
    
    //name
    _lblName.text = blogVo.strCreateByName;
    _lblName.textColor = [SkinManage colorNamed:@"Share_Title_Color"];
    
    [_btnClear setImage:[SkinManage imageNamed:@"cancel_collection"] forState:UIControlStateNormal];
    _btnClear.hidden = self.isHideClearButton;
}

- (void)layoutSubviews
{
    if (_blogVo.aryPictureUrl.count > 0)
    {
        _constraintTitleTop.constant = _imgViewPic.width+12;
    }
    else
    {
        _constraintTitleTop.constant = 41;
    }
    
    _lblTitle.preferredMaxLayoutWidth = _lblTitle.bounds.size.width;
    _lblContent.preferredMaxLayoutWidth = _lblContent.bounds.size.width;
    
    [super layoutSubviews];
}

- (IBAction)cancelStoreShare:(UIButton *)sender
{
    //取消收藏
    [Common showProgressView:nil view:self modal:NO];
    [ServerProvider cancelCollection:_blogVo.streamId andType:_blogVo.strBlogType result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self];
        if (retInfo.bSuccess)
        {
            [self.delegate cancelStoreCollection:_blogVo];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

@end
