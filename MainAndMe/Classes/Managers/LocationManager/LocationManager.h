//
//  LocationManager.h
//  TestMap1
//
//  Created by Sasha Bukov on 5/1/12.
//  Copyright (c) 2012 Company. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#define kUNDidUpdateLocetionNotification @"kUNDidUpdateLocetionNotification"
#define kUNDidFailUpdateLocetionNotification @"kUNDidFailUpdateLocetionNotification"
#define kUNDidUpdateDefaultLocetionNotification @"kUNDidUpdateDefaultLocetionNotification"

#define kUNDidUpdateCommunityNotification @"kUNDidUpdateCommunityNotification"

@interface LocationManager : NSObject

@property (strong, nonatomic) NSString* stateName;
@property (strong, nonatomic) NSString* statePrefix;

//!! New location functionality
@property (strong, nonatomic) NSString* communityStateName;
@property (strong, nonatomic) NSString* communityStatePrefix;
@property (strong, nonatomic) CLLocation* communityLocation;
//!!

@property (strong, nonatomic) CLLocation* defaultLocation;
@property (assign, nonatomic) BOOL locationFailed;


+ (LocationManager*)shared;
- (void)updateLocation;
- (CLLocation*)currentLocation;
- (void)setDefaultLocation:(CLLocation *)defaultLocation
                  sateName:(NSString*)stateName
                    prefix:(NSString*)prefix;

- (void)notifyUpdate;
- (void)notifyCommunityUpdate;

- (void)setupComminityLocation:(CLLocation*)location
                          name:(NSString*)name
                        prefix:(NSString*)prefix;
@end
