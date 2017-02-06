//
//  UserEditViewController.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-3-17.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "CustomDatePicker.h"
#import "UserVo.h"

@interface UserEditViewController : QNavigationViewController<UITextFieldDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,CustomDatePickerDelegate>

@property(nonatomic,strong)UserVo *m_userVo;
@property(nonatomic,strong)NSMutableDictionary *dicOffsetY; //键盘视图，调整位置

////////////////////////////////////////////////////////////
@property(nonatomic,strong)UIScrollView *m_scrollView;

@property(nonatomic,strong)UIImageView *imgViewTopBK;
@property(nonatomic,strong)UIButton *btnHead;
@property(nonatomic,strong)UIImageView *imgViewHead;
@property(nonatomic,strong)UIImageView *imgViewHeadArrow;

@property(nonatomic,strong)UIImageView *imgViewMiddleBK;
@property(nonatomic,strong)UILabel *lblName;
@property(nonatomic,strong)UITextField *txtName;

@property(nonatomic,strong)UILabel *lblBirthday;
@property(nonatomic,strong)UITextField *txtBirthday;
@property(nonatomic,strong)UIButton *btnBirthday;
@property(nonatomic,strong)CustomDatePicker *pickerDate;

@property(nonatomic,strong)UILabel *lblGender;
@property(nonatomic,retain)UITextField *txtGender;
@property(nonatomic,retain)UIButton *btnGender;

@property(nonatomic,strong)UILabel *lblPosition;
@property(nonatomic,strong)UITextField *txtPosition;

@property(nonatomic,strong)UILabel *lblPhoneNum;
@property(nonatomic,strong)UITextField *txtPhoneNum;

@property(nonatomic,strong)UILabel *lblViewPhone;
@property(nonatomic,strong)UISwitch *switchViewPhone;

@property(nonatomic,strong)UILabel *lblQQ;
@property(nonatomic,strong)UITextField *txtQQ;

@property(nonatomic,strong)UILabel *lblEmail;
@property(nonatomic,strong)UITextField *txtEmail;

@property(nonatomic,strong)UILabel *lblAddress;
@property(nonatomic,strong)UITextField *txtAddress;

@property(nonatomic,strong)UILabel *lblSignature;
@property(nonatomic,strong)UITextField *txtSignature;

//modify pwd
@property (nonatomic, strong)UIImageView *imgViewBottomBK;
@property(nonatomic,strong)UIButton *btnModifyPwd;
@property(nonatomic,strong)UIImageView *imgViewPwd;
@property(nonatomic,strong)UIImageView *imgViewPwdArrow;

//UIImagePickerController
@property(nonatomic,retain)UIImagePickerController *photoController;
@property(nonatomic,retain)UIImagePickerController *photoAlbumController;

@end
