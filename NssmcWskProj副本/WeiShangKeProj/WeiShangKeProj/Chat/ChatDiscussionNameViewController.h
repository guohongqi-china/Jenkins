//
//  ChatDiscussionNameViewController.h
//  ChinaMobileSocialProj
//
//  Created by 焱 孙 on 14-5-27.
//
//

#import "QNavigationViewController.h"
#import "ChatObjectVo.h"

@interface ChatDiscussionNameViewController : QNavigationViewController<UITextFieldDelegate>

@property(nonatomic,strong) ChatObjectVo *m_chatObjectVo;
@property(nonatomic,strong) UITextField *txtName;

@end
