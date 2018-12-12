//
//  CryptoJsWrap.h
//  BitKey
//
//  Created by 1626e47afacebae00046e7517d5e1969 on 9/9/14.
//  Copyright (c) 2014 bitkey.app. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CryptoJsWrap : NSObject
-(NSString *)cryptoJsAESEncrypt:(NSString *)string password:(NSString *)passsword;
-(NSString *)cryptoJsAESDecrypt:(NSString *)string password:(NSString *)passsword;
-(NSString *)cryptoJsMD5:(NSString *)string;


@end
