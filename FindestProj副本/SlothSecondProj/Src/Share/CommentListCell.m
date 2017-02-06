//
//  CommentListCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/6.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "CommentListCell.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+clickLike.h"
#import "FaceLabel.h"
#import "Constants+OC.h"
#import "IntegralInfoVo.h"
@import WebKit;

@interface CommentListCell ()
{
    CommentVo *commentVo;
    UIView *viewSelected;
}

@property (weak, nonatomic) IBOutlet UIImageView *imgViewHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewLevel;
@property (weak, nonatomic) IBOutlet FaceLabel *lblContent;
@property (weak, nonatomic) IBOutlet UIImageView *likeImageView;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblPraiseNum;

@property (weak, nonatomic) IBOutlet UIView *viewLine;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintContentH;
@property (weak, nonatomic) IBOutlet UIView *praiseClickView;

//@property (weak, nonatomic) UIWebView *myWebView;




@end

@implementation CommentListCell

- (void)awakeFromNib {
    // Initialization code
    
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    viewSelected = [[UIView alloc] initWithFrame:self.frame];
    viewSelected.backgroundColor = [SkinManage colorNamed:@"Table_Selected_Color"];
    self.selectedBackgroundView = viewSelected;
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.lblName.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.lblTime.textColor = [SkinManage colorNamed:@"Comment_Date_Color"];
    self.lblPraiseNum.textColor = [SkinManage colorNamed:@"Comment_Number_Color"];
    _viewLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    
    //content
    self.lblContent.textColor = [SkinManage colorNamed:@"Share_Content_Color"];
    self.lblContent.bShowGIF = YES;
    [self.lblContent initLabelWithFont:[UIFont systemFontOfSize:14]];
    
    
    
//    //add by fjz
//    UIWebView *myWebView = [[UIWebView alloc] init];
//    [self.contentView addSubview:myWebView];
//    myWebView.scrollView.scrollEnabled = NO;
//    myWebView.backgroundColor = [UIColor clearColor];
//    myWebView.opaque = 0;
//    myWebView.scalesPageToFit = YES;
//    self.myWebView = myWebView;
    
    UITapGestureRecognizer *tapPraiseVIew = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(praiseCommentClick)];
    [self.praiseClickView addGestureRecognizer:tapPraiseVIew];
    
    UITapGestureRecognizer *tapIconGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconOfCellClick)];
    [self.imgViewHeader addGestureRecognizer:tapIconGesture];
    //end
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(CommentVo *)entity
{
    commentVo = entity;
    
    [_imgViewHeader sd_setImageWithURL:[NSURL URLWithString:entity.strUserImage] placeholderImage:[UIImage imageNamed:@"default_m"]];
    _lblName.text = entity.strUserName;
    _imgViewLevel.image = [UIImage imageNamed:[BusinessCommon getIntegralInfo:entity.fIntegral].strLevelImage];
    _lblTime.text = [Common getDateTimeStrStyle2:entity.strCreateDate andFormatStr:@"yy-MM-dd HH:mm"];
    _lblPraiseNum.text = [NSString stringWithFormat:@"%li",(long)entity.nPraiseCount];
    
    if (entity.strMentionID == nil)
    {
        self.likeImageView.image = [SkinManage imageNamed:@"btn_share_praise"];
        _lblPraiseNum.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
    }
    else
    {
        _lblPraiseNum.textColor = COLOR(234, 18, 98, 1.0);
        if (entity.praiseState == PraiseStatePraise) {
            self.likeImageView.image = nil;
//            NSString *path = [[NSBundle mainBundle] pathForResource:@"tzhLike" ofType:@"gif"];
//            NSData *gifData = [NSData dataWithContentsOfFile:path];
//            [self.myWebView loadData:gifData MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.likeImageView.image =  [UIImage imageNamed:@"comment_praise_h"];
//                [self.myWebView loadHTMLString:@"" baseURL:nil];
                commentVo.praiseState = PraiseStateNomal;
//            });
            
        } else
            self.likeImageView.image =  [UIImage imageNamed:@"comment_praise_h"];
    }
    
    NSString *strComment = commentVo.strContent;
    if (commentVo.strparentId.length>0 && commentVo.strParentUserName.length>0)
    {
        NSString *strReply = [NSString stringWithFormat:@"回复 %@：",commentVo.strParentUserName];
        strComment = [NSString stringWithFormat:@"%@%@",strReply,strComment];
        [self.lblContent setReplyNameColor:THEME_COLOR range:NSMakeRange(3, strReply.length-4)];
    }
    else
    {
        [self.lblContent setReplyNameColor:nil range:NSMakeRange(0, 0)];
    }
    
    CGSize size = [self.lblContent calculateTextHeight:strComment andBound:CGSizeMake(kScreenWidth-75, MAXFLOAT)];
    self.lblContent.text = strComment;
    if (size.height < 20)
    {
        size.height = 20;
    }
    self.constraintContentH.constant = size.height;
    [self.lblContent setNeedsDisplay];
}



//赞
- (void)praiseCommentClick
{
    if (self.delegate != nil)
    {
        [self.delegate praiseComment:commentVo];
    }
}



#pragma  mark - 头像点击事件
- (void) iconOfCellClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(commentCell:iconClick:)]) {
        [self.delegate commentCell:self iconClick:commentVo];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
//    CGFloat temp = 7;
//    CGFloat webViewX = self.likeImageView.frame.origin.x;
//    CGFloat webViewY = self.likeImageView.frame.origin.y;
//    CGFloat webViewW = self.likeImageView.frame.size.width;
//    self.myWebView.frame = CGRectMake(webViewX - temp, webViewY - temp, webViewW + temp * 2, webViewW + temp * 2);
    [self.contentView bringSubviewToFront:self.praiseClickView];
}
@end
