//
//  ProximityKitManager.h
//  MainAndMe
//
//  Created by Alexander Bukov on 9/27/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <CampaignKit/CampaignKit.h>

#define kNewCampaignNotification @"kNewCampaignNotification"


@interface ProximityKitManager : NSObject

@property (strong, nonatomic) NSMutableArray* compaignArray;

+ (ProximityKitManager*)shared;

- (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification;


- (void)showIBeaconController:(CKCampaign*)campaign;
- (void)deleteCompaign:(CKCampaign*)obj;

@end