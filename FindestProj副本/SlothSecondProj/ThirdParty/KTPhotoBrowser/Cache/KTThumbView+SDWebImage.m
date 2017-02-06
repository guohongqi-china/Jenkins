//
//  KTThumbView+SDWebImage.m
//  Sample
//
//  Created by Henrik Nyh on 3/18/10.
//

#import "KTThumbView+SDWebImage.h"
#import "SDWebImageManager.h"

@implementation KTThumbView (SDWebImage)

- (void)setImageWithURL:(NSURL *)url {
   [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    [self setThumbImage:placeholder];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:url
                          options:0
                         progress:nil
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                            if (image) {
                                // do something with image
                                [self setThumbImage:image];
                            }
                        }];
}
@end
