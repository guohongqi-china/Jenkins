//
//  NSDataAdditions.h
//
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSString;

@interface NSData (Additions)

- (NSData *)AES128EncryptWithKey;
- (NSData *)AES128DecryptWithKey;
- (NSString *)newStringInBase64FromData;

@end