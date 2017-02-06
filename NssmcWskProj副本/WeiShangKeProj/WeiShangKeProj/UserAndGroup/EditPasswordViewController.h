//
//  EditPasswordViewController.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-3-18.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "QNavigationViewController.h"

@interface EditPasswordViewController : QNavigationViewController<UITextFieldDelegate>

@property(nonatomic,strong)NSString *strUserID;

@property(nonatomic,strong)UIImageView *imgViewBK;

@property(nonatomic,strong)UILabel *lblCurrentPwd;
@property(nonatomic,strong)UITextField *txtCurrentPwd;

@property(nonatomic,strong)UILabel *lblNewPwd;
@property(nonatomic,strong)UITextField *txtNewPwd;

@property(nonatomic,strong)UILabel *lblConfirmNewPwd;
@property(nonatomic,strong)UITextField *txtConfirmNewPwd;

@end
