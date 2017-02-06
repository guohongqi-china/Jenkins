//
//  UserCenterViewController.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-3-17.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "UserDetailViewController.h"
#import "UserVo.h"
#import "MessageVo.h"
#import "ChatObjectVo.h"

@interface UserCenterViewController : QNavigationViewController<UIScrollViewDelegate,MBProgressHUDDelegate>

//////////////
@property(nonatomic,strong)UserVo *m_userVo;

@property(nonatomic,strong)UserDetailViewController *userDetailViewController;

//头信息///////////////////////////////////////////////////////
@property(nonatomic,strong)UIScrollView *m_scrollView;

@property(nonatomic,strong)UIImageView *imgViewTopBK;
@property(nonatomic,strong)UIImageView *imgViewHead;
@property(nonatomic,strong)UIImageView *imgViewGender;
@property(nonatomic,strong)UILabel *lblName;

@property(nonatomic,strong)UIButton *btnShareComment;               //分享
@property(nonatomic,strong)UIButton *btnQACount;                    //问答
@property(nonatomic,strong)UIButton *btnIntegration;                //积分

@property(nonatomic,strong)UIButton *btnUserDetail;
@property(nonatomic,strong)UIImageView *imgViewUserDetailArrow;

//签名
@property(nonatomic,strong)UIView *viewSignature;
@property(nonatomic,strong)UILabel *lblSignature;

//职位、电话、邮箱///////////////////////////////////////////////////////////////
@property (nonatomic, strong) UIImageView *imgViewMiddleBK;
@property (nonatomic, strong) UILabel *lblPosition;
@property (nonatomic, strong) UIImageView *imgViewPositionIcon;

@property (nonatomic, strong) UILabel *lblPhoneNum;
@property (nonatomic, strong) UIImageView *imgViewPhoneIcon;

@property (nonatomic, strong) UILabel *lblEmail;
@property (nonatomic, strong) UIImageView *imgViewEmailIcon;

//分享、问答、相册///////////////////////////////////////////////////////////////
//share
@property (nonatomic, strong) UIImageView *imgViewBottomBK;
@property (nonatomic, strong) UIImageView *imgViewShareIcon;
@property (nonatomic, strong) UILabel *lblShare;
@property (nonatomic, strong) UILabel *lblShareNum;
@property (nonatomic, strong) UIImageView *imgViewShareArrow;
@property (nonatomic, strong) UIButton *btnShare;

//question and answer
@property (nonatomic, strong) UIImageView *imgViewQAIcon;
@property (nonatomic, strong) UILabel *lblQA;
@property (nonatomic, strong) UILabel *lblQANum;
@property (nonatomic, strong) UIImageView *imgViewQAArrow;
@property (nonatomic, strong) UIButton *btnQA;

//album
@property (nonatomic, strong) UIImageView *imgViewAlbumIcon;
@property (nonatomic, strong) UILabel *lblAlbum;
@property (nonatomic, strong) UILabel *lblAlbumNum;
@property (nonatomic, strong) UIImageView *imgViewAlbumArrow;
@property (nonatomic, strong) UIButton *btnAlbum;

//bottom button
@property(nonatomic,strong)UIButton *btnVoice;
@property(nonatomic,strong)UIButton *btnAskQuestion;
@property(nonatomic,strong)UIButton *btnSendMsg;
@property(nonatomic,strong)ChatObjectVo *m_chatObjectVo;
@property(nonatomic,strong)MBProgressHUD *hud;

@end
