//
//  NSData+AESEncryption.h
//  DNENetworkFramework
//
//  Created by yuson on 12-5-31.
//  Copyright (c) 2012年 DNE. All rights reserved.
//

#import <Foundation/Foundation.h>

/*********************************
 可配置AES加密类型，默认为AES128，若需要
 配置为AES256，在此前增加
 #define ENCRYPTION_AES256即可
 *********************************/
#ifdef ENCRYPTION_AES256
    #define AES_KEY_SIZE        32
    #define AES_BLOCK_SIZE      32
#elif defined ENCRYPTION_AES192
    #define AES_KEY_SIZE        24
    #define AES_BLOCK_SIZE      24
#else
    #define AES_KEY_SIZE        16
    #define AES_BLOCK_SIZE      16
#endif

@class NSString;

@interface NSData (Encryption)

/*********************************************
 key字符串的最大长度分别为：
 AES128 - 16个字符（对应128bit）
 AES192 - 24个字符
 AES256 - 32个字符
 注：当key长度超过限制时，自动截取对应最大长度
 *********************************************/
- (NSData *)AESEncryptWithKey:(NSString *)key;   //加密
- (NSData *)AESDecryptWithKey:(NSString *)key;   //解密
- (NSString *)newStringInBase64FromData;         //追加64编码
+ (NSString*)base64encode:(NSString*)str;        //同上64编码

@end