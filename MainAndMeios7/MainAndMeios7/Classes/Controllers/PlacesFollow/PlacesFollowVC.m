//
//  PlacesFollowVC.m
//  MainAndMeios7
//
//  Created by Max on 11/8/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "PlacesFollowVC.h"
#import "PlacesFollowCell.h"
#import "SearchTypeView.h"

#import "CustomTitleView.h"
#import "StoreCell.h"
#import "SearchRequest.h"
#import "SVPullToRefresh.h"
#import "StoreDetailsVC.h"
#import "SearchManager.h"
#import "FollowingsRequest.h"

@interface PlacesFollowVC () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (assign, nonatomic) BOOL searchShouldBeginEditing;

@property (strong, nonatomic) NSMutableArray* tableArray;
@property (strong, nonatomic) NSArray* loadedArray;

@property (assign, nonatomic) NSInteger page;

@property (assign, nonatomic) BOOL sortType;

@property (strong, nonatomic) AFHTTPRequestOperation* searchOperation;


@end

@implementation PlacesFollowVC

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton* menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setImage:[UIImage imageNamed:@"menu_button.png"] forState:UIControlStateNormal];
    menuButton.frame = CGRectMake(0, 0, 40, 40);
    [menuButton addTarget:self action:@selector(anchorRight) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *anchorLeftButton  = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    self.navigationItem.leftBarButtonItem = anchorLeftButton;
    
    [self updateSrotButton];
    
    __weak PlacesFollowVC* wSelf = self;
    self.navigationItem.titleView = [[CustomTitleView alloc] initWithTitle:@"Places I Follow" dropDownIndicator:NO clickCallback:^(CustomTitleView *titleView) {
        [[LayoutManager shared].homeNVC popToRootViewControllerAnimated:NO];
        [[LayoutManager shared] showHomeControllerAnimated:YES];
        [wSelf.navigationController popToRootViewControllerAnimated:YES];

    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"StoreCell" bundle:nil] forCellReuseIdentifier:@"StoreCell"];
    
    //    [self.tableView addInfiniteScrollingWithActionHandler:^{
    //        [self searchRequest];
    //    }];
    
    [self startSearch];
    
}


- (void) anchorRight {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

- (void) sortButtonAction {
    _sortType = !_sortType;
    [self sortData];
    [_tableView reloadData];
    [self updateSrotButton];
}

- (void)updateSrotButton{
    
    NSString* imageName;
    if (_sortType) {
        imageName = @"nav_az_button";
    }else{
        imageName = @"nav_za_button";
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(sortButtonAction)];
}

#pragma mark - TableView

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tableArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StoreCell *cell = (StoreCell *) [tableView dequeueReusableCellWithIdentifier:@"StoreCell"];
    
    [cell setStore:_tableArray[indexPath.row]];
    
    if ((indexPath.row == 4 || indexPath.row == 0) && 0) {
//        cell.backlighted = YES;
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.backlighted = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary* storeDict = [_tableArray safeObjectAtIndex:indexPath.row];
    
    StoreDetailsVC* storeDetailsVC = [StoreDetailsVC loadFromXIBForScrrenSizes];
    storeDetailsVC.storeDict = storeDict;
    [self.navigationController pushViewController:storeDetailsVC animated:YES];
    
}


#pragma mark - Search field



- (void)startSearch{
    
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    
    [self.searchOperation cancel];
    _page = 1;
    [self searchRequest];
    
}


- (void)searchRequest{
    
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    
    [self loadFollowings];
    return;
    SearchRequest *searchRequest = [[SearchRequest alloc] initWithSearchType:SearchTypeStores searchFilter:SearchFilterRandom];
    //searchRequest.coordinate = CLLocationCoordinate2DMake(42.283215, -71.123029);
    
    searchRequest.city = [SearchManager shared].city;
    searchRequest.state = [SearchManager shared].state;
    searchRequest.page = _page;
    //searchRequest.searchKey = _searchBar.text;
    searchRequest.name = _searchBar.text;
    
    if (_page == 1) {
        [self showSpinnerWithName:@""];
    }
    
    self.searchOperation = [[MMServiceProvider sharedProvider] sendRequest:searchRequest success:^(SearchRequest* request) {
        NSLog(@"Succceess!");
        [self hideSpinnerWithName:@""];
        
        [_tableView.infiniteScrollingView stopAnimating];
        
        if (_page == 1) {
            self.tableArray = [NSMutableArray new];
            [self.tableView reloadData];
        }
        
        if (request.objects.count > 0) {
            [_tableArray addObjectsFromArray:request.objects];
            _page ++;
        }
        
        [self sortData];
        [_tableView reloadData];
        
        self.searchOperation = nil;
        
    } failure:^(id _request, NSError *error) {
        NSLog(@"Fail: %@", error);
        [self hideSpinnerWithName:@""];
        
        [_tableView.infiniteScrollingView stopAnimating];
        _page = 1;
        self.tableArray = [NSMutableArray new];
        
        [_tableView reloadData];
        NSLog(@"error: %@", error);
        
        self.searchOperation = nil;
    }];
}


- (void) loadFollowings {

    FollowingsRequest *request = [FollowingsRequest new];
    request.userId = [CommonManager shared].userId;
    request.followableType = FollowableStore;
    //http://mainandme.com/api/v1/users/3/follows/followings/store?_token=n9Mn4Nr1Lgw8cxsgry9R
    __weak PlacesFollowVC *wself = self;
    
    
    [self showSpinnerWithName:@""];
    [[MMServiceProvider sharedProvider] sendRequest:request success:^(FollowingsRequest *request) {
        [self hideSpinnerWithName:@""];
        wself.loadedArray = request.followings;
        wself.tableArray = [NSMutableArray arrayWithArray:request.followings];
        [self filterData];
        [self sortData];
        [_tableView reloadData];
        
    } failure:^(id _request, NSError *error) {
        [self hideSpinnerWithName:@""];
        [[AlertManager shared] showOkAlertWithTitle:@"Main and me" message:error.localizedDescription];
    }];
}


- (void)filterData{

    if (_searchBar.text.length == 0) {
        self.tableArray = [NSMutableArray arrayWithArray:_loadedArray];
    }else{
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", _searchBar.text];
        NSArray* temp = [self.loadedArray filteredArrayUsingPredicate:predicate];
        self.tableArray = [NSMutableArray arrayWithArray:temp];
    }
}

- (void)sortData{
    
    [_tableArray sortUsingComparator:^NSComparisonResult(NSDictionary* obj1, NSDictionary* obj2) {
        NSString *first = [obj1 safeStringObjectForKey:@"name"];
        NSString *second = [obj2 safeStringObjectForKey:@"name"];
        
        if (_sortType) {
            return [second caseInsensitiveCompare:first];
        }else{
            return [first caseInsensitiveCompare:second];
        }
    }];
}


#pragma mark - Search Bar Delegate


- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)bar {
    // reset the shouldBeginEditing BOOL ivar to YES, but first take its value and use it to return it from the method call
    BOOL boolToReturn = _searchShouldBeginEditing;
    _searchShouldBeginEditing = YES;
    return boolToReturn;
}
-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    //This'll Show The cancelButton with Animation
    //[searchBar setShowsCancelButton:YES animated:YES];
    //remaining Code'll go here
}

- (void) searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    // TODO - dynamically update the search results here, if we choose to do that.
    
    if (![theSearchBar isFirstResponder]) {
        // The user clicked the [X] button while the keyboard was hidden
        _searchShouldBeginEditing = NO;
        //[self startSearch];
    }
    else if ([searchText length] == 0) {
        // The user clicked the [X] button or otherwise cleared the text.
        [theSearchBar performSelector: @selector(resignFirstResponder)
                           withObject: nil
                           afterDelay: 0.1];
        //[self startSearch];
    }
    
    [self filterData];
    [self sortData];
    [self.tableView reloadData];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self filterData];
    [self sortData];
    [self.tableView reloadData];
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    // [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self.searchBar resignFirstResponder];
    return YES;
}

- (IBAction)searchCancelButtonPressed:(id)sender {
    
}


#pragma mark _______________________ Notifications _________________________

- (void)keyboardWillShow:(NSNotification *)notification {
    //get the end position keyboard frame
    NSDictionary *keyInfo = [notification userInfo];
    CGRect keyboardFrame = [[keyInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    //convert it to the same view coords as the tableView it might be occluding
    keyboardFrame = [self.tableView convertRect:keyboardFrame fromView:nil];
    //calculate if the rects intersect
    CGRect intersect = CGRectIntersection(keyboardFrame, self.tableView.bounds);
    if (!CGRectIsNull(intersect)) {
        //yes they do - adjust the insets on tableview to handle it
        //first get the duration of the keyboard appearance animation
        NSTimeInterval duration = [[keyInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
        //change the table insets to match - animated to the same duration of the keyboard appearance
        [UIView animateWithDuration:duration animations:^{
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, intersect.size.height, 0);
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, intersect.size.height, 0);
        }];
    }
}

- (void) keyboardWillHide:  (NSNotification *) notification{
    NSDictionary *keyInfo = [notification userInfo];
    NSTimeInterval duration = [[keyInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    //clear the table insets - animated to the same duration of the keyboard disappearance
    [UIView animateWithDuration:duration animations:^{
        self.tableView.contentInset = UIEdgeInsetsZero;
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    }];
}

@end
