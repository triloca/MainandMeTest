//
//  LocationManager.h
//  LocationManager
//
//  Created by Vladislav Zozulyak on 20.10.14.
//  Copyright (c) 2014 Vladislav Zozulyak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define LOCATION_CHANGED_NOTIFICATION_NAME @"LOCATION_CHANGED_NOTIFICATION"
#define REGION_CHANGED_NOTIFICATION_NAME @"REGION_CHANGED"
#define GEOCODING_INFO_UPDATED_NOTIFICATION_NAME @"GEOCODING_INFO_UPDATED"

typedef void (^LocationFoundCompletionBlock) (CLLocation *location);

@interface LocationManager : NSObject

//input
@property (nonatomic) CLLocationDistance distanceFilter; //default is 1km
@property (nonatomic) NSInteger updatePeriod; //period for auto-update location routine. default is 10 min

//output
@property (strong, nonatomic) CLPlacemark *currentPlacemark; //Reverse geocoder info
@property (strong, nonatomic) CLLocation *currentLocation;


- (void) start;
- (void) stop;
- (void) update;

- (void) updateWithCompletionBlock: (LocationFoundCompletionBlock) completion;
+ (LocationManager *) sharedManager;

@end
