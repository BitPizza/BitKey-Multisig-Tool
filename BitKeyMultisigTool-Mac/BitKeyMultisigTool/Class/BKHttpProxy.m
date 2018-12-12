//
//  BKHttpProxy.m
//  WebP_demo
//
//  Created by 1626e47afacebae00046e7517d5e1969 on 3/14/17.
//  Copyright © 2017 bitkey.app. All rights reserved.
//

#import "BKHttpProxy.h"
#import "NetworkLogger.h"    


static NSString *URLProtocolHandledKey = @"URLHasHandle";

@interface BKHttpProxy()<NSURLSessionDelegate, NSURLSessionDataDelegate> {
    NSMutableData *_mutableData;
}
@property (nonatomic,strong) NSURLSession *session;
@property (atomic, strong, readwrite) NSThread * clientThread;       ///< The thread on which we should call the client.    
@end

@implementation BKHttpProxy

#pragma mark 初始化请求


+ (void)registerProxy {
    [NSURLProtocol registerClass:self];
}

+ (void)unregister {
    [self unregisterClass:self];
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    //只处理http和https请求
    NSString *scheme = [[request URL] scheme];
    if (([scheme caseInsensitiveCompare:@"http"] == NSOrderedSame ||
          [scheme caseInsensitiveCompare:@"https"] == NSOrderedSame)) {
        //看看是否已经处理过了，防止无限循环
        if ([NSURLProtocol propertyForKey:URLProtocolHandledKey inRequest:request]) {
            return NO;
        }
        return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

#pragma mark 通信协议内容实现
- (void)startLoading {
    self.clientThread = [NSThread currentThread];
    _mutableData = [NSMutableData new];
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    [mutableReqeust setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    //标示改request已经处理过了，防止无限循环
    [NSURLProtocol setProperty:@YES forKey:URLProtocolHandledKey inRequest:mutableReqeust];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:config
                                                 delegate:self
                                            delegateQueue:[NSOperationQueue currentQueue]];
    
    NSString *url = mutableReqeust.URL.absoluteString;
    NSLog(@"urlurlurl %@", mutableReqeust.URL.host);
    [NetworkLogger log:[NSString stringWithFormat:@"- > %@", url]];
    if ([[NetworkLogger sharedInstance] hostIsInWhiteList:mutableReqeust.URL.host]) {
        [[self.session dataTaskWithRequest:mutableReqeust] resume];
    } else {
        

        
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
         
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"Network Block!!!"];
            [alert setInformativeText:[NSString stringWithFormat:@"[WARNING] %@ blocked!", url]];
            [alert addButtonWithTitle:@"Close"];
            [alert runModal];
            
            
        });

        
        [NetworkLogger log:[NSString stringWithFormat:@"[WARNING] %@ blocked!", url]];
    }
}

- (void)stopLoading{
    [self.session invalidateAndCancel];
}

#pragma mark dataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    [self performOnThread:self.clientThread modes:nil block:^{
//        NSLog(@"didReceiveResponse  %@", self);
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        if (completionHandler) {
            completionHandler(NSURLSessionResponseAllow);
        }
    }];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    [self performOnThread:self.clientThread modes:nil block:^{
        [self->_mutableData appendData:data];
        [self.client URLProtocol:self didLoadData:data];
    }];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error{
    [self performOnThread:self.clientThread modes:nil block:^{
        if (error) {
            NSString *errr = [NSString stringWithFormat:@"%@", error];
            [NetworkLogger log:[NSString stringWithFormat:@"error: %@",errr]];
            printf("error: %s \n", errr.UTF8String);
            [self.client URLProtocol:self didFailWithError:error];
        }else{
            NSHTTPURLResponse *res = (NSHTTPURLResponse *)task.response;
            NSString *code = [NSString stringWithFormat:@"%ld", (long)res.statusCode];
            [NetworkLogger log:[NSString stringWithFormat:@"< - %@ %@", res.URL.absoluteString, code]];
            [self.client URLProtocolDidFinishLoading:self];
        }
    }];
}

- (void)performOnThread:(NSThread *)thread modes:(NSArray *)modes block:(dispatch_block_t)block {
    // thread may be nil
    // modes may be nil
    assert(block != nil);
    if (thread == nil) {
        thread = [NSThread mainThread];
    }
    if ([modes count] == 0) {
        modes = @[ NSDefaultRunLoopMode ];
    }
    [self performSelector:@selector(onThreadPerformBlock:) onThread:thread withObject:[block copy] waitUntilDone:NO modes:modes];
}

- (void)onThreadPerformBlock:(dispatch_block_t)block {
    assert(block != nil);
    block();
}

- (void)dealloc {
//    NSLog(@"dealloc  %@", self);
}


@end





/*** TEST BKHttpProxy 可以捕捉 UIWebview 发出的请求

 <script>
 var httpxml;
 if (window.XMLHttpRequest) {
 //大多数浏览器
 httpxml = new XMLHttpRequest();
 } else {
 //古董级浏览器
 httpxml = new ActiveXObject("Microsoft.XMLHTTP");
 }
 httpxml.onreadystatechange = function () {
 if (httpxml.readyState == 4 && httpxml.status == 200) {
 console.log(httpxml)
 } else {
 console.log("发生了错误");
 }
 }
 httpxml.open("get", "http://127.0.0.1", true);
 httpxml.send();
 </script>
 
 *****/
