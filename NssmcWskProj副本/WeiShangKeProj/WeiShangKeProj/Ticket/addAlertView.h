//
//  addAlertView.h
//  NssmcWskProj
//
//  Created by MacBook on 16/5/25.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVAudioRecorderModel.h"
#import "VoiceConverter.h"
#import "RecordView.h"
@class RecordModel;
typedef enum _addAlertViewType{
    addAlertViewTypeForText,
    addAlertViewTypeForImage,
    addAlertViewTypeForSound
}addAlertViewType;

@interface addAlertView : UIView<UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>


@property (nonatomic, assign)  BOOL isAdd;/** <#注释#> */

@property (nonatomic, strong) UIView *SDView;/** <#注释#> */
@property (strong, nonatomic) IBOutlet UIButton *tijiaoButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *inputLine;
@property (strong, nonatomic) IBOutlet UIProgressView *progress;
@property (strong, nonatomic) IBOutlet UIView *judgeView;
@property (strong, nonatomic) IBOutlet UITextField *judgeTextField;
@property (strong, nonatomic) IBOutlet UITextField *inputTextField;
@property (strong, nonatomic) IBOutlet UIView *inputView;
@property (strong, nonatomic) IBOutlet UIButton *normalbutton;
@property (strong, nonatomic) IBOutlet UIButton *abnomalbutton;
@property (strong, nonatomic) IBOutlet UISlider *ProgressSlide;
@property (strong, nonatomic) IBOutlet UIView *baseview;
@property (strong, nonatomic) IBOutlet UIButton *soundButton;
@property (nonatomic, assign) BOOL isNormalEnd;/** 正常完成状态 */

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *vvvv;

@property (nonatomic, strong) UIColor *textColor;/**  */

@property (nonatomic, strong) UILabel *tagLabel;/** <#注释#> */

@property(nonatomic,copy)NSString *imgUrl;
@property (strong, nonatomic) IBOutlet UILabel *label1;
@property (strong, nonatomic) IBOutlet UILabel *label2;

@property (strong, nonatomic) IBOutlet UILabel *label3;
@property (strong, nonatomic) IBOutlet UILabel *label4;
@property (strong, nonatomic) IBOutlet UILabel *label5;
@property (strong, nonatomic) IBOutlet UIImageView *CamerView;

@property (strong, nonatomic) IBOutlet UIImageView *pickerView;

@property (nonatomic, copy)  NSString *percentage;/** <#注释#> */
@property (nonatomic, copy) NSString *malfunctionId;/** <#注释#> */

@property (nonatomic, copy) NSString *detailId;/** <#注释#> */

@property (nonatomic, assign) NSInteger no;/** <#注释#> */

@property (nonatomic, copy) NSString *buttonString;/** <#注释#> */

@property (nonatomic, strong) UIImage *dickerImageView;/** <#注释#> */
@property (strong, nonatomic) IBOutlet UIButton *button;


@property (nonatomic, strong) NSTimer *timer;/** <#注释#> */
@property (nonatomic, strong) RecordView *soundView;/** <#注释#> */


@property (nonatomic, strong) AVAudioRecorderModel *RecordModel;/** <#注释#> */


@property (nonatomic, copy) NSString *guestId;/** <#注释#> */

/** pin码 */
@property (nonatomic, copy) NSString *pinCd;

- (void)updateUI;
@end
