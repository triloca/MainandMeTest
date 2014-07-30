//
//  StoreMapViewController.h
//  MainAndMe
//
//  Created by Sasha on 3/18/13.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "GAITrackedViewController.h"

@interface StoreMapViewController : GAITrackedViewController
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (strong, nonatomic) NSDictionary* storeInfo;
@end
