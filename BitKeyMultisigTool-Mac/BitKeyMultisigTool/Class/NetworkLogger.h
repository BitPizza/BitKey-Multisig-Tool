//
//  UPAVPlayerLogger.h
//  UPAVPlayerDemo
//
//  Created by 1626e47afacebae00046e7517d5e1969  on 2/23/16.
//  Copyright © 2016 bitkey.app. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NetworkLogger : NSObject


+ (NetworkLogger *)sharedInstance;

+ (void)log:(NSString *)message;

+ (void)logTx:(NSString *)txInfo;


- (BOOL)hostIsInWhiteList:(NSString *)host;

@end
