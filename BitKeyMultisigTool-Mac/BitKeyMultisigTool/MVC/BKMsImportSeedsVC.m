//
//  BKMsImportSeedsVC.m
//  BitKeyMultisigTool
//
//  Created by df on 2018/9/21.
//  Copyright © 2018 bitkey.app. All rights reserved.
//

#import "BKMsImportSeedsVC.h"

typedef NS_ENUM(NSInteger, MnemonicVCStatus) {
    MnemonicVCStatus_init = 0,
    MnemonicVCStatus_passwordSetted = 2,
    MnemonicVCStatus_passwordHintSetted = 3,
    MnemonicVCStatus_testSeedWordsGenerated = 4,
    MnemonicVCStatus_testSeedWordSuccess = 5,
    MnemonicVCStatus_testSeedWordFailed = 6,
    MnemonicVCStatus_allInfoSaved = 8
};

@interface BKMsImportSeedsVC ()<NSTextFieldDelegate>{
   
}


@property (nonatomic, strong) NSArray *seedWordsImported;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *passwordHint;
@property (nonatomic, assign) MnemonicVCStatus status;



@property (weak) IBOutlet NSButton *closeBtn;
@property (weak) IBOutlet NSButton *saveBtn;



@property (weak) IBOutlet NSBox *box2;
@property (weak) IBOutlet NSView *box3;

@property (weak) IBOutlet NSTextField *box2Label;
@property (weak) IBOutlet NSTextField *box3Label;

@property (weak) IBOutlet NSTextField *setPasswordFeild;
@property (weak) IBOutlet NSTextField *setPasswordHitFeild;




@end

@implementation BKMsImportSeedsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setWantsLayer: YES];
    [self.view.layer setBackgroundColor: [NSColor whiteColor].CGColor];
    

    self.box3.hidden = YES;

}

- (IBAction)closeBtnTap:(id)sender {
    [self.presentingViewController dismissViewController:self];
}

- (void)viewWillAppear {
    _status = MnemonicVCStatus_init;
    [self setStatus:_status];
    self.setPasswordFeild.delegate = self;
    self.setPasswordHitFeild.delegate = self;
}

- (IBAction)saveBtnTap:(id)sender {
    [self.presentingViewController dismissViewController:self];
    NSString *passwordMD5 = [[CryptoJsWrap new] cryptoJsMD5: _password];
    [[NSUserDefaults standardUserDefaults] setObject:@{@"seeds": _seedWordsImported,
                                                       @"passwordMD5": passwordMD5,
                                                       @"passwordHint": _passwordHint}
                                              forKey:NSUserDefaults_Key_HDWalletInfo];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:Notice_Name_NewSeedsSaved object:nil userInfo:nil];
}

- (void)setStatus:(MnemonicVCStatus)s{
    self.box2.hidden = YES;
    self.saveBtn.hidden = YES;
    
    switch (s) {
        case MnemonicVCStatus_init:{
            self.box2.hidden = NO;
        }
            break;

        case MnemonicVCStatus_passwordSetted:{
            self.box2.hidden = NO;
        }
            break;
        case MnemonicVCStatus_passwordHintSetted:{
            self.box2.hidden = NO;
            self.box3.hidden = NO;
        }
            break;
        case MnemonicVCStatus_testSeedWordsGenerated:{
            self.box3.hidden = NO;
            self.box2.hidden = NO;

            
        }
            break;
        case MnemonicVCStatus_testSeedWordSuccess:{
            self.box3.hidden = NO;
            self.box2.hidden = NO;
            self.saveBtn.hidden = NO;


        }
            break;
        case MnemonicVCStatus_testSeedWordFailed:{
            self.box3.hidden = NO;
            self.box2.hidden = NO;
            
        }
            break;
        default:
            break;
    }
}


- (void)checkInputSeedWords:(NSArray *)words{
    
    
    [BKMsCoinMachine_Mac_Obj app_validateBip39Mnemonic:words withCompleteBlock:^(CoinMachineResult *coinMachineResult) {
        if (coinMachineResult.boolResult) {
            for (NSView *subview in self.box3.subviews) {
                if ([subview isKindOfClass:[NSTextField class]] && subview.tag >= 100) {
                    NSTextField *target = (NSTextField *)subview;
                    target.editable = NO;
                }
            }
            self.seedWordsImported = words;
            self->_status = MnemonicVCStatus_testSeedWordSuccess;
            [self setStatus:self->_status];
        }

        for (NSView *subview in self.box3.subviews) {
            if ([subview isKindOfClass:[NSTextField class]] && subview.tag >= 100) {
                NSTextField *target = (NSTextField *)subview;
                if (target.stringValue.length > 0 && ![BKMsCoinMachine_Mac_Obj app_validateBip39word:target.stringValue]) {
                    target.alphaValue = 0.5;
                } else {
                    target.alphaValue = 1;
                }
            }
        }
    }];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField *textField = [notification object];
    NSLog(@"%@",[textField stringValue]);
    
    if (textField.tag < 100 &&
        self.setPasswordFeild.stringValue.length > 0
        && self.setPasswordHitFeild.stringValue.length > 0) {
        _status = MnemonicVCStatus_passwordHintSetted;
        self.box3.hidden = NO;
        
        _password = self.setPasswordFeild.stringValue;
        _passwordHint = self.setPasswordHitFeild.stringValue;

        
        for (NSView *subview in self.box3.subviews) {
            if ([subview isKindOfClass:[NSTextField class]] && subview.tag >= 100) {
                NSTextField *target = (NSTextField *)subview;
                target.delegate = self;
            }
        }
        
    }
    
    if (textField.tag >= 100) {
        NSMutableArray *seedArray = [NSMutableArray new];
        for (NSView *subview in self.box3.subviews) {
            if ([subview isKindOfClass:[NSTextField class]] && subview.tag >= 100) {
                NSTextField *target = (NSTextField *)subview;
                seedArray[target.tag - 100] = target.cell.title;
            }
        }
        [self checkInputSeedWords: seedArray];
    }
    
    
}

@end
