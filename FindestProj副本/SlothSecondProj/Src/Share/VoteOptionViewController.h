//
//  VoteOptionViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/1.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "VoteVo.h"

@protocol VoteOptionDelegate <NSObject>

@optional
-(void)completeVoteAction:(VoteVo *)voteVo;

@end

@interface VoteOptionViewController : CommonViewController<UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property(nonatomic,weak) id<VoteOptionDelegate> delegate;

//option data
@property(nonatomic,strong)VoteVo *voteVo;
@property (nonatomic)NSInteger nButtonTag;

@property(nonatomic,strong)UIImagePickerController *photoController;
@property(nonatomic,strong)UIImagePickerController *photoAlbumController;

@property(nonatomic)NSInteger nMinOption;//最小项
@property(nonatomic)NSInteger nMaxOption;//最大项

- (void)swichValueChanged:(BOOL)bOn;
- (void)refreshWithVoteVo:(VoteVo *)voteVoData;
- (void)addIconButton:(UIButton *)sender;
- (void)removeVoteOption:(UIButton*)btnRemove;

@end
