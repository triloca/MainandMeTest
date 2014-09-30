//
//  ProximityKitManager.m
//  MainAndMe
//
//  Created by Alexander Bukov on 9/27/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "ProximityKitManager.h"
//#import "CKManager.h"
#import <CampaignKit/CampaignKit.h>
#import "AlertManager.h"

@interface ProximityKitManager() <CKManagerDelegate>

@property (strong, nonatomic) CKManager* campaignKitManager;

@end


@implementation ProximityKitManager
#pragma mark _______________________ Class Methods _________________________

#pragma mark - Shared Instance and Init
+ (ProximityKitManager *)shared {
    
    static ProximityKitManager *shared = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}

#pragma mark ____________________________ Init _____________________________

-(id)init{
    
    self = [super init];
    if (self) {
   		// your initialization here
    }
    return self;
}

#pragma mark _______________________ Privat Methods ________________________



#pragma mark _______________________ Delegates _____________________________

- (void)campaignKit:(CKManager *)manager didFindCampaign:(CKCampaign *)campaign
{
    UIApplication* app = [UIApplication sharedApplication];
    if (app.applicationState != UIApplicationStateActive)
    {
        // if in background, pop a local notification
        [app presentLocalNotificationNow:[campaign buildLocalNotification]];
        NSLog(@"Notification Displayed");
    } else {
        // else if app is open, show alert view
        [CKCampaignAlertView showWithCampaign:campaign andCompletion:^{
            [self showCampaign:campaign];
        }];
    }
}

- (void)showCampaign:(CKCampaign*)campaign
{
    // TODO: write custom code or use code from the Campaign Kit reference app
    [[AlertManager shared] showOkAlertWithTitle:[NSString stringWithFormat:@"%@", campaign]];

}

#pragma mark _______________________ Public Methods ________________________

- (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
#ifdef __IPHONE_8_0
    if ([UIUserNotificationSettings class]) {
        // register to be allowed to notify user (for iOS 8)
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert) categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
#endif
    
    self.campaignKitManager = [CKManager managerWithDelegate:self];
    [self.campaignKitManager start];
    
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    CKCampaign* campaign = [_campaignKitManager campaignFromNotification:notification];
    if (campaign)
    {
        [self showCampaign:campaign];
    }
}



- (void)campaignKit:(CKManager *)manager didFailWithError:(NSError *)error{

}

#pragma mark _______________________ Notifications _________________________



@end
