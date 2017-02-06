//
//  NSString+NSString_Category.h
//  NssmcWskProj
//
//  Created by MacBook on 16/5/23.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NSString_Category)
- (CGSize)sizeWithFont:(UIFont *)font maxW:(CGFloat)maxW;
- (CGSize)sizeWithFont:(UIFont *)font;
+ (void)sizeWithFontWithString:(UIFont *)font UIView:(UILabel *)sizeForView textString:(NSString *)string;
@end
