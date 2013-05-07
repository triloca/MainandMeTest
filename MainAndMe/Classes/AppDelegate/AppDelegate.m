//
//  AppDelegate.m
//  testroot1
//
//  Created by Sasha Bukov on 4/29/12.
//  Copyright (c) 2012 Company. All rights reserved.
//

#import "AppDelegate.h"
#import "LayoutManager.h"
#import "ReachabilityManager.h"
#import "FacebookSDK/FacebookSDK.h"
#import "AlertManager.h"
#import "NotificationManager.h"
#import "TestFlight.h"
#import "UIDevice+IdentifierAddition.h"

@interface AppDelegate()

@end


@implementation AppDelegate
@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
//#ifndef DEBUG
     [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueDeviceIdentifier]];
   
    [TestFlight takeOff:@"13260f43-93c0-465c-b350-5c1293135100"];
    
//#endif

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];

    [[LayoutManager shared] application:application
          didFinishLaunchingWithOptions:launchOptions];
    [ReachabilityManager shared];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeAlert |
      UIRemoteNotificationTypeBadge |
      UIRemoteNotificationTypeSound)];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark - Facebook
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [FBSession.activeSession handleOpenURL:url];
}

// For iOS 4.2+ support
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    return [FBSession.activeSession handleOpenURL:url];
}

#pragma mark Push Notifications
// Delegation methods
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    NSString *tokenKey = [devToken description];
    NSLog(@"APNS Token = %@", tokenKey);
    
	tokenKey = [tokenKey stringByReplacingOccurrencesOfString:@"<" withString:@""];
	tokenKey = [tokenKey stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    [NotificationManager shared].deviceToken = tokenKey;
    tokenKey = [tokenKey stringByReplacingOccurrencesOfString:@" " withString:@""];
    //!Save token
    NSLog(@"APNS Token = %@", tokenKey);
    //NSString* alertText = [NSString stringWithFormat:@"%@\n%@\n%@", @"Notification Token =", tokenKey, @"For test only"];
    //[[AlertManager shared] showOkAlertWithTitle:alertText];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError: [%@]", err);
    //!Reset token
    [[AlertManager shared] showOkAlertWithTitle:@"Failed To Register For Remote Notifications"];
}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif {
    NSLog(@"notif.userInfo: %@", notif.userInfo);
   // [[AlertManager shared] showOkAlertWithTitle:[NSString stringWithFormat:@"%@", notif.userInfo]];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSLog(@"userInfo: %@", userInfo);
   // NSString* notifString = [NSString stringWithFormat:@"%@", userInfo];
    [[LayoutManager shared].mainViewController loadNotifications];
    //[[AlertManager shared] showOkAlertWithTitle:@"Notification" message:notifString];
}
@end
