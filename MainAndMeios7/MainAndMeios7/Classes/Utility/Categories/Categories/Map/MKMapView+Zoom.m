//
//  MKMapView+Zoom.m
//  iC
//
//  Created by user on 4/9/14.
//  Copyright (c) 2014 quadecco. All rights reserved.
//

#import "MKMapView+Zoom.h"

@implementation MKMapView (Zoom)

- (void)zoomMapToCoordinate:(CLLocationCoordinate2D)coordinate
                     radius:(CGFloat)radius
                   animated:(BOOL)animated{
    
    if (CLLocationCoordinate2DIsValid(coordinate) && radius >= 0) {
        [self setRegion:MKCoordinateRegionMakeWithDistance(coordinate, radius * 2, radius * 2) animated:animated];
    }
}

- (void)zoomToAnnotations{
    
    MKMapRect zoomRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in self.annotations)
    {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    [self setVisibleMapRect:zoomRect animated:YES];
}

@end
