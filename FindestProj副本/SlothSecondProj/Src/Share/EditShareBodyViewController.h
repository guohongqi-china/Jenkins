//
//  EditShareBodyViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/14.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonViewController.h"
#import "BlogVo.h"

typedef NS_ENUM(NSInteger,EditShareBodyType)
{
    EditShareBodyBlogType,      //发分享模块
    EditShareBodyAnswerType     //问答 - 回答模块
};

@protocol EditShareBodyDelegate <NSObject>

@optional
- (void)completedEditShareBody:(NSAttributedString*)attriText video:(NSURL*)urlVideo link:(NSString *)strLink;
- (void)completedEditShareBodyWithAnswer:(BlogVo*)answerVo;

@end

@interface EditShareBodyViewController : CommonViewController

@property (nonatomic) EditShareBodyType editShareBodyType;
@property (nonatomic,strong) NSString *strRefID;

@property (nonatomic,weak) id<EditShareBodyDelegate> delegate;

- (void)setText:(NSAttributedString *)attriText link:(NSString *)strLink;

@end
