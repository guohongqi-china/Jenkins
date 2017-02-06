//
//  EditTitleViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/15.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonViewController.h"

@protocol EditTitleDelegate <NSObject>

- (void)completedEditShareTitle:(NSString *)strText;

@end

@interface EditTitleViewController : CommonViewController

@property (nonatomic,weak) id<EditTitleDelegate> delegate;

- (void)setText:(NSString *)strText;

@end
