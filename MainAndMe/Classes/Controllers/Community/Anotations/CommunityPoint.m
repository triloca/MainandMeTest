//
//  PlacePoint.m
//  Places
//
//  Created by Sasha on 1/15/13.
//
//

#import "CommunityPoint.h"

@implementation CommunityPoint

- (id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate
{
    if ((self = [super init])) {
        self.name = name;
        self.address = address;
        _coordinate = coordinate;
    }
    return self;
}

- (NSString *)title {
    if ([_name isKindOfClass:[NSNull class]])
        return @"Unknown charge";
    else
        return _name;
}

- (NSString *)subtitle {
    return _address;
}

@end
