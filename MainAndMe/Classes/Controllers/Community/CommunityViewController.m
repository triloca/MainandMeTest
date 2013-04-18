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
#import "CommunityCell.h"
#include "UIView+Common.h"

@interface CommunityViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;
@property (assign, nonatomic) NSInteger page;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatiorView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray* tableArray;
@property (strong, nonatomic) NSArray* searchArray;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (assign, nonatomic) BOOL isAnimatesDrop;

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
    [self setActivityIndicatiorView:nil];
    [self setTableView:nil];
    [self setSearchTextField:nil];
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
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
        annotationView.animatesDrop = _isAnimatesDrop;
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_tableArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCommunityCellIdentifier = @"CommunityCell";
    
    CommunityCell *cell = [tableView dequeueReusableCellWithIdentifier:kCommunityCellIdentifier];

    if (cell == nil){
        cell = [CommunityCell loadViewFromXIB];
        //cell.transform = CGAffineTransformMake(0.0f, 1.0f, 1.0f, 0.0f, 0.0f, 0.0f);
    }
    
    // Configure the cell...
    
    NSDictionary* obj = [_tableArray safeDictionaryObjectAtIndex:indexPath.row];
    cell.nameLabel.text = [obj safeStringObjectForKey:@"slug"];
    cell.addressLabel.text = [obj safeStringObjectForKey:@"city"];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary* obj = [_tableArray safeDictionaryObjectAtIndex:indexPath.row];
    
    [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            CLLocation* location = [[CLLocation alloc]initWithLatitude:[[obj safeNumberObjectForKey:@"lat"] floatValue]
                                                             longitude:[[obj safeNumberObjectForKey:@"lng"] floatValue]];
            [LocationManager shared].defaultLocation = location;
            [[LocationManager shared] notifyUpdate];
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        }else{
            [_tableView reloadData];
        }
    }
                                           title:@"Message"
                                         message:@"Use this location as default?"
                               cancelButtonTitle:@"Ok"
                               otherButtonTitles:@"Cancel", nil];
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldDidBeginEditing");
    [UIView animateWithDuration:0.3
                     animations:^{
                         CGRect rc = self.tableView.frame;
                         rc.origin.y -= 165;
                         self.tableView.frame = rc;
                         rc = _mapView.frame;
                         rc.origin.y -= 165;
                         _mapView.frame = rc;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldEndEditing");
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [UIView animateWithDuration:0.3
                     animations:^{
                         CGRect rc = self.tableView.frame;
                         rc.origin.y += 165;
                         self.tableView.frame = rc;
                         rc = _mapView.frame;
                         rc.origin.y += 165;
                         _mapView.frame = rc;
                     }
                     completion:^(BOOL finished) {
                         
                     }];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [self zoomToFitMapAnnotations];
    return YES;
}



#pragma mark - Buttons Action
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)locationButtonClicked:(id)sender {
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(_mapView.userLocation.coordinate, 1500, 1500);
    MKCoordinateRegion adjustRegion = [_mapView regionThatFits:region];
    [_mapView setRegion:adjustRegion animated:YES];
}

#pragma mark - Privat Methods
- (IBAction)searchValueChanged:(id)sender {
    [self applyFilterWith:_searchTextField.text];
    _isAnimatesDrop = NO;
    [self showOnMap:nil];
}

- (void)loadData{
    _page++;
    if (_page == 1) {
        [self showSpinnerWithName:@"CommunityViewController"];
    }else{
        [_activityIndicatiorView startAnimating];
    }
    [SearchManager loadCommunityForState:_statePrefix
                                    page:_page
                                 success:^(NSArray* communities) {
                                     [self hideSpinnerWithName:@"CommunityViewController"];
                                     [self showOnTable:communities];
                                     _isAnimatesDrop = YES;
                                     [self showOnMap:communities];
                                     if (_page == 1) {
                                         [self zoomToFitMapAnnotations];
                                     }
                                     
                                     if (communities.count > 0) {
                                         [self loadData];
                                     }else{
                                         [_activityIndicatiorView stopAnimating];
                                         [self zoomToFitMapAnnotations];
                                     }
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

- (void)showOnTable:(NSArray*)communities{
    NSMutableArray* tableCommunities = [NSMutableArray arrayWithArray:_searchArray];
    [tableCommunities addObjectsFromArray:communities];
    _searchArray = [NSArray arrayWithArray:tableCommunities];
    [self applyFilterWith:_searchTextField.text];
}

- (void)showOnMap:(NSArray*)communities{
   
    
    NSMutableArray* annotations = [NSMutableArray new];
    for (id obj in _tableArray) {
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

    
    NSMutableArray* annotationToAdd = [NSMutableArray array];
    NSMutableArray* annotationToRemove = [NSMutableArray array];
    
    NSArray* allAnnotations = _mapView.annotations;
    
    for (id obj in allAnnotations) {
        if ([obj isKindOfClass:[CommunityPoint class]]) {
            if (![annotations containsObject:obj]) {
                [annotationToRemove addObject:obj];
            }
        }
    }
    
    for (id obj in annotations) {
        if ([obj isKindOfClass:[CommunityPoint class]]) {
            if (![allAnnotations containsObject:obj]) {
                [annotationToAdd addObject:obj];
            }
        }
    }
    
    [_mapView removeAnnotations:annotationToRemove];
    [_mapView addAnnotations:annotationToAdd];
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

- (void)applyFilterWith:(NSString*)name{
    
    if ([name isEqualToString:@""]) {
        _tableArray = _searchArray;
        [_tableView reloadData];
        return;
    }
    
    NSMutableArray* filterdMutableArray = [NSMutableArray array];
    
    [_searchArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString* n = [[obj safeStringObjectForKey:@"slug"] lowercaseString];
        if ([n hasPrefix:name]) {
            [filterdMutableArray addObject:obj];
        }
    }];
      _tableArray = [NSArray arrayWithArray:filterdMutableArray];
    [_tableView reloadData];
}
@end
