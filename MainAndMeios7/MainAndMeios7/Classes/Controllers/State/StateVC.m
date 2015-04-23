//
//  StateVC.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 13.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "StateVC.h"
#import "CustomTitleView.h"
#import "StateCell.h"
#import "SearchRequest.h"
#import "SVPullToRefresh.h"
#import "StoreDetailsVC.h"
#import "SearchManager.h"

@interface StateVC () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) BOOL searchShouldBeginEditing;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSArray* tableArray;
@property (strong, nonatomic) NSArray* searchArray;

@property (assign, nonatomic) NSInteger page;

@property (assign, nonatomic) BOOL sortType;

@property (strong, nonatomic) AFHTTPRequestOperation* searchOperation;


@end

@implementation StateVC


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_button"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_az_button"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(sortButtonAction)];
//    

    self.navigationItem.titleView = [[CustomTitleView alloc] initWithTitle:@"SELECT CITY"
                                                         dropDownIndicator:NO clickCallback:^(CustomTitleView *titleView) {
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    
    [self.tableView registerNib:[UINib nibWithNibName:@"StateCell" bundle:nil] forCellReuseIdentifier:@"StateCell"];
    
//    [self.tableView addInfiniteScrollingWithActionHandler:^{
//        [self searchRequest];
//    }];
    
    
    if (_addressDict == nil) {
        self.addressDict = @{@"Prefix" : [SearchManager shared].state};
    }
    [self loadData];
    
}

- (void)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) anchorRight {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}


#pragma mark - TableView

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tableArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StateCell *cell = (StateCell *) [tableView dequeueReusableCellWithIdentifier:@"StateCell"];
    
    cell.titleLabel.text = [_tableArray[indexPath.row] safeStringObjectForKey:@"city"];
    
    if ((indexPath.row == 4 || indexPath.row == 0) && 0) {
        cell.backlighted = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.backlighted = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary* communityDict = [_tableArray safeObjectAtIndex:indexPath.row];
    
    [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            [_searchBar resignFirstResponder];
            [self loadCummunityInfo:communityDict];
        }else{
            [_tableView reloadData];
        }
    }
                                           title:@"Message"
                                         message:@"Use this location as default?"
                               cancelButtonTitle:@"Ok"
                               otherButtonTitles:@"Cancel", nil];

    
//    [SearchManager shared].city = [communityDict safeStringObjectForKey:@"city"];
//    [SearchManager shared].communityID = [communityDict safeStringObjectForKey:@"id"];
}

- (void)loadCummunityInfo:(NSDictionary*)community{
    
    NSNumber* communityId = [community safeNSNumberObjectForKey:@"id"];
    NSString* communityName = [community safeStringObjectForKey:@"city"];
    
    
    [self showSpinnerWithName:@"CommunityViewController"];
    
    [SearchManager loadCommunityById:communityId
                             success:^(NSDictionary *obj) {
                                 [self hideSpinnerWithName:@"CommunityViewController"];
                                 
                                 CLLocation* location = [[CLLocation alloc]initWithLatitude:[[obj safeNumberObjectForKey:@"lat"] floatValue]
                                                                                  longitude:[[obj safeNumberObjectForKey:@"lng"] floatValue]];
                                 //                                 [LocationManager shared].defaultLocation = location;
                                 //
                                 
                                 //                                 NSString* slug = [obj safeStringObjectForKey:@"slug"];
                                 //                                 NSString* name = [[slug componentsSeparatedByString:@"-"] firstObject];
                                 //                                 name = [name stringWithCapitalizedFirstCharacter];
                                 
                                 [SearchManager shared].communityLocation = location;
                                 [SearchManager shared].city = [community safeStringObjectForKey:@"city"];
                                 [SearchManager shared].state = [obj safeStringObjectForKey:@"state"];
                                 [SearchManager shared].communityID = [[community safeNSNumberObjectForKey:@"id"] stringValue];
                                 
//                                 [[LocationManager shared] setupComminityLocation:location
//                                                                             name:communityName
//                                                                           prefix:_statePrefix
//                                                                      communityId:[[obj safeNumberObjectForKey:@"id"] stringValue]];
                                 
                                 [[NSNotificationCenter defaultCenter] postNotificationName:@"kCommunityChanged" object:nil];
                                 
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

#pragma mark - Search field


- (void)loadData{
    //    _page++;
    //
    //    if (_page == 1) {
    [self showSpinnerWithName:@"CommunityViewController"];
    //    }
    
    [SearchManager loadCommunityForState:[_addressDict safeStringObjectForKey:@"Prefix"]
                                    page:_page
                                 success:^(NSArray* communities) {
                                     
                                     //if ([communities count] == 0) {
                                     [self hideSpinnerWithName:@"CommunityViewController"];
                                     [self showOnTable:communities];
                                     //                                     }else{
                                     //                                         [_tempTableArray addObjectsFromArray:communities];
                                     //                                         [self loadData];
                                     //                                     }
                                     
                                     //[_pullToRefresh tableViewReloadFinished];
                                 }
                                 failure:^(NSError *error, NSString *errorString) {
                                     [self hideSpinnerWithName:@"CommunityViewController"];
                                     [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                         message:errorString];
                                     //[_pullToRefresh tableViewReloadFinished];
                                 }
                               exception:^(NSString *exceptionString) {
                                   [self hideSpinnerWithName:@"CommunityViewController"];
                                   [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                   //[_pullToRefresh tableViewReloadFinished];
                               }];
}

#pragma mark - Privat Methods

- (void)showOnTable:(NSArray*)communities{
    NSMutableArray* tableCommunities = [NSMutableArray arrayWithArray:_searchArray];
    [tableCommunities addObjectsFromArray:communities];
    _searchArray = [NSArray arrayWithArray:tableCommunities];
    [self applyFilterWith:_searchBar.text];
}

- (void)applyFilterWith:(NSString*)name{
    
    name = [name lowercaseString];
    
    if (!name || [name isEqualToString:@""]) {
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
    
    [self applyFilterWith:searchText];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self applyFilterWith:searchBar.text];
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
