//
//  PlacePoint.m
//  Places
//
//  Created by Sasha on 1/15/13.
//
//

#define CLCOORDINATES_EQUAL( coord1, coord2 ) ((coord1.latitude == coord2.latitude && coord1.longitude == coord2.longitude))

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

- (BOOL)isEqual:(id)object{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    CommunityPoint* point = (CommunityPoint*)object;
    if (![_name isEqualToString:point.name]) {
        return NO;
    }
    if (![_address isEqualToString:point.address]) {
        return NO;
    }
    if (!CLCOORDINATES_EQUAL(_coordinate, point.coordinate)) {
        return NO;
    }
    return YES;
}

@end
