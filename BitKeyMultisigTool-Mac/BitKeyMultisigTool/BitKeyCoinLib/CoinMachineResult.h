//
//  CoinMachineResult.h
//  CoinLibDemo
//
//  Created by df on 2018/12/7.
//  Copyright © 2018 df. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CoinMachineResult;
typedef void(^CMCompleteBlock)(CoinMachineResult *coinMachineResult);

NS_ASSUME_NONNULL_BEGIN

@interface CoinMachineResult : NSObject
@property (nonnull, strong) NSString *error;
@property (nonnull, strong) id obj;
@property (assign, nonatomic) BOOL boolResult;

@end
NS_ASSUME_NONNULL_END
