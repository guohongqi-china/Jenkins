//
//  ToolView.h
//  ChinaMobileSocialProj
//
//  Created by dne on 13-11-20.
//
//

#import <UIKit/UIKit.h>
#import "SMPageControl.h"

@protocol ToolViewDelegate <NSObject>

@optional
- (void)cameraButton:(id)sender;
- (void)photoButton:(id)sender;
- (void)videoButton:(id)sender;

@end

@interface ToolView : UIView<UIScrollViewDelegate>
{
    UIScrollView *contentView;
}

@property(nonatomic,weak) UITextView *textView;

@property(nonatomic,strong) UIScrollView *scrollViewFacial;         //表情视图
@property(nonatomic,strong) UIView *viewAttach;                     //附件视图

@property(nonatomic,strong) SMPageControl *pageControlFace;
@property(nonatomic) NSInteger nPage;

@property (nonatomic, assign) id<ToolViewDelegate> toolViewDelegate;

- (void)addImageToContent:(UIImage *)image index:(NSUInteger)index target:(id)target action:(SEL)action;
- (void)deleteSubView:(NSUInteger)index;
- (void)deleteAllSubView;

@end