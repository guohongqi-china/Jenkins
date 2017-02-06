//
//  NSString+NSString_Category.m
//  NssmcWskProj
//
//  Created by MacBook on 16/5/23.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "NSString+NSString_Category.h"

@implementation NSString (NSString_Category)
- (CGSize)sizeWithFont:(UIFont *)font maxW:(CGFloat)maxW
{
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = font;
    CGSize maxSize = CGSizeMake(maxW, MAXFLOAT);
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

- (CGSize)sizeWithFont:(UIFont *)font
{
    return [self sizeWithFont:font maxW:MAXFLOAT];
}
+ (void)sizeWithFontWithString:(UIFont *)font UIView:(UILabel *)sizeForView textString:(NSString *)string{
    sizeForView.font = font;
    sizeForView.text = string;
    [sizeForView sizeToFit];
    
}

@end
