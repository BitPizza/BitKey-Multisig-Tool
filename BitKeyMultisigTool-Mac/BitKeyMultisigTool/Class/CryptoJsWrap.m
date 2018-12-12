//  CryptoJsWrap.m
//  BitKey
//
//  Created by 1626e47afacebae00046e7517d5e1969 on 9/9/14.
//  Copyright (c) 2014 bitkey.app. All rights reserved.
//

#import "CryptoJsWrap.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonKeyDerivation.h>

/***
 crypto-js 文档
 https://code.google.com/archive/p/crypto-js/wikis/QuickStartGuide_v3beta.wiki
 
 AES265
 CBC (the default)
 Pkcs7 (the default)
 
 #参考
 PKBDF2(10,000 iterations)
 AES256 in CBC mode with random IV and no
 padding
 */


@import JavaScriptCore;

@implementation CryptoJsWrap
{
    NSString *JSstring;
    JSContext *context;
}


-(id)init
{
    self = [super init];
    if(self)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"crypto-js" ofType:@"txt"];
        NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        JSstring = content;
        
        context = [JSContext new];
        [context evaluateScript:content];

    }
    return self;
}

//var encrypted = CryptoJS.AES.encrypt("definefunction", "123");
//alert(encrypted);
//var Base64String = CryptoJS.enc.Hex.parse(encrypted);
//alert(Base64String);
//var decrypted = CryptoJS.AES.decrypt("U2FsdGVkX19jGTdXp1WtIj33hH6w27xZ4K76IExo=","123").toString(CryptoJS.enc.Utf8);
//alert(decrypted);

-(NSString *)cryptoJsAESEncrypt:(NSString *)string password:(NSString *)passsword {
    JSValue *jsFunction = context[@"CryptoJS"][@"AES"][@"encrypt"];
    JSValue *value = [jsFunction callWithArguments:@[string, passsword]];
    return   [NSString stringWithFormat:@"%@",value];
}

-(NSString *)cryptoJsAESDecrypt:(NSString *)string password:(NSString *)passsword
{
    JSValue *jsFunction = context[@"CryptoJS"][@"AES"][@"decrypt_s"];
    JSValue *value = [jsFunction callWithArguments:@[string, passsword]];
    return   [NSString stringWithFormat:@"%@",value];
}

-(NSString *)cryptoJsMD5:(NSString *)string{
    JSValue *jsFunction = context[@"CryptoJS"][@"MD5"];
    JSValue *value = [jsFunction callWithArguments:@[string]];
    return   [NSString stringWithFormat:@"%@",value];
}

- (void)test {
    
    NSString* password = @"******";//NEED_HIDE_LINE
    NSString* salt = @"***!";//NEED_HIDE_LINE
    NSMutableData* hash = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    NSMutableData* key = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(salt.UTF8String, (CC_LONG)strlen(salt.UTF8String), hash.mutableBytes);
    CCKeyDerivationPBKDF(kCCPBKDF2, password.UTF8String, strlen(password.UTF8String), hash.bytes, hash.length, kCCPRFHmacAlgSHA1, 1000, key.mutableBytes, key.length);
//    NSLog(@"Hash : %@",[hash base64EncodedStringWithOptions:0]);
//    NSLog(@"Key : %@",[key base64EncodedStringWithOptions:0]);
    
    // Generate a random IV (or use the base64 version from node.js)
    NSString* iv64 = @"***==";//NEED_HIDE_LINE
    NSData* iv = [[NSData alloc] initWithBase64EncodedString:iv64 options:0];
//    NSLog(@"IV : %@",[iv base64EncodedStringWithOptions:0]);
    
    // Encrypt message into base64
    NSData* message = [@"Hello World!" dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData* encrypted = [NSMutableData dataWithLength:message.length + kCCBlockSizeAES128];
    size_t bytesEncrypted = 0;
    CCCrypt(kCCEncrypt,
            kCCAlgorithmAES128,
            kCCOptionPKCS7Padding,
            key.bytes,
            key.length,
            iv.bytes,
            message.bytes, message.length,
            encrypted.mutableBytes, encrypted.length, &bytesEncrypted);
    NSString* encrypted64 = [[NSMutableData dataWithBytes:encrypted.mutableBytes length:bytesEncrypted] base64EncodedStringWithOptions:0];
    NSLog(@"Encrypted : %@",encrypted64);
    
    // Decrypt base 64 into message again
    NSData* encryptedWithout64 = [[NSData alloc] initWithBase64EncodedString:encrypted64 options:0];
    NSMutableData* decrypted = [NSMutableData dataWithLength:encryptedWithout64.length + kCCBlockSizeAES128];
    size_t bytesDecrypted = 0;
    CCCrypt(kCCDecrypt,
            kCCAlgorithmAES128,
            kCCOptionPKCS7Padding,
            key.bytes,
            key.length,
            iv.bytes,
            encryptedWithout64.bytes, encryptedWithout64.length,
            decrypted.mutableBytes, decrypted.length, &bytesDecrypted);
    NSData* outputMessage = [NSMutableData dataWithBytes:decrypted.mutableBytes length:bytesDecrypted];
    NSString* outputString = [[NSString alloc] initWithData:outputMessage encoding:NSUTF8StringEncoding];
    NSLog(@"Decrypted : %@",outputString);
    
}    
    
    



@end
