//
//  NSDataAdditions.m
//
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSDataAdditions.h"
#import <CommonCrypto/CommonCryptor.h>

static char base64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static NSString *strKey = @"slothvisionetkey";

@implementation NSData (Additions)

@class NSString;

- (NSData *)AES128EncryptWithKey
{
    //1.声明和初试化字符串密钥
    NSString *key = strKey;
    char keyPtr[kCCKeySizeAES128+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSASCIIStringEncoding];//NSASCIIStringEncoding NSUTF8StringEncoding
    
    //二进制密钥
    //char keyPtr[] = {0x6f,0xd6,0x8c,0xe2,0xa9,0x27,0x36,0x1a,0x2c,0x9d,0x84,0xbf,0x20,0x98,0x2b,0x44,'\0'};

    //2.初始化加密数据
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    //3.加密操作
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCKeySizeAES128,
                                          NULL,
                                          [self bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    
    //4.成功则获取加密后的数据
    if (cryptStatus == kCCSuccess) 
    {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    //5.失败则返回
    free(buffer);
    return nil;
}

- (NSData *)AES128DecryptWithKey
{
    NSString *key = strKey;
    char keyPtr[kCCKeySizeAES128+1];//kCCKeySizeAES128 kCCKeySizeAES256
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    //char keyPtr[] = {0x6f,0xd6,0x8c,0xe2,0xa9,0x27,0x36,0x1a,0x2c,0x9d,0x84,0xbf,0x20,0x98,0x2b,0x44,'\0'};
    
    NSUInteger dataLength = [self length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCKeySizeAES128,
                                          NULL,
                                          [self bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess)
    {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    return nil;
}

- (NSString *)newStringInBase64FromData 
{
    NSMutableString *dest = [[NSMutableString alloc] initWithString:@""];
    unsigned char * working = (unsigned char *)[self bytes];
    NSUInteger srcLen = [self length];
    
    for (int i=0; i<srcLen; i += 3) 
    {
        for (int nib=0; nib<4; nib++) 
        {
            int byt = (nib == 0)?0:nib-1;
            int ix = (nib+1)*2;
            
            if (i+byt >= srcLen)
            { 
                break;
            }
            
            unsigned char curr = ((working[i+byt] << (8-ix)) & 0x3F);
            
            if (i+nib < srcLen)
            {
                curr |= ((working[i+nib] >> ix) & 0x3F);
            }
            
            [dest appendFormat:@"%c", base64[curr]];
        }
    }
    
    return dest;
}

@end