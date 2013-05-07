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
#import "MNMBottomPullToRefreshManager.h"

@interface CommunityViewController () <MNMBottomPullToRefreshManagerClient>

@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;
@property (assign, nonatomic) NSInteger page;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray* tableArray;
@property (strong, nonatomic) NSArray* searchArray;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) MNMBottomPullToRefreshManager* pullToRefresh;
@property (strong, nonatomic) NSMutableArray* tempTableArray;
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
    self.pullToRefresh = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:_tableView withClient:self];

    self.tempTableArray = [NSMutableArray new];
    
    [self loadData];
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    [_pullToRefresh relocatePullToRefreshView];
}


- (void)viewDidUnload {
   
    [self setTitleTextLabel:nil];
    [self setTableView:nil];
    [self setSearchTextField:nil];
    [super viewDidUnload];
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
    cell.nameLabel.text = [obj safeStringObjectForKey:@"city"];
    //cell.addressLabel.text = [obj safeStringObjectForKey:@"city"];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary* obj = [_tableArray safeDictionaryObjectAtIndex:indexPath.row];
    
    [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            [self loadCummunityByID:[obj safeNSNumberObjectForKey:@"id"]];
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
                         rc.size.height -= 165;
                         self.tableView.frame = rc;
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
                         rc.size.height += 165;
                         self.tableView.frame = rc;
                     }
                     completion:^(BOOL finished) {
                         
                     }];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Scroll View Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_pullToRefresh tableViewScrolled];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_pullToRefresh tableViewReleased];
}


#pragma mark - Refresh Control Action

- (void)bottomPullToRefreshTriggered:(MNMBottomPullToRefreshManager *)manager {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadData];
    });
}


#pragma mark - Buttons Action
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Privat Methods

- (IBAction)searchValueChanged:(id)sender {
    [self applyFilterWith:_searchTextField.text];
}

- (void)loadData{
//    _page++;
//    
//    if (_page == 1) {
        [self showSpinnerWithName:@"CommunityViewController"];
//    }
    
    [SearchManager loadCommunityForState:_statePrefix
                                    page:_page
                                 success:^(NSArray* communities) {
                                     
                                     //if ([communities count] == 0) {
                                         [self hideSpinnerWithName:@"CommunityViewController"];
                                         [self showOnTable:communities];
//                                     }else{
//                                         [_tempTableArray addObjectsFromArray:communities];
//                                         [self loadData];
//                                     }
                                    
                                     [_pullToRefresh tableViewReloadFinished];
                                 }
                                 failure:^(NSError *error, NSString *errorString) {
                                     [self hideSpinnerWithName:@"CommunityViewController"];
                                    [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                        message:errorString];
                                     [_pullToRefresh tableViewReloadFinished];
                                 }
                               exception:^(NSString *exceptionString) {
                                   [self hideSpinnerWithName:@"CommunityViewController"];
                                    [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                   [_pullToRefresh tableViewReloadFinished];
                               }];
}


- (void)loadCummunityByID:(NSNumber*)communityId{
    
    [self showSpinnerWithName:@"CommunityViewController"];
    
    [SearchManager loadCommunityById:communityId
                             success:^(NSDictionary *obj) {
                                 [self hideSpinnerWithName:@"CommunityViewController"];
                                 
                                 CLLocation* location = [[CLLocation alloc]initWithLatitude:[[obj safeNumberObjectForKey:@"lat"] floatValue]
                                                                                  longitude:[[obj safeNumberObjectForKey:@"lng"] floatValue]];
                                 [LocationManager shared].defaultLocation = location;
                                 [[LocationManager shared] notifyUpdate];
                                 [self.navigationController popToRootViewControllerAnimated:YES];

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

- (void)applyFilterWith:(NSString*)name{
    
    if ([name isEqualToString:@""]) {
        _tableArray = _searchArray;
        [_tableView reloadData];
        return;
    }
    
    NSMutableArray* filterdMutableArray = [NSMutableArray array];
    
    [_searchArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString* n = [[obj safeStringObjectForKey:@"city"] lowercaseString];
        if ([n hasPrefix:name]) {
            [filterdMutableArray addObject:obj];
        }
    }];
      _tableArray = [NSArray arrayWithArray:filterdMutableArray];
    [_tableView reloadData];
}
@end
