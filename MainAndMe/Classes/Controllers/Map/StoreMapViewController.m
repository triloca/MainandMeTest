//
//  StoreMapViewController.m
//  MainAndMe
//
//  Created by Sasha on 3/18/13.
//
//

#import "StoreMapViewController.h"

#import "PlacePoint.h"

@interface StoreMapViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;

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
    
    _titleTextLabel.font = [UIFont fontWithName:@"Perec-SuperNegra" size:22];
    _titleTextLabel.text = @"Store On Map";
    
    PlacePoint* placePoint = [[PlacePoint alloc] initWithName:@""
                                                      address:@""
                                                   coordinate:_coordinate];
    [_mapView addAnnotation:placePoint];
    [self updateRegion:_coordinate];
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
    static NSString * const kAnnotationId = @"PlacePointAnnotation";
    
    MKPinAnnotationView *annotationView = nil;
    if ([annotation isKindOfClass:[PlacePoint class]])
    {
        annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:kAnnotationId];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kAnnotationId];
            annotationView.canShowCallout = YES;
        }
        
        PlacePoint* placePoint = (PlacePoint*)annotation;
        annotationView.pinColor = placePoint.pinColor;
        
    }
    
    return annotationView;
}

#pragma mark - Buttons Action
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
