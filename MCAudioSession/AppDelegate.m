//
//  AppDelegate.m
//  MCAudioSession
//
//  Created by Chengyin on 14-7-10.
//  Copyright (c) 2014年 Chengyin. All rights reserved.
//

#import "AppDelegate.h"
#import "MCAudioSession.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.rootViewController = [UIViewController new];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interruptionNotificationReceived:) name:MCAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChangeNotificationReceived:) name:MCAudioSessionRouteChangeNotification object:nil];
    
    [self activeAudioSession];
    
    return YES;
}


- (void)activeAudioSession
{
    NSError *error = nil;
    if ([[MCAudioSession sharedInstance] setActive:YES error:&error])
    {
        NSLog(@"audiosession actived");
    }
    else
    {
        NSLog(@"audiosession active failed, error: %@",[error description]);
    }
}

- (void)interruptionNotificationReceived:(NSNotification *)notification
{
    UInt32 interruptionState = [notification.userInfo[MCAudioSessionInterruptionStateKey] unsignedIntValue];
    AudioSessionInterruptionType interruptionType = [notification.userInfo[MCAudioSessionInterruptionTypeKey] unsignedIntValue];
    [self handleAudioSessionInterruptionWithState:interruptionState type:interruptionType];
}

- (void)handleAudioSessionInterruptionWithState:(UInt32)interruptionState type:(AudioSessionInterruptionType)interruptionType
{
    if (interruptionState == kAudioSessionBeginInterruption)
    {
        NSLog(@"interrupt begin");
        NSLog(@"pause the playing audio");
    }
    else if (interruptionState == kAudioSessionEndInterruption)
    {
        NSLog(@"interrupt end");
        if (interruptionType == kAudioSessionInterruptionType_ShouldResume)
        {
            OSStatus status = AudioSessionSetActive(true);
            if (status == noErr)
            {
                NSLog(@"resume the paused audio");
            }
        }
    }
}

- (void)routeChangeNotificationReceived:(NSNotification *)notification
{
    NSLog(@"route changed! %@",[MCAudioSession isAirplayActived] ? @"airplay actived" : @"airplay is actived");
    
    BOOL usingHeadset = [MCAudioSession usingHeadset];
    SInt32 routeChangeReason = [notification.userInfo[MCAudioSessionRouteChangeReason] intValue];
    if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable && !usingHeadset)
    {
        NSLog(@"headset off, pause the playing audio");
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [self activeAudioSession];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
