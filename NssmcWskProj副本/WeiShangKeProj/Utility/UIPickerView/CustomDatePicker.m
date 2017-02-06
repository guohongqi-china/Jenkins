//
//  CustomPicker.m
//  Sloth
//
//  Created by 焱 孙 on 13-5-2.
//
//

#import "CustomDatePicker.h"
#import "UIViewExt.h"

@interface CustomDatePicker ()
{
    
}

@end

@implementation CustomDatePicker

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andDelegate:(id<CustomDatePickerDelegate>)tempDelegate
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.delegate = tempDelegate;
        self.backgroundColor = [UIColor whiteColor];
        
        self.pickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, kScreenWidth, 216)];
        self.pickerView.datePickerMode = UIDatePickerModeDate;
        [self addSubview:self.pickerView];
        
        UIView *viewToolBar = [[UIView alloc] initWithFrame: CGRectMake(0, 0, kScreenWidth, 44)];
        viewToolBar.backgroundColor = COLOR(235, 235, 235, 1.0);
        [self addSubview:viewToolBar];
        
        UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeSystem];
        btnDone.frame = CGRectMake(kScreenWidth-70, 0, 70, 44);
        [btnDone setTitle:@"完成" forState:UIControlStateNormal];
        [btnDone setTitleColor:COLOR(20, 111, 223, 1.0) forState:UIControlStateNormal];
        [btnDone addTarget:self action:@selector(doneClick) forControlEvents:UIControlEventTouchUpInside];
        [viewToolBar addSubview:btnDone];
        
        UIButton *btnCacnel = [UIButton buttonWithType:UIButtonTypeSystem];
        btnCacnel.frame = CGRectMake(0, 0, 70, 44);
        [btnCacnel setTitle:@"取消" forState:UIControlStateNormal];
        [btnCacnel setTitleColor:COLOR(20, 111, 223, 1.0) forState:UIControlStateNormal];
        [btnCacnel addTarget:self action:@selector(cancelClick) forControlEvents:UIControlEventTouchUpInside];
        [viewToolBar addSubview:btnCacnel];
    }
    return self;
}

-(void)doneClick
{
    [self.delegate doneDatePickerButtonClick:self];
}

-(void)cancelClick
{
    [self.delegate cancelDatePickerButtonClick:self];
}

@end
