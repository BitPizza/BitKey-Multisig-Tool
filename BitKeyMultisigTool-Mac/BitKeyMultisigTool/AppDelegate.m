//
//  AppDelegate.m
//  TEST_MacOS
//
//  Created by df on 2018/9/21.
//  Copyright © 2018 bitkey.app. All rights reserved.
//

#import "AppDelegate.h"
#import "MainVC.h"
#import "BKHttpProxy.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSLog(@"applicationDidFinishLaunching %@", self.window);
    [BKMsCoinMachine_Mac sharedInstance];
    self.window.backgroundColor = [NSColor whiteColor];
    MainVC *mvc = [MainVC new];
    self.window.contentViewController = mvc;
    [BKHttpProxy registerProxy];

}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag {
    NSLog(@"applicationShouldHandleReopen %d", flag);
    [self.window makeKeyAndOrderFront:self];
    return NO;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application {
    NSLog(@"applicationShouldTerminateAfterLastWindowClosed");
    return YES;
}

- (IBAction)deleteWalletData:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Important"];
    [alert setInformativeText:@"Make sure you have backup your seed words or you will lose all your coins."];
    [alert addButtonWithTitle:@"Cancel"];
    [alert addButtonWithTitle:@"Delete All Wallet Data"];
    NSModalResponse responseTag = [alert runModal];
    if(responseTag == 1001) {
        [[NSUserDefaults standardUserDefaults]  removeObjectForKey:NSUserDefaults_Key_HDWalletInfo];
        [[NSUserDefaults standardUserDefaults]  removeObjectForKey:NSUserDefaults_Key_PathCount];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:Notice_Name_NewSeedsSaved object:nil userInfo:nil];
    } else {
//        [BKMsCoinMachine testJs];
    }
    
    
    MainVC *mvc = [MainVC new];
    self.window.contentViewController = mvc;
    //删除之后一定全新生成MainVC。否则一些数据会在内存生成错误的数据实在是太危险了！！！！！！
}




@end
