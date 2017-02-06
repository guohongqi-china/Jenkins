//
//  ResizeImage.h
//  ChinaMobileSocialProj
//
//  Created by dne on 13-11-26.
//
//

#import <Foundation/Foundation.h>

@interface ResizeImage : NSObject

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;

@end
