//
//  InPutView.h
//  SlothSecondProj
//
//  Created by visionet on 14-3-26.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ToolView.h"

@protocol InPutSendDelegateWithAttach <NSObject>
@optional
-(void)completeSend:(NSString*)strText;
-(void)cancelSend;
@end

@interface InPutView : UIView<ToolViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,weak)id<InPutSendDelegateWithAttach> delegate;
@property (nonatomic,strong)UIView *bgView;
@property (nonatomic,strong)UITextView *inputTextView;
@property (nonatomic,strong)UILabel *titleLab;
@property (nonatomic,strong)UIButton *sendBtn;
@property (nonatomic,strong)UIButton *cancelBtn;
@property (nonatomic,strong)NSString *titleStr;
@property (nonatomic,strong)NSString *requestUrl;
@property (nonatomic,weak)UIViewController *parentController;
@property (nonatomic,strong)NSMutableArray *attachList;
@property (nonatomic,strong)UIButton *previewButton;

//附件选择按钮 工具栏
@property(nonatomic)BOOL keyboardIsShow;//键盘是否显示
@property(nonatomic,strong)UIView *attachView;      //附件(投票、日程、附件)
@property(nonatomic,strong)ToolView *toolView;      //工具栏
@property(nonatomic,strong)UIButton *btnAttach;
@property(nonatomic,strong)UIImageView *imgViewAttachIcon;

//表情
@property(nonatomic,strong)UIButton *btnFace;

-(void)initView;
-(void)doCancel;
-(void)initInputViewControlValue;
- (void)hideAttachView:(BOOL)bHide;

@end
