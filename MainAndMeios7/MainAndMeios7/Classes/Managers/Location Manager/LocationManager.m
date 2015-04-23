//
//  LocationManager.m
//  LocationManager
//
//  Created by Vladislav Zozulyak on 20.10.14.
//  Copyright (c) 2014 Vladislav Zozulyak. All rights reserved.
//

#import "LocationManager.h"

@interface LocationManager() <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *clLocationManager;
@property (strong, nonatomic) NSTimer *timer;
@property BOOL started;
@property BOOL forcedUpdate;

@property (strong, nonatomic) CLLocation *regionLocation;
@property (strong, nonatomic) LocationFoundCompletionBlock completionBlock;

@end

@implementation LocationManager


#pragma mark ____________________________ Init _____________________________

- (id) init {
    if (self = [super init]) {
        self.clLocationManager = [[CLLocationManager alloc] init];
        self.clLocationManager.delegate = self;
        self.clLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        self.updatePeriod = 0;
        
#ifdef __IPHONE_8_0
        if ([self.clLocationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
            [self.clLocationManager requestWhenInUseAuthorization];
#endif

    }
    return self;
}

+ (LocationManager *) sharedManager {
    static __strong LocationManager *instance = nil;
    if (!instance)
        instance = [[LocationManager alloc] init];
    return instance;
}

#pragma mark _______________________ Public Methods ________________________

- (void) start {
    if (_started)
        return;
    
    [self.clLocationManager startUpdatingLocation];
    self.started = YES;
    [self startTimer];
    NSLog(@"Location manager did started");
}

- (void) stop {
    if (!_started)
        return;
    
    [self.clLocationManager stopUpdatingLocation];
    self.started = NO;
    [self.timer invalidate];
    self.timer = nil;
}

- (void) update {
    self.clLocationManager.distanceFilter = 0;
    self.forcedUpdate = YES;
}

- (void) updateWithCompletionBlock: (LocationFoundCompletionBlock) completion {
    self.completionBlock = completion;
    [self update];
}

- (void) setDistanceFilter: (CLLocationDistance) distanceFilter {
    _distanceFilter = distanceFilter;
    self.clLocationManager.distanceFilter = distanceFilter;
}

- (void) setUpdatePeriod:(NSInteger)updatePeriod {
    if (_updatePeriod == updatePeriod)
        return;
    _updatePeriod = updatePeriod;
    [self startTimer];
}

#pragma mark _______________________ Private Methods ________________________

- (void) startTimer {
    if (_updatePeriod > 0 && _started) {
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:_updatePeriod target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
    }
}

- (void) timerTick: (NSTimer *) timer {
    if (!_started)
        return;
    [self update];
}

#pragma mark _______________________ Core Location ___________________________

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    NSLog(@"loc");
    if (self.currentLocation == nil || _forcedUpdate || [self.currentLocation distanceFromLocation:location] > 1) { //1 is for treshold
        self.currentLocation = location;
        [self processGeocoderWithCoordinate:location];
        [self notify:LOCATION_CHANGED_NOTIFICATION_NAME withObject:location];
        
        if (_forcedUpdate) {
            self.distanceFilter = _distanceFilter;
        }
        self.forcedUpdate = NO;
        if (self.completionBlock != nil) {
            dispatch_async(dispatch_get_main_queue(),^{
                self.completionBlock(location);
                self.completionBlock = nil;
            });
        }
    }

    if (_distanceFilter > 0) {
        if (self.regionLocation == nil) {
            self.regionLocation = location;
        } else if ([location distanceFromLocation:self.regionLocation] > self.distanceFilter) {
            self.regionLocation = self.currentLocation;
            [self notify:REGION_CHANGED_NOTIFICATION_NAME withObject:self.currentLocation];
        }
    }
    
    [self stop];
}


- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Location manager did failed with error: %@", error.description);
}

- (void) processGeocoderWithCoordinate: (CLLocation *) locaiton {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:locaiton completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error || [placemarks count] == 0) {
            self.currentPlacemark = nil;
        } else {
            CLPlacemark *placemark = [placemarks lastObject];
            self.currentPlacemark = placemark;
            [self notify:GEOCODING_INFO_UPDATED_NOTIFICATION_NAME withObject:self.currentPlacemark];
            NSLog(@"Placemark name: %@", placemark.name);
        }
    }];
}

#pragma mark _______________________ Notifications _________________________

- (void) notify: (NSString *) notificationName withObject: (id) object {
    dispatch_async(dispatch_get_main_queue(),^{
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                            object:nil
                                                          userInfo:object];
    });
}

@end
