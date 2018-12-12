//
//  ShowQRcodeSmallVC.m
//  BitKeyMultisigTool
//
//  Created by df on 2018/9/28.
//  Copyright © 2018 df. All rights reserved.
//

#import "ShowQRcodeSmallVC.h"
#import "QRCode.h"

@interface ShowQRcodeSmallVC ()

@property (weak) IBOutlet NSImageView *imageView;

@property (weak) IBOutlet NSTextField *titleLable;
@end

@implementation ShowQRcodeSmallVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setWantsLayer: YES];
    [self.view.layer setBackgroundColor: [NSColor whiteColor].CGColor];
    

}

- (void)viewWillAppear {
    self.titleLable.cell.title = [NSString stringWithFormat:@"%@", self.name];

    if (self.text.length > 0) {
        self.imageView.image = [QRCode qrImageWithContent:self.text logo:nil size:400 red:20 green:100 blue:100];
    } else {
        [self.imageView setWantsLayer: YES];
        [self.imageView.layer setBorderWidth: 2];
        [self.imageView.layer setBorderColor:CGColorCreateGenericRGB(20/255., 100/255., 100/255., 1)];
        
    }
    
    
}







@end
