//
//  popView.h
//  FindestProj
//
//  Created by MacBook on 16/7/22.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cengView.h"
@interface popView : UIView<UITextFieldDelegate>
{
    cengView *baseView;
    
}
@property (nonatomic, copy) NSString *strID;/** <#注释#> */
@end
