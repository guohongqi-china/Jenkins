//
//  UIImage+UIImageScale.h
//  CorpKnowlGroup
//
//  Created by Ann Yao on 12-7-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UIImageScale)

-(UIImage*)getSubImage:(CGRect)rect;  
-(UIImage*)scaleToSize:(CGSize)size;
-(UIImage *)getSquareImage;

@end
