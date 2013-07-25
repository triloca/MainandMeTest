//
//  LocationManager.m
//  TestMap1
//
//  Created by Sasha Bukov on 5/1/12.
//  Copyright (c) 2012 Company. All rights reserved.
//

#import "LocationManager.h"

@interface LocationManager() <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) CLLocation* currentLocation;
@property (assign, nonatomic) BOOL isUpdating;


@end


@implementation LocationManager

#pragma mark - Shared Instance and Init
+ (LocationManager *)shared {
    
    static LocationManager *shared = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}

-(id)init{
    
    self = [super init];
    if (self) {
   		// your initialization here
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.delegate = self;
        _isUpdating = NO;
        
        _stateName = @"";
        _statePrefix = @"";
        
        _locationFailed = NO;
        
    }
    return self;
}

#pragma mark - 

#pragma mark -  CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    _locationFailed = YES;
    [_locationManager stopUpdatingLocation];
    if (_isUpdating) {
        _isUpdating = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:kUNDidFailUpdateLocetionNotification
                                                            object:error];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    _locationFailed = NO;
    
    self.currentLocation = newLocation;
    self.defaultLocation = newLocation;
 
    [_locationManager stopUpdatingLocation];
    if (_isUpdating) {
        _isUpdating = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:kUNDidUpdateLocetionNotification
                                                        object:newLocation];
    }
}

#pragma mark - Public Methods


- (void)updateLocation{
    if (!_isUpdating) {
        _isUpdating = YES;
        [_locationManager startUpdatingLocation];
    }
}

- (CLLocation*)currentLocation{
    return _currentLocation;
}


- (void)setDefaultLocation:(CLLocation *)defaultLocation
                  sateName:(NSString*)stateName
                    prefix:(NSString*)prefix{

    _defaultLocation = defaultLocation;
    _stateName = stateName;
    _statePrefix = prefix;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kUNDidUpdateLocetionNotification
                                                        object:nil];
}

- (void)notifyUpdate{
    [[NSNotificationCenter defaultCenter] postNotificationName:kUNDidUpdateLocetionNotification
                                                        object:_defaultLocation];
}

@end
