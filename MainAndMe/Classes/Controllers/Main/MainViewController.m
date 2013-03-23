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


typedef enum {
    ControllerStateStores = 0,
    ControllerStateProducts
} ControllerState;


static NSString *kProductCellIdentifier = @"ProductCell";
static NSString *kPageCellIdentifier = @"PageCell";
static NSString *kStorePageCellIdentifier = @"StorePageCell";

@interface MainViewController ()
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *storefrontButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *itemsButton;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *recentButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *popularButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *randomButton;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *toggleButton;
@property (assign, nonatomic) BOOL isPageStile;

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
    
    _pageTableProfileArray = [NSMutableArray new];
    _isNeedRefresh = NO;
    
     _controllerState = ControllerStateStores;
    _isPageStile = NO;
    
    [self showOveralyView];
    [_storefrontButton setBackgroundImage:[_storefrontButton backgroundImageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted | UIControlStateSelected];
    [_itemsButton setBackgroundImage:[_itemsButton backgroundImageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted | UIControlStateSelected];
    [_storefrontButton setTitleColor:[_storefrontButton titleColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted | UIControlStateSelected];
    [_itemsButton setTitleColor:[_itemsButton titleColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted | UIControlStateSelected];
    
    _storefrontButton.titleLabel.font = [UIFont fontWithName:@"Perec-SuperNegra" size:16];
    _itemsButton.titleLabel.font = [UIFont fontWithName:@"Perec-SuperNegra" size:16];
    _addressLabel.font = [UIFont fontWithName:@"Perec-SuperNegra" size:22];
    
    [_recentButton setTitleColor:[_recentButton titleColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted | UIControlStateSelected];
    [_popularButton setTitleColor:[_popularButton titleColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted | UIControlStateSelected];
    [_randomButton setTitleColor:[_randomButton titleColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted | UIControlStateSelected];
    
    
    self.refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [self.refreshControl addTarget:self action:@selector(refreshCurrentList:) forControlEvents:UIControlEventValueChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdateLocation:)
                                                 name:kUNDidUpdateLocetionNotification
                                               object:nil];

    _barTriangleImageView.hidden = YES;

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_isNeedRefresh) {
        [self refreshCurrentList:nil];
    }
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
                             [[LocationManager shared] updateLocation];
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
    
    [self searchWithSearchType:SearchTypeStores searchFilter:SearchFilterNone];
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
    
    [self searchWithSearchType:SearchTypeProducts searchFilter:SearchFilterNone];
    [self moveTriangleToPosition:214];
}

- (IBAction)recentButtonDown:(id)sender {
    _recentButton.selected = YES;
    _popularButton.selected = NO;
    _randomButton.selected = NO;
    
    [self moveTriangleToPosition:28];
    
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
    }else{
        [_toggleButton setImage:[UIImage imageNamed:@"grid_button@2x.png"] forState:UIControlStateNormal];
        _isPageStile = YES;
        _tableView.hidden = YES;
        _pageTableView.hidden = NO;
    }
    [self reloadNeededTable];
}

- (IBAction)titleButtonClicked:(id)sender {
    AddressViewController* addressViewController = [AddressViewController new];
    [self.navigationController pushViewController:addressViewController animated:YES];
}

- (IBAction)searchButtonClicked:(id)sender {
    SearchViewController* searchViewController = [SearchViewController new];
    [self.navigationController pushViewController:searchViewController animated:YES];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _tableView) {
        return 108;
    }else{
        return 385;
    }
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
        
        if (_controllerState == ControllerStateStores) {
            imageUrl = [[object safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
        }else if(_controllerState == ControllerStateProducts){
            imageUrl = [[object safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
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
        
        if (_controllerState == ControllerStateStores) {
            imageUrl = [[object safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
        }else if(_controllerState == ControllerStateProducts){
            imageUrl = [[object safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
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
        
        if (_controllerState == ControllerStateStores) {
            imageUrl = [[object safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
        }else if(_controllerState == ControllerStateProducts){
            imageUrl = [[object safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
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
    
    [self searchWithSearchType:[ProductsStoresManager shared].lastSearchType
                  searchFilter:[ProductsStoresManager shared].lastSearchFilter];
    [self.refreshControl endRefreshing];
}

- (void)searchWithSearchType:(SearchType)type searchFilter:(SearchFilter)filter{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ProductsStoresManager searchWithSearchType:type
                                   searchFilter:filter
                                        success:^(NSArray *objects) {
                                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                            
                                            if (type == SearchTypeStores) {
                                                _controllerState = ControllerStateStores;
                                            }else{
                                                _controllerState = ControllerStateProducts;
                                            }
                                            _objectsArray = objects;
                                            
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
                                            _objectsArray = [NSArray new];
                                            
                                            [self reloadNeededTable];
                                            
                                        }exception:^(NSString *exceptionString) {
                                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                            [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                        }];
}

- (void)reloadNeededTable{
    if (_isPageStile) {
        self.pageTableArray = _objectsArray;
        [_pageTableView reloadData];
    }else{
        _tableArray = _objectsArray;
        [_tableView reloadData];
    }

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
    [self setTitleText:@"Loading..."];
    [self loadLocationName];
}

- (void)loadLocationName{
    
    [ProductsStoresManager loadPlaceInfo:[LocationManager shared].defaultLocation.coordinate.latitude
                                 lngnear:[LocationManager shared].defaultLocation.coordinate.longitude
                                 success:^(NSString* name, NSString* prefix) {
                                     
                                     NSString* title = [NSString stringWithFormat:@"%@, %@",
                                                        name, prefix];
                                     [self setTitleText:title];
                                     
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
    if (rc.size.width > 250){
        rc.size.width = 250;
    }
    rc.origin.x = (self.view.frame.size.width - rc.size.width) / 2;
    _addressLabel.frame = rc;
    
    CGRect rc2 = _triagleImageView.frame;
    rc2.origin.x = CGRectGetMaxX(rc);
    _triagleImageView.frame = rc2;
}

@end
