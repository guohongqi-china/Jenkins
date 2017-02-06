//
//  buttonView.m
//  NssmcWskProj
//
//  Created by MacBook on 16/5/25.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "buttonView.h"

@implementation buttonView

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        
        
        
    }
    return self;
}
//COLOR(64, 161, 132, 1) 
- (void)updateButton:(id)target action:(SEL)buttonAction judge:(BOOL)judge buttonTitle:(NSString *)titleButton color1:(UIColor *)color1 color2:(UIColor *)color2{
    
    [self setButton:self.setOutButton color:color1];
    [self setButton:self.confirmButton color:color2 ];
    [self setButton:self.addRecordButton color:color2 ];
    if (judge) {
        _setOutButton.userInteractionEnabled = YES;
        _confirmButton.userInteractionEnabled = NO;
        _addRecordButton.userInteractionEnabled = NO;
    }else{
        _setOutButton.userInteractionEnabled = NO;
        _setOutButton.userInteractionEnabled = YES;
        _setOutButton.userInteractionEnabled = YES;
    }
    [self.setOutButton addTarget:target action:buttonAction forControlEvents:(UIControlEventTouchUpInside)];
    [self.confirmButton addTarget:target action:buttonAction forControlEvents:(UIControlEventTouchUpInside)];
    [self.addRecordButton addTarget:target action:buttonAction forControlEvents:(UIControlEventTouchUpInside)];

}

- (void)setButton:(UIButton *)button color:(UIColor *)color {
    button.layer.borderWidth = 1;
//    [button setTitleColor:color forState:(UIControlStateNormal)];
    [button setBackgroundColor:color];
    button.layer.borderColor = [color CGColor];
}




@end
