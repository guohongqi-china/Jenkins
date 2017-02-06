//
//  soundView.m
//  NssmcWskProj
//
//  Created by MacBook on 16/6/12.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "soundView.h"
#import "SDWebImageDataSource.h"
@implementation soundView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame ]) {
        _soundImageView = [[UIImageView alloc]init];
        _soundImageView.image = [UIImage imageNamed:@"ReceiverVoiceNodePlaying@2x"];
        
        _soundLabel = [[UILabel alloc]init];
    
        
        NSArray *imageArray = @[[UIImage imageNamed:@"ReceiverVoiceNodePlaying001@2x"],[UIImage imageNamed:@"ReceiverVoiceNodePlaying002@2x"],[UIImage imageNamed:@"ReceiverVoiceNodePlaying003@2x"]];
        _soundImageView.animationImages = imageArray;
        _soundImageView.animationDuration = 1.0;
        _soundImageView.animationRepeatCount = 0;
        
        [self addSubview:_soundImageView];
        [self addSubview:_soundLabel];

        
        
        
        
    }
    return self;
}







@end
