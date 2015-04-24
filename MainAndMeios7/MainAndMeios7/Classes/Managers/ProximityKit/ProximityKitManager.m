//
//  ProximityKitManager.m
//  MainAndMe
//
//  Created by Alexander Bukov on 9/27/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "ProximityKitManager.h"
//#import "CKManager.h"
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
        self.compaignArray = [NSMutableArray new];
        [self loadArchive];
        
        self.campaignKitManager = [CKManager managerWithDelegate:self];
        [self.campaignKitManager start];

    }
    return self;
}

#pragma mark _______________________ Privat Methods ________________________


-(NSString*)getFullFilePath:(NSString*)name
{
    
    NSString *theFileName = [NSString stringWithFormat:@"%@.data", name];
    
    NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    
    NSString *librarysDir = [libraryPaths objectAtIndex:0];
    NSString *folder = [librarysDir stringByAppendingPathComponent:@"Caches/Specials"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if (![fileManager fileExistsAtPath:folder]) {
        [fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:&error];
        
        //! Remove iCloud sync
        NSURL *url = [NSURL fileURLWithPath:folder];
        [self addSkipBackupAttributeToItemAtURL:url];

    }
    if (error != nil) {
        NSLog(@"Some error: %@", error);
        return librarysDir;
    }
    
    NSString *databasePath = [folder stringByAppendingPathComponent:theFileName];
    
    return databasePath;
}


- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}


- (void)addCompaign:(CKCampaign*)obj{
    [_compaignArray addObject:obj];
    [self saveArchive];
    [self sendNewCampaignNotification:obj];
}

- (void)deleteCompaign:(CKCampaign*)compaign{
    
    __block NSInteger index = -1;
    
    [_compaignArray enumerateObjectsUsingBlock:^(CKCampaign* obj, NSUInteger idx, BOOL *stop) {
        if (obj == compaign) {
            index = (NSInteger)idx;
        }
    }];
    
    if (index >= 0) {
        [_compaignArray removeObjectAtIndex:index];
    }
    
    [self saveArchive];
    [self sendNewCampaignNotification:nil];
}


- (void)saveArchive{
    // Archive
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_compaignArray];
    NSString *path = [self getFullFilePath:@"compaign"];
    [data writeToFile:path options:NSDataWritingAtomic error:nil];
}

- (void)loadArchive{
    
    // Unarchive
    NSString *path = [self getFullFilePath:@"compaign"];
    self.compaignArray = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
    if (_compaignArray == nil) {
        self.compaignArray = [NSMutableArray new];
    }
}

#pragma mark _______________________ Delegates _____________________________

- (void)campaignKit:(CKManager *)manager didFindCampaign:(CKCampaign *)campaign
{
    
    [self addCompaign:campaign];
    
    UIApplication* app = [UIApplication sharedApplication];
    if (app.applicationState == UIApplicationStateBackground)
    {
        // if in background, pop a local notification
        [app presentLocalNotificationNow:[campaign buildLocalNotification]];
        NSLog(@"Notification Displayed");
    } else {
        // else if app is open, show alert view
        [CKCampaignAlertView showWithCampaign:campaign andCompletion:^{
            [self showIBeaconController:campaign];
        }];
    }
}

- (void)showCampaign:(CKCampaign*)campaign
{
    // TODO: write custom code or use code from the Campaign Kit reference app
    
   // [[AlertManager shared] showOkAlertWithTitle:[NSString stringWithFormat:@"%@", campaign]];
    
    [[AlertManager shared] showOkAlertWithTitle:campaign.content.alertTitle
                                        message:[NSString stringWithFormat:@"%@", campaign.content.body]];

}


- (void)showIBeaconController:(CKCampaign*)campaign{
    
    [[LayoutManager shared] showSpecialDetails:campaign];
    
//    IBeaconInfoViewController* iBeaconInfoViewController = [IBeaconInfoViewController loadFromXIB_Or_iPhone5_XIB];
//    iBeaconInfoViewController.campaign = campaign;
//    [[LayoutManager shared].rootNavigationController pushViewController:iBeaconInfoViewController animated:YES];
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
    
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    CKCampaign* campaign = [_campaignKitManager campaignFromNotification:notification];
    if (campaign)
    {
        [self showIBeaconController:campaign];
    }
}



- (void)campaignKit:(CKManager *)manager didFailWithError:(NSError *)error{

}

- (NSArray*)activeCampaigns{
    return self.campaignKitManager.activeCampaigns;
}

#pragma mark _______________________ Notifications _________________________

- (void)sendNewCampaignNotification:(CKCampaign*)campaign{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewCampaignNotification object:campaign];
}

@end
