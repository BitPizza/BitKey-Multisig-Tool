//
//  BKHttpProxy.h
//
//  Created by 1626e47afacebae00046e7517d5e1969 on 3/14/17.
//  Copyright © 2017 bitkey.app. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BKHttpProxy : NSURLProtocol


+ (void)registerProxy;
+ (void)unregister;


@end
