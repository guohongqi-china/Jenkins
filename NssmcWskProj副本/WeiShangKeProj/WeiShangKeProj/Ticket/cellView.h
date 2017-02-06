//
//  cellView.h
//  NssmcWskProj
//
//  Created by MacBook on 16/5/31.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "topModel.h"
@class DrawRound;
@class cellModel;
@class AnimationImage;
@class GHQlineView;
#import "buttonAndLabel.h"
#import "AVAudioRecorderModel.h"
#import "VoiceConverter.h"
typedef enum _cellViewContentType{
    cellViewTypeForContentText,
    cellViewTypeForImage,
    cellViewTypeForSound
}cellViewContentType;

typedef void(^myBlock)(NSString *str);

@class cellView;
@protocol cellViewDelegate <NSObject>



- (void)cellViewiImage:(NSString *)image;
- (void)CellViewUrlImage:(NSString *)urlString;

@end
@interface cellView : UIView<AVAudioRecorderModelDelegate,AVAudioPlayerDelegate>

@property (nonatomic, strong) GHQlineView *progressView;/** <#注释#> */

@property (nonatomic, copy) myBlock block;/** <#注释#> */

@property (nonatomic, assign) id<cellViewDelegate> delegate;/** <#注释#> */

@property (strong, nonatomic)   AVAudioPlayer    *player;

@property(nonatomic,strong) AVAudioPlayer *audioPlayer;

@property (nonatomic, strong) buttonAndLabel *soundButton;/** <#注释#> */
@property (nonatomic, strong) AVAudioRecorderModel *RecordModel;/** <#注释#> */

@property (nonatomic, strong) AnimationImage *senderButton;/** <#注释#> */
@property (nonatomic, strong) topModel *cellModel;/** <#注释#> */
@property (nonatomic, assign) cellViewContentType cellViewType;/** <#注释#> */

@property (nonatomic, strong) DrawRound *drawRound;/** <#注释#> */

@property (nonatomic, strong) UILabel *updateLabel;/** <#注释#> */

@property (nonatomic, strong) UILabel *timeLabel;/** <#注释#> */

@property (nonatomic, strong) UILabel *contentLabel;/** <#注释#> */

@property (nonatomic, strong) UIImageView *ImageButton;/** <#注释#> */

@property (nonatomic, strong) UIImageView *baseImageView;/** <#注释#> */

@property (nonatomic, copy) NSString *pathString;/** <#注释#> */

@property (nonatomic, strong) UILabel *progressLabel;/** <#注释#> */
- (CGFloat )getHeight;
//@property (nonatomic, strong) cellModel *MODEL;/** <#注释#> */
@end
