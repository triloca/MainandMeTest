//
//  AppDelegate.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 10/16/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "AppDelegate.h"
#import "LocationManager.h"
#import <AddressBook/AddressBook.h>

#import "RegistrationRequest.h"
#import "MMServiceProvider.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [LayoutManager application:application didFinishLaunchingWithOptions:launchOptions];
    [[LocationManager sharedManager] setUpdatePeriod:10];//10 seconds
    [[LocationManager sharedManager] setDistanceFilter:10];//10 meters
    [[LocationManager sharedManager] start];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:LOCATION_CHANGED_NOTIFICATION_NAME object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        
        CLLocation *loc = (CLLocation *) notification.userInfo;
        NSLog(@"--- LOCATION UPDATED: %@ ----", loc);
    }];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:REGION_CHANGED_NOTIFICATION_NAME object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        
        CLLocation *loc = (CLLocation *) notification.userInfo;
        NSLog(@"--- REGION CHANGED: %@ ----", loc);
    }];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:GEOCODING_INFO_UPDATED_NOTIFICATION_NAME object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        
        CLPlacemark *placemark = (CLPlacemark *) notification.userInfo;
        NSLog(@"Placemark name: %@", placemark.name);
//        NSDictionary *dict = placemark.addressDictionary;
//        NSString *locationName = [NSString stringWithFormat:@"%@", [dict objectForKey:(NSString *) kABPersonAddressStreetKey]];
    }];
    
    [[LocationManager sharedManager] updateWithCompletionBlock:^(CLLocation * loc) {
        NSLog(@"Forced udpate location: %@", loc);
    }];
    
    
//    RegistrationRequest *request = [[RegistrationRequest alloc] init];
//    request.username = @"test12";
//    request.password = @"passwd";
//    request.email = @"ee1@ee.com";
//    
//    [[MMServiceProvider sharedProvider] sendRequest:request success:^(RegistrationRequest *request) {
//        NSLog(@"Registration complete! %@", request.response);
//    } failure:^(RegistrationRequest *request, NSError *error) {
//        NSLog(@"Registration failed: %@", error);
//        NSLog(@"Response: %@", request.response);
//    }];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
