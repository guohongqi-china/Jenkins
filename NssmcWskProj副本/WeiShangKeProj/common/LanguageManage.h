//
//  LanguageManage.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 7/4/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LanguageManage : NSObject

+ (NSString *)getCurrLanguage;
+ (NSString *)getUserDefaultLanguage;
+ (void)setCurrLanguage:(NSString *)strLanguage;
+ (void)initLanguageSetting;
+ (void)updateLanguageToServer;

@end
