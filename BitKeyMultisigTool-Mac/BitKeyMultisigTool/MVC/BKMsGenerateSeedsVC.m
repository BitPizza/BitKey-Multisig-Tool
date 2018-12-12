//
//  BKMsGenerateSeedsVC.m
//  BitKeyMultisigTool
//
//  Created by df on 2018/9/21.
//  Copyright © 2018 bitkey.app. All rights reserved.
//

#import "BKMsGenerateSeedsVC.h"
typedef NS_ENUM(NSInteger, MnemonicVCStatus) {
    MnemonicVCStatus_init = 0,
    MnemonicVCStatus_newSeedWordsGenerated = 1,
    MnemonicVCStatus_passwordSetted = 2,
    MnemonicVCStatus_passwordHintSetted = 3,
    MnemonicVCStatus_testSeedWordsGenerated = 4,
    MnemonicVCStatus_testSeedWordSuccess = 5,
    MnemonicVCStatus_testSeedWordFailed = 6,
    MnemonicVCStatus_reenterPasswordOk = 7,
    MnemonicVCStatus_allInfoSaved = 8
};

@interface BKMsGenerateSeedsVC ()<NSTextFieldDelegate>{

}

@property (strong, nonatomic) NSArray *seedWordsGenergted;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *passwordHint;
@property (assign, nonatomic) MnemonicVCStatus status;


@property (weak) IBOutlet NSButton *closeBtn;
@property (weak) IBOutlet NSButton *nextBtn;
@property (weak) IBOutlet NSButton *saveBtn;
@property (weak) IBOutlet NSView *box1;


@property (weak) IBOutlet NSBox *box2;
@property (weak) IBOutlet NSView *box3;
@property (weak) IBOutlet NSBox *box4;
@property (weak) IBOutlet NSTextField *box1Label;
@property (weak) IBOutlet NSTextField *box2Label;
@property (weak) IBOutlet NSTextField *box3Label;
@property (weak) IBOutlet NSTextField *box4Label;

@property (weak) IBOutlet NSTextField *setPasswordFeild;
@property (weak) IBOutlet NSTextField *setPasswordHitFeild;
@property (weak) IBOutlet NSTextField *passwordCheckFeild;
@property (weak) IBOutlet NSTextField *passwordHintCheckFeild;






@end

@implementation BKMsGenerateSeedsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setWantsLayer: YES];
    [self.view.layer setBackgroundColor: [NSColor whiteColor].CGColor];
}

- (IBAction)closeBtnTap:(id)sender {
    [self.presentingViewController dismissViewController:self];
}

- (void)viewWillAppear {
    _status = MnemonicVCStatus_init;
    [self setStatus:_status];
    self.setPasswordFeild.delegate = self;
    self.setPasswordHitFeild.delegate = self;
    self.passwordCheckFeild.delegate = self;
}

- (IBAction)nextBtnTap:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Important"];
    [alert setInformativeText:@"Make sure you have written *the 12 seed words and the password hint* on a paper and the paper has been backed up. IMPORTANT: the password works as the 13th seed word, if the password lost, the wallet cannot find back, so the password-hint message must be carefully marked on your backup paper. "];
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"Cancel"];
    
    
    NSModalResponse responseTag = [alert runModal];
   
    if(responseTag == 1000) {
        _status = MnemonicVCStatus_testSeedWordsGenerated;
        [self setStatus:_status];
    }
}

- (IBAction)saveBtnTap:(id)sender {
    [self.presentingViewController dismissViewController:self];
    NSString *passwordMD5 = [[CryptoJsWrap new] cryptoJsMD5: _password];
    [[NSUserDefaults standardUserDefaults] setObject:@{@"seeds": _seedWordsGenergted,
                                                       @"passwordMD5": passwordMD5,
                                                       @"passwordHint": _passwordHint}
                                              forKey:NSUserDefaults_Key_HDWalletInfo];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:Notice_Name_NewSeedsSaved object:nil userInfo:nil];
}

- (void)setStatus:(MnemonicVCStatus)s{
    self.box1.hidden = YES;
    self.box2.hidden = YES;
    self.box3.hidden = YES;
    self.box4.hidden = YES;
    self.nextBtn.hidden = YES;
    self.saveBtn.hidden = YES;
    
    switch (s) {
        case MnemonicVCStatus_init:{
            self.box1.hidden = NO;
            [self fillBox1WithNewSeeds];
        }
            break;
        case MnemonicVCStatus_newSeedWordsGenerated:{
            self.box1.hidden = NO;
            self.box2.hidden = NO;
        }
            break;
        case MnemonicVCStatus_passwordSetted:{
            self.box1.hidden = NO;
            self.box2.hidden = NO;
            
        }
            break;
        case MnemonicVCStatus_passwordHintSetted:{
            self.box1.hidden = NO;
            self.box2.hidden = NO;
            self.nextBtn.hidden = NO;
            
        }
            break;
        case MnemonicVCStatus_testSeedWordsGenerated:{
            self.box3.hidden = NO;
            [self fillBox3WithSomeSeeds];
            
        }
            break;
        case MnemonicVCStatus_testSeedWordSuccess:{
            self.box3.hidden = NO;
            self.box4.hidden = NO;
        }
            break;
        case MnemonicVCStatus_testSeedWordFailed:{
            self.box3.hidden = NO;
            self.box4.hidden = NO;
            
        }
            break;
        case MnemonicVCStatus_reenterPasswordOk:{
            self.box3.hidden = NO;
            self.box4.hidden = NO;
            self.saveBtn.hidden = NO;
            
        }
            break;
        default:
            break;
    }
}


- (void)fillBox3WithSomeSeeds{
    NSMutableArray *seeds = [[NSMutableArray alloc] initWithArray:_seedWordsGenergted];
    seeds[0] = @"";
    seeds[3] = @"";
    seeds[6] = @"";
    seeds[7] = @"";
    seeds[9] = @"";
    seeds[10] = @"";
    
    for (NSView *subview in self.box3.subviews) {
        if ([subview isKindOfClass:[NSTextField class]] && subview.tag >= 100) {
            NSTextField *target = (NSTextField *)subview;
            target.delegate = self;
            target.cell.title = seeds[target.tag - 100];
        }
    }
}

- (void)checkInputSeedWords:(NSArray *)words{
    
    [BKMsCoinMachine_Mac_Obj app_validateBip39Mnemonic:words withCompleteBlock:^(CoinMachineResult *coinMachineResult) {
        NSLog(@"checkInputSeedWords coinMachineResult %d", coinMachineResult.boolResult);
        if (coinMachineResult.boolResult) {
            for (NSView *subview in self.box3.subviews) {
                if ([subview isKindOfClass:[NSTextField class]] && subview.tag >= 100) {
                    NSTextField *target = (NSTextField *)subview;
                    target.editable = NO;
                }
            }
            self->_status = MnemonicVCStatus_testSeedWordSuccess;
            [self setStatus:self->_status];
            self.passwordHintCheckFeild.cell.title = self.passwordHint;
        }
    }];

}

- (void)chechPassword:(NSString *)password{
    if ([password isEqualToString:_password]) {
        NSLog(@"密码重新输入 正确");
        _status = MnemonicVCStatus_reenterPasswordOk;
        self.passwordCheckFeild.editable = NO;
        [self setStatus:_status];
    } else {
        NSLog(@"%@ %@", password, _password);
    }
}

- (void)fillBox1WithNewSeeds{
    [BKMsCoinMachine_Mac_Obj app_getB39mnemonic:128 withCompleteBlock:^(CoinMachineResult *coinMachineResult) {
        NSArray *seeds = coinMachineResult.obj;
        
        for (NSView *subview in self.box1.subviews) {
            if ([subview isKindOfClass:[NSTextField class]] && subview.tag >= 100) {
                NSTextField *target = (NSTextField *)subview;
                target.cell.title = seeds[target.tag - 100];
            }
        }
        self.box1Label.cell.title = @"New gnerated 12 seed words";
        self->_status = MnemonicVCStatus_newSeedWordsGenerated;
        [self setStatus:self->_status];
        self.seedWordsGenergted = seeds;
//        NSLog(@"self.seedWordsGenergted %@", self.seedWordsGenergted);

    }];
}

//- (IBAction)test:(id)sender {
//    _status = _status + 1;
//    if (_status > MnemonicVCStatus_allInfoSaved) {
//        _status = 0;
//    }
//    [self setStatus:_status];
//}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField *textField = [notification object];
    if(textField.tag >= 100){
        NSMutableArray *seedArray = [NSMutableArray new];
        for (NSView *subview in self.box3.subviews) {
            if ([subview isKindOfClass:[NSTextField class]] && subview.tag >= 100) {
                NSTextField *target = (NSTextField *)subview;
                seedArray[target.tag - 100] = target.cell.title;
            }
        }
        [self checkInputSeedWords: seedArray];
    } else if(textField == self.setPasswordHitFeild
              || textField == self.setPasswordFeild){
        if (self.setPasswordHitFeild.stringValue.length > 0
            && self.setPasswordFeild.stringValue.length > 0) {
            _status = MnemonicVCStatus_passwordHintSetted;
            self.nextBtn.hidden = NO;
        } else {
            self.nextBtn.hidden = YES;
        }
         _password = self.setPasswordFeild.stringValue;
        _passwordHint = self.setPasswordHitFeild.stringValue;
        
        
    } else if(textField == self.passwordCheckFeild){
        [self chechPassword:textField.stringValue];
    }
}

@end
