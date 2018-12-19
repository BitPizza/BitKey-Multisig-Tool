//
//  MainVC.m
//  TEST_MacOS
//
//  Created by df on 2018/9/21.
//  Copyright © 2018 bitkey.app. All rights reserved.
//

#import "MainVC.h"
#import "BKMsImportSeedsVC.h"
#import "BKMsGenerateSeedsVC.h"
#import "ShowQRcodeSmallVC.h"
#import "ShowQRcodeBigVC.h"



typedef NS_ENUM(NSInteger, BKMsToolStatus) {
    BKMsToolStatus_init = 0,
    BKMsToolStatus_needPassword = 1,
    BKMsToolStatus_ok = 2
};

@interface MainVC ()<NSTextFieldDelegate, NSTableViewDataSource, NSTableViewDelegate, NSTextViewDelegate>{
    BKMsToolStatus _status;
    NSDictionary *_hdWalletInfo;
    NSString *_password;
    NSInteger _pathCount;
    NSInteger _rowCount;
    NSDictionary *_currentkeypairInfo;
    BOOL _alertDidShow;
}

@property (weak) IBOutlet NSSecureTextField *passwordFeild;
@property (weak) IBOutlet NSTextField *statusLabel;
@property (weak) IBOutlet NSButton *topBtn0;
@property (weak) IBOutlet NSButton *topBtn1;
@property (weak) IBOutlet NSButton *topBtn2;
@property (weak) IBOutlet NSTableView *pathList;
@property (unsafe_unretained) IBOutlet NSTextView *txInfoTextView;
@property (weak) IBOutlet NSBox *box1;
@property (weak) IBOutlet NSBox *box2;
@property (weak) IBOutlet NSBox *box3;

@property (weak) IBOutlet NSTextField *pubkeyLable;
@property (weak) IBOutlet NSTextField *privateKeyLable;
@property (weak) IBOutlet NSTextField *inputJsonStatusLabel;
@property (unsafe_unretained) IBOutlet NSTextView *trInputTextView;
@property (unsafe_unretained) IBOutlet NSTextView *resultTextView;

@property (weak) IBOutlet NSTextField *keypairTitleLabel;
@property (strong, nonatomic) NSDictionary *currentkeypairInfo;





@end

@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _pathCount = [[[NSUserDefaults standardUserDefaults] objectForKey:NSUserDefaults_Key_PathCount] integerValue];
    [self chechWalletStatus];
    [self updateSelectedKeypairInfo];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notice:)
                                                 name:Notice_Name_NewSeedsSaved
                                               object:nil];
    
    

}

- (void)notice:(id)sender{
    [self chechWalletStatus];
}
- (IBAction)addPath:(id)sender {
    if (_status != BKMsToolStatus_ok) {
        return;
    }
    _pathCount = _pathCount + 1;
    [self chechWalletStatus];

}
- (IBAction)removePath:(id)sender {
    if (_status != BKMsToolStatus_ok) {
        return;
    }
    _pathCount = _pathCount - 1;
    if (_pathCount < 0) {
        _pathCount = 0;
    }
    [self chechWalletStatus];
}


- (void)viewDidAppear {
    self.passwordFeild.delegate = self;
    [self chechWalletStatus];

    self.pathList.delegate = self;
    self.pathList.dataSource = self;
    self.pathList.rowHeight = 30;
    
    
    
    [self.txInfoTextView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [self.txInfoTextView setVerticallyResizable:YES];
    [self.txInfoTextView setHorizontallyResizable:YES];
    [self.txInfoTextView setAutoresizingMask:NSViewWidthSizable];
    [[self.txInfoTextView textContainer] setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [[self.txInfoTextView textContainer] setWidthTracksTextView:NO];
    
    
    [self.resultTextView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [self.resultTextView setVerticallyResizable:YES];
    [self.resultTextView setHorizontallyResizable:YES];
    [self.resultTextView setAutoresizingMask:NSViewWidthSizable];
    [[self.resultTextView textContainer] setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [[self.resultTextView textContainer] setWidthTracksTextView:NO];
    
    
    self.trInputTextView.delegate = self;
}

- (void)chechWalletStatus{
    _hdWalletInfo = [[NSUserDefaults standardUserDefaults] objectForKey:NSUserDefaults_Key_HDWalletInfo];
    _status = BKMsToolStatus_init;
    if (_hdWalletInfo
        && _hdWalletInfo[@"seeds"]
        && _hdWalletInfo[@"passwordMD5"]
        && _hdWalletInfo[@"passwordHint"]) {
        _status = BKMsToolStatus_needPassword;
        if (_password) {
            _status = BKMsToolStatus_ok;
        }
    }
    [self setStatus:_status];
    
    
    if (_pathCount > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:_pathCount] forKey:NSUserDefaults_Key_PathCount];
        NSLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:NSUserDefaults_Key_PathCount] );
        
        _rowCount = _pathCount;
    }

    

    if (_status != BKMsToolStatus_ok) {
        _rowCount = 0;
    }
    
    
    if (_status == BKMsToolStatus_ok && _pathCount <= 0) {
        _rowCount = 1;
    }
    
    
    
    NSLog(@"chechWalletStatus %ld", (long)_pathCount);
    [self.pathList reloadData];
}

//Mnemonic / SeedWords
- (IBAction)topBtnTap:(NSButton *)sender {
    sender.state = YES;
    NSLog(@"tap");
    
    if (sender == self.topBtn0) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Wallet Info"];
        NSString * seeds = [_hdWalletInfo[@"seeds"] componentsJoinedByString:@" "];
        [alert setInformativeText:[NSString stringWithFormat:@"Seeds: %@  \n\nPassword Hint: %@ \n\n[Important] You should write down the *12 words and password hint* on a piece of paper then store it somewhere safe.", seeds, _hdWalletInfo[@"passwordHint"]]];
        [alert addButtonWithTitle:@"Close"];
        [alert runModal];
    }
    
    if (sender == self.topBtn1) {
        BKMsGenerateSeedsVC *vc = [BKMsGenerateSeedsVC new];
        [self presentViewControllerAsSheet:vc];
    }
    
    if (sender == self.topBtn2) {
        BKMsImportSeedsVC *vc = [BKMsImportSeedsVC new];
        [self presentViewControllerAsSheet:vc];
    }

}

- (IBAction)testTap:(id)sender {
    _status = _status + 1;
    if (_status > BKMsToolStatus_ok) {
        _status = 0;
    }
    [self setStatus:_status];
}


- (void)showAlert_MUSTREAD{
    if (_alertDidShow) {
        return;
    }
    _alertDidShow = YES;
    dispatch_async(dispatch_get_main_queue(), ^(){
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"MUST READ"];
        [alert setInformativeText:@"BitKeyMultisigTool is not a cryptocurrency exchange. \n\nThis is a pure tool co-working with Bitkey app on iPhone, using the Multisig-Timelock address to manage Bitcoin keys for individual users. \n\nThis app does not need to connect the Internet, you can keep your private-keys(Key2) in cold storage."];
        [alert addButtonWithTitle:@"Close"];
//        [alert addButtonWithTitle:@"Introduction Multisig-TimeLock Address"];
        [alert runModal];
    });

}

- (void)setStatus:(BKMsToolStatus)status {
    self.passwordFeild.hidden = YES;
    self.topBtn0.hidden = YES;
    self.topBtn1.hidden = YES;
    self.topBtn2.hidden = YES;
    switch (status) {
        case BKMsToolStatus_init:{
            self.statusLabel.cell.title =  @"Wallet Status: \n\nNeed to generate new seed words or import seed words.";
            self.statusLabel.textColor = [NSColor redColor];
            self.topBtn1.hidden = NO;
            self.topBtn2.hidden = NO;
            [self showAlert_MUSTREAD];

        }
            break;
        case BKMsToolStatus_needPassword:{
            NSString *message = [NSString stringWithFormat:@"Wallet Status: \n\nEnter your password. Hint: %@", _hdWalletInfo[@"passwordHint"]];
            self.statusLabel.cell.title = message;
            self.statusLabel.textColor = [NSColor redColor];
            self.passwordFeild.hidden = NO;
            [self showAlert_MUSTREAD];

            

        }
            break;
        case BKMsToolStatus_ok:{
            self.statusLabel.cell.title =  @"Wallet Status: \n\nok.";
            self.statusLabel.textColor = [NSColor lightGrayColor];
            self.topBtn0.hidden = NO;
        }
              break;
        default:
            break;
    }
}

- (void)chekPassword:(NSString *)password {
    NSString *passwordMD5 = _hdWalletInfo[@"passwordMD5"];
    if ([[[CryptoJsWrap new] cryptoJsMD5:password] isEqualToString:passwordMD5]) {
        _password = password;
        [self chechWalletStatus];
    }
    
}
- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField *textField = [notification object];
    if(textField == self.passwordFeild){
        [self chekPassword:[textField stringValue]];
    }
}


#pragma mark table datasource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return _rowCount;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSTextField *view   = [[NSTextField alloc] initWithFrame:NSMakeRect(30, 30, 40, 30)];
    view.editable = NO;
    view.backgroundColor = [NSColor clearColor];
    view.bordered = NO;
    view.textColor = [NSColor grayColor];
    return view;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSString *path = [NSString stringWithFormat:@" m/322'/0'/0'/0/%ld", (long)row];
    return path;
}

-(void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    [self updateSelectedKeypairInfo];
}





- (IBAction)showPubKey:(NSButton *)sender {
    NSString *jsonString;
    
    if (_currentkeypairInfo) {
        NSMutableDictionary *PubKeyInfo = [NSMutableDictionary new];
        PubKeyInfo[@"hd_wallet_key_info"] = _currentkeypairInfo[@"i"];
        PubKeyInfo[@"publicKey_hex"] = self.pubkeyLable.stringValue;
        
        NSDictionary *info = PubKeyInfo;
        if ([NSJSONSerialization isValidJSONObject:info])
        {
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:&error];
            jsonString =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    }


    [self ShowQRcodeSmallVC:@"Public Key Info" text:jsonString btn:sender fromView:self.box1];
}
- (IBAction)showPrivateKey:(NSButton *)sender {    
    NSString *jsonString;

    if (_currentkeypairInfo) {
        NSMutableDictionary *PrivateKeyInfo = [NSMutableDictionary new];
        PrivateKeyInfo[@"hd_wallet_key_info"] = _currentkeypairInfo[@"i"];
        PrivateKeyInfo[@"privateKey_wif"] = _currentkeypairInfo[@"privateKey_wif"];
        
        NSDictionary *info = PrivateKeyInfo;
        if ([NSJSONSerialization isValidJSONObject:info])
        {
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:&error];
            jsonString =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }

    }

    [self ShowQRcodeSmallVC:@"Private Key Info" text:jsonString btn:sender fromView:self.box2];
}
- (IBAction)showSignDetail:(NSButton *)sender {
}
- (IBAction)showSignResult:(NSButton *)sender {
    ShowQRcodeBigVC *vc = [ShowQRcodeBigVC new];
    vc.name = @"Sign Result";
    vc.text = self.resultTextView.string;
    [self presentViewControllerAsSheet:vc];
}

- (void)ShowQRcodeSmallVC:(NSString *)name text:(NSString *)text btn:(NSButton *)sender fromView:(NSView *)fromView{
    ShowQRcodeSmallVC *vc = [ShowQRcodeSmallVC new];
    vc.name = name;
    vc.text = text;
    NSLog(@"%@ %@", sender, NSStringFromRect(sender.frame));
    CGRect f = [self.view convertRect:sender.frame fromView:fromView];
    
    
    [self presentViewController:vc
        asPopoverRelativeToRect:f
                         ofView:self.view
                  preferredEdge:NSRectEdgeMinX
                       behavior:NSPopoverBehaviorTransient];
}

- (void)updateSelectedKeypairInfo{
    NSInteger selectedRow = [self.pathList selectedRow];
    NSLog(@"selectedRow %ld", selectedRow);
    
    self.pubkeyLable.cell.title = @"";
    self.privateKeyLable.cell.title = @"";
    self.trInputTextView.string = @"";
    self.resultTextView.string = @"";
    self.pubkeyLable.cell.title = @"";
    self.keypairTitleLabel.cell.title = @"keypair Info";

    
    
    if (selectedRow < 0) {
        self.pubkeyLable.hidden = YES;
        self.privateKeyLable.hidden = YES;
        self.box3.hidden = YES;
        return;
    } else {
        self.pubkeyLable.hidden = NO;
        self.privateKeyLable.hidden = NO;
        self.box3.hidden = NO;
    }
    
    NSString *path = [NSString stringWithFormat:@"m/322'/0'/0'/0/%ld", (long)selectedRow];
    NSMutableDictionary *loaclHDWalletObj = [NSMutableDictionary new];
    loaclHDWalletObj[@"words"] = [_hdWalletInfo[@"seeds"] componentsJoinedByString:@" "];
    loaclHDWalletObj[@"password"] = _password;
    loaclHDWalletObj[@"passwordHint"] = _hdWalletInfo[@"passwordHint"];
    
    [BKMsCoinMachine_Mac_Obj app_getHDKeypairFromSeedInfo:loaclHDWalletObj path:path withCompleteBlock:^(CoinMachineResult *coinMachineResult) {
        self.currentkeypairInfo = coinMachineResult.obj;
        self.pubkeyLable.cell.title = self.currentkeypairInfo[@"publicKey_hex"];
        NSString *privateKey_wif = self.currentkeypairInfo[@"privateKey_wif"];
        NSString *subString = [privateKey_wif substringWithRange:NSMakeRange(5, privateKey_wif.length - 10)];
        NSString *privateKey_wif_mask = [privateKey_wif stringByReplacingOccurrencesOfString:subString withString:@"◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼◼"];
        self.privateKeyLable.cell.title = privateKey_wif_mask;
        self.trInputTextView.string = @"";
        self.resultTextView.string = @"";
        self.inputJsonStatusLabel.cell.title = @"";
        self.keypairTitleLabel.cell.title = [NSString stringWithFormat:@"keypair Info, Path: %@", path];
    }];
    
}

- (void)textViewDidChangeSelection:(NSNotification *)notification{
    NSTextView *textview = [notification object];
    [self chechInputJosnInfo:textview.string];
}

- (void)chechInputJosnInfo:(NSString *)jsonString{
    self.resultTextView.string = @"";
    if (jsonString.length <= 0) {
        self.inputJsonStatusLabel.cell.title = @"blank";
        self.inputJsonStatusLabel.textColor = [NSColor redColor];
        return;
    }
    
    /////// json  ------> dict
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[(NSString *)jsonString  dataUsingEncoding:NSUTF8StringEncoding]options:kNilOptions error:&error];
    if (json == nil) {
        self.inputJsonStatusLabel.cell.title = @"json parse failed.";
        self.inputJsonStatusLabel.textColor = [NSColor redColor];
        return;
    }
    
    if (json[@"fromAddress"]
        && json[@"fromAddress"]
        && json[@"uTXOsArray"]
        && json[@"witnessScriptAsm"]
        && json[@"value"]
        && json[@"fee"]
        && json[@"nlockTime"]
        && (json[@"toAddress"] || (json[@"outputAddressArray"] && json[@"outputValueArray"]))) {
        
    
        NSString *witnessScriptAsm = json[@"witnessScriptAsm"];
        NSString *publicKey_hex = _currentkeypairInfo[@"publicKey_hex"];
        if ([witnessScriptAsm rangeOfString:publicKey_hex].location == NSNotFound) {
            self.inputJsonStatusLabel.cell.title = @"The multisig address(script) does not match this public key.";
            self.inputJsonStatusLabel.textColor = [NSColor redColor];
            [self sign:json];

        } else {
            self.inputJsonStatusLabel.cell.title = @"ok";
            self.inputJsonStatusLabel.textColor = [NSColor greenColor];
            [self sign:json];
        }
        
    } else {
        self.inputJsonStatusLabel.cell.title = @"Invalid transaction json.";
        self.inputJsonStatusLabel.textColor = [NSColor redColor];

    }
}

- (void)sign:(NSDictionary *)paymentObj{
    
    
    
    [BKMsCoinMachine_Mac_Obj app_timeLockMultiSigTxb_getHashHexForSigArray:paymentObj withCompleteBlock:^(CoinMachineResult *coinMachineResult1) {
        NSArray *hashHexForSig = coinMachineResult1.obj;
        [BKMsCoinMachine_Mac_Obj app_multiSig_sigUseKey:self.currentkeypairInfo[@"privateKey_wif"] hashHex:hashHexForSig withCompleteBlock:^(CoinMachineResult *coinMachineResult2) {
            
            NSArray *signedData = coinMachineResult2.obj;
            NSLog(@"%@", hashHexForSig);
            NSLog(@"%@", signedData);
            NSLog(@"%@", self.currentkeypairInfo);
            NSMutableDictionary *ret = [NSMutableDictionary new];
            ret[@"info"] = self.currentkeypairInfo[@"i"];
            ret[@"signature"] = signedData;
            
            NSDictionary *info = ret;
            NSString *jsonString;
            if ([NSJSONSerialization isValidJSONObject:info])
            {
                NSError *error;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:&error];
                jsonString =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
            
            
            [self.resultTextView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
            [self.resultTextView setVerticallyResizable:YES];
            [self.resultTextView setHorizontallyResizable:YES];
            [self.resultTextView setAutoresizingMask:NSViewWidthSizable];
            [[self.resultTextView textContainer] setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];
            [[self.resultTextView textContainer] setWidthTracksTextView:NO];
            
            
            
            self.resultTextView.string = jsonString;
            
        }];
        
    }];

}




@end
