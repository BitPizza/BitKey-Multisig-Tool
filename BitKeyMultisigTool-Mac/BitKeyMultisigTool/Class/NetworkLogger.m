//
//  UPAVPlayerLogger.m
//  UPAVPlayerDemo
//
//  Created by 1626e47afacebae00046e7517d5e1969  on 2/23/16.
//  Copyright © 2016 bitkey.app. All rights reserved.
//

#import "NetworkLogger.h"

@interface NetworkLogger ()
{
    NSString *_logPath;
    NSString *_rawtxPath;
    dispatch_queue_t _writeQueue;
    NSInteger _verboseMesageCount;
    NSMutableDictionary *_whiteList;

}
@property (nonatomic ,strong) NSFileHandle *fileHandle;
@property (nonatomic ,strong) NSFileHandle *fileHandlerForRawTx;


@end

@implementation NetworkLogger

void UPLog(NSString* format, ...) {
#if DEBUG
    va_list vargs;
    va_start(vargs, format);
    NSString* formattedMessage = [[NSString alloc] initWithFormat:format arguments:vargs];
    va_end(vargs);
    NSString* message = [NSString stringWithFormat:@"%@", formattedMessage];
    printf("%s\n", [message UTF8String]);
#endif
}

+ (NetworkLogger *)sharedInstance {
    static NetworkLogger *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[NetworkLogger alloc] init];
        
    });
    return _sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        //创建日志目录，及日志文件
        _writeQueue = dispatch_queue_create("NetworkLogger.write.queue", DISPATCH_QUEUE_SERIAL);
        _whiteList = [NSMutableDictionary new];
//        _whiteList[@"bitcoinfees.earn.com"] = [NSNumber numberWithBool:YES];
//        _whiteList[@"blockchain.info"] = [NSNumber numberWithBool:YES];
//        _whiteList[@"blockchain.com"] = [NSNumber numberWithBool:YES];
//        _whiteList[@"bitkey.app"] = [NSNumber numberWithBool:YES];
//        _whiteList[@"api.coinbase.com"] = [NSNumber numberWithBool:YES];
//        _whiteList[@"api.blockcypher.com"] = [NSNumber numberWithBool:YES];
    }
    
    return self;
}


+ (void)logTx:(NSString *)txInfo {
    
    static NSDateFormatter* timeStampFormat;
    if (!timeStampFormat) {
        timeStampFormat = [[NSDateFormatter alloc] init];
        [timeStampFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSSSSS"];
        [timeStampFormat setTimeZone:[NSTimeZone systemTimeZone]];
    }
    NSString* timestamp = [timeStampFormat stringFromDate:[NSDate date]];
    NSString *logText = [NSString stringWithFormat:@"[%@] %@ \n", timestamp, txInfo];
    
    [[NetworkLogger sharedInstance] saveTxText:[NSString stringWithFormat:@"%@\n", logText]];
}


+ (void)log:(NSString *)message {
    
    static NSDateFormatter* timeStampFormat;
    if (!timeStampFormat) {
        timeStampFormat = [[NSDateFormatter alloc] init];
        [timeStampFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSSSSS"];
        [timeStampFormat setTimeZone:[NSTimeZone systemTimeZone]];
    }
    NSString* timestamp = [timeStampFormat stringFromDate:[NSDate date]];
    NSString *logText = [NSString stringWithFormat:@"[%@] %@ \n", timestamp,message];
    
    
    
    [[NetworkLogger sharedInstance] saveLogText:[NSString stringWithFormat:@"%@\n", logText]];

}



- (NSFileHandle *)fileHandle {
    
    if (!_fileHandle) {
        NSString *tmpDirectory = NSTemporaryDirectory();
        NSDate *now = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [dateFormatter setDateFormat:@"HHmmss"];
        NSString *filename = [NSString stringWithFormat:@"%@.txt", [dateFormatter stringFromDate:now]];
        
        
        
        NSDateFormatter *dateFormatter_day = [[NSDateFormatter alloc] init];
        [dateFormatter_day setTimeZone:[NSTimeZone localTimeZone]];
        [dateFormatter_day setDateFormat:@"yyyyMMdd"];
        
        NSString *rootlogPath = [tmpDirectory stringByAppendingPathComponent:@"/NetworkLogger/"];
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:rootlogPath]) {
            
            [[NSFileManager defaultManager] createDirectoryAtPath:rootlogPath
                                      withIntermediateDirectories:NO
                                                       attributes:nil
                                                            error:nil];
            
        }
        
        
        
        NSString *dayPath = [NSString stringWithFormat:@"/NetworkLogger/%@/", [dateFormatter_day stringFromDate:now]];
        
        
        _logPath = [tmpDirectory stringByAppendingPathComponent:dayPath];
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:_logPath]) {
            //            NSLog(@"createDirectoryAtPath _logPath %@ ", _logPath);
            
            [[NSFileManager defaultManager] createDirectoryAtPath:_logPath
                                      withIntermediateDirectories:NO
                                                       attributes:nil
                                                            error:nil];
            
        }
        _logPath = [_logPath stringByAppendingPathComponent:filename];
        if(![[NSFileManager defaultManager] fileExistsAtPath:_logPath]) {
            //            NSLog(@"createFileAtPath _logPath %@ ", _logPath);
            [[NSFileManager defaultManager] createFileAtPath:_logPath
                                                    contents:nil
                                                  attributes:nil];
        }
        _verboseMesageCount = 0;
        _fileHandle = [NSFileHandle fileHandleForWritingAtPath:_logPath];
        
    }
    return _fileHandle;
}

- (NSFileHandle *)fileHandlerForRawTx {

    
    if (!_fileHandlerForRawTx) {
        
        
        NSString *tmpDirectory = NSTemporaryDirectory();
        NSDate *now = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [dateFormatter setDateFormat:@"HHmmss"];
        NSString *filename = [NSString stringWithFormat:@"%@.txt", [dateFormatter stringFromDate:now]];
        
        
        
        NSDateFormatter *dateFormatter_day = [[NSDateFormatter alloc] init];
        [dateFormatter_day setTimeZone:[NSTimeZone localTimeZone]];
        [dateFormatter_day setDateFormat:@"yyyyMMdd"];
        
        NSString *rootTxPath = [tmpDirectory stringByAppendingPathComponent:@"/RawTransaction/"];
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:rootTxPath]) {
            
            [[NSFileManager defaultManager] createDirectoryAtPath:rootTxPath
                                      withIntermediateDirectories:NO
                                                       attributes:nil
                                                            error:nil];
            
        }
        
        
        
        NSString *dayPath = [NSString stringWithFormat:@"/RawTransaction/%@/", [dateFormatter_day stringFromDate:now]];
        
        
        _rawtxPath = [tmpDirectory stringByAppendingPathComponent:dayPath];
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:_rawtxPath]) {
            
            [[NSFileManager defaultManager] createDirectoryAtPath:_rawtxPath
                                      withIntermediateDirectories:NO
                                                       attributes:nil
                                                            error:nil];
            
        }
        _rawtxPath = [_rawtxPath stringByAppendingPathComponent:filename];
        if(![[NSFileManager defaultManager] fileExistsAtPath:_rawtxPath]) {
            [[NSFileManager defaultManager] createFileAtPath:_rawtxPath
                                                    contents:nil
                                                  attributes:nil];
        }
        _fileHandlerForRawTx = [NSFileHandle fileHandleForWritingAtPath:_rawtxPath];
    }
    
    return _fileHandlerForRawTx;
}


- (void)saveLogText:(NSString *)text{
    dispatch_async(_writeQueue, ^(){
        [self.fileHandle seekToEndOfFile];
        [self.fileHandle writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];
        [self.fileHandle synchronizeFile];
    });
}

- (void)saveTxText:(NSString *)text{
    dispatch_async(_writeQueue, ^(){
        [self.fileHandlerForRawTx seekToEndOfFile];
        [self.fileHandlerForRawTx writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];
        [self.fileHandlerForRawTx synchronizeFile];
    });
}


- (BOOL)hostIsInWhiteList:(NSString *)host{
    NSNumber *boolNum = [_whiteList objectForKey:host];
    if (boolNum && boolNum.boolValue) {
        return YES;
    }
    return NO;
}


@end
