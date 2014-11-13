//
//  HomeVC.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 10/19/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "HomeVC.h"
#import "UIFont+All.h"
#import "SearchTypeView.h"
#import "SearchTypeView.h"
#import "TMQuiltView.h"
#import "HomeStoreCell.h"
#import "HomeItemCell.h"
#import "LoadProductsRequest.h"
#import "SVPullToRefresh.h"
#import "SearchRequest.h"
#import "CustomTitleView.h"
#import "ProductDetailsVC.h"

typedef enum {
    ScreenStateStore = 0,
    ScreenStateItem,
    
} ScreenState;


@interface HomeVC () <TMQuiltViewDataSource, TMQuiltViewDelegate>

@property (strong, nonatomic) SearchTypeView *searchTypeView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (assign, nonatomic) BOOL searchShouldBeginEditing;


@property (strong, nonatomic) TMQuiltView *quiltView;
@property (strong, nonatomic) NSMutableArray* collectionArray;

@property (assign, nonatomic) NSInteger page;

@property (strong, nonatomic) AFHTTPRequestOperation* searchOperation;

@property (assign, nonatomic) ScreenState screenState;
@end

@implementation HomeVC

#pragma mark _______________________ Class Methods _________________________
#pragma mark ____________________________ Init _____________________________

- (void)dealloc{

}
#pragma mark _______________________ View Lifecycle ________________________

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    __weak HomeVC* wSelf = self;
    
    UIButton* menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setImage:[UIImage imageNamed:@"menu_button.png"] forState:UIControlStateNormal];
    menuButton.frame = CGRectMake(0, 0, 40, 40);
    [menuButton addTarget:self action:@selector(anchorRight) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *anchorLeftButton  = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    
    
    self.searchTypeView = [SearchTypeView loadViewFromXIB];
    [self.view addSubview:_searchTypeView];
    
    _searchTypeView.didSelectItems = ^(SearchTypeView* view, UIButton* button){
        [wSelf.searchBar resignFirstResponder];
        [wSelf startSearch];
        wSelf.quiltView.hidden = NO;
    };
    
    _searchTypeView.didSelectStorefronts = ^(SearchTypeView* view, UIButton* button){
        [wSelf.searchBar resignFirstResponder];
        [wSelf startSearch];
        wSelf.quiltView.hidden = NO;
    };
    
    _searchTypeView.didSelectSpecials = ^(SearchTypeView* view, UIButton* button){
        [wSelf.searchBar resignFirstResponder];
        wSelf.collectionArray = [NSMutableArray new];
        [wSelf.quiltView reloadData];
        wSelf.quiltView.hidden = YES;

    };
    
    [self configSearchBar];
    
    self.navigationItem.titleView = [[CustomTitleView alloc] initWithTitle:@"ROSLINDALE, MA"
                                                         dropDownIndicator:YES
                                                             clickCallback:^(CustomTitleView *titleView) {
                                                                 [[AlertManager shared] showOkAlertWithTitle:@"This functionality is not implemented yet"];
//        NSLog(@"It works!");
//        titleView.title = @"CLICKED";
//        titleView.shouldShowDropdownIndicator = YES;
    }];

    self.navigationItem.leftBarButtonItem = anchorLeftButton;
    
    [_searchTypeView selectStorefronts];

    [self setupCollection];
    
    
    self.collectionArray = [NSMutableArray new];
    
    //_quiltView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    
    
    [_quiltView addInfiniteScrollingWithActionHandler:^{
        [wSelf searchRequest];
    }];
    
    [self startSearch];
    
    _searchShouldBeginEditing = YES;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    [_quiltView reloadData];

}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    [self updateSearchTypeViewFrame];
    [self configureCollectionFrame];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark _______________________ Privat Methods(view)___________________


- (void)anchorRight {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

- (void)updateSearchTypeViewFrame{
    CGRect rc = _searchTypeView.frame;
    rc.origin.y = 0;
    _searchTypeView.frame = rc;
    
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
    
    CGRect rc = _searchBar.frame;
    rc.origin.y = CGRectGetMaxY(_searchTypeView.frame);
    _searchBar.frame = rc;
}


- (void)setupCollection{
    
    self.quiltView = [[TMQuiltView alloc] initWithFrame:CGRectZero];
    _quiltView.delegate = self;
    _quiltView.dataSource = self;
    _quiltView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_quiltView];
    _quiltView.backgroundColor = [UIColor clearColor];

}

- (void)configureCollectionFrame{
    
    CGRect rc = self.view.frame;
    rc.origin.y = CGRectGetMaxY(_searchBar.frame);
    rc.size.height -= rc.origin.y;
    _quiltView.frame = rc;

}

#pragma mark _______________________ Privat Methods ________________________


- (void)startSearch{
    
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    
    _page = 1;
    [self searchRequest];
   
}


- (void)searchRequest{

    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    
    
    SearchType searchType = SearchTypeStores;
    if (_searchTypeView.searchType == SearchTypeItems) {
        searchType = SearchTypeProducts;
    }
    
    
    SearchRequest *searchRequest = [[SearchRequest alloc] initWithSearchType:searchType searchFilter:SearchFilterRandom];
    searchRequest.coordinate = CLLocationCoordinate2DMake(42.283215, -71.123029);
    searchRequest.city = @"Roslindale";
    searchRequest.state = @"MA";
    searchRequest.page = _page;
    searchRequest.searchKey = _searchBar.text;
    
    if (_page == 1) {
        [self showSpinnerWithName:@""];
    }

    self.searchOperation =   [[MMServiceProvider sharedProvider] sendRequest:searchRequest success:^(SearchRequest* request) {
        NSLog(@"Succceess!");
        [self hideSpinnerWithName:@""];
        
        //! Set cell type
        if (searchRequest.searchType == SearchTypeProducts) {
            _screenState = ScreenStateItem;
        }else if (searchRequest.searchType == SearchTypeStores){
            _screenState = ScreenStateStore;
        }
        
        [_quiltView.infiniteScrollingView stopAnimating];
        
        if (_page == 1) {
            self.collectionArray = [NSMutableArray new];
            [self.quiltView reloadData];
        }
        
        if (request.objects.count > 0) {
            [_collectionArray addObjectsFromArray:request.objects];
            _page ++;
        }
        
        [_quiltView reloadData];
        
        self.searchOperation = nil;

    } failure:^(id _request, NSError *error) {
        NSLog(@"Fail: %@", error);
         [self hideSpinnerWithName:@""];
        
        [_quiltView.infiniteScrollingView stopAnimating];
        _page = 1;
        self.collectionArray = [NSMutableArray new];
        [_quiltView reloadData];
        NSLog(@"error: %@", error);
        self.searchOperation = nil;
    }];
}


- (void)setSearchOperation:(AFHTTPRequestOperation *)searchOperation{
    //[_searchOperation cancel];
    _searchOperation = searchOperation;
}

//- (void)loadProducts{
//
//    
//    
//    LoadProductsRequest *request = [[LoadProductsRequest alloc] init];
//    request.keywords = @"find";
//    request.
//
//    [self showSpinnerWithName:@""];
//    [[MMServiceProvider sharedProvider] sendRequest:request success:^(id _request) {
//        [self hideSpinnerWithName:@""];
//        NSLog(@"products: %@", request.products);
//        
//        [_quiltView.infiniteScrollingView stopAnimating];
//        
//        if (_page == 1) {
//            self.collectionArray = [NSMutableArray new];
//        }
//        
//        if (request.products.count > 0) {
//            [_collectionArray addObjectsFromArray:request.products];
//            _page ++;
//        }
//        
//        [_quiltView reloadData];
//        
//    } failure:^(id _request, NSError *error) {
//        [self hideSpinnerWithName:@""];
//        [_quiltView.infiniteScrollingView stopAnimating];
//        _page = 1;
//        self.collectionArray = [NSMutableArray new];
//        
//        NSLog(@"error: %@", error);
//    }];
//
//}
//
#pragma mark _______________________ Buttons Action ________________________
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
#pragma mark - QuiltViewControllerDataSource

//- (NSArray *)images {
//    if (!_images) {
//        NSMutableArray *imageNames = [NSMutableArray array];
//        for(int i = 0; i < kNumberOfCells; i++) {
//            [imageNames addObject:[NSString stringWithFormat:@"%d.jpeg", i % 10 + 1]];
//        }
//        _images = [imageNames retain];
//    }
//    return _images;
//}

//- (UIImage *)imageAtIndexPath:(NSIndexPath *)indexPath {
//    return [UIImage imageNamed:[self.images objectAtIndex:indexPath.row]];
//}


- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)TMQuiltView {
    return _collectionArray.count;
}

- (TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    //! Set cell type
    if (_screenState == ScreenStateItem) {
       
        HomeItemCell *cell = (HomeItemCell *)[quiltView dequeueReusableCellWithReuseIdentifier:@"HomeItemCell"];
        if (!cell) {
            cell = [HomeItemCell loadViewFromXIB];
            [cell setReuseIdentifier:@"HomeItemCell"];
        }
        
        
        NSDictionary* storeDict = [_collectionArray safeDictionaryObjectAtIndex:indexPath.row];
        
        cell.storeDict = storeDict;
        
        return cell;

    }else if (_screenState == ScreenStateStore){
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
    
    if (_screenState == ScreenStateItem) {
        ProductDetailsVC *vc = [[ProductDetailsVC alloc] initWithProduct:dict];
        [self.navigationController pushViewController:vc animated:YES];

    }else{
        [[AlertManager shared] showOkAlertWithTitle:@"This functionality is not implemented yet"];
    }
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


- (void)viewWillDisappear:(BOOL)animated {
    /*
     your code here
     */
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [super viewWillDisappear:animated];
}

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
            self.quiltView.contentInset = UIEdgeInsetsMake(0, 0, intersect.size.height, 0);
            self.quiltView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, intersect.size.height, 0);
        }];
    }
}

- (void) keyboardWillHide:  (NSNotification *) notification{
    NSDictionary *keyInfo = [notification userInfo];
    NSTimeInterval duration = [[keyInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    //clear the table insets - animated to the same duration of the keyboard disappearance
    [UIView animateWithDuration:duration animations:^{
        self.quiltView.contentInset = UIEdgeInsetsZero;
        self.quiltView.scrollIndicatorInsets = UIEdgeInsetsZero;
    }];
}
@end
