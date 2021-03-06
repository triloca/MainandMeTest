//
//  MainViewController.m
//  MainAndMe
//
//  Created by Sasha on 3/12/13.
//
//

#import "MainViewController.h"
#import "LoginSignUpManager.h"
#import "LayoutManager.h"
#import "OverlayView.h"
#import "UIView+Common.h"
#import "ProductCell.h"
#import "ProductHorizontalCell.h"
#import "ProductView.h"
#import "MBProgressHUD.h"
#import "ProductsStoresManager.h"
#import "AlertManager.h"
#import "UIImageView+UNNetworking.h"
#import "ODRefreshControl.h"
#import "PageCell.h"
#import "UILabel+Common.h"
#import "LocationManager.h"
#import "StoreDetailViewController.h"
#import "ProductDetailViewController.h"
#import "AddressViewController.h"
#import "SearchViewController.h"
#import "ProductDetailsManager.h"
#import "NSMutableArray+Safe.h"
#import "StorePageCell.h"
#import "LocationManager.h"
#import "NotificationManager.h"
#import "MNMBottomPullToRefreshManager.h"
#import "CommunityViewController.h"
#import "ProximityKitManager.h"

typedef enum {
    ControllerStateStores = 0,
    ControllerStateProducts
} ControllerState;


static NSString *kProductCellIdentifier = @"ProductCell";
static NSString *kPageCellIdentifier = @"PageCell";
static NSString *kStorePageCellIdentifier = @"StorePageCell";

@interface MainViewController () <MNMBottomPullToRefreshManagerClient>
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *storefrontButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *itemsButton;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *recentButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *popularButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *randomButton;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *toggleButton;
@property (assign, nonatomic) BOOL isPageStile;
@property (assign, nonatomic) NSInteger page;
@property (assign, nonatomic) NSInteger refreshingPage;

@property (assign, nonatomic) ControllerState controllerState;

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *pageTableView;

@property (strong, nonatomic) NSArray* tableArray;
@property (strong, nonatomic) NSArray* pageTableArray;
@property (strong, nonatomic) NSMutableArray* pageTableProfileArray;
@property (strong, nonatomic) NSArray* objectsArray;

@property (strong, nonatomic) ODRefreshControl* refreshControl;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *addressLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *triagleImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *titleButton;

@property (weak, nonatomic) IBOutlet UIImageView *barTriangleImageView;

@property (strong, nonatomic) MNMBottomPullToRefreshManager* pullToRefresh;


@end

@implementation MainViewController

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
    
    [UIImageView clearMemoryImageCache];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.screenName = @"Main screen";
    
    self.pullToRefresh = [[MNMBottomPullToRefreshManager alloc]
                          initWithPullToRefreshViewHeight:60.0f
                          tableView:_tableView
                          withClient:self];
    
    _page = 1;
    
    _pageTableProfileArray = [NSMutableArray new];
    _isNeedRefresh = NO;
    
     _controllerState = ControllerStateStores;
    _isPageStile = NO;
    
    
    [_storefrontButton setBackgroundImage:[_storefrontButton backgroundImageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted | UIControlStateSelected];
    [_itemsButton setBackgroundImage:[_itemsButton backgroundImageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted | UIControlStateSelected];
    [_storefrontButton setTitleColor:[_storefrontButton titleColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted | UIControlStateSelected];
    [_itemsButton setTitleColor:[_itemsButton titleColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted | UIControlStateSelected];
    
    _storefrontButton.titleLabel.font = [UIFont fontWithName:@"Perec-SuperNegra" size:16];
    _itemsButton.titleLabel.font = [UIFont fontWithName:@"Perec-SuperNegra" size:16];
    _addressLabel.font = [UIFont fontWithName:@"Perec-SuperNegra" size:20];
    _addressLabel.minimumFontSize = 15;
    
    [_recentButton setTitleColor:[_recentButton titleColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted | UIControlStateSelected];
    [_popularButton setTitleColor:[_popularButton titleColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted | UIControlStateSelected];
    [_randomButton setTitleColor:[_randomButton titleColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted | UIControlStateSelected];
    
    
    self.refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [self.refreshControl addTarget:self action:@selector(refreshCurrentList:) forControlEvents:UIControlEventValueChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdateLocation:)
                                                 name:kUNDidUpdateLocetionNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFailedUpdateLocation:)
                                                 name:kUNDidFailUpdateLocetionNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdateCommunity:)
                                                 name:kUNDidUpdateCommunityNotification
                                               object:nil];

    _barTriangleImageView.hidden = YES;
    
    _isNeedSendToken = YES;
    
    //! Check if user want change first community
    NSDictionary* communityDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"kCommunityInfo"];
    if (communityDict == nil) {
        [self showCommunityAlertIfNecessary];
    }else{
        [self storefrontButtonDown:nil];
    }
    
    NSString* title = [NSString stringWithFormat:@"%@, %@",
                       [LocationManager shared].communityStateName, [LocationManager shared].communityStatePrefix];
    
    [self setTitleText:title];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    _isJustExplore = NO;
    
    if (_isNeedRefresh) {
        _page = 1;
        [self refreshCurrentList:nil];
    }
    
    [self loadNotifications];
    
    if (_isNeedSendToken) {
        [self addDeviceToken];
        _isNeedSendToken = NO;
    }
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    [_pullToRefresh relocatePullToRefreshView];
}


- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setStorefrontButton:nil];
    [self setItemsButton:nil];
    [self setRecentButton:nil];
    [self setPopularButton:nil];
    [self setRandomButton:nil];
    [self setTableView:nil];
    [self setPageTableView:nil];
    [self setToggleButton:nil];
    [self setAddressLabel:nil];
    [self setTriagleImageView:nil];
    [self setTitleButton:nil];
    [self setBarTriangleImageView:nil];
    [super viewDidUnload];
}


- (void)showOveralyView{
    
    OverlayView* overalyView = [OverlayView loadViewFromXIB_or_iPhone5_XIB];
    __unsafe_unretained OverlayView* weak_overlyView = overalyView;
    
    overalyView.didClickOverlay = ^{
        [UIView animateWithDuration:0.3
                         animations:^{
                             weak_overlyView.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             [weak_overlyView removeFromSuperview];
                             [self storefrontButtonDown:nil];
                             //[[LocationManager shared] updateLocation];
                         }];
    };
    
    [[LayoutManager shared].appDelegate.window addSubview:overalyView];
}

#pragma mark - Buttons Action

- (IBAction)storefrontButtonDown:(UIButton*)sender {
    _storefrontButton.selected = YES;
    _itemsButton.selected = NO;
    
    _storefrontButton.titleLabel.shadowOffset = CGSizeMake(0, 0);
    _itemsButton.titleLabel.shadowOffset = CGSizeMake(1, 1);
    
    _recentButton.selected = NO;
    _popularButton.selected = NO;
    _randomButton.selected = NO;
    
    _page = 1;
    [self searchWithSearchType:SearchTypeStores searchFilter:SearchFilterRandom];
    [self moveTriangleToPosition:53];
}

- (IBAction)itemsButtonDown:(UIButton *)sender {
    _storefrontButton.selected = NO;
    _itemsButton.selected = YES;
    
    _storefrontButton.titleLabel.shadowOffset = CGSizeMake(1, 1);
    _itemsButton.titleLabel.shadowOffset = CGSizeMake(0, 0);
    
    _recentButton.selected = NO;
    _popularButton.selected = NO;
    _randomButton.selected = NO;
    
    _page = 1;
    [self searchWithSearchType:SearchTypeProducts searchFilter:SearchFilterRandom];
    [self moveTriangleToPosition:214];
}

- (IBAction)recentButtonDown:(id)sender {
    _recentButton.selected = YES;
    _popularButton.selected = NO;
    _randomButton.selected = NO;
    
    [self moveTriangleToPosition:28];
    
    _page = 1;
    
    if (_controllerState == ControllerStateStores) {
        
        [self searchWithSearchType:SearchTypeStores searchFilter:SearchFilterNewly];
        
    }else if (_controllerState == ControllerStateProducts) {
        
        [self searchWithSearchType:SearchTypeProducts searchFilter:SearchFilterNewly];
    }
}

- (IBAction)popularButtonDown:(id)sender {
    _recentButton.selected = NO;
    _popularButton.selected = YES;
    _randomButton.selected = NO;
    
    [self moveTriangleToPosition:135];
    
    _page = 1;
    
    if (_controllerState == ControllerStateStores) {
        
        [self searchWithSearchType:SearchTypeStores searchFilter:SearchFilterPopular];
        
    }else if (_controllerState == ControllerStateProducts) {
        
        [self searchWithSearchType:SearchTypeProducts searchFilter:SearchFilterPopular];
    }
}

- (IBAction)randomButtonDown:(id)sender {
    _recentButton.selected = NO;
    _popularButton.selected = NO;
    _randomButton.selected = YES;
    
    [self moveTriangleToPosition:242];
    
    _page = 1;
    
    if (_controllerState == ControllerStateStores) {
        
        [self searchWithSearchType:SearchTypeStores searchFilter:SearchFilterRandom];
        
    }else if (_controllerState == ControllerStateProducts) {
        
        [self searchWithSearchType:SearchTypeProducts searchFilter:SearchFilterRandom];
    }
}

- (IBAction)toggleButtonClicked:(id)sender {
    
    if (_isPageStile) {
        [_toggleButton setImage:[UIImage imageNamed:@"page_button@2x.png"] forState:UIControlStateNormal];
        _isPageStile = NO;
        _tableView.hidden = NO;
        _pageTableView.hidden = YES;

        self.pullToRefresh = [[MNMBottomPullToRefreshManager alloc]
                              initWithPullToRefreshViewHeight:60.0f
                              tableView:_tableView
                              withClient:self];

    }else{
        [_toggleButton setImage:[UIImage imageNamed:@"grid_button@2x.png"] forState:UIControlStateNormal];
        _isPageStile = YES;
        _tableView.hidden = YES;
        _pageTableView.hidden = NO;

        self.pullToRefresh = [[MNMBottomPullToRefreshManager alloc]
                              initWithPullToRefreshViewHeight:60.0f
                              tableView:_pageTableView
                              withClient:self];

    }
    [self reloadNeededTable];
    //[self refreshCurrentList:nil];
    [self searchWithSearchType:[ProductsStoresManager shared].lastSearchType
                  searchFilter:[ProductsStoresManager shared].lastSearchFilter];
}

- (IBAction)titleButtonClicked:(id)sender {
    
    AddressViewController* addressViewController = [AddressViewController loadFromXIB_Or_iPhone5_XIB];
    
    NSDictionary* communityDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"kCommunityInfo"];
    
    NSString* statePrefix = [communityDict safeStringObjectForKey:@"prefix"];
    NSString* stateName = [communityDict safeStringObjectForKey:@"name"];
    CommunityViewController* communityViewController = [CommunityViewController loadFromXIB_Or_iPhone5_XIB];
    communityViewController.statePrefix = statePrefix;
    communityViewController.stateName = stateName;

    
    NSMutableArray* controllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [controllers safeAddObject:addressViewController];
    self.navigationController.viewControllers = [NSArray arrayWithArray:controllers];
    
    [self.navigationController pushViewController:communityViewController animated:YES];
}

- (IBAction)searchButtonClicked:(id)sender {
    SearchViewController* searchViewController = [SearchViewController loadFromXIB_Or_iPhone5_XIB];
    searchViewController.isStoreState = _storefrontButton.selected;
    [self.navigationController pushViewController:searchViewController animated:YES];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _tableView) {
        
        if (_controllerState == ControllerStateStores) {
           return 144;
        }else if (_controllerState == ControllerStateProducts) {
          return 108;
        }
        
    }else{
        return 385;
    }
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == _tableView) {
        NSInteger count = [_tableArray count];
        NSInteger temp = count % 3;
        NSInteger rowsCount = count / 3;
        if (temp > 0) {
            rowsCount++;
        }
        return rowsCount;
   
    }else{
        return [_pageTableArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == _tableView) {
        ProductCell* cell = [self productCellForIndexPath:indexPath];
        return cell;
    }else{
        
        if (_controllerState == ControllerStateStores) {
            StorePageCell* cell = [self storePageCellForIndexPath:indexPath];
            return cell;
        
        }else if (_controllerState == ControllerStateProducts) {
            PageCell* cell = [self pageCellForIndexPath:indexPath];
            return cell;
        }
    }
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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
        [self loadNextPage:nil];
    });
}


#pragma mark - Privat Method

- (ProductCell*)productCellForIndexPath:(NSIndexPath*)indexPath{
    ProductCell *cell = [_tableView dequeueReusableCellWithIdentifier:kProductCellIdentifier];
    
    if (cell == nil){
        cell = [ProductCell loadViewFromXIB];
        //cell.transform = CGAffineTransformMake(0.0f, 1.0f, 1.0f, 0.0f, 0.0f, 0.0f);
        
        cell.didClickAtIndex = ^(NSInteger selectedIndex){
            NSDictionary* itemData = [_tableArray safeDictionaryObjectAtIndex:selectedIndex];
            
            if (_controllerState == ControllerStateStores) {
                [self showStoreDetailWithData:itemData];
            }else if(_controllerState == ControllerStateProducts){
                [self showProductDetailsWithData:itemData];
            }
        };
    }
    
    // Configure the cell...
    
    NSInteger index = indexPath.row * 3;
    
    if ([_tableArray count] > index) {
        NSDictionary* object = [_tableArray safeDictionaryObjectAtIndex:index];
        NSString* imageUrl = nil;
        
        imageUrl = [[object safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
        if (_controllerState == ControllerStateStores) {
            cell.firstView.textLabel.text = [object safeStringObjectForKey:@"name"];
            cell.firstView.backgroundColor = [UIColor whiteColor];
        }else if(_controllerState == ControllerStateProducts){
            cell.firstView.textLabel.text = @"";
            cell.firstView.backgroundColor = [UIColor clearColor];
        }
        
        if ([[NotificationManager shared] isContainId:[object safeNumberObjectForKey:@"id"]]) {
            cell.firstView.badgeImageView.hidden = NO;
        }else{
            cell.firstView.badgeImageView.hidden = YES;
        }
        
        [cell.firstView setImageURLString:imageUrl];
        cell.firstView.hidden = NO;
        
    }else{
        cell.firstView.hidden = YES;
    }
    cell.firstView.coverButton.tag = index;
    
    if ([_tableArray count] > index + 1) {
        NSDictionary* object = [_tableArray safeDictionaryObjectAtIndex:index + 1];
        NSString* imageUrl = nil;
        
        imageUrl = [[object safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
        if (_controllerState == ControllerStateStores) {
            cell.secondView.textLabel.text = [object safeStringObjectForKey:@"name"];
            cell.secondView.backgroundColor = [UIColor whiteColor];
        }else if(_controllerState == ControllerStateProducts){
            cell.secondView.textLabel.text = @"";
            cell.secondView.backgroundColor = [UIColor clearColor];
        }
        
        if ([[NotificationManager shared] isContainId:[object safeNumberObjectForKey:@"id"]]) {
            cell.secondView.badgeImageView.hidden = NO;
        }else{
            cell.secondView.badgeImageView.hidden = YES;
        }
        
        [cell.secondView setImageURLString:imageUrl];
        cell.secondView.hidden = NO;
    }else{
        cell.secondView.hidden = YES;
    }
    cell.secondView.coverButton.tag = index + 1;
    
    if ([_tableArray count] > index + 2) {
        NSDictionary* object = [_tableArray safeDictionaryObjectAtIndex:index + 2];
        NSString* imageUrl = nil;
        
        imageUrl = [[object safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
        if (_controllerState == ControllerStateStores) {
            cell.thirdView.textLabel.text = [object safeStringObjectForKey:@"name"];
            cell.thirdView.backgroundColor = [UIColor whiteColor];
        }else if(_controllerState == ControllerStateProducts){
            cell.thirdView.textLabel.text = @"";
            cell.thirdView.backgroundColor = [UIColor clearColor];
        }
        
        if ([[NotificationManager shared] isContainId:[object safeNumberObjectForKey:@"id"]]) {
            cell.thirdView.badgeImageView.hidden = NO;
        }else{
            cell.thirdView.badgeImageView.hidden = YES;
        }
        
        [cell.thirdView setImageURLString:imageUrl];
        cell.thirdView.hidden = NO;
    }else{
        cell.thirdView.hidden = YES;
    }
    cell.thirdView.coverButton.tag = index + 2;
    
    return cell;
}


- (PageCell*)pageCellForIndexPath:(NSIndexPath*)indexPath{
    
    PageCell *cell = [_pageTableView dequeueReusableCellWithIdentifier:kPageCellIdentifier];
    
    if (cell == nil){
        cell = [PageCell loadViewFromXIB];
        //cell.transform = CGAffineTransformMake(0.0f, 1.0f, 1.0f, 0.0f, 0.0f, 0.0f);
        }
    
    // Configure the cell...
    
    NSDictionary* object = [_pageTableArray safeDictionaryObjectAtIndex:indexPath.row];
    
    [cell setCellData:object];
    cell.tag = indexPath.row;
    
    id profileInfoObject = [_pageTableProfileArray safeObjectAtIndex:indexPath.row];
    if ([profileInfoObject isKindOfClass:[NSString class]]) {
        
        [ProductDetailsManager loadProfileInfoForUserIdNumber:[object safeNumberObjectForKey:@"user_id"]
                                                      success:^(NSNumber *userIdNumber, NSDictionary *profile) {
                                                          
                                                          NSNumber* cellUserNumber = [cell.cellData safeNumberObjectForKey:@"user_id"];
                                                          if ([cellUserNumber isEqual:userIdNumber]) {
                                                              [cell setCellProfileData:profile];
                                                              [_pageTableProfileArray safeReplaceObjectAtIndex:indexPath.row withObject:profile];
                                                          }
                                                      }
                                                      failure:^(NSNumber *userIdNumber, NSError *error, NSString *errorString) {
                                                          
                                                      }
                                                    exception:^(NSNumber *userIdNumber, NSString *exceptionString) {
                                                        
                                                        
                                                    }];
    }else if([profileInfoObject isKindOfClass:[NSDictionary class]]){
        [cell setCellProfileData:profileInfoObject];
    }
    
    cell.didClickAtIndex = ^(NSInteger selectedIndex){
       
        NSDictionary* itemData = [_pageTableArray safeDictionaryObjectAtIndex:selectedIndex];
        [self showProductDetailsWithData:itemData];
    };
    
    return cell;
}


- (StorePageCell*)storePageCellForIndexPath:(NSIndexPath*)indexPath{
    
    StorePageCell *cell = [_pageTableView dequeueReusableCellWithIdentifier:kStorePageCellIdentifier];
    
    if (cell == nil){
        cell = [StorePageCell loadViewFromXIB];
        //cell.transform = CGAffineTransformMake(0.0f, 1.0f, 1.0f, 0.0f, 0.0f, 0.0f);
    }
    
    // Configure the cell...
    
    NSDictionary* object = [_pageTableArray safeDictionaryObjectAtIndex:indexPath.row];
    
    [cell setCellData:object];
    cell.tag = indexPath.row;
    
    id profileInfoObject = [_pageTableProfileArray safeObjectAtIndex:indexPath.row];
    if ([profileInfoObject isKindOfClass:[NSString class]]) {
        
        [ProductDetailsManager loadProfileInfoForUserIdNumber:[object safeNumberObjectForKey:@"user_id"]
                                                      success:^(NSNumber *userIdNumber, NSDictionary *profile) {
                                                          
                                                          NSNumber* cellUserNumber = [cell.cellData safeNumberObjectForKey:@"user_id"];
                                                          if ([cellUserNumber isEqual:userIdNumber]) {
                                                              [cell setCellProfileData:profile];
                                                              [_pageTableProfileArray safeReplaceObjectAtIndex:indexPath.row withObject:profile];
                                                          }
                                                      }
                                                      failure:^(NSNumber *userIdNumber, NSError *error, NSString *errorString) {
                                                          
                                                      }
                                                    exception:^(NSNumber *userIdNumber, NSString *exceptionString) {
                                                        
                                                        
                                                    }];
    }else if([profileInfoObject isKindOfClass:[NSDictionary class]]){
        [cell setCellProfileData:profileInfoObject];
    }
    
    cell.didClickAtIndex = ^(NSInteger selectedIndex){
        NSDictionary* itemData = [_pageTableArray safeDictionaryObjectAtIndex:selectedIndex];

        [self showStoreDetailWithData:itemData];
    };
    
    return cell;
}


- (void)showStoreDetailWithData:(NSDictionary*)data {
    
//    [[ProximityKitManager shared] showIBeaconController:nil];
//    
//    return;
    StoreDetailViewController* storeDetailViewController = [StoreDetailViewController loadFromXIB_Or_iPhone5_XIB];
    storeDetailViewController.storeInfo = data;
    [self.navigationController pushViewController:storeDetailViewController animated:YES];
}

- (void)showProductDetailsWithData:(NSDictionary*)data{
    
    ProductDetailViewController* productDetailViewController = [ProductDetailViewController loadFromXIB_Or_iPhone5_XIB];
    productDetailViewController.productInfo = data;
    [self.navigationController pushViewController:productDetailViewController animated:YES];

}


- (void)refreshCurrentList:(id)refreshCurrentList {
//    [self searchWithSearchType:[ProductsStoresManager shared].lastSearchType
//                  searchFilter:[ProductsStoresManager shared].lastSearchFilter];
    _refreshingPage = 1;
    [self refreshToPage:_page];
    [self.refreshControl endRefreshing];
}

- (void)loadNextPage:(id)sender {
    _page++;
    [self searchWithSearchType:[ProductsStoresManager shared].lastSearchType
                  searchFilter:[ProductsStoresManager shared].lastSearchFilter];
    [self.refreshControl endRefreshing];
}

- (void)searchWithSearchType:(SearchType)type searchFilter:(SearchFilter)filter{
    
    if ([_objectsArray count] == 0) {
        _page = 1;
    }
    
    if (_page == 1) {
        _objectsArray = [NSArray array];
    }
    
    [ProductsStoresManager shared].lastSearchType = type;
    [ProductsStoresManager shared].lastSearchFilter = filter;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ProductsStoresManager searchWithSearchType:type
                                   searchFilter:filter
                                           page:_page
                                        success:^(NSArray *objects) {
                                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                            
                                            if (type == SearchTypeStores) {
                                                _controllerState = ControllerStateStores;
                                            }else{
                                                _controllerState = ControllerStateProducts;
                                            }
                                            [_pullToRefresh tableViewReloadFinished];
                                            NSMutableArray* temp = [NSMutableArray arrayWithArray:_objectsArray];
                                            [temp addObjectsFromArray:objects];
                                            _objectsArray = temp;
                                            
//                                            if (_objectsArray.count == 0) {
//                                                [self showAlert];
//                                            }
                                            
                                            [self reloadNeededTable];
                                            
                                        }
                                        failure:^(NSError *error, NSString *errorString) {
                                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                            [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                                message:errorString];
                                            
                                            if (type == SearchTypeStores) {
                                                _controllerState = ControllerStateStores;
                                            }else{
                                                _controllerState = ControllerStateProducts;
                                            }
                                            [_pullToRefresh tableViewReloadFinished];
                                            _objectsArray = [NSArray new];
                                            
                                            [self reloadNeededTable];
                                            
                                        }exception:^(NSString *exceptionString) {
                                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                            [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                            [_pullToRefresh tableViewReloadFinished];
                                        }];
}

- (void)showCommunityAlertIfNecessary{
    
    [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            [self showOveralyView];
        }else{
            [self titleButtonClicked:nil];
            _isNeedRefresh = YES;
        }
    }
                                           title:@"Roslindale, MA not your location? Tap below to find your city"
                                         message:nil
                               cancelButtonTitle:@"Continue"
                               otherButtonTitles:@"Find my city", nil];

}

- (void)showAlert{
    
    if (_isJustExplore) {
        _page = 1;
        
        if (_controllerState == ControllerStateStores) {
            [self searchWithSearchType:SearchTypeStores searchFilter:SearchFilterNewlyAll];
        }else{
            [self searchWithSearchType:SearchTypeProducts searchFilter:SearchFilterNewlyAll];
        }
        return;
    }
    
    [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            
            double delayInSeconds = 0.1;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [[LayoutManager shared].rootTabBarController loadPhotoButtonClicked:nil];
            });
            
        }else{
            _isJustExplore = YES;
            
            _page = 1;
            
            if (_controllerState == ControllerStateStores) {
                [self searchWithSearchType:SearchTypeStores searchFilter:SearchFilterNewlyAll];
            }else{
                [self searchWithSearchType:SearchTypeProducts searchFilter:SearchFilterNewlyAll];
            }
        
        }
    }
                                           title:@"Your town isn't online yet..."
                                         message:@"Be the first to add an item from an independent business"
                               cancelButtonTitle:@"Add an item"
                               otherButtonTitles:@"Just explore", nil];
    
}

- (void)refreshToPage:(NSInteger)page{
    
    if (_refreshingPage == 1) {
        _objectsArray = [NSArray array];
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ProductsStoresManager searchWithSearchType:[ProductsStoresManager shared].lastSearchType
                                   searchFilter:[ProductsStoresManager shared].lastSearchFilter
                                           page:_refreshingPage
                                        success:^(NSArray *objects) {
                                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                            
                                            if (_refreshingPage <= page) {
                                                _refreshingPage++;
                                                NSMutableArray* temp = [NSMutableArray arrayWithArray:_objectsArray];
                                                [temp addObjectsFromArray:objects];
                                                _objectsArray = temp;
                                                [self refreshToPage:page];
                                            }else{
                                                
                                                if ([ProductsStoresManager shared].lastSearchType == SearchTypeStores) {
                                                    _controllerState = ControllerStateStores;
                                                }else{
                                                    _controllerState = ControllerStateProducts;
                                                }
                                                
                                                _refreshingPage = 1;
                                                [_pullToRefresh tableViewReloadFinished];
                                                [self reloadNeededTable];
                                                _isNeedRefresh = NO;
                                            }
                                            
                                        }
                                        failure:^(NSError *error, NSString *errorString) {
                                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                            [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                                message:errorString];
                                            _refreshingPage = 1;
                                            if ([ProductsStoresManager shared].lastSearchType == SearchTypeStores) {
                                                _controllerState = ControllerStateStores;
                                            }else{
                                                _controllerState = ControllerStateProducts;
                                            }
                                            [_pullToRefresh tableViewReloadFinished];
                                            _objectsArray = [NSArray new];
                                            
                                            [self reloadNeededTable];
                                            
                                        }exception:^(NSString *exceptionString) {
                                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                            [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                            [_pullToRefresh tableViewReloadFinished];
                                        }];
}




- (void)reloadNeededTable{
    if (_isPageStile) {
        
        self.pageTableArray = [self sortObjects:_objectsArray];
        [_pageTableView reloadData];
    }else{
        
        _tableArray = [self sortObjects:_objectsArray];
        [_tableView reloadData];
    }

}


- (NSArray*)sortObjects:(NSArray*)array{
    if ([ProductsStoresManager shared].lastSearchFilter == SearchFilterPopular) {
        
        NSArray *sorteArray = [array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSInteger first = [[a safeNumberObjectForKey:@"like_count"] integerValue];
            NSInteger second = [[b safeNumberObjectForKey:@"like_count"] integerValue];
            return first < second;
        }];
        return sorteArray;
    }else if ([ProductsStoresManager shared].lastSearchFilter == SearchFilterNewly) {
        [self filterByLocation:array];
    }
    return array;
}

- (NSArray*)filterByLocation:(NSArray*)array{
    NSLog(@"%@", array);
    NSArray *sorteArray = [array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        CLLocation *first = [[CLLocation alloc] initWithLatitude:[[a safeNumberObjectForKey:@"lat"] floatValue]
                                                       longitude:[[a safeNumberObjectForKey:@"lng"] floatValue]];
        CLLocation *second = [[CLLocation alloc] initWithLatitude:[[b safeNumberObjectForKey:@"lat"] floatValue]
                                                        longitude:[[b safeNumberObjectForKey:@"lng"] floatValue]];
        
        CLLocation* defaultLocetion = [LocationManager shared].defaultLocation;
        CGFloat firstDistance = [defaultLocetion distanceFromLocation:first];
        CGFloat secondDistance = [defaultLocetion distanceFromLocation:second];
        return firstDistance < secondDistance;
    }];
    
    return sorteArray;
}

- (void)moveTriangleToPosition:(CGFloat)value{
    _barTriangleImageView.hidden = YES;//NO;
    [UIView animateWithDuration:0.3
                     animations:^{
                         CGRect rc = _barTriangleImageView.frame;
                         rc.origin.x = value;
                         _barTriangleImageView.frame = rc;
                        
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)setPageTableArray:(NSArray *)pageTableArray{
    _pageTableArray = pageTableArray;
    [_pageTableProfileArray removeAllObjects];
    for (id obj in pageTableArray) {
        [_pageTableProfileArray addObject:@""];
    }
}

- (void)didUpdateLocation:(NSNotification*)notif{
    //return;
    //[self setTitleText:@"Loading..."];
    
}

- (void)didUpdateCommunity:(NSNotification*)notif{
    [self loadLocationName];
}

- (void)didFailedUpdateLocation:(NSNotification*)notif{
    [self loadNearest];
}

- (void)loadLocationName{
    
    
    NSString* title = [NSString stringWithFormat:@"%@, %@",
                       [LocationManager shared].communityStateName, [LocationManager shared].communityStatePrefix];
    
    [self setTitleText:title];
    
    [self storefrontButtonDown:nil];
    return;
    
    _page = 1;
   [self refreshCurrentList:nil];
    
    return;
    [ProductsStoresManager loadPlaceInfo:[LocationManager shared].defaultLocation.coordinate.latitude
                                 lngnear:[LocationManager shared].defaultLocation.coordinate.longitude
                                 success:^(NSString* name, NSString* prefix) {
                                     
                                     [LocationManager shared].stateName = name;
                                     [LocationManager shared].statePrefix = prefix;
                                     
                                     NSString* title = [NSString stringWithFormat:@"%@, %@",
                                                        name, prefix];
                                     [self setTitleText:title];
                                     [self refreshCurrentList:nil];
                                 }
                                 failure:^(NSError *error, NSString *errorString) {
                                     NSString* text = @"Address not found";
                                     [self setTitleText:text];
                                 }exception:^(NSString *exceptionString) {
                                     [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                 }];
}


- (void)setTitleText:(NSString*)text{
    
    _addressLabel.text = text;
    [_addressLabel resizeToStretch];
    CGRect rc = _addressLabel.frame;
    if (rc.size.width > 220){
        rc.size.width = 220;
    }
    rc.origin.x = (self.view.frame.size.width - rc.size.width) / 2;
    rc.origin.x -= 7;
    _addressLabel.frame = rc;
    
    CGRect rc2 = _triagleImageView.frame;
    rc2.origin.x = CGRectGetMaxX(rc);
    _triagleImageView.frame = rc2;
    
    _addressLabel.text = text;
}

- (void)addDeviceToken{
    
    if ([NotificationManager shared].deviceToken.length == 0) {
        return;
    }
    
    [NotificationManager addDeviceToken:[NotificationManager shared].deviceToken
                                success:^(NSArray *obj) {
                                    
                                }
                                failure:^(NSError *error, NSString *errorString) {
                                    [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                        message:errorString];
                                }
                              exception:^(NSString *exceptionString) {
                                  [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                              }];
    

}

- (void)loadNotifications{
    
    [NotificationManager loadNotificationsWithSuccess:^(NSArray *notif) {
        [_tableView reloadData];
    }
                                              failure:^(NSError *error, NSString *errorString) {
                                              }
                                            exception:^(NSString *exceptionString) {
                                            }];
    
}


#pragma mark - Public Methods
- (void)loadNearest{
    [self recentButtonDown:_recentButton];
}
@end
