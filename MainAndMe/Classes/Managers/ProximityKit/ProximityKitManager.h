//
//  ProximityKitManager.h
//  MainAndMe
//
//  Created by Alexander Bukov on 9/27/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <CampaignKit/CampaignKit.h>


@interface ProximityKitManager : NSObject

+ (ProximityKitManager*)shared;

- (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification;


- (void)showIBeaconController:(CKCampaign*)campaign;

@end