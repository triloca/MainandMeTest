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


typedef enum {
    ScreenStateStore = 0,
    ScreenStateItem,
    
} ScreenState;


@interface HomeVC () <TMQuiltViewDataSource, TMQuiltViewDelegate>
@property (strong, nonatomic) SearchTypeView *searchTypeView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;


@property (strong, nonatomic) TMQuiltView *quiltView;
@property (strong, nonatomic) NSMutableArray* collectionArray;

@property (assign, nonatomic) NSInteger page;

@property (strong, nonatomic) AFHTTPRequestOperation* searchOperation;

@property (strong, nonatomic) NSTimer* searchTimer;

@property (assign, nonatomic) ScreenState screenState;
@end

@implementation HomeVC

#pragma mark _______________________ Class Methods _________________________
#pragma mark ____________________________ Init _____________________________
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
    
    self.navigationItem.title = @"Layout Demo";
    self.navigationItem.leftBarButtonItem = anchorLeftButton;
    
    [_searchTypeView selectStorefronts];

    [self setupCollection];
    
    
    self.collectionArray = [NSMutableArray new];
    
    //_quiltView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    
    
    [_quiltView addInfiniteScrollingWithActionHandler:^{
        [wSelf searchRequest];
    }];
    
    _page = 1;

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_quiltView reloadData];
    
    [self startSearch];
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


- (void)startSearchTimer{
    
    self.searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.7f
                                                      target:self
                                                    selector:@selector(readTimerTick:)
                                                    userInfo:nil
                                                     repeats:NO];
}

- (void)resetSearchTimer{
    [self.searchTimer invalidate];
    self.searchTimer = nil;
}

- (void)readTimerTick:(NSTimer*)timer{
    
    [self startSearch];
}


- (void)startSearch{
    
    _page = 1;
    [self searchRequest];
   
}



- (void)searchRequest{

    SearchType searchType = SearchTypeStores;
    if (_searchTypeView.searchType == SearchTypeItems) {
        searchType = SearchTypeProducts;
    }
    
    
    SearchRequest *searchRequest = [[SearchRequest alloc] initWithSearchType:searchType searchFilter:SearchFilterPopular];
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

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length > 2) {
        
    }
    [self resetSearchTimer];
    [self startSearchTimer];
    
    // The user clicked the [X] button or otherwise cleared the text.
    if([searchText length] == 0) {
        [searchBar performSelector: @selector(resignFirstResponder)
                        withObject: nil
                        afterDelay: 0.1];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self.searchBar resignFirstResponder];
    return YES;
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

- (NSInteger)quiltViewNumberOfColumns:(TMQuiltView *)quiltView {
    
    
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft
        || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        return 3;
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
@end
