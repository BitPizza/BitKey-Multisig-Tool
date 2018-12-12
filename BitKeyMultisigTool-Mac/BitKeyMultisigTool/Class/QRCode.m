//
//  NSImage+QRCode.m
//  QRCodeGenerated
//
//  Created by ZhangWeichen on 2017/6/6.
//  Copyright © 2017年 Avcon. All rights reserved.
//

#import "QRCode.h"

@implementation QRCode


void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}
+ (CIImage *)qrByContent:(NSString *)content {
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    NSData *stringData = [content dataUsingEncoding:NSUTF8StringEncoding];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"L" forKey:@"inputCorrectionLevel"];
    CIImage *image = qrFilter.outputImage;
    return image;
}

+(NSImage *)qrImageWithContent:(NSString *)content size:(CGFloat)size
{
    CIImage *image = [QRCode qrByContent:content];
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [QRCode imageFromCGImageRef:scaledImage];
}

+ (NSImage *)qrImageWithContent:(NSString *)content size:(CGFloat)size red:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue {
    NSImage *image = [QRCode qrImageWithContent:content size:size];
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), [QRCode nsImageToCGImageRef:image]);
    // 遍历像素
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900)    // 将白色变成透明
        {
            // 改成下面的代码，会将图片转成想要的颜色
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }else
        {
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    // 输出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    NSImage *resultUIImage = [QRCode imageFromCGImageRef:imageRef];
    // 清理空间
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}
// CGImageRef 转NSImage
+(NSImage*) imageFromCGImageRef:(CGImageRef)image
{
    NSRect imageRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    CGContextRef imageContext = nil;
    NSImage* newImage = nil;
    // Get the image dimensions.
    imageRect.size.height = CGImageGetHeight(image);
    imageRect.size.width = CGImageGetWidth(image);
    
    // Create a new image to receive the Quartz image data.
    newImage = [[NSImage alloc] initWithSize:imageRect.size];
    [newImage lockFocus];
    // Get the Quartz context and draw.
    imageContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGContextDrawImage(imageContext, *(CGRect*)&imageRect, image);
    [newImage unlockFocus];
    return newImage;
}
//NSImage转CGImageRef
+(CGImageRef)nsImageToCGImageRef:(NSImage*)image;
{
    NSData * imageData = [image TIFFRepresentation];
    CGImageRef imageRef;
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)imageData,  NULL);
    imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
    
    return imageRef;
}
+ (NSImage *)qrImageWithContent:(NSString *)content logo:(NSImage *)logo size:(CGFloat)size red:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue {
    NSImage* resultUIImage = [self qrImageWithContent:content size:size red:red green:green blue:blue];
    
    return resultUIImage;
}

@end
