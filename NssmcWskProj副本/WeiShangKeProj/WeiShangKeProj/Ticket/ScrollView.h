//
//  ScrollView.h
//  NssmcWskProj
//
//  Created by MacBook on 16/6/23.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDWebImageDataSource.h"

@interface ScrollView : UIScrollView<UIScrollViewDelegate>
{
    UIImageView *imageViewe;
}

@property (nonatomic, strong) UILabel *textLabel;/** <#注释#> */

@property (nonatomic, strong) NSMutableArray *itemsArray;/** <#注释#> */

@property (nonatomic, strong) UIImageView *tagView;/** <#注释#> */

@property (nonatomic, assign) NSInteger tagNumber;/** <#注释#> */


- (void)scrollViewSetAnimation;






@end
