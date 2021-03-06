//
//  PlacePoint.h
//  Places
//
//  Created by Sasha on 1/15/13.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PlacePoint : NSObject <MKAnnotation>
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* address;
@property (assign, nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (assign, nonatomic) MKPinAnnotationColor pinColor;

- (id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate;
@end
