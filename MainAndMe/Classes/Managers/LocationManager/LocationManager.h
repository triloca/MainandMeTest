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

@interface LocationManager : NSObject
@property (strong, nonatomic) NSString* stateName;
@property (strong, nonatomic) NSString* statePrefix;
@property (strong, nonatomic) CLLocation* defaultLocation;


+ (LocationManager*)shared;
- (void)updateLocation;
- (CLLocation*)currentLocation;
- (void)setDefaultLocation:(CLLocation *)defaultLocation
                  sateName:(NSString*)stateName
                    prefix:(NSString*)prefix;
- (void)notifyUpdate;
@end
