//
//  EditIntegralView.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 4/14/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InsetsTextField.h"
#import "UserVo.h"

@class EditIntegralView;
@protocol EditIntegralDelegate <NSObject>
- (void)changeIntegralAction:(EditIntegralView *)editIntegralView integral:(NSString*)strNum user:(UserVo*)userVo;
@end

@interface EditIntegralView : UIView<UITextFieldDelegate,UITextViewDelegate>

@property(nonatomic,weak)id<EditIntegralDelegate> delegate;

@property(nonatomic,strong)UIView *viewContainer;
@property(nonatomic,strong)UILabel *lblTitle;
@property(nonatomic,strong)UIButton *btnCancel;
@property(nonatomic,strong)UIButton *btnSave;

@property(nonatomic,strong)UIButton *btnAdd;
@property(nonatomic,strong)UIButton *btnMinus;
@property(nonatomic,strong)UIView *viewLine;

@property(nonatomic,strong)InsetsTextField *txtIntegral;
@property(nonatomic,strong)UILabel *lblTip;

@property(nonatomic,strong)UILabel *lblRemark;
@property(nonatomic,strong)UITextView *txtViewRemark;

@property(nonatomic,strong)UserVo *userVo;
@property(nonatomic)NSInteger nSelectedTag;

-(void)hideView;

@end
