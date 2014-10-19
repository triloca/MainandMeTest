//
//  MKMapView+Zoom.h
//  iC
//
//  Created by user on 4/9/14.
//  Copyright (c) 2014 quadecco. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (Zoom)

- (void)zoomMapToCoordinate:(CLLocationCoordinate2D)coordinate
                     radius:(CGFloat)radius
                   animated:(BOOL)animated;

- (void)zoomToAnnotations;

@end
