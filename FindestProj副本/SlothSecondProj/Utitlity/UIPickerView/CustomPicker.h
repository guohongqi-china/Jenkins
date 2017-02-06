//
//  CustomPicker.h
//  Sloth
//
//  Created by 焱 孙 on 13-5-2.
//
//

#import <UIKit/UIKit.h>

#define CUSTOM_PICKER_H 260

@protocol CustomPickerDelegate;

@interface CustomPicker : UIView

@property(nonatomic,retain)UIPickerView *pickerView;
@property(nonatomic,retain)UIBarButtonItem *btnDoneItem;
@property(nonatomic,weak)id<CustomPickerDelegate,UIPickerViewDataSource,UIPickerViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame andDelegate:(id<CustomPickerDelegate,UIPickerViewDataSource,UIPickerViewDelegate>)tempDelegate;
- (void)doneClick;
- (NSInteger)getSelectedRowNum;
- (void)hideCancelButton;

@end


@protocol CustomPickerDelegate<NSObject>
@optional
- (void)donePickerButtonClick:(CustomPicker*)pickerViewCtrl;
- (void)cancelPickerButtonClick:(CustomPicker*)pickerViewCtrl;

@end