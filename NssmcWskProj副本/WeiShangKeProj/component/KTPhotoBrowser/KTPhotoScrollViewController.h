//
//  KTPhotoScrollViewController.h
//  KTPhotoBrowser
//
//  Created by Kirby Turner on 2/4/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>



@class KTPhotoViewController;
@protocol KTPhotoBrowserDataSource;

@interface KTPhotoScrollViewController : UIViewController<UIScrollViewDelegate, UIActionSheetDelegate> 
{
   id <KTPhotoBrowserDataSource> dataSource_;
   UIScrollView *scrollView_;
   UIToolbar *toolbar_;
   NSUInteger startWithIndex_;
   NSInteger currentIndex_;
   NSInteger photoCount_;
   
   NSMutableArray *photoViews_;

   // these values are stored off before we start rotation so we adjust our content offset appropriately during rotation
   int firstVisiblePageIndexBeforeRotation_;
   CGFloat percentScrolledIntoFirstVisiblePage_;
   
   UIStatusBarStyle statusBarStyle_;

   BOOL statusbarHidden_; // Determines if statusbar is hidden at initial load. In other words, statusbar remains hidden when toggling chrome.
   BOOL isChromeHidden_;
   BOOL rotationInProgress_;
  
   BOOL viewDidAppearOnce_;
   BOOL navbarWasTranslucent_;
   
   NSTimer *chromeHideTimer_;
   
   UIBarButtonItem *nextButton_;
   UIBarButtonItem *previousButton_;
}

@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@property (nonatomic, assign, getter=isStatusbarHidden) BOOL statusbarHidden;

//add by sunyan
@property (nonatomic, retain) UIActivityIndicatorView * activity;
@property (nonatomic, retain) UIImageView *imgViewWaiting;
@property (nonatomic, retain) UIBarButtonItem *btnForward;
@property (nonatomic, retain) UIBarButtonItem *btnShare;
@property (nonatomic, retain) UIBarButtonItem *btnImageNum;
@property (nonatomic, assign) BOOL bShowToolBarBtn;
@property (nonatomic, assign) BOOL bShowImageNumBarBtn;
@property (nonatomic, retain) NSMutableArray *aryImageVo;
//end

- (id)initWithDataSource:(id <KTPhotoBrowserDataSource>)dataSource andStartWithPhotoAtIndex:(NSUInteger)index;
- (void)toggleChromeDisplay;

@end
