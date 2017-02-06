//
//  TopView.h
//  NssmcWskProj
//
//  Created by MacBook on 16/5/24.
//  Copyright © 2016年 visionet. All rights reserved.
//

typedef enum _judgeImageOrData{
    EqualToImage,
    EqualToData
}JudgeImageOrData;

#import <UIKit/UIKit.h>
#import "buttonAndLabel.h"
#import "topModelFrame.h"
#import "RepairView.h"

@class ImageCollectionView;
@class viewToShowInformation;
@class ImageScrollview;

@protocol TopViewDelegate<NSObject>

- (void)pinCodeVerification:(void (^)(NSString *pinText))block;

@end

@interface TopView : UIView
{
    UILabel *progressLabel;
//    buttonAndLabel *soundeButton;
}
/** 代理 */
@property (nonatomic, assign) id<TopViewDelegate> delegate;
/** pin码验证button */
@property (nonatomic, strong) UIButton *pinCodeButton;
@property (nonatomic, strong) NSMutableArray *itemsArray;/** <#注释#> */
@property (nonatomic, assign) JudgeImageOrData judgeImageOrData;/** <#注释#> */
@property (nonatomic, strong) buttonAndLabel *soundeButton;/** <#注释#> */
@property (nonatomic, strong)  topModelFrame *topModelFrame;/** <#注释#> */
@property (nonatomic, strong) UIProgressView *progressView;/** <#注释#> */

@property (nonatomic, strong) UILabel *titleLabel ;/** <#注释#> */
@property (nonatomic, strong) UILabel *contentLabel;/** <#注释#> */

@property (nonatomic, strong) ImageCollectionView *describeImage;/** <#注释#> */

@property (nonatomic, strong) UIButton *senderButton;/** <#注释#> */

@property (nonatomic, strong) viewToShowInformation *view1;/** <#注释#> */

@property (nonatomic, strong) viewToShowInformation *view2;/** <#注释#> */
@property (nonatomic, strong) viewToShowInformation *view3;/** <#注释#> */
@property (nonatomic, strong) RepairView *view4;/** 可维修时间 */
@property (nonatomic, strong) viewToShowInformation *view5;/** <#注释#> */

@property (nonatomic, strong) viewToShowInformation *view6;/** <#注释#> */
@property (nonatomic, strong) viewToShowInformation *view7;/** <#注释#> */
@property (nonatomic, strong) viewToShowInformation *view8;/** <#注释#> */
/**
 * 9和10是后来添加的两个view
 */
@property (nonatomic, strong) viewToShowInformation *view9;/** 客户区分 */
@property (nonatomic, strong) viewToShowInformation *view10;/** 约定上门时间 */

@property (nonatomic, strong) NSMutableArray *timeArray;/** <#注释#> */


@end
