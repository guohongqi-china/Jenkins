//
//  KTPhotoView.h
//  Sample
//
//  Created by Kirby Turner on 2/24/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "YLGIFImage.h"
//#import "YLImageView.h"

@class KTPhotoScrollViewController;


@interface KTPhotoView : UIScrollView <UIScrollViewDelegate>
{
   UIImageView *imageView_;
   KTPhotoScrollViewController *scroller_;
   NSInteger index_;
}

//@property (nonatomic, retain) YLImageView *imgViewGIF;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, assign) KTPhotoScrollViewController *scroller;
@property (nonatomic, assign) NSInteger index;

//转发和分享GIF图片 add by sunyan
@property (nonatomic, assign) BOOL bIsGIF;
@property (nonatomic, retain) UIImage *imgThumb;
@property (nonatomic, retain) NSData *dataGIF;
//end

- (void)setImage:(UIImage *)newImage;
- (void)setGifImage:(NSData*)data;
- (void)turnOffZoom;

- (CGPoint)pointToCenterAfterRotation;
- (CGFloat)scaleToRestoreAfterRotation;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)restoreCenterPoint:(CGPoint)oldCenter scale:(CGFloat)oldScale;


@end
