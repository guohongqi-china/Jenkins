//
//  AnswerListCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/3.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "AnswerListCell.h"
#import "UIImageView+WebCache.h"
@import WebKit;
@interface AnswerListCell ()
{
    BlogVo *answerVo;
    UIView *viewSelected;
}

@property (weak, nonatomic) IBOutlet UIImageView *imgViewHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet UIButton *btnPraise;
@property (weak, nonatomic) IBOutlet UILabel *lblPraise;
@property (weak, nonatomic) IBOutlet UILabel *lblAnswerNum;

@property (weak, nonatomic) IBOutlet UIView *viewLine;
//@property (weak, nonatomic) UIWebView *myWebView;
@end

@implementation AnswerListCell

- (void)awakeFromNib {
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.lblName.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.lblTime.textColor = [SkinManage colorNamed:@"Comment_Date_Color"];
    self.lblContent.textColor = [SkinManage colorNamed:@"Share_Content_Color"];
    self.lblAnswerNum.textColor = [SkinManage colorNamed:@"Comment_Number_Color"];
    _viewLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    viewSelected = [[UIView alloc] initWithFrame:self.frame];
    viewSelected.backgroundColor = [SkinManage colorNamed:@"Table_Selected_Color"];
    self.selectedBackgroundView = viewSelected;
    
//    //add by fjz
//    UIWebView *myWebView = [[UIWebView alloc] init];
//    [self.btnPraise addSubview:myWebView];
//    myWebView.scalesPageToFit = YES;
//    myWebView.scrollView.scrollEnabled = NO;
//    myWebView.backgroundColor = [UIColor clearColor];
//    myWebView.opaque = 0;
//    self.myWebView = myWebView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(BlogVo *)entity
{
    answerVo = entity;
    
    [_imgViewHeader sd_setImageWithURL:[NSURL URLWithString:entity.vestImg] placeholderImage:[UIImage imageNamed:@"default_m"]];
    _lblName.text = entity.strCreateByName;
    _lblContent.text = entity.strText;
    _lblTime.text = [Common getDateTimeStrStyle2:entity.strCreateDate andFormatStr:@"yy-MM-dd HH:mm"];
    _lblPraise.text = [NSString stringWithFormat:@"%li",(long)entity.nPraiseCount];
    
    if (entity.strMentionID == nil)
    {
        [self.btnPraise setImage:[UIImage imageNamed:@"comment_praise"] forState:UIControlStateNormal];
        _lblPraise.textColor = COLOR(166, 139, 136, 1.0);
    }
    else
    {
        _lblPraise.textColor = COLOR(234, 18, 98, 1.0);
        if (answerVo.praiseState == PraiseStatePraise) {
            [self.btnPraise setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
//            NSString *path = [[NSBundle mainBundle] pathForResource:@"tzhLike" ofType:@"gif"];
//            NSData *gifData = [NSData dataWithContentsOfFile:path];
//            [self.myWebView loadData:gifData MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.btnPraise setImage:[UIImage imageNamed:@"comment_praise_h"] forState:UIControlStateNormal];
//                [self.myWebView loadHTMLString:@"" baseURL:nil];
                answerVo.praiseState = PraiseStateNomal;
//            });
            
        } else
            [self.btnPraise setImage:[UIImage imageNamed:@"comment_praise_h"] forState:UIControlStateNormal];
        
    }
    
    //评论数量
    if (entity.nCommentCount > 0)
    {
        _lblAnswerNum.text = [NSString stringWithFormat:@"%li",(long)entity.nCommentCount];
        _lblAnswerNum.hidden = NO;
    }
    else
    {
        _lblAnswerNum.hidden = YES;
    }
}

//赞
- (IBAction)praiseComment
{
    if (self.delegate != nil)
    {
        [self.delegate praiseAnswer:answerVo];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
//    CGFloat temp = 7;
//    CGFloat webViewX = self.btnPraise.imageView.frame.origin.x;
//    CGFloat webViewY = self.btnPraise.imageView.frame.origin.y;
//    CGFloat webViewW = self.btnPraise.imageView.frame.size.width;
//    self.myWebView.frame = CGRectMake(webViewX - temp, webViewY - temp, webViewW + temp * 2, webViewW + temp * 2);
}

@end
