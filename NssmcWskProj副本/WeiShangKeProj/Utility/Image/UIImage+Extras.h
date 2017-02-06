//
//  UIImage+Extras.h
//  Sloth
//
//  Created by Ann Yao on 12-9-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//



@interface UIImage (Extras)

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;

- (UIImage *) roundedWithSize:(CGSize)size;

@end
