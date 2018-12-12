//
//  NSImage+QRCode.h
//  QRCodeGenerated
//
//  Created by ZhangWeichen on 2017/6/6.
//  Copyright © 2017年 Avcon. All rights reserved.
//

//author github: https://github.com/shibiao/QRCodeGenerated

#import <Cocoa/Cocoa.h>
#import <CoreImage/CoreImage.h>
@interface QRCode : NSObject 


//pre
+ (NSImage *)qrImageWithContent:(NSString *)content size:(CGFloat)size;
/*
 色值 0~255
 */
+ (NSImage *)qrImageWithContent:(NSString *)content size:(CGFloat)size red:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue;


+(NSImage *)qrImageWithContent:(NSString *)content logo:(NSImage *)logo size:(CGFloat)size red:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue;

@end
