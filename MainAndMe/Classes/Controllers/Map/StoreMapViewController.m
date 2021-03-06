//
//  StoreMapViewController.m
//  MainAndMe
//
//  Created by Sasha on 3/18/13.
//
//

#import "StoreMapViewController.h"
#import "AlertManager.h"
#import "PlacePoint.h"
#import "LocationManager.h"
#import <QuartzCore/QuartzCore.h>

@interface StoreMapViewController () <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;
@property (strong, nonatomic) UIImageView* storeImageView;

@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) CLLocation* location;
@end

@implementation StoreMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.screenName = @"Store Map screen";

    _titleTextLabel.font = [UIFont fontWithName:@"Perec-SuperNegra" size:22];
    _titleTextLabel.text = @"Store On Map";
    
    _storeImageView = [UIImageView new];
    _storeImageView.frame = CGRectMake(0, 0, 30, 30);
    _storeImageView.layer.cornerRadius = 4;
    _storeImageView.contentMode = UIViewContentModeScaleAspectFill;
    _storeImageView.clipsToBounds = YES;
    [self setStoreImageURLString:[[_storeInfo safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"thumb"]];
    
    PlacePoint* placePoint = [[PlacePoint alloc] initWithName:[_storeInfo safeStringObjectForKey:@"name"]
                                                      address:[_storeInfo safeStringObjectForKey:@"street"]
                                                   coordinate:_coordinate];
    [_mapView addAnnotation:placePoint];
    [self updateRegion:_coordinate];
    [_mapView selectAnnotation:placePoint animated:YES];
    
    _locationManager = [CLLocationManager new];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager startUpdatingLocation];
    
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [self setTitleTextLabel:nil];
    [super viewDidUnload];
}

- (void)updateRegion:(CLLocationCoordinate2D)coordinate{
    
    CGFloat radius = 250;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 2 * radius, 2 * radius);
    [_mapView setRegion:region];
    
}


#pragma mark - MapView Delegate

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString * const kAnnotationId = @"PlacePointAnnotation";
    
    MKPinAnnotationView *annotationView = nil;
    if ([annotation isKindOfClass:[PlacePoint class]])
    {
        annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:kAnnotationId];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kAnnotationId];
            annotationView.canShowCallout = YES;
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            annotationView.leftCalloutAccessoryView = _storeImageView;
        }
        
        PlacePoint* placePoint = (PlacePoint*)annotation;
        annotationView.pinColor = placePoint.pinColor;
        
    }
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    PlacePoint* communityPoint = (PlacePoint*)[view annotation];
    [mapView deselectAnnotation:communityPoint animated:YES];
    
    [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
          
            
//            NSString* addr = [NSString stringWithFormat:@"http://maps.apple.com/maps?daddr=%1.6f,%1.6f&saddr=%1.6f,%1.6f",communityPoint.coordinate.latitude,communityPoint.coordinate.longitude,42.286731719970703, -71.1306];
            
//            NSString* addr = [NSString stringWithFormat:@"http://maps.apple.com/maps?daddr=%1.6f,%1.6f&saddr=%1.6f,%1.6f",communityPoint.coordinate.latitude,communityPoint.coordinate.longitude,mapView.userLocation.coordinate.latitude,mapView.userLocation.coordinate.longitude];

            NSString* addr = [NSString stringWithFormat:@"http://maps.apple.com/maps?daddr=%1.6f,%1.6f&saddr=%1.6f,%1.6f",communityPoint.coordinate.latitude,communityPoint.coordinate.longitude,[LocationManager shared].currentLocation.coordinate.latitude,[LocationManager shared].currentLocation.coordinate.longitude];
            
//           NSString* addr = [NSString stringWithFormat:@"http://maps.apple.com/maps?daddr=%1.6f,%1.6f&saddr=%1.6f,%1.6f", 44.502964, 34.19,[LocationManager shared].currentLocation.coordinate.latitude,[LocationManager shared].currentLocation.coordinate.longitude];
            
            NSURL* url = [[NSURL alloc] initWithString:[addr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            [[UIApplication sharedApplication] openURL:url];
            
//            NSString *urlToOpen =
//            [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f",
//             _location.coordinate.latitude,
//             _location.coordinate.longitude,
//             communityPoint.coordinate.latitude, communityPoint.coordinate.longitude];
//                       
//
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlToOpen]];
        }
    }
                                           title:nil
                                         message:@"Get directions to this store in Maps app?"
                               cancelButtonTitle:@"Ok"
                               otherButtonTitles:@"Cancel", nil];
}

#pragma mark -  CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    [_locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    [_locationManager stopUpdatingLocation];
    self.location = newLocation;
}

#pragma mark - Buttons Action
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//NSString *urlToOpen = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f",
//                       [sourceAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//                       [destinationAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//
//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlToOpen]];

#pragma mark - Privat Methods
- (void)setStoreImageURLString:(NSString*)imageURLString{
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURLString]
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:30];
    
    [self.storeImageView  setImageWithURLRequest:request
                                 placeholderImage:[UIImage imageNamed:@"posted_user_ic@2x.png"]
                                     failureImage:nil
                                 progressViewSize:CGSizeMake(_storeImageView.bounds.size.width - 5, 4)
                                progressViewStile:UIProgressViewStyleDefault
                                progressTintColor:[UIColor colorWithRed:109/255.0f green:145/255.0f blue:109/255.0f alpha:1]
                                   trackTintColor:nil
                                       sizePolicy:UNImageSizePolicyScaleAspectFill
                                      cachePolicy:UNImageCachePolicyMemoryAndFileCache
                                          success:nil
                                          failure:nil
                                         progress:nil];
    
}

@end
