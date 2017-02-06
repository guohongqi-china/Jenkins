//
//  ShareListCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/4.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "ShareListCell.h"
#import "UIImageView+WebCache.h"
#import "TipNumLabel.h"
#import "SDWebImageDataSource.h"
#import "KTPhotoScrollViewController.h"
#import "CommonHeaderView.h"
#import "ShareService.h"
#import "KeyValueVo.h"
#import "ReportUserVo.h"
#import "BufferVideoFirstImage.h"
#import "ExtScope.h"
#import "ShareHomeViewController.h"
#import "IntegralInfoVo.h"
#import "NSString+Size.h"

#import "UserProfileViewController.h"
#import "ShareListViewController.h"

static NSInteger nNumawakeFromNib = 0;

@interface ShareListCell()<UIActionSheetDelegate,CommonHeaderViewDelegate>
{
    TipNumLabel *lblPicNum;     //图片的数量
    BlogVo *_blogVo;
    UIView *viewSelected;
}

@property (nonatomic, weak) UIViewController *parentController;

@property (weak, nonatomic) IBOutlet UIImageView *imgViewType;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewBK;
@property (weak, nonatomic) IBOutlet UIButton *btnBackground;

@property (weak, nonatomic) IBOutlet UIView *viewContainer;
//@property (weak, nonatomic) IBOutlet UIImageView *imgViewHeader;

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewLevel;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewTimeIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UIButton *btnArrow;

@property (weak, nonatomic) IBOutlet UIView *viewSepLine;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewSharePic;
@property (strong, nonatomic) UIImageView *imgViewVideoIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;

@property (weak, nonatomic) IBOutlet UIImageView *imgViewPraiseIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblPraiseNum;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewCommentIcon;   //问答的回答数量和评论数量共用一个控件
@property (weak, nonatomic) IBOutlet UILabel *lblCommentNum;

@property (weak, nonatomic) IBOutlet UIView *viewLinkCotainer;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewLinkIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblLinkText;

@end


@implementation ShareListCell

- (void)awakeFromNib
{
    viewSelected = [[UIView alloc] initWithFrame:self.frame];
    viewSelected.backgroundColor =[SkinManage colorNamed:@"Table_Selected_Color"];
    self.selectedBackgroundView = viewSelected;
    nNumawakeFromNib ++;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshSkin) name:NOTIFY_REFRESH_SKIN object:nil];
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
    
    [self.viewContainer removeConstraints:self.viewContainer.constraints];

    //header image
    _headerView = [[CommonHeaderView alloc]initWithFrame:CGRectMake(0, 0, 41, 41) canTap:YES parent:(UIViewController *)self.delegate];
    _headerView.delegate = self;
    [self.viewContainer addSubview:_headerView];
    [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(10);
        make.width.height.equalTo(41);
    }];
    
    //change by fjz
    
    //name
    [_lblName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.viewContainer).insets(UIEdgeInsetsMake(10, 60, 0, 40));
    }];
    
    [_imgViewLevel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_lblName.mas_centerY);
        make.size.equalTo(CGSizeMake(25, 25));
        make.leading.equalTo(_lblName.mas_trailing).offset(5);
    }];
    //end fjz
    
    //time
    [_imgViewTimeIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(60);
        make.top.equalTo(_lblName.mas_bottom).offset(4);
    }];
    [_lblTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_imgViewTimeIcon).offset(0.5);
        make.left.equalTo(_imgViewTimeIcon.mas_right).offset(5);
    }];
    
    //arrow
    [_btnArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(50, 40));
        make.top.equalTo(10);
        make.right.equalTo(3);
    }];
    
    //line
    [_viewSepLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(0.5);
        make.leading.equalTo(10);
        make.trailing.equalTo(-10);
        make.top.equalTo(_headerView.mas_bottom).offset(5);
    }];
    
    [_imgViewSharePic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(110);
        make.leading.equalTo(10);
        make.top.equalTo(_viewSepLine.mas_bottom).offset(8.5);
    }];
    
    _imgViewVideoIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_play_small"]];
    _imgViewVideoIcon.frame = CGRectMake((110-36)/2, (110-36)/2, 36, 36);
    [_imgViewSharePic addSubview:_imgViewVideoIcon];
    
    UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapContentImageView:)];
    [_imgViewSharePic addGestureRecognizer:singleTap1];
    
    //title
    _lblTitle.font = [Common fontWithName:@"PingFangSC-Medium" size:14];
    [_lblTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_imgViewSharePic.mas_right).offset(10);
        make.top.equalTo(_viewSepLine.mas_bottom).offset(10);
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
    
    UITapGestureRecognizer *linkViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLinkView)];
    [_viewLinkCotainer addGestureRecognizer:linkViewTap];
    
    [_imgViewLinkIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(28);
        make.leading.top.equalTo(2);
    }];
    
    [_lblLinkText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(_viewLinkCotainer).insets(UIEdgeInsetsMake(5, 0, 5, 10));
        make.leading.equalTo(_imgViewLinkIcon.mas_trailing).offset(10);
    }];
    
    [self.viewContainer bringSubviewToFront:_headerView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(BlogVo *)blogVo
{
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    _blogVo = blogVo;
    
    //type
    if([blogVo.strBlogType isEqualToString:@"qa"])
    {
        //问答
        _imgViewType.image = [UIImage imageNamed:@"qa_type_icon"];
        
        _imgViewCommentIcon.image = [SkinManage imageNamed:@"qa_answer_num"];
        self.imgViewPraiseIcon.hidden = YES;
        self.lblPraiseNum.hidden = YES;
    }
    else
    {
        if ([blogVo.strBlogType isEqualToString:@"blog"])
        {
            //分享
            _imgViewType.image = [UIImage imageNamed:@"share_type_icon"];
        }
        else if ([blogVo.strBlogType isEqualToString:@"vote"])
        {
            //投票
            _imgViewType.image = [UIImage imageNamed:@"vote_type_icon"];
        }
        
        _imgViewCommentIcon.image = [SkinManage imageNamed:@"comment_icon"];
        self.imgViewPraiseIcon.hidden = NO;
        self.lblPraiseNum.hidden = NO;
    }
    
    //bk
    _imgViewBK.image = [[SkinManage imageNamed:@"share_list_bk"] stretchableImageWithLeftCapWidth:40 topCapHeight:40];
    [_btnBackground setBackgroundImage:[[SkinManage imageNamed:@"share_list_bk"] stretchableImageWithLeftCapWidth:40 topCapHeight:40] forState:UIControlStateNormal];
    
    //header image
    [_headerView refreshViewWithImage:blogVo.vestImg userID:blogVo.strCreateBy];
    //    [_imgViewHeader sd_setImageWithURL:[NSURL URLWithString:blogVo.vestImg] placeholderImage:[UIImage imageNamed:@"default_m"]];
    
    //name
    _lblName.text = blogVo.strCreateByName;
    _lblName.textColor = [SkinManage colorNamed:@"Share_Title_Color"];
    _imgViewLevel.image = [UIImage imageNamed:[BusinessCommon getIntegralInfo:blogVo.fIntegral].strLevelImage];
    
    //time
    _lblTime.text = [Common getDateTimeStrStyle2:blogVo.strCreateDate andFormatStr:@"yy-MM-dd HH:mm"];
    _lblTime.textColor = [SkinManage colorNamed:@"Share_Time"];
    _imgViewTimeIcon.image = [SkinManage imageNamed:@"share_time_icon"];
    
    [_btnArrow setImage:[SkinManage imageNamed:@"share_arow"] forState:UIControlStateNormal];
    
    _viewSepLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    
    //图片
    if (blogVo.aryPictureUrl.count > 0 || blogVo.aryVideoUrl.count > 0)
    {
        //分享图片
        _imgViewSharePic.hidden = NO;
        if (blogVo.aryPictureUrl.count>0)
        {
            lblPicNum.hidden = NO;
            lblPicNum.text = [NSString stringWithFormat:@"%lu",(unsigned long)blogVo.aryPictureUrl.count];
        }
        
        if (blogVo.aryVideoUrl.count > 0)
        {
            //视频图片 (获取视频第一帧图片)
            NSString *strURL = blogVo.aryVideoUrl[0];
            
            @weakify(self)
            self.imgViewSharePic.image = [UIImage imageNamed:@"default_image"];
            [BufferVideoFirstImage getFirstFrameImageFromURL:strURL finished:^(UIImage *image) {
                @strongify(self)
                if (image) {
                    self.imgViewSharePic.image = image;
                }
            }];
            
            lblPicNum.hidden = YES;
            _imgViewVideoIcon.hidden = NO;
        }
        else
        {
            //分享图片
            [_imgViewSharePic sd_setImageWithURL:[NSURL URLWithString:blogVo.aryPictureUrl[0]] placeholderImage:[UIImage imageNamed:@"default_image"]];
            _imgViewVideoIcon.hidden = YES;
        }
        
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
    _viewLinkCotainer.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    _lblLinkText.textColor = [SkinManage colorNamed:@"Content_Color"];
    _imgViewLinkIcon.image = [SkinManage imageNamed:@"share_link"];
    
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
    _lblCommentNum.textColor = [SkinManage colorNamed:@"Share_Praise_Txt_Color"];
    _lblCommentNum.text = [NSString stringWithFormat:@"%li",(long)blogVo.nCommentCount];    //评论数量和回答数量一致
    
    [self layoutIfNeeded];
}

- (void)setEntity:(BlogVo *)blogVo controller:(UIViewController *)controller
{
    self.parentController = controller;
    [self setEntity:blogVo];
}

// If you are not using auto layout, override this method, enable it by setting
// "fd_enforceFrameLayout" to YES.
- (CGSize)sizeThatFits:(CGSize)size
{
    CGFloat totalHeight = 0;
    if (_blogVo.aryPictureUrl.count>0 || _blogVo.aryVideoUrl.count > 0)
    {
        totalHeight = 192;
    }
    else
    {
        CGSize sizeContent = CGSizeZero;
        totalHeight += 74.5;
        CGSize sizeTitle = [self.lblTitle sizeThatFits:CGSizeMake(kScreenWidth-75, MAXFLOAT)];
        totalHeight += sizeTitle.height;
        totalHeight += 9;
        
        if (_blogVo.strShareLink != nil && _blogVo.strShareLink.length>0)
        {
            totalHeight += 32;
        }
        else
        {
            sizeContent = [self.lblContent sizeThatFits:CGSizeMake(kScreenWidth-75, MAXFLOAT)];
            totalHeight += sizeContent.height;
        }
        
        totalHeight += 40;
    }
    
    return CGSizeMake(size.width, totalHeight);
}

- (IBAction)buttonAction:(UIButton *)sender
{
    if(sender == _btnArrow)
    {
        //屏蔽 & 举报
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"屏蔽",@"举报", nil];
        actionSheet.tag = 1001;
        [actionSheet showInView:self];
    }
    else if (sender == _btnBackground)
    {
        
    }
}

-(void)refreshSkin
{
    viewSelected = [[UIView alloc] initWithFrame:self.frame];
    viewSelected.backgroundColor =[SkinManage colorNamed:@"Table_Selected_Color"];
    self.selectedBackgroundView = viewSelected;
    
}

- (void)tapContentImageView:(UITapGestureRecognizer*)gestureRecognizer
{
    if (_blogVo.aryVideoUrl.count > 0)
    {
        //小视频
        UIViewController *tempController = self.parentController;
        if (tempController == nil)
        {
            tempController = (UIViewController *)self.delegate;
        }
        [BusinessCommon presentVideoViewController:[NSURL URLWithString:_blogVo.aryVideoUrl[0]] controller:tempController];
    }
    else if (_blogVo.aryPictureUrl.count>0)
    {
        //预览图片
        NSInteger nIndex = gestureRecognizer.view.tag%1000;
        
        if (_blogVo.aryMaxPictureUrl == nil)
        {
            _blogVo.aryMaxPictureUrl = [NSMutableArray array];
            for (NSString *strURL in _blogVo.aryPictureUrl)
            {
                NSURL *urlMax = [NSURL URLWithString:[strURL stringByReplacingOccurrencesOfString:@"-mid." withString:@"."]];
                NSURL *urlMin = [NSURL URLWithString:strURL];
                
                if (urlMax == nil || urlMin == nil)
                {
                    continue;
                }
                
                NSArray *ary = @[urlMax,urlMin];
                [_blogVo.aryMaxPictureUrl addObject:ary];
            }
        }
        
        SDWebImageDataSource *dataSource = [[SDWebImageDataSource alloc] init];
        dataSource.images_ = _blogVo.aryMaxPictureUrl;
        KTPhotoScrollViewController *photoScrollViewController = [[KTPhotoScrollViewController alloc]
                                                                  initWithDataSource:dataSource
                                                                  andStartWithPhotoAtIndex:nIndex];
        photoScrollViewController.bShowImageNumBarBtn = YES;
        if([self.parentController isKindOfClass:[ShareHomeViewController class]])
        {
            [(ShareHomeViewController *)self.parentController hideBottomWhenPushed];
        }
        [self.parentController.navigationController pushViewController:photoScrollViewController animated:YES];
    }
}

//#warning .......................... 查看链接
- (void)tapLinkView
{
    if([self.parentController isKindOfClass:[ShareHomeViewController class]])
    {
        [(ShareHomeViewController *)self.parentController hideBottomWhenPushed];
    }
    
    [BusinessCommon checkShareURLJump:_blogVo.strShareLink parent:self.parentController];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIViewController *parentController = (UIViewController *)self.delegate;
    if(actionSheet.tag == 1001)
    {
        if (buttonIndex == 0)
        {
            //屏蔽
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"屏蔽后，将不再收到对方的留言和发送的消息"
                                                                     delegate:self
                                                            cancelButtonTitle:@"取消"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:@"确定",nil];
            actionSheet.tag = 1002;
            [actionSheet showInView:self];
        }
        else if (buttonIndex == 1)
        {
            //举报
            [BusinessCommon getReportUserInfoList:self.contentView result:^(NSMutableArray *aryReportInfo) {
                if (aryReportInfo)
                {
                    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:_blogVo.strCreateByName
                                                                             delegate:self
                                                                    cancelButtonTitle:nil
                                                               destructiveButtonTitle:nil
                                                                    otherButtonTitles:nil];
                    
                    for (KeyValueVo *keyValueVo in aryReportInfo)
                    {
                        [actionSheet addButtonWithTitle:keyValueVo.strValue];
                    }
                    
                    [actionSheet addButtonWithTitle:@"取消"];
                    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons-1;
                    actionSheet.tag = 1003;
                    
                    [actionSheet showInView:self];
                }
            }];
            
            
        }
    }
    else if(actionSheet.tag == 1002)
    {
        //屏蔽
        if (buttonIndex == 0)
        {
            [Common showProgressView:nil view:parentController.view modal:NO];
            [ShareService shieldUserByID:_blogVo.strCreateBy result:^(ServerReturnInfo *retInfo) {
                [Common hideProgressView:parentController.view];
                if (retInfo.bSuccess)
                {
                    [self.delegate shareListCellAction:0 data:_blogVo];
                    [Common bubbleTip:@"屏蔽成功" andView:parentController.view];
                }
                else
                {
                    [Common tipAlert:retInfo.strErrorMsg];
                }
            }];
        }
    }
    else if(actionSheet.tag == 1003)
    {
        //举报
        [BusinessCommon getReportUserInfoList:self.contentView result:^(NSMutableArray *aryReportInfo) {
            if (aryReportInfo && buttonIndex<aryReportInfo.count)
            {
                KeyValueVo *keyValueVo = aryReportInfo[buttonIndex];
                
                //"blog"：分享；"vote": 投票；"qa":问答；"answer":回答；
                NSString *strReportRefType;
                if ([_blogVo.strBlogType isEqualToString:@"qa"])
                {
                    strReportRefType = @"Q";
                }
                else
                {
                    strReportRefType = @"B";
                }
                
                ReportUserVo *reportVo = [[ReportUserVo alloc]init];
                reportVo.strReportUserID = _blogVo.strCreateBy;
                reportVo.strReportRefID = _blogVo.streamId;
                reportVo.strReportRefType = strReportRefType;
                reportVo.strReasonID = keyValueVo.strKey;
                
                [Common showProgressView:nil view:parentController.view modal:NO];
                [ShareService reportUser:reportVo result:^(ServerReturnInfo *retInfo) {
                    [Common hideProgressView:parentController.view];
                    if (retInfo.bSuccess)
                    {
                        [Common bubbleTip:@"举报成功" andView:parentController.view];
                    }
                    else
                    {
                        [Common tipAlert:retInfo.strErrorMsg];
                    }
                }];
            }
        }];
    }
}



// add by fjz 5.11
- (void)tapHeaderViewAction:(CommonHeaderView *)headerView
{
    UserProfileViewController *userProfileViewController = [[UserProfileViewController alloc]init];
    userProfileViewController.strUserID = _blogVo.strCreateBy;
    if ([self.currentViewController isKindOfClass:[ShareListViewController class]]) {
        ShareListViewController *shareListVC = (ShareListViewController *)self.currentViewController;
        [shareListVC.shareHomeViewController hideBottomWhenPushed];
        [shareListVC.shareHomeViewController.navigationController pushViewController:userProfileViewController animated:YES];
    } else
        [self.currentViewController.navigationController pushViewController:userProfileViewController animated:YES];
    
}

- (UIViewController *)currentViewController
{
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

@end
