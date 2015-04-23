//
//  AddressVC.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 13.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "AddressVC.h"
#import "CustomTitleView.h"
#import "AddressCell.h"
#import "SearchRequest.h"
#import "SVPullToRefresh.h"
#import "StoreDetailsVC.h"
#import "SearchManager.h"
#import "StateVC.h"

@interface AddressVC () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) BOOL searchShouldBeginEditing;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSArray* tableArray;

@property (assign, nonatomic) NSInteger page;

@property (assign, nonatomic) BOOL sortType;

@property (strong, nonatomic) AFHTTPRequestOperation* searchOperation;

@property (strong, nonatomic) NSDictionary* statesDictionary;
@property (strong, nonatomic) NSArray* statesArray;

@end

@implementation AddressVC


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_button"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_az_button"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(sortButtonAction)];
    

    self.navigationItem.titleView = [[CustomTitleView alloc] initWithTitle:@"SELECT STATE" dropDownIndicator:NO clickCallback:^(CustomTitleView *titleView) {
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    
    [self.tableView registerNib:[UINib nibWithNibName:@"AddressCell" bundle:nil] forCellReuseIdentifier:@"AddressCell"];
    
//    [self.tableView addInfiniteScrollingWithActionHandler:^{
//        [self searchRequest];
//    }];
    
    [self loadAddresses];
}

- (void)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) anchorRight {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}



#pragma mark _______________________ Privat Methods ________________________

- (void)loadAddresses{
    
    [self showSpinnerWithName:@"AddressViewController"];
    
    [SearchManager loadStatesSuccess:^(NSDictionary* states) {
        [self hideSpinnerWithName:@"AddressViewController"];
        _statesDictionary = states;
        [self convertStates];
    }
                             failure:^(NSError *error, NSString *errorString) {
                                 [self hideSpinnerWithName:@"AddressViewController"];
                                 [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                     message:errorString];
                             }
                           exception:^(NSString *exceptionString) {
                               [self hideSpinnerWithName:@"AddressViewController"];
                               [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                           }];
}

- (void)convertStates{
    
    NSMutableArray* resultArray = [NSMutableArray new];
    NSArray* keys = [_statesDictionary allKeys];
    for (id obj in keys){
        if ([obj isKindOfClass:[NSString class]]) {
            NSString* state = [_statesDictionary safeStringObjectForKey:obj];
            NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  obj, @"Prefix",
                                  state, @"Name",
                                  nil];
            [resultArray addObject:dict];
        }
        
    }
    
    _statesArray = [NSArray safeArrayWithArray:resultArray];
    [self applyFilterWith:@""];
}

- (void)applyFilterWith:(NSString*)name{
    
    if ([name isEqualToString:@""]) {
        _tableArray = [self sortAddresses:_statesArray];
        [_tableView reloadData];
        return;
    }
    
    NSMutableArray* filterdMutableArray = [NSMutableArray array];
    
    NSArray *searchNames = [[name lowercaseString]componentsSeparatedByString: @" "];
    NSString *firstSearchName = [[searchNames objectAtIndex: 0] lowercaseString];
    NSString *secondSearchName =nil;
    if(searchNames.count>1)secondSearchName =[[searchNames objectAtIndex: 1] lowercaseString];
    
    
    
    for (NSDictionary* friend in _statesArray) {
        
        NSString* fixedName =[[friend objectForKey:@"Name"] stringByReplacingOccurrencesOfString:@"  " withString:@" "];//some names are separated by double space :(
        
        NSArray *names = [fixedName componentsSeparatedByString: @" "];
        
        NSString *firstName = nil;
        NSString *secondName = nil;
        if ([names count] > 0) {
            firstName = [[names objectAtIndex: 0] lowercaseString];
        }
        if ([names count] > 1) {
            secondName = [[names objectAtIndex: 1] lowercaseString];
        }
        //  NSLog(@"|%@|,|%@|,|%@|",person.name,firstName,secondName);
        if(secondSearchName == nil || secondSearchName.length==0){//search by one name
            if ([firstName hasPrefix: firstSearchName] || [secondName hasPrefix: firstSearchName]) {
                [filterdMutableArray addObject:friend];
            }
        }
        else{
            if ( ([firstName hasPrefix: firstSearchName] && [secondName hasPrefix: secondSearchName])
                || ([firstName hasPrefix: secondSearchName] && [secondName hasPrefix: firstSearchName]) ) {//both searchNames must be contained
                [filterdMutableArray addObject:friend];
            }
        }
        
    }
    _tableArray = [NSArray arrayWithArray:filterdMutableArray];
    [_tableView reloadData];
    
}

- (NSArray*)sortAddresses:(NSArray*)array{
    NSArray *sorteArray = [array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [a safeStringObjectForKey:@"Name"];
        NSString *second = [b safeStringObjectForKey:@"Name"];
        return [first caseInsensitiveCompare:second];
    }];
    
    return sorteArray;
    
}


#pragma mark - TableView

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tableArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddressCell *cell = (AddressCell *) [tableView dequeueReusableCellWithIdentifier:@"AddressCell"];
    
    [cell setAddress:_tableArray[indexPath.row]];

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
    
    NSDictionary* addressDict = [_tableArray safeObjectAtIndex:indexPath.row];
    
    [SearchManager shared];
    
    StateVC* stateVC = [StateVC loadFromXIBForScrrenSizes];
    stateVC.addressDict = addressDict;
    [self.navigationController pushViewController:stateVC animated:YES];

}


#pragma mark - Search field



//- (void)startSearch{
//    
//    if (![ReachabilityManager isReachable]) {
//        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
//        return;
//    }
//    
//    [self.searchOperation cancel];
//    _page = 1;
//    [self searchRequest];
//    
//}
//
//
//
//
//- (void)sortData{
//    
//    [_tableArray sortUsingComparator:^NSComparisonResult(NSDictionary* obj1, NSDictionary* obj2) {
//        NSString *first = [obj1 safeStringObjectForKey:@"name"];
//        NSString *second = [obj2 safeStringObjectForKey:@"name"];
//        
//        if (_sortType) {
//            return [second caseInsensitiveCompare:first];
//        }else{
//            return [first caseInsensitiveCompare:second];
//        }
//    }];
//}
//

//- (void)loadData{
//    //    _page++;
//    //
//    //    if (_page == 1) {
//    [self showSpinnerWithName:@"CommunityViewController"];
//    //    }
//    
//    [SearchManager loadCommunityForState:_statePrefix
//                                    page:_page
//                                 success:^(NSArray* communities) {
//                                     
//                                     //if ([communities count] == 0) {
//                                     [self hideSpinnerWithName:@"CommunityViewController"];
//                                     [self showOnTable:communities];
//                                     //                                     }else{
//                                     //                                         [_tempTableArray addObjectsFromArray:communities];
//                                     //                                         [self loadData];
//                                     //                                     }
//                                     
//                                     [_pullToRefresh tableViewReloadFinished];
//                                 }
//                                 failure:^(NSError *error, NSString *errorString) {
//                                     [self hideSpinnerWithName:@"CommunityViewController"];
//                                     [[AlertManager shared] showOkAlertWithTitle:@"Error"
//                                                                         message:errorString];
//                                     [_pullToRefresh tableViewReloadFinished];
//                                 }
//                               exception:^(NSString *exceptionString) {
//                                   [self hideSpinnerWithName:@"CommunityViewController"];
//                                   [[AlertManager shared] showOkAlertWithTitle:exceptionString];
//                                   [_pullToRefresh tableViewReloadFinished];
//                               }];
//}


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
    //[self startSearch];
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
