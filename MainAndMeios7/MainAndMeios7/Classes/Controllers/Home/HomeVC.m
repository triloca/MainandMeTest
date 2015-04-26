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
#import "HomeHorisontalListView.h"
#import "StoreDetailsVC.h"
#import "UIViewController+Common.h"
#import "SpecialsView.h"
#import "SpecialDetailsVC.h"
#import "LoadStoreRequest.h"

#import "ProximityKitManager.h"
#import "AddressVC.h"
#import "SearchManager.h"
#import "StateVC.h"

#import "HomeCoverView.h"
#import "ProductCell.h"
#import "CustomSearchBar.h"

typedef enum {
    ScreenStateStore = 0,
    ScreenStateItem,
    
} ScreenState;

typedef enum {
    ListStyleCollection = 0,
    ListStyleHorisontal,
    
} ListStyle;

static NSString *kProductCellIdentifier = @"ProductCell";

@interface HomeVC ()
<TMQuiltViewDataSource,
TMQuiltViewDelegate,
HorisontalListViewDelegate,
UITableViewDataSource,
UITableViewDelegate>

@property (strong, nonatomic) SearchTypeView *searchTypeView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (assign, nonatomic) BOOL searchShouldBeginEditing;


@property (strong, nonatomic) TMQuiltView *quiltView;
@property (strong, nonatomic) NSMutableArray* collectionArray;

@property (strong, nonatomic) UITableView* tableView;

@property (strong, nonatomic) HomeHorisontalListView* homeHorisontalListView;

@property (strong, nonatomic) SpecialsView *specialsView;

@property (assign, nonatomic) NSInteger page;

@property (strong, nonatomic) AFHTTPRequestOperation* searchOperation;

@property (assign, nonatomic) ScreenState screenState;
@property (assign, nonatomic) ListStyle listStyle;

@property (strong, nonatomic) HomeCoverView* coverView;

@end

@implementation HomeVC

#pragma mark _______________________ Class Methods _________________________
#pragma mark ____________________________ Init _____________________________

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark _______________________ View Lifecycle ________________________

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];// To test
    
    __weak HomeVC* wSelf = self;
    
    UIButton* menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setImage:[UIImage imageNamed:@"menu_button.png"] forState:UIControlStateNormal];
    menuButton.frame = CGRectMake(0, 0, 40, 40);
    [menuButton addTarget:self action:@selector(anchorRight) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *anchorLeftButton  = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    self.navigationItem.leftBarButtonItem = anchorLeftButton;
    
    [self setupSearchTypeView];
    
    
    [self configSearchBar];
    
    [_searchTypeView selectStorefronts];
    self.searchTypeView.hideTriger = YES;
    [self.searchTypeView unselectAll];

    [self setupCollectionView];
    //[self setupCollection];
    
    //[self setupHorisontalView];
    
    [self setupSpecialsView];
    
    
    self.collectionArray = [NSMutableArray new];
    
    [_quiltView addInfiniteScrollingWithActionHandler:^{
        [wSelf searchRequest];
    }];
    
    [self startSearch];
    
    _searchShouldBeginEditing = YES;
    
    [self updateByListStyle];
    
    //! Add camera button
    UIButton* customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customButton setBackgroundImage:[UIImage imageNamed:@"camera_icon.png"] forState:UIControlStateNormal];
    customButton.frame = CGRectMake(0, 0, 40, 40);
    [customButton addTarget:self action:@selector(cameraButtinCliced:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton  = [[UIBarButtonItem alloc] initWithCustomView:customButton];
    self.navigationItem.rightBarButtonItem = barButton;
    
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self addCoverViewAnimated:YES];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
        
    [self setupNavigationTitle];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveCampaignNotification:) name:kNewCampaignNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeCommunityNotification:) name:@"kCommunityChanged" object:nil];

    
    [self.navigationController.view removeGestureRecognizer:[LayoutManager shared].slidingVC.panGesture];

    [self updateByListStyle];
    
    [_tableView reloadData];
    //[_quiltView reloadData];
    
    

}

- (void)viewWillDisappear:(BOOL)animated {
    /*
     your code here
     */
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    

    [super viewWillDisappear:animated];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
//    [self updateSearchTypeViewFrame];
//    [self configureCollectionFrame];
//    [self configureHorisontalViewFrame];
    [self updateCoverViewFrames];

}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self updateSearchTypeViewFrame];
    [self configureCollectionFrame];
    [self configureCollectionViewFrame];
    [self configureHorisontalViewFrame];

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

- (void)updateSearchTypeViewFrame{
    CGRect rc = _searchTypeView.frame;
    rc.origin.y = 0;
    _searchTypeView.frame = rc;
    
}

- (void)configSearchBar{
    
    CGRect rc = _searchBar.frame;
    rc.origin.y = CGRectGetMaxY(_searchTypeView.frame);
    _searchBar.frame = rc;
}

- (void)setupCollectionView{
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    _tableView.backgroundColor = [UIColor colorWithRed:0.949f green:0.949f blue:0.949f alpha:1.00f];
    
    __weak HomeVC* wSelf = self;
    [_tableView addPullToRefreshWithActionHandler:^{
        [wSelf startSearch];
    }];
    
    [_tableView addInfiniteScrollingWithActionHandler:^{
        [wSelf searchRequest];
    }];
    
}

- (void)setupCollection{
    
    self.quiltView = [[TMQuiltView alloc] initWithFrame:CGRectZero];
    _quiltView.delegate = self;
    _quiltView.dataSource = self;
    _quiltView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_quiltView];
    _quiltView.backgroundColor = [UIColor colorWithRed:0.949f green:0.949f blue:0.949f alpha:1.00f];

}

- (void)configureCollectionViewFrame{
    
    CGRect rc = self.view.frame;
    rc.origin.y = CGRectGetMaxY(_searchBar.frame);
    rc.size.height -= rc.origin.y;
    self.tableView.frame = rc;
    
}


- (void)configureCollectionFrame{
    
    CGRect rc = self.view.frame;
    rc.origin.y = CGRectGetMaxY(_searchBar.frame);
    rc.size.height -= rc.origin.y;
    _quiltView.frame = rc;

}

- (void)configureHorisontalViewFrame{
    
    CGRect rc = self.view.frame;
    rc.origin.y = CGRectGetMaxY(_searchBar.frame);
    rc.size.height -= rc.origin.y;
    _homeHorisontalListView.frame = rc;
    
}


- (void)updateByListStyle{

    
    switch (_listStyle) {
        case ListStyleCollection:{
            break;
            UIButton* customButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [customButton setImage:[UIImage imageNamed:@"nav_list_button.png"] forState:UIControlStateNormal];
            customButton.frame = CGRectMake(0, 0, 40, 40);
            [customButton addTarget:self action:@selector(setupHorisontalStyle) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *barButton  = [[UIBarButtonItem alloc] initWithCustomView:customButton];
            self.navigationItem.rightBarButtonItem = barButton;
            break;
        }
        case ListStyleHorisontal:{
            break;
            UIButton* customButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [customButton setImage:[UIImage imageNamed:@"nav_collection_button.png"] forState:UIControlStateNormal];
            customButton.frame = CGRectMake(0, 0, 40, 40);
            [customButton addTarget:self action:@selector(setupListStyle) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *barButton  = [[UIBarButtonItem alloc] initWithCustomView:customButton];
            self.navigationItem.rightBarButtonItem = barButton;
            break;
        }
 
        default:
            break;
    }
    
    switch (_listStyle) {
        case ListStyleCollection:{
            
            [self.view bringSubviewToFront:_quiltView];
            
            [self.view insertSubview:_quiltView aboveSubview:_homeHorisontalListView];
            
            self.homeHorisontalListView.hidden = YES;
            self.quiltView.hidden = NO;
            
//            self.homeHorisontalListView.hidden = NO;
//            self.quiltView.hidden = NO;

            
            break;
        }
        case ListStyleHorisontal:{
            
            self.homeHorisontalListView.tableArray = _collectionArray;
            [self.homeHorisontalListView reloadData];
            
            
            [self.view insertSubview:_homeHorisontalListView aboveSubview:_quiltView];
            
            self.homeHorisontalListView.hidden = NO;
            self.quiltView.hidden = YES;

//            self.homeHorisontalListView.hidden = NO;
//            self.quiltView.hidden = NO;

            
            break;
        }
            
        default:
            break;
    }
}

- (void)setupHorisontalStyle{
    _listStyle = ListStyleHorisontal;
    [self updateByListStyle];
}

- (void)setupListStyle{
    _listStyle = ListStyleCollection;
    [self updateByListStyle];
}

- (void)setupNavigationTitle{
    
    NSString* title = [NSString stringWithFormat:@"%@, %@", [SearchManager shared].city, [SearchManager shared].state];
    
    self.navigationItem.titleView = [[CustomTitleView alloc] initWithTitle:title
                                                         dropDownIndicator:NO
                                                             clickCallback:^(CustomTitleView *titleView) {
                                                                 [self showAddressController];
                                                             }];

}

- (void) setupSpecialsView {
    
    __weak HomeVC* wSelf = self;
    
    
    self.specialsView = [SpecialsView loadViewFromXIB];
    
    _specialsView.didSelectCampaign = ^(SpecialsView* view, CKCampaign* campaign){
        [wSelf showSpecialDetails:campaign];
    };
    
//    self.specialsView.items = @[
//                                [NSURL URLWithString:@"http://google.com"],
//                                [NSURL URLWithString:@"http://yahoo.com"],
//                                [NSURL URLWithString:@"http://www.com"],
//                                [NSURL URLWithString:@"http://instagram.com"],
//                                [NSURL URLWithString:@"http://twitter.com"],
//                                ];
    CGRect rc = _specialsView.frame;
    rc.origin.y = CGRectGetMaxY(_searchBar.frame);
    rc.size.height = self.view.frame.size.height - rc.origin.y;
    _specialsView.frame = rc;
    _specialsView.hidden = YES;
    
    [self.view addSubview:self.specialsView];
}

- (void)setupHorisontalView{
    
    __weak HomeVC* wSelf = self;
    
    self.homeHorisontalListView = [HomeHorisontalListView loadViewFromXIB];
    self.homeHorisontalListView.delegate = self;
    
    _homeHorisontalListView.didSelectItem = ^(HomeHorisontalListView* view, NSDictionary* itemDict){
        [wSelf onClickWithItemDict:itemDict];
    };
    
    
    CGRect rc = _homeHorisontalListView.frame;
    rc.origin.y = CGRectGetMaxY(_searchBar.frame);
    _homeHorisontalListView.frame = rc;
    [self.view addSubview:_homeHorisontalListView];
}

- (void)showSpecialDetails:(CKCampaign*)compaign{
    
    [[LayoutManager shared] showSpecialDetails:compaign];
    
//    SpecialDetailsVC* specialDetailsVC = [SpecialDetailsVC loadFromXIBForScrrenSizes];
//    specialDetailsVC.campaign = compaign;
//    [[LayoutManager shared].rootNVC pushViewController:specialDetailsVC animated:YES];
}

- (void)showAddressController{
    AddressVC* addressVC = [AddressVC loadFromXIBForScrrenSizes];
    
    StateVC* stateVC = [StateVC loadFromXIBForScrrenSizes];
    //stateVC.addressDict = addressDict;

    NSMutableArray* controllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [controllers safeAddObject:addressVC];
    self.navigationController.viewControllers = [NSArray arrayWithArray:controllers];
    [self.navigationController pushViewController:stateVC animated:YES];

}

- (void)setupSearchTypeView{
    
    __weak HomeVC* wSelf = self;
    
    self.searchTypeView = [SearchTypeView loadViewFromXIB];
    [self.view addSubview:_searchTypeView];
    
    _searchTypeView.didSelectItems = ^(SearchTypeView* view, UIButton* button){
        view.hideTriger = NO;
        
        if (view.oldSearchType == SearchTypeItems) {
        }else{
            [wSelf.searchBar resignFirstResponder];
            [wSelf startSearch];
            wSelf.quiltView.hidden = NO;
            wSelf.homeHorisontalListView.hidden = YES;
            wSelf.specialsView.hidden = YES;
        }
        
        if (wSelf.coverView) {
            [wSelf.coverView scrollOutAnimated:YES];
            [wSelf removeCoverViewAnimated:YES];
        }
        
    };
    
    _searchTypeView.didSelectStorefronts = ^(SearchTypeView* view, UIButton* button){
        view.hideTriger = NO;
        if (view.oldSearchType == SearchTypeStorefronts) {
        }else{
            [wSelf.searchBar resignFirstResponder];
            [wSelf startSearch];
            wSelf.quiltView.hidden = NO;
            wSelf.homeHorisontalListView.hidden = YES;
            wSelf.specialsView.hidden = YES;
        }
        if (wSelf.coverView) {
            [wSelf.coverView scrollOutAnimated:YES];
            [wSelf removeCoverViewAnimated:YES];
        }
    };
    
    _searchTypeView.didSelectSpecials = ^(SearchTypeView* view, UIButton* button){
        view.hideTriger = NO;
        if (view.oldSearchType == SearchTypeSpecials) {
        }else{
            [wSelf.searchBar resignFirstResponder];
            wSelf.collectionArray = [NSMutableArray new];
            //[wSelf.quiltView reloadData];
            [wSelf.tableView reloadData];
            wSelf.quiltView.hidden = YES;
            wSelf.homeHorisontalListView.hidden = YES;
            wSelf.specialsView.hidden = NO;
            
            [wSelf updateSpecials];
        }
        
        if (wSelf.coverView) {
            [wSelf.coverView scrollOutAnimated:YES];
            [wSelf removeCoverViewAnimated:YES];
        }
    };
}


#pragma mark  Cover View
- (void)addCoverViewAnimated:(BOOL)animated{

    __weak HomeVC* wSelf = self;
    
    if (self.coverView == nil) {
        self.coverView = [HomeCoverView loadViewFromXIB];
        self.coverView.didFinishViewing = ^(HomeCoverView* view){
            
            if (wSelf.searchTypeView.hideTriger) {
                wSelf.searchTypeView.hideTriger = NO;
                [wSelf.searchTypeView selectStorefronts];
            }
            
            [wSelf removeCoverViewAnimated:YES];
        };
        
        self.coverView.didClickSponsorButton = ^(HomeCoverView* view, UIButton* button){
        
            wSelf.searchTypeView.hideTriger = NO;
            [wSelf.searchTypeView selectStorefronts];
            
            [LayoutManager shared].slidingVC.topViewController = [LayoutManager shared].searchNVC;
            [[LayoutManager shared].slidingVC resetTopViewAnimated:YES onComplete:^{}];
        };
    }
    
    
    if ([[ProximityKitManager shared].activeCampaigns firstObject]) {
        [_coverView setupCampaign:[[ProximityKitManager shared].activeCampaigns firstObject]];
    }else{
        
        [[ProximityKitManager shared].campaignKitManager syncWithCompletionHandler:^(UIBackgroundFetchResult res) {
            if ([[ProximityKitManager shared].activeCampaigns firstObject]) {
                [_coverView setupCampaign:[[ProximityKitManager shared].activeCampaigns firstObject]];
            }else{
                [self removeCoverViewAnimated:YES];
            }
        }];
    }
    
    
    _coverView.alpha = 0;
    [self updateCoverViewFrames];
    [self.view addSubview:_coverView];
    
    [UIView animateWithDuration:animated ? 0.3 : 0
                     animations:^{
                         _coverView.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)removeCoverViewAnimated:(BOOL)animated{
    
    [UIView animateWithDuration:animated ? 0.6 : 0
                     animations:^{
                         _coverView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [self.coverView removeFromSuperview];
                        self.coverView = nil;
                     }];
}

- (void)updateCoverViewFrames{
    _coverView.frame = CGRectMake(0, CGRectGetMaxY(_searchBar.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(_searchBar.frame));
}

#pragma mark _______________________ Privat Methods ________________________

- (void)updateSpecials{
    self.specialsView.items = [NSArray arrayWithArray:[ProximityKitManager shared].compaignArray];
}


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
    searchRequest.location = [[CLLocation alloc] initWithLatitude:42.283215 longitude:-71.123029];
    searchRequest.city = [SearchManager shared].city;
    searchRequest.state = [SearchManager shared].state;
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
        
        [self.tableView.infiniteScrollingView stopAnimating];
        [self.tableView.pullToRefreshView stopAnimating];
        //[_quiltView.infiniteScrollingView stopAnimating];
        
        if (_page == 1) {
            self.collectionArray = [NSMutableArray new];
            //[self.quiltView reloadData];
            [self.tableView reloadData];
            
            _homeHorisontalListView.tableArray = _collectionArray;
            [_homeHorisontalListView.collectionView setContentOffset:CGPointZero animated:NO];
            [_homeHorisontalListView reloadData];

        }
        
        if (request.objects.count > 0) {
            [_collectionArray addObjectsFromArray:request.objects];
            _page ++;
        }
        
        _homeHorisontalListView.tableArray = _collectionArray;
        [_homeHorisontalListView reloadData];
        //[_quiltView reloadData];
        [self.tableView reloadData];
        
        self.searchOperation = nil;

    } failure:^(id _request, NSError *error) {
        NSLog(@"Fail: %@", error);
         [self hideSpinnerWithName:@""];
        
        //[_quiltView.infiniteScrollingView stopAnimating];
        [self.tableView.infiniteScrollingView stopAnimating];
        [self.tableView.pullToRefreshView stopAnimating];
        
        _page = 1;
        self.collectionArray = [NSMutableArray new];
        _homeHorisontalListView.tableArray = _collectionArray;
        [_homeHorisontalListView reloadData];

        //[_quiltView reloadData];
        [_tableView reloadData];
        NSLog(@"error: %@", error);
        self.searchOperation = nil;
    }];
}


- (void)setSearchOperation:(AFHTTPRequestOperation *)searchOperation{
    //[_searchOperation cancel];
    _searchOperation = searchOperation;
}


- (void)onClickWithItemDict:(NSDictionary*)itemDict{
    
    if (_screenState == ScreenStateItem) {
        ProductDetailsVC *vc = [[ProductDetailsVC alloc] initWithProduct:itemDict];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else{
        StoreDetailsVC* storeDetailsVC = [StoreDetailsVC loadFromXIBForScrrenSizes];
        storeDetailsVC.storeDict = itemDict;
        [self.navigationController pushViewController:storeDetailsVC animated:YES];
    }
}

- (void) horisontalListViewdidScrollToEnd: (HomeHorisontalListView *) listView {
    [self searchRequest];
}


- (void)showStoreWithId:(NSNumber*)storeId{
    
    [self loadStore:storeId comletion:^(NSDictionary* storeInfo, NSError* error){
        if (error == nil) {
            StoreDetailsVC* storeDetailsVC = [StoreDetailsVC loadFromXIBForScrrenSizes];
            storeDetailsVC.storeDict = storeInfo;
            [self.navigationController pushViewController:storeDetailsVC animated:YES];
        }else{
            [[AlertManager shared] showOkAlertWithTitle:error.localizedDescription];
        }
    }];
}

- (void)loadStore:(NSNumber*)storeId comletion:(void(^)(NSDictionary* storeInfo, NSError* error))completion{
    
    
    LoadStoreRequest *storeRequest = [[LoadStoreRequest alloc] init];
    storeRequest.storeId = storeId;
    
    
    [self showSpinnerWithName:@""];
    [[MMServiceProvider sharedProvider] sendRequest:storeRequest success:^(LoadStoreRequest *request) {
        [self hideSpinnerWithName:@""];
        NSLog(@"store: %@", request.storeDetails);
        
        completion(request.storeDetails, nil);
        
    } failure:^(LoadStoreRequest *request, NSError *error) {
        [self hideSpinnerWithName:@""];
        NSLog(@"Error: %@", error);
        completion(nil, error);
    }];
    
}


- (void)callAction:(NSDictionary*)store {
    
    NSString* phone = [store safeStringObjectForKey:@"phone"];
    if ([phone isKindOfClass:[NSNull class]] || ![phone isValidate]) {
        
        [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
        }
                                               title:@"A number has not been provided for this store yet"
                                             message:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
        
    }else{
        
        NSString* messageString = [NSString stringWithFormat:@"Call %@ at %@?", [[store safeDictionaryObjectForKey:@"user"] safeStringObjectForKey:@"name"], phone];
        
        [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (alertView.cancelButtonIndex != buttonIndex) {
                    [self callToAction:phone];
            }
        }
                                               title:messageString
                                             message:nil
                                   cancelButtonTitle:@"Cancel"
                                   otherButtonTitles:@"Call", nil];
        
    }
}

- (void)callToAction:(NSString*)phone {
    
    phone = [phone stringByReplacingOccurrencesOfString:@"(" withString:@""];
    phone = [phone stringByReplacingOccurrencesOfString:@")" withString:@""];
    phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *telLink = [NSString stringWithFormat:@"tel://%@", phone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telLink]];
}


- (void)loadStoreInfoForProduct:(NSDictionary*)product
                  comletion:(void(^)(NSDictionary* storeDetails))completion{
    
    
    LoadStoreRequest *storeRequest = [[LoadStoreRequest alloc] init];
    storeRequest.storeId = [product safeNSNumberObjectForKey:@"store_id"];
    
    
    [self showSpinnerWithName:@""];
    [[MMServiceProvider sharedProvider] sendRequest:storeRequest success:^(LoadStoreRequest *request) {
        [self hideSpinnerWithName:@""];
        NSLog(@"store: %@", request.storeDetails);
        
        completion(request.storeDetails);
        
    } failure:^(LoadStoreRequest *request, NSError *error) {
        [self hideSpinnerWithName:@""];
        NSLog(@"Error: %@", error);
        completion(nil);
    }];
    
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

- (void)cameraButtinCliced:(UIButton*)button{

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
    
    if (self.searchTypeView.hideTriger) {
        self.searchTypeView.hideTriger = NO;
        [self.searchTypeView selectStorefronts];
    }
    
    [self.coverView scrollOutAnimated:YES];
    [self removeCoverViewAnimated:YES];
    
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
            
            cell.didClickStoreButton = ^(HomeItemCell* cell, UIButton* sender, NSDictionary* productDict){
                [self showStoreWithId:[productDict safeNumberObjectForKey:@"store_id"]];
            };
            
            cell.didClickPriceButton = ^(HomeItemCell* cell, UIButton* sender, NSDictionary* productDict){
                //[self showStoreWithId:[productDict safeNumberObjectForKey:@"store_id"]];
                
                [self showSpinnerWithName:@""];
                [self loadStoreInfoForProduct:productDict
                                    comletion:^(NSDictionary *storeDetails) {
                                        [self hideSpinnerWithName:@""];
                                        [self callAction:storeDetails];
                                    }];
            };
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


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return tableView.frame.size.width / 3 + 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
        NSInteger count = [_collectionArray count];
        NSInteger temp = count % 3;
        NSInteger rowsCount = count / 3;
        if (temp > 0) {
            rowsCount++;
        }
        return rowsCount;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ProductCell* cell = [self productCellForIndexPath:indexPath];
    return cell;
}

- (ProductCell*)productCellForIndexPath:(NSIndexPath*)indexPath{
    ProductCell *cell = [_tableView dequeueReusableCellWithIdentifier:kProductCellIdentifier];
    
    if (cell == nil){
        cell = [ProductCell loadViewFromXIB];
        //cell.transform = CGAffineTransformMake(0.0f, 1.0f, 1.0f, 0.0f, 0.0f, 0.0f);
        
        cell.didClickAtIndex = ^(NSInteger selectedIndex){
            //NSDictionary* itemDict = [_collectionArray safeDictionaryObjectAtIndex:selectedIndex];
            
            if (_screenState == ScreenStateItem) {
                
                ProductDetailsVC *vc = [ProductDetailsVC loadFromXIBForScrrenSizes];
                vc.productsArray = _collectionArray;
                vc.index = selectedIndex;

                [self.navigationController pushViewController:vc animated:YES];
                
            }else if (_screenState == ScreenStateStore){
                StoreDetailsVC* storeDetailsVC = [StoreDetailsVC loadFromXIBForScrrenSizes];
                storeDetailsVC.storesArray = _collectionArray;
                storeDetailsVC.index = selectedIndex;
                //storeDetailsVC.storeDict = itemDict;
                [self.navigationController pushViewController:storeDetailsVC animated:YES];
            }
        };
    }
    
    // Configure the cell...
    
    NSInteger index = indexPath.row * 3;
    
    if ([_collectionArray count] > index) {
        NSDictionary* object = [_collectionArray safeDictionaryObjectAtIndex:index];
        NSString* imageUrl = nil;
        
        imageUrl = [[object safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
        
        if (_screenState == ScreenStateStore) {
            cell.firstView.textLabel.text = [object safeStringObjectForKey:@"name"];
            //cell.firstView.backgroundColor = [UIColor whiteColor];
        }else if(_screenState == ScreenStateItem){
            cell.firstView.textLabel.text = @"";
            //cell.firstView.backgroundColor = [UIColor clearColor];
        }
        
        [cell.firstView setImageURLString:imageUrl];
        cell.firstView.hidden = NO;
        
    }else{
        cell.firstView.hidden = YES;
    }
    cell.firstView.coverButton.tag = index;
    
    if ([_collectionArray count] > index + 1) {
        NSDictionary* object = [_collectionArray safeDictionaryObjectAtIndex:index + 1];
        NSString* imageUrl = nil;
        
        imageUrl = [[object safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
        if (_screenState == ScreenStateStore) {
            cell.secondView.textLabel.text = [object safeStringObjectForKey:@"name"];
            //cell.secondView.backgroundColor = [UIColor whiteColor];
        }else if(_screenState == ScreenStateItem){
            cell.secondView.textLabel.text = @"";
            //cell.secondView.backgroundColor = [UIColor clearColor];
        }
        
        [cell.secondView setImageURLString:imageUrl];
        cell.secondView.hidden = NO;
    }else{
        cell.secondView.hidden = YES;
    }
    cell.secondView.coverButton.tag = index + 1;
    
    if ([_collectionArray count] > index + 2) {
        NSDictionary* object = [_collectionArray safeDictionaryObjectAtIndex:index + 2];
        NSString* imageUrl = nil;
        
        imageUrl = [[object safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
        if (_screenState == ScreenStateStore) {
            cell.thirdView.textLabel.text = [object safeStringObjectForKey:@"name"];
            //cell.thirdView.backgroundColor = [UIColor whiteColor];
        }else if(_screenState == ScreenStateItem){
            cell.thirdView.textLabel.text = @"";
            //cell.thirdView.backgroundColor = [UIColor clearColor];
        }
        
        [cell.thirdView setImageURLString:imageUrl];
        cell.thirdView.hidden = NO;
    }else{
        cell.thirdView.hidden = YES;
    }
    cell.thirdView.coverButton.tag = index + 2;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark _______________________ Public Methods ________________________
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


- (void)didReceiveCampaignNotification:(NSNotification*)notification{
    [self updateSpecials];
}

- (void)didChangeCommunityNotification:(NSNotification*)notification{
    [self setupNavigationTitle];
    [self startSearch];
}


@end
