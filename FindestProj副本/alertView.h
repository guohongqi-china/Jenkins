//
//  alertView.h
//  FindestProj
//
//  Created by MacBook on 16/7/20.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cengView.h"
@interface alertView : UIView<UITextFieldDelegate>
{
    cengView *baseView;

}
@property (strong, nonatomic) IBOutlet UITextField *textFieldLabel;


@property (nonatomic, copy) NSString *strId;/** <#注释#> */
@property (nonatomic, strong) UIWindow *keyWin;/** <#注释#> */
- (void)hidden;
- (void)show;
- (void)sdddd;
@end
