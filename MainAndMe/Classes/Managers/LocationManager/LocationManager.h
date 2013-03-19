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

@interface LocationManager : NSObject

+ (LocationManager*)shared;
- (void)updateLocation;
- (CLLocation*)currentLocation;

@end
