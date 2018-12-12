//
//  BKMsCoinMachine_Mac.h
//  BitKeyMultisigTool
//
//  Created by df on 2018/9/26.
//  Copyright © 2018 bitkey.app. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoinMachineResult.h"
#import <WebKit/WebKit.h>


@interface BKMsCoinMachine_Mac : NSObject
@property (nonatomic, assign) BOOL didLoaded;

//Mac
+ (BKMsCoinMachine_Mac *)sharedInstance;
//Mac app_getB39mnemonic
-(void)app_getB39mnemonic:(int)bit withCompleteBlock:(CMCompleteBlock)block;//ret NSArray
//Mac app_getHDKeypairFromSeedInfo
-(void)app_getHDKeypairFromSeedInfo:(NSDictionary *)loaclHDWalletObj
                                path:(NSString *)path
                   withCompleteBlock:(CMCompleteBlock)block;//dict
//Mac app_timeLockMultiSigTxb_getHashHexForSigArray
-(void)app_timeLockMultiSigTxb_getHashHexForSigArray:(NSDictionary *)paymentObj
                                   withCompleteBlock:(CMCompleteBlock)block;//ret NSArray
//Mac app_multiSig_sigUseKey
-(void)app_multiSig_sigUseKey:(NSString *)key
                      hashHex:(NSArray *)hashHexForSig
            withCompleteBlock:(CMCompleteBlock)block;//ret NSArray
//Mac app_validateBip39Mnemonic
-(void)app_validateBip39Mnemonic:(NSArray *)words
               withCompleteBlock:(CMCompleteBlock)block;//BOOL
//Mac app_validateBip39word
-(BOOL)app_validateBip39word:(NSString *)word;





-(void)app_getRandomKeypairWithCompleteBlock:(CMCompleteBlock)block;//dict

-(void)app_sigVerify:(NSString *)message_hex
           signature:(NSString *)signature_hex
              pubKey:(NSString *)pubKey_hex
   withCompleteBlock:(CMCompleteBlock)block;//BOOL

-(void)app_generateP2SH_P2WSH_1cltvOf2MultiSig_AddressWithKey1:(NSString *)pk1
                                                          key2:(NSString *)pk2
                                                      timelock:(int64_t)timestamp
                                             withCompleteBlock:(CMCompleteBlock)block;//NSDictionary

-(void)app_TimeLockMultiSigTxb_getSignedTx:(NSDictionary *)paymentObj
                              sigHexArray1:(NSArray *)d1_sigHexArray_fromKey1
                              sigHexArray2:(NSArray *)d2_sigHexArray_fromKey2
                         withCompleteBlock:(CMCompleteBlock)block;//NSDictionary

-(void)app_bitcoinMessage_sign:(NSString *)message
                 privateKeyWif:(NSString *)privateKey
             withCompleteBlock:(CMCompleteBlock)block;//NSString

-(void)app_bitcoinMessage_verify:(NSString *)message
                 signatureBase64:(NSString *)signature
               withCompleteBlock:(CMCompleteBlock)block;//NSDictionary

-(void)app_testPublicKeyAndPrivateKeySignatureMatch:(NSString *)publicKey_hex
                                         privateKey:(NSString *)privateKey_wif
                                  withCompleteBlock:(CMCompleteBlock)block;//BOOL
@end
