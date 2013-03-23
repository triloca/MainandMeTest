//
//  StoreMapViewController.m
//  MainAndMe
//
//  Created by Sasha on 3/18/13.
//
//

#import "CommunityViewController.h"
#import "SearchManager.h"
#import "AlertManager.h"
#import "CommunityPoint.h"
#import "LocationManager.h"

@interface CommunityViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;


@end

@implementation CommunityViewController

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
    
    _titleTextLabel.font = [UIFont fontWithName:@"Perec-SuperNegra" size:22];
    _titleTextLabel.text = @"Communities";
    [self loadData];
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [self setTitleTextLabel:nil];
    [super viewDidUnload];
}

- (void)updateRegion:(CLLocationCoordinate2D)coordinate{
    
    CGFloat radius = 20000;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 2 * radius, 2 * radius);
    [_mapView setRegion:region];
    
}


#pragma mark - MapView Delegate

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString * const kAnnotationId = @"CommunityPointAnnotation";
    
    MKPinAnnotationView *annotationView = nil;
    if ([annotation isKindOfClass:[CommunityPoint class]])
    {
        annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:kAnnotationId];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kAnnotationId];
            annotationView.canShowCallout = YES;
            annotationView.animatesDrop = NO;
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
        
        CommunityPoint* communityPoint = (CommunityPoint*)annotation;
        annotationView.pinColor = communityPoint.pinColor;
        
    }
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    CommunityPoint* communityPoint = (CommunityPoint*)[view annotation];
    [mapView deselectAnnotation:communityPoint animated:YES];
    
    [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            CLLocation* location = [[CLLocation alloc] initWithLatitude:communityPoint.coordinate.latitude
                                                              longitude:communityPoint.coordinate.longitude];
            
            [LocationManager shared].defaultLocation = location;
            [[LocationManager shared] notifyUpdate];
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        }
    }
                                           title:@"Message"
                                         message:@"Use this location as default?"
                               cancelButtonTitle:@"Ok"
                               otherButtonTitles:@"Cancel", nil];
    
}

#pragma mark - Buttons Action
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Privat Methods
- (void)loadData{
    [self showSpinnerWithName:@"CommunityViewController"];
    
    [SearchManager loadCommunityForState:_statePrefix
                                 success:^(NSArray* communities) {
                                     [self hideSpinnerWithName:@"CommunityViewController"];
                                     [self showOnMap:communities];
                                 }
                                 failure:^(NSError *error, NSString *errorString) {
                                     [self hideSpinnerWithName:@"CommunityViewController"];
                                    [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                        message:errorString];
                                 }
                               exception:^(NSString *exceptionString) {
                                   [self hideSpinnerWithName:@"CommunityViewController"];
                                    [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                               }];
}

- (void)showOnMap:(NSArray*)communities{
   
    [self showSpinnerWithName:@"CommunityViewController"];
    NSMutableArray* annotations = [NSMutableArray new];
    for (id obj in communities) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[obj safeNumberObjectForKey:@"lat"] floatValue],
                                                                           [[obj safeNumberObjectForKey:@"lng"] floatValue]);
            CommunityPoint* point =
            [[CommunityPoint alloc] initWithName:[obj safeStringObjectForKey:@"slug"]
                                         address:[obj safeStringObjectForKey:@"city"]
                                      coordinate:coordinate];
            [annotations addObject:point];
        }
    }
    
    [_mapView addAnnotations:annotations];
    
    [self zoomToFitMapAnnotations];
    
    [self hideSpinnerWithName:@"CommunityViewController"];
}

- (void)zoomToFitMapAnnotations {
    
    NSMutableArray* annotations = [NSMutableArray arrayWithArray:_mapView.annotations];
    id<MKAnnotation> obj = _mapView.userLocation;
    [annotations removeObject:obj];
    
    if ([annotations count] == 0) return;
    
    int i = 0;
    MKMapPoint points[[annotations count]];
    
    //build array of annotation points
    for (id<MKAnnotation> annotation in annotations)
        points[i++] = MKMapPointForCoordinate(annotation.coordinate);
    
    MKPolygon *poly = [MKPolygon polygonWithPoints:points count:i];
    
    [self.mapView setRegion:MKCoordinateRegionForMapRect([poly boundingMapRect]) animated:YES];
}

@end
