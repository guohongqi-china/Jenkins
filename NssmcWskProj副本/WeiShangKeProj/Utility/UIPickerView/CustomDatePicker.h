//
//  CustomPicker.h
//  Sloth
//
//  Created by 焱 孙 on 13-5-2.
//
//

#import <UIKit/UIKit.h>

@protocol CustomDatePickerDelegate;

@interface CustomDatePicker : UIView

@property(nonatomic,retain)UIDatePicker *pickerView;
@property(nonatomic,retain)UIBarButtonItem *btnDoneItem;
@property(nonatomic,assign)id<CustomDatePickerDelegate> delegate; 

-(id)initWithFrame:(CGRect)frame andDelegate:(id<CustomDatePickerDelegate>)tempDelegate;

@end


@protocol CustomDatePickerDelegate<NSObject>
@optional
- (void)doneDatePickerButtonClick:(CustomDatePicker*)pickerViewCtrl;
- (void)cancelDatePickerButtonClick:(CustomDatePicker*)pickerViewCtrl;

@end