//
//  buttonView.h
//  NssmcWskProj
//
//  Created by MacBook on 16/5/25.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface buttonView : UIView
@property (strong, nonatomic) IBOutlet UIButton *setOutButton;
@property (strong, nonatomic) IBOutlet UIButton *confirmButton;
@property (strong, nonatomic) IBOutlet UIButton *addRecordButton;

- (void)updateButton:(id)target action:(SEL)buttonAction judge:(BOOL)judge buttonTitle:(NSString *)titleButton color1:(UIColor *)color1 color2:(UIColor *)color2;
- (void)setButton:(UIButton *)button color:(UIColor *)color;
@end
