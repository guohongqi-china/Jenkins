//
//  EmailInputView.h
//  WeiShangKeProj
//
//  Created by 焱 孙 on 15/6/3.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSTokenField.h"

@class EmailInputView;

@protocol EmailInputViewDelegate <NSObject>
@optional
-(void)completeEditEmail:(EmailInputView*)emailInputView email:(NSMutableArray*)aryEmail;
-(void)cancelEditEmail:(EmailInputView*)emailInputView;
@end

@interface EmailInputView : UIView<JSTokenFieldDelegate>

@property (nonatomic,weak)id<EmailInputViewDelegate> delegate;
@property (nonatomic,strong)UIView *bgView;
@property (nonatomic,strong)UIScrollView *scrollViewText;
@property (nonatomic,strong)JSTokenField *inputTextView;
@property (nonatomic,strong)UILabel *titleLab;
@property (nonatomic,strong)UIButton *sendBtn;
@property (nonatomic,strong)UIButton *cancelBtn;
@property (nonatomic,strong)NSString *titleStr;

@property (nonatomic,strong)NSMutableArray *aryData;

-(void)initView;
-(void)doCancel;
-(void)initInputViewControlValue;
-(void)dismissEmailView;

@end
