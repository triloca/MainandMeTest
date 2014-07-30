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

@interface CommunityViewController : GAITrackedViewController
@property (assign, nonatomic) NSString* stateName;
@property (strong, nonatomic) NSString* statePrefix;

@end
