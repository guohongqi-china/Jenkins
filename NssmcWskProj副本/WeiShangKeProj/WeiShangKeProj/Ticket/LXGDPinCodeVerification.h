//
//  LXGDPinCodeVerification.h
//  NssmcWskProj
//
//  Created by MacBook on 16/11/24.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXGDPinCodeVerification : UIView
- (void)show:(void (^)(NSString *text))finshedInput;
- (void)hidden;
@end
