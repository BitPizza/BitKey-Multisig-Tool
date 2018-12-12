//
//  BKMsCoinMachine_Mac.m
//  BitKeyMultisigTool
//
//  Created by df on 2018/9/26.
//  Copyright © 2018 bitkey.app. All rights reserved.
//
@import JavaScriptCore;

#import "BKMsCoinMachine_Mac.h"
@interface BKMsCoinMachine_Mac()<WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>
{
    NSString *JSstring;
    JSContext *context;
    NSArray *_bip39wordsListEn;

}
@property (nonatomic, strong) WKWebView *wkWebView;
@end

@implementation BKMsCoinMachine_Mac

//Mac
+ (BKMsCoinMachine_Mac *)sharedInstance {
    static BKMsCoinMachine_Mac *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[BKMsCoinMachine_Mac alloc] init];
        
    });
    return _sharedInstance;
}
//Mac
- (void)app_getB39mnemonic:(int)bit withCompleteBlock:(CMCompleteBlock)block {
    dispatch_async(dispatch_get_main_queue(), ^(){
        __block NSArray *obj;
        __block NSString *e;
        NSString *javascript = [NSString stringWithFormat:@"app_getB39mnemonic(%d)", bit];
        [self.wkWebView evaluateJavaScript:javascript completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            NSArray *words;
            @try {
                words = [result componentsSeparatedByString:@" "];
            } @catch (NSException *exception) {
            } @finally {
            }
            if (words.count >= 12) {
                obj = words;
            } else {
                e = @"app_getB39mnemonic error";
            }
            CoinMachineResult *coinMachineResult = [CoinMachineResult new];
            coinMachineResult.obj = obj;
            coinMachineResult.error = e;
            block(coinMachineResult);
        }];
    });
}
//Mac
- (void)app_getHDKeypairFromSeedInfo:(NSDictionary *)loaclHDWalletObj
                                path:(NSString *)path
                   withCompleteBlock:(CMCompleteBlock)block {
    
    NSMutableDictionary *parameterObj = [NSMutableDictionary new];
    parameterObj[@"loaclHDWalletObj"] = loaclHDWalletObj;
    parameterObj[@"path"] =  path;
    __block NSDictionary *obj;
    __block NSString *e;
    dispatch_async(dispatch_get_main_queue(), ^(){
        
        
        
        
        
        NSString *javascript = [NSString stringWithFormat:@"app_getHDKeypairFromSeedInfoAndPath('%@')",
                                [self objectToJSON:parameterObj]];
        
        NSLog(@"[self objectToJSON:parameterObj] %@",[self objectToJSON:parameterObj]);
        
        [self.wkWebView evaluateJavaScript:javascript completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            NSString *publicKey_hex;
            NSString *privateKey_wif;
            @try {
                publicKey_hex = result[@"publicKey_hex"];
                privateKey_wif = result[@"privateKey_wif"];
            } @catch (NSException *exception) {
            } @finally {
            }
            if (publicKey_hex && privateKey_wif) {
                obj = result;
            } else {
                e = [NSString stringWithFormat:@"app_getHDKeypairFromSeedInfo error  %@", error.description];

            }
            
            CoinMachineResult *coinMachineResult = [CoinMachineResult new];
            coinMachineResult.obj = obj;
            coinMachineResult.error = e;
            block(coinMachineResult);
        }];
    });
}

//Mac
- (void)app_timeLockMultiSigTxb_getHashHexForSigArray:(NSDictionary *)paymentObj
                                    withCompleteBlock:(CMCompleteBlock)block{
    NSDictionary *parameterObj = paymentObj;
    dispatch_async(dispatch_get_main_queue(), ^(){
        NSString *javascript = [NSString stringWithFormat:@"app_TimeLockMultiSigTxb_getHashHexForSigArray('%@')", [self objectToJSON:parameterObj]];
        [self.wkWebView evaluateJavaScript:javascript completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            CoinMachineResult *coinMachineResult = [CoinMachineResult new];
            if (result && !error ) {
                coinMachineResult.obj = result;
            }
            coinMachineResult.error = error.description;
            block(coinMachineResult);
        }];
    });
}

//Mac
- (void)app_multiSig_sigUseKey:(NSString *)key
                       hashHex:(NSArray *)hashHexForSig
             withCompleteBlock:(CMCompleteBlock)block{

    NSMutableDictionary *parameterObj = [NSMutableDictionary new];
    parameterObj[@"key"] = key;
    parameterObj[@"hashHexForSigArray"] =  hashHexForSig;

    dispatch_async(dispatch_get_main_queue(), ^(){
        NSString *javascript = [NSString stringWithFormat:@"app_multiSig_sigUseKey('%@')", [self objectToJSON:parameterObj]];
        [self.wkWebView evaluateJavaScript:javascript completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            CoinMachineResult *coinMachineResult = [CoinMachineResult new];
            if (result && !error ) {
                coinMachineResult.obj = result;
            }
            coinMachineResult.error = error.description;
            block(coinMachineResult);
        }];
    });
}

//Mac
- (void)app_validateBip39Mnemonic:(NSArray *)wordsArray
                withCompleteBlock:(CMCompleteBlock)block{
    NSString * words = [[wordsArray valueForKey:@"description"] componentsJoinedByString:@" "];
    dispatch_async(dispatch_get_main_queue(), ^(){
        NSString *javascript = [NSString stringWithFormat:@"app_validateBip39Mnemonic('%@')", words];
        [self.wkWebView evaluateJavaScript:javascript completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            CoinMachineResult *coinMachineResult = [CoinMachineResult new];
            if (result && !error ) {
                coinMachineResult.boolResult = [result boolValue];
            }
            coinMachineResult.error = error.description;
            block(coinMachineResult);
        }];
    });
}


- (id)init {
    self = [super init];
    if (self) {
        if (!_bip39wordsListEn) {
            NSString *txtFilePath = [[NSBundle mainBundle] pathForResource:@"bip39-en" ofType:@"txt"];
            NSString *content = [NSString stringWithContentsOfFile:txtFilePath encoding:NSUTF8StringEncoding error:nil];
            _bip39wordsListEn = [[content componentsSeparatedByString:@"\n"] subarrayWithRange:NSMakeRange(0, 2048)];
        }
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"JsJson" ofType:@"js"];
        NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        JSstring = content;
        context = [JSContext new];
        [context evaluateScript:content];
        NSLog(@"init");
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        CGRect wkFrame = CGRectZero;
        self.wkWebView = [[WKWebView alloc] initWithFrame:wkFrame
                                            configuration:configuration];
        self.wkWebView.navigationDelegate = self;
        NSString* productURL = [[NSBundle mainBundle] pathForResource:@"app-v2-multisig" ofType:@"html"];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:productURL]];
        [self.wkWebView loadRequest:request];
    }
    return self;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"🚗didLoad BKMsCoinMachine_Mac");
    self.didLoaded = YES;
}
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSLog(@"userContentController");
}

- (NSString *)objectToJSON:(id)obj {
    
    // 曲折过程1： NSJSONSerialization 自带的不行，'/'被转译。
    // 曲折过程2： 使用javescript自带的JSON， ‘ 单引号会有问题。
    // 曲折过程3： 正则解决单引号问题，其他任意输入也会出现问题.
    // 曲折过程4： 本质原因json包含的字符串很复杂，将其将纬到一个更底维代码空间（字符串）本质无法发实现。
    // 曲折过程5： 借助更简单的base64编码，将json包裹一层。然后可以自由的拼接字符串。使用时候再层层解码，需要JS函数代码配合。
    // 解决非常烦人的斜杠反斜杠问题  path和密码里面的自定义数据有很大风险
    JSValue *jsFunction = context[@"JsonStringFy"];
    JSValue *value = [jsFunction callWithArguments:@[obj]];
    NSString *jsjson = [value toString];
    NSData *plainData = [jsjson dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String;
    base64String = [plainData base64EncodedStringWithOptions:kNilOptions];  // iOS 7+
    return  base64String;
}

//Mac
- (BOOL)app_validateBip39word:(NSString *)word{
    if ([_bip39wordsListEn containsObject:word]) {
        return  YES;
    }
    return  NO;
}



//以上MAC
-(void)app_getRandomKeypairWithCompleteBlock:(CMCompleteBlock)block {
    dispatch_async(dispatch_get_main_queue(), ^(){
        __block NSDictionary *obj;
        __block NSString *e;
        NSString *javascript = [NSString stringWithFormat:@"app_getRandomKeypair()"];
        [self.wkWebView evaluateJavaScript:javascript completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            NSString *privateKey_wif;
            NSString *publicKey_hex;
            @try {
                privateKey_wif = result[@"privateKey_wif"];
                publicKey_hex = result[@"publicKey_hex"];
            } @catch (NSException *exception) {
            } @finally {
            }
            if (privateKey_wif && publicKey_hex) {
                obj = result;
            } else {
                e = @"app_getRandomKeypairWithCompleteBlock error";
            }
            CoinMachineResult *coinMachineResult = [CoinMachineResult new];
            coinMachineResult.obj = obj;
            coinMachineResult.error = e;
            block(coinMachineResult);
        }];
    });
}


- (void)app_sigVerify:(NSString *)message_hex
            signature:(NSString *)signature_hex
               pubKey:(NSString *)pubKey_hex
    withCompleteBlock:(CMCompleteBlock)block{
    NSMutableDictionary *parameterObj = [NSMutableDictionary new];
    parameterObj[@"message_hex"] = message_hex;
    parameterObj[@"signature_hex"] =  signature_hex;
    parameterObj[@"pubKey_hex"] =  pubKey_hex;
    dispatch_async(dispatch_get_main_queue(), ^(){
        NSString *javascript = [NSString stringWithFormat:@"app_sigVerify('%@')", [self objectToJSON:parameterObj]];
        [self.wkWebView evaluateJavaScript:javascript completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            CoinMachineResult *coinMachineResult = [CoinMachineResult new];
            if (result && !error ) {
                coinMachineResult.boolResult = [result boolValue];
            }
            coinMachineResult.error = error.description;
            block(coinMachineResult);
        }];
    });
}


- (void)app_generateP2SH_P2WSH_1cltvOf2MultiSig_AddressWithKey1:(NSString *)pk1
                                                           key2:(NSString *)pk2
                                                       timelock:(int64_t)timestamp
                                              withCompleteBlock:(CMCompleteBlock)block{
    NSMutableDictionary *parameterObj = [NSMutableDictionary new];
    parameterObj[@"pubkey1_"] = pk1;
    parameterObj[@"pubkey2_"] = pk2;
    parameterObj[@"lockTimestamp_"] =  [NSNumber numberWithLongLong:timestamp];
    
    __block NSDictionary *obj;
    __block NSString *e;
    dispatch_async(dispatch_get_main_queue(), ^(){
        NSString *javascript = [NSString stringWithFormat:@"app_generateP2SH_P2WSH_1cltvOf2MultiSig_Address('%@')", [self objectToJSON:parameterObj]];
        [self.wkWebView evaluateJavaScript:javascript completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            NSString *P2SH_P2WSH_1cltvOf2MultiSig_address;
            NSString *witnessScript;
            @try {
                P2SH_P2WSH_1cltvOf2MultiSig_address = result[@"P2SH_P2WSH_1cltvOf2MultiSig_address"];
                witnessScript = result[@"witnessScript"];
            } @catch (NSException *exception) {
            } @finally {
            }
            if (P2SH_P2WSH_1cltvOf2MultiSig_address && witnessScript) {
                obj = result;
            } else {
                e = @"app_generateP2SH_P2WSH_1cltvOf2MultiSig_AddressWithKey1 error";
            }
            CoinMachineResult *coinMachineResult = [CoinMachineResult new];
            coinMachineResult.obj = obj;
            coinMachineResult.error = e;
            block(coinMachineResult);
        }];
    });
}

-(void)app_TimeLockMultiSigTxb_getSignedTx:(NSDictionary *)paymentObj
                              sigHexArray1:(NSArray *)d1_sigHexArray_fromKey1
                              sigHexArray2:(NSArray *)d2_sigHexArray_fromKey2
                         withCompleteBlock:(CMCompleteBlock)block{
    
    NSMutableDictionary *parameterObj = [NSMutableDictionary new];
    parameterObj[@"paymentObj_"] = paymentObj;
    
    if (d1_sigHexArray_fromKey1) {
        parameterObj[@"sigHexArray_fromKey1_"] = d1_sigHexArray_fromKey1;
    }
    
    if (d2_sigHexArray_fromKey2) {
        parameterObj[@"sigHexArray_fromKey2_"] =  d2_sigHexArray_fromKey2;
    }
    
    __block NSDictionary *obj;
    __block NSString *e;
    dispatch_async(dispatch_get_main_queue(), ^(){
        NSString *javascript = [NSString stringWithFormat:@"app_TimeLockMultiSigTxb_getSignedTx('%@')", [self objectToJSON:parameterObj]];
        [self.wkWebView evaluateJavaScript:javascript completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            NSString *tx;
            NSString *txId;
            @try {
                tx = result[@"tx"];
                txId = result[@"txId"];
            } @catch (NSException *exception) {
            } @finally {
            }
            if (tx && txId) {
                obj = result;
            } else {
                e = @"app_TimeLockMultiSigTxb_getSignedTx error";
            }
            CoinMachineResult *coinMachineResult = [CoinMachineResult new];
            coinMachineResult.obj = obj;
            coinMachineResult.error = e;
            block(coinMachineResult);
        }];
    });
}


- (void)app_bitcoinMessage_sign:(NSString *)message
                  privateKeyWif:(NSString *)privateKey
              withCompleteBlock:(CMCompleteBlock)block{
    NSMutableDictionary *parameterObj = [NSMutableDictionary new];
    parameterObj[@"message"] = message;
    parameterObj[@"privateKeyWif"] = privateKey;
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        NSString *javascript = [NSString stringWithFormat:@"app_bitcoinMessage_sign('%@')", [self objectToJSON:parameterObj]];
        [self.wkWebView evaluateJavaScript:javascript completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            CoinMachineResult *coinMachineResult = [CoinMachineResult new];
            if (result && !error ) {
                coinMachineResult.obj = result;
            }
            coinMachineResult.error = error.description;
            block(coinMachineResult);
        }];
    });
    
}

- (void)app_bitcoinMessage_verify:(NSString *)message
                  signatureBase64:(NSString *)signature
                withCompleteBlock:(CMCompleteBlock)block{
    NSMutableDictionary *parameterObj = [NSMutableDictionary new];
    parameterObj[@"message"] = message;
    parameterObj[@"signatureBase64"] = signature;
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        NSString *javascript = [NSString stringWithFormat:@"app_bitcoinMessage_verify('%@')", [self objectToJSON:parameterObj]];
        [self.wkWebView evaluateJavaScript:javascript completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            CoinMachineResult *coinMachineResult = [CoinMachineResult new];
            if (result && !error ) {
                coinMachineResult.obj = result;
            }
            coinMachineResult.error = error.description;
            block(coinMachineResult);
        }];
    });
}


- (void)app_testPublicKeyAndPrivateKeySignatureMatch:(NSString *)publicKey_hex
                                          privateKey:(NSString *)privateKey_wif
                                   withCompleteBlock:(CMCompleteBlock)block {
    
    NSString *message = @"hello";
    [self app_bitcoinMessage_sign:message privateKeyWif:privateKey_wif withCompleteBlock:^(CoinMachineResult *coinMachineResult) {
        NSString *signatureBase64 = coinMachineResult.obj;
        [self app_bitcoinMessage_verify:message signatureBase64:signatureBase64 withCompleteBlock:^(CoinMachineResult *coinMachineResult) {
            NSDictionary *obj = coinMachineResult.obj;
            CoinMachineResult *coinMachineResult_final = [CoinMachineResult new];
            if ([obj[@"publicKey_hex"] isEqualToString:publicKey_hex]) {
                coinMachineResult_final.boolResult = YES;
            } else {
                coinMachineResult_final.boolResult = NO;
            }
            block(coinMachineResult_final);
        }];
    }];
}

@end
