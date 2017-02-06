//
//  ImageViewForPickImage.h
//  NssmcWskProj
//
//  Created by MacBook on 16/5/31.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GHQlineView;
@interface ImageViewForPickImage : UIScrollView<UIScrollViewDelegate>
{
    UIView *grayView;
    GHQlineView *progressV;
}



@property (nonatomic, assign) NSInteger tagImage;/** <#注释#> */

@property (nonatomic, strong) NSArray *itemsArray;/** <#注释#> */

@property (nonatomic, strong) UIWindow *baseWindow;/** <#注释#> */

@property (nonatomic, strong) UILabel *numberLabel;/** <#注释#> */
@end
