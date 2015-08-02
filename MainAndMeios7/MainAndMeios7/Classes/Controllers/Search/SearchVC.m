//
//  SearchVC.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 10/19/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "SearchVC.h"
#import "UIFont+All.h"
#import "TMQuiltView.h"
#import "HomeItemCell.h"
#import "LoadProductsRequest.h"
#import "CustomTitleView.h"
#import "LoadProductsByStoreRequest.h"
#import "ProductDetailsVC.h"
#import "HomeStoreCell.h"
#import "SearchView.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "FacebookSDK/FacebookSDK.h"
#import "TwitterManager.h"
#import "FollowStoreRequest.h"

#import "StoreMapViewController.h"
#import "SearchRequest.h"
#import "StoreDetailsVC.h"

#import "ItemStoreVC.h"
#import "SearchManager.h"


@interface SearchVC ()
<TMQuiltViewDataSource,
TMQuiltViewDelegate>

@property (strong, nonatomic) TMQuiltView *quiltView;
@property (strong, nonatomic) NSMutableArray* collectionArray;

@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *titleTextLable;
@property (strong, nonatomic) SearchView* searchView;

@property (strong, nonatomic) NSString *phone;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (assign, nonatomic) BOOL searchShouldBeginEditing;

@property (assign, nonatomic) BOOL sortType;



@end

@implementation SearchVC

#pragma mark _______________________ Class Methods _________________________
#pragma mark ____________________________ Init _____________________________

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc{

}
#pragma mark _______________________ View Lifecycle ________________________

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (_wasPushed) {
        UIButton* menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [menuButton setImage:[UIImage imageNamed:@"nav_back_button.png"] forState:UIControlStateNormal];
        menuButton.frame = CGRectMake(0, 0, 40, 40);
        [menuButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *anchorLeftButton  = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
        self.navigationItem.leftBarButtonItem = anchorLeftButton;
    }else{
        UIButton* menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [menuButton setImage:[UIImage imageNamed:@"menu_button.png"] forState:UIControlStateNormal];
        menuButton.frame = CGRectMake(0, 0, 40, 40);
        [menuButton addTarget:self action:@selector(anchorRight) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *anchorLeftButton  = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
        self.navigationItem.leftBarButtonItem = anchorLeftButton;
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_az_button"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(sortButtonAction)];

    [self setupNavigationTitle];
 
    [self setupCollection];
    
    [self setupSearchView];
    
    self.collectionArray = [NSMutableArray new];
    
    _searchShouldBeginEditing = YES;
    
    //! Sort categories
    _sortType = YES;
    [self sortButtonAction];

 }

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    
    [_searchView layoutIfNeeded];
    [_quiltView layoutIfNeeded];
    [_quiltView reloadData];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    [self configureCollectionFrame];

}


- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}

#pragma mark _______________________ Privat Methods(view)___________________


- (void)anchorRight {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}


- (void)setupCollection{
    
    self.quiltView = [[TMQuiltView alloc] initWithFrame:CGRectZero];
    _quiltView.delegate = self;
    _quiltView.dataSource = self;
    _quiltView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_quiltView];
    _quiltView.backgroundColor = [UIColor clearColor];
    

}


- (void)setupSearchView{
    
    __weak SearchVC* wSelf = self;
    
    self.searchView = [SearchView loadViewFromXIB];
    
    
    _searchView.didSelectCategory = ^(SearchView* view, NSDictionary* category){
        [wSelf selectedCategory:category];
    };
    
    _searchView.didSelectAllCategory = ^(SearchView* view, NSDictionary* category){
        [wSelf selectedAllCategory:category];
    };
    
    
    [_quiltView addSubview:_searchView];
    
}

- (void)selectedCategory:(NSDictionary*)category{
    ItemStoreVC* vc = [ItemStoreVC loadFromXIBForScrrenSizes];
    vc.category = category;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)selectedAllCategory:(NSDictionary*)category{
    ItemStoreVC* vc = [ItemStoreVC loadFromXIBForScrrenSizes];
    vc.isAllCategories = YES;
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)configureCollectionFrame{
    
    CGRect rc = self.view.bounds;
    rc.origin.y = CGRectGetMaxY(_searchBar.frame);
    rc.size.height -= rc.origin.y;
    _quiltView.frame = rc;
    _quiltView.backgroundColor  =[UIColor clearColor];
    
    [self setupContentInset];
 }


- (void)setupContentInset{
    
    CGRect rc1 = CGRectMake(0, 0, _quiltView.frame.size.width, _searchView.frame.size.height);
    rc1.origin.y -= rc1.size.height;
    _searchView.frame =rc1;
    
    _quiltView.contentInset = UIEdgeInsetsMake(rc1.size.height, 0, 0, 0);
    _quiltView.scrollIndicatorInsets = UIEdgeInsetsMake(rc1.size.height, 0, 0, 0);
    
    _quiltView.contentOffset = CGPointMake(0, -rc1.size.height);

}

- (void)setupNavigationTitle{
    
    __weak SearchVC* wSelf = self;
    self.navigationItem.titleView = [[CustomTitleView alloc] initWithTitle:@"Search"
                                                         dropDownIndicator:NO
                                                             clickCallback:^(CustomTitleView *titleView) {
                                                                 [[LayoutManager shared].homeNVC popToRootViewControllerAnimated:NO];
                                                                 [[LayoutManager shared] showHomeControllerAnimated:YES];
                                                                 [wSelf.navigationController popToRootViewControllerAnimated:YES];
                                                             }];

}

- (void)configSearchBar{
    
    UIView* topCoverView = [UIView new];
    topCoverView.backgroundColor = [UIColor colorWithRed:0.929f green:0.925f blue:0.925f alpha:1.00f];
    topCoverView.frame = CGRectMake(0, 0, _searchBar.frame.size.width, 1);
    topCoverView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_searchBar addSubview:topCoverView];
    
    UIView* bottomCoverView = [UIView new];
    bottomCoverView.backgroundColor = [UIColor colorWithRed:0.929f green:0.925f blue:0.925f alpha:1.00f];
    bottomCoverView.frame = CGRectMake(0, _searchBar.frame.size.height - 1, _searchBar.frame.size.width, 1);
    bottomCoverView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_searchBar addSubview:bottomCoverView];
    
    [_searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"scope_bar_background.png"]forState:UIControlStateNormal];
    
//    CGRect rc = _searchBar.frame;
//    rc.origin.y = CGRectGetMaxY(_searchTypeView.frame);
//    _searchBar.frame = rc;
}


- (void)onClickWithItemDict:(NSDictionary*)itemDict{
    
    if ([itemDict.allKeys containsObject:@"price"]) {
        ProductDetailsVC *vc = [[ProductDetailsVC alloc] initWithProduct:itemDict];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else{
        StoreDetailsVC* storeDetailsVC = [StoreDetailsVC loadFromXIBForScrrenSizes];
        storeDetailsVC.storeDict = itemDict;
        [self.navigationController pushViewController:storeDetailsVC animated:YES];
    }
}


#pragma mark _______________________ Privat Methods ________________________


- (void)loadProducts{
    
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    
    
    LoadProductsByStoreRequest *productsRequest = [[LoadProductsByStoreRequest alloc] init];
    //productsRequest.storeId = [_storeDict safeNumberObjectForKey:@"id"];
    productsRequest.latest = YES;
    
    [self showSpinnerWithName:@""];
    [[MMServiceProvider sharedProvider] sendRequest:productsRequest success:^(LoadProductsByStoreRequest *request) {
        [self hideSpinnerWithName:@""];
        NSLog(@"products: %@", request.products);
        
        self.collectionArray = [NSMutableArray arrayWithArray:request.products];
        [self.quiltView reloadData];
        
    } failure:^(LoadProductsByStoreRequest *request, NSError *error) {
        [self hideSpinnerWithName:@""];
        NSLog(@"Error: %@", error);
        
        self.collectionArray = [NSMutableArray new];
        [_quiltView reloadData];
        [[AlertManager shared] showOkAlertWithTitle:@"Error" message:error.localizedDescription];
    }];
}


- (void)startSearch{
    
    
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    
    [self searchItemsRequest:^(NSArray* items, NSError* error){
        [self searchStoresRequest:^(NSArray* stores, NSError* error){
            
            self.collectionArray = [NSMutableArray new];
            
            for (int i = 0; i < items.count && i < stores.count; i++) {
                [_collectionArray safeAddObject:[stores safeObjectAtIndex:i]];
                [_collectionArray safeAddObject:[items safeObjectAtIndex:i]];
            }
            
            [_quiltView reloadData];
            
            if (_collectionArray.count > 0) {
                [_quiltView setContentOffset:CGPointMake(0, 0) animated:YES];
            }
            
        }];
    }];
}
- (void)searchStoresRequest:(void (^)(NSArray* objects, NSError* error))completion{
    
    if (_searchBar.text.length == 0) {
        completion(@[], nil);
        return;
    }
    
    
    SearchRequest *searchRequest = [[SearchRequest alloc] initWithSearchType:SearchTypeStores searchFilter:SearchFilterRandom];
    searchRequest.location = [[CLLocation alloc] initWithLatitude:42.283215 longitude:-71.123029];
    searchRequest.city = [SearchManager shared].city;
    searchRequest.state = [SearchManager shared].state;
    searchRequest.page = 1;
    searchRequest.perPage = 20;
    searchRequest.searchKey = _searchBar.text;
    
    [self showSpinnerWithName:@""];
    
    [[MMServiceProvider sharedProvider] sendRequest:searchRequest success:^(SearchRequest* request) {
        NSLog(@"Succceess!");
        [self hideSpinnerWithName:@""];
        
        completion(request.objects, nil);
        
    } failure:^(id _request, NSError *error) {
        NSLog(@"Fail: %@", error);
        [self hideSpinnerWithName:@""];
        
        NSLog(@"error: %@", error);
        completion(@[], error);
    }];
}


- (void)searchItemsRequest:(void (^)(NSArray* objects, NSError* error))completion{
    
    if (_searchBar.text.length == 0) {
        completion(@[], nil);
        return;
    }
    
    
    SearchRequest *searchRequest = [[SearchRequest alloc] initWithSearchType:SearchTypeProducts searchFilter:SearchFilterRandom];
    searchRequest.location = [[CLLocation alloc] initWithLatitude:42.283215 longitude:-71.123029];
    searchRequest.city = [SearchManager shared].city;
    searchRequest.state = [SearchManager shared].state;
    searchRequest.page = 1;
    searchRequest.perPage = 20;
    searchRequest.searchKey = _searchBar.text;
    
    [self showSpinnerWithName:@""];
    
    [[MMServiceProvider sharedProvider] sendRequest:searchRequest success:^(SearchRequest* request) {
        NSLog(@"Succceess!");
        [self hideSpinnerWithName:@""];
    
         completion(request.objects, nil);
        
    } failure:^(id _request, NSError *error) {
        NSLog(@"Fail: %@", error);
        [self hideSpinnerWithName:@""];
        
        NSLog(@"error: %@", error);
        completion(@[], error);
    }];
}

#pragma mark _______________________ Buttons Action ________________________

- (void)backButtonClicked{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)customBackButtinClicked:(id)sender {
     [self.navigationController popViewControllerAnimated:YES];
}

- (void) sortButtonAction {
    _sortType = !_sortType;
    [_searchView sortDataAssending:_sortType];
}

#pragma mark _______________________ Delegates _____________________________

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
        [self startSearch];
    }
    else if ([searchText length] == 0) {
        // The user clicked the [X] button or otherwise cleared the text.
        [theSearchBar performSelector: @selector(resignFirstResponder)
                           withObject: nil
                           afterDelay: 0.1];
        [self startSearch];
    }
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self startSearch];
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


- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)TMQuiltView {
    return _collectionArray.count;
}

- (TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary* objDict = [_collectionArray safeDictionaryObjectAtIndex:indexPath.row];
    
    
    //! Set cell type
    if ([objDict.allKeys containsObject:@"price"]) {
        
        HomeItemCell *cell = (HomeItemCell *)[quiltView dequeueReusableCellWithReuseIdentifier:@"HomeItemCell"];
        if (!cell) {
            cell = [HomeItemCell loadViewFromXIB];
            [cell setReuseIdentifier:@"HomeItemCell"];
        }
        
        
        NSDictionary* storeDict = [_collectionArray safeDictionaryObjectAtIndex:indexPath.row];
        
        cell.storeDict = storeDict;
        
        return cell;
        
    }else{
        
        HomeStoreCell *cell = (HomeStoreCell *)[quiltView dequeueReusableCellWithReuseIdentifier:@"HomeStoreCell"];
        if (!cell) {
            cell = [HomeStoreCell loadViewFromXIB];
            [cell setReuseIdentifier:@"HomeStoreCell"];
        }
        
        
        NSDictionary* storeDict = [_collectionArray safeDictionaryObjectAtIndex:indexPath.row];
        
        cell.storeDict = storeDict;
        
        return cell;
        
    }
    return nil;
}

#pragma mark - TMQuiltViewDelegate

- (void)quiltView:(TMQuiltView *)quiltView didSelectCellAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dict = [_collectionArray safeDictionaryObjectAtIndex:indexPath.row];
    
    [self onClickWithItemDict:dict];
}

- (NSInteger)quiltViewNumberOfColumns:(TMQuiltView *)quiltView {
    
    
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft
        || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        return 2;
    } else {
        return 2;
    }
}

- (CGFloat)quiltView:(TMQuiltView *)quiltView heightForCellAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary* storeDict = [_collectionArray safeDictionaryObjectAtIndex:indexPath.row];
    
    CGFloat height = [HomeStoreCell cellHeghtForStore:storeDict];
    
    return height;
}

#pragma mark _______________________ Public Methods ________________________


#pragma mark _______________________ Notifications _________________________

- (void)keyboardWillShow:(NSNotification *)notification {
    //get the end position keyboard frame
    NSDictionary *keyInfo = [notification userInfo];
    CGRect keyboardFrame = [[keyInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    //convert it to the same view coords as the tableView it might be occluding
    keyboardFrame = [self.quiltView convertRect:keyboardFrame fromView:nil];
    //calculate if the rects intersect
    CGRect intersect = CGRectIntersection(keyboardFrame, self.quiltView.bounds);
    if (!CGRectIsNull(intersect)) {
        //yes they do - adjust the insets on tableview to handle it
        //first get the duration of the keyboard appearance animation
        NSTimeInterval duration = [[keyInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
        //change the table insets to match - animated to the same duration of the keyboard appearance
        [UIView animateWithDuration:duration animations:^{
            
            UIEdgeInsets ei = self.quiltView.contentInset;
            ei.bottom = intersect.size.height;
            
            self.quiltView.contentInset = ei;
            self.quiltView.scrollIndicatorInsets = ei;
        }];
    }
}

- (void) keyboardWillHide:  (NSNotification *) notification{
    NSDictionary *keyInfo = [notification userInfo];
    NSTimeInterval duration = [[keyInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    //clear the table insets - animated to the same duration of the keyboard disappearance
    [UIView animateWithDuration:duration animations:^{
        [self setupContentInset];
    }];
}


@end
