//
//  SearchDetailsViewController.m
//  MainAndMe
//
//  Created by Sasha on 3/19/13.
//
//

static NSString *kProductCellIdentifier = @"ProductCell";
static NSString *kStorePageCellIdentifier = @"StorePageCell";

#import "MyLikesViewController.h"
#import "ProductCell.h"
#import "UIView+Common.h"
#import "StorePageCell.h"
#import "PageCell.h"
#import "ProductDetailsManager.h"
#import "StoreDetailViewController.h"
#import "SearchManager.h"
#import "AlertManager.h"
#import "MBProgressHUD.h"
#import "DataManager.h"
#import "ProductDetailViewController.h"

@interface MyLikesViewController ()
@property (strong, nonatomic) NSArray* tableArray;
@property (strong, nonatomic) NSArray* pageTableArray;
@property (strong, nonatomic) NSMutableArray* pageTableProfileArray;
@property (strong, nonatomic) NSArray* objectsArray;
@property (weak, nonatomic) IBOutlet UIButton *toggleButton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *pageTableView;

@property (assign, nonatomic) BOOL isPageStile;
@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;
@end

@implementation MyLikesViewController

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

#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = @"My Likes screen";

    // Do any additional setup after loading the view from its nib.
   
    _titleTextLabel.font = [UIFont fontWithName:@"Perec-SuperNegra" size:22];
    _titleTextLabel.text = @"My Likes";
   
    _isPageStile = NO;
    
    _pageTableProfileArray = [NSMutableArray new];
    _isNeedRefresh = NO;
    
    _pageTableView.hidden = YES;

    [self loadLikeForProducts];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_isNeedRefresh) {
       // [self refreshCurrentList:nil];
    }
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setToggleButton:nil];
    [self setTitleTextLabel:nil];
    [super viewDidUnload];
}

#pragma mark - Buttons Action
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)toggleButtonClicked:(id)sender {
    return;
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
        StorePageCell* cell = [self storePageCellForIndexPath:indexPath];
        return cell;
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
    
            [self showProductDetailsWithData:itemData];
        };
    }
    
    // Configure the cell...
    
    NSInteger index = indexPath.row * 3;
    
    if ([_tableArray count] > index) {
        NSDictionary* object = [_tableArray safeDictionaryObjectAtIndex:index];
        NSString* imageUrl = nil;
        
        imageUrl = [[object safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
        
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
        
        [cell.thirdView setImageURLString:imageUrl];
        cell.thirdView.hidden = NO;
    }else{
        cell.thirdView.hidden = YES;
    }
    cell.thirdView.coverButton.tag = index + 2;
    
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


- (void)reloadNeededTable{
    if (_isPageStile) {
        self.pageTableArray = _objectsArray;
        [_pageTableView reloadData];
    }else{
        _tableArray = _objectsArray;
        [_tableView reloadData];
    }
}

- (void)loadStoresForCategory{

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [SearchManager loadStoresForCategory:[[_categoryInfo safeNumberObjectForKey:@"id"] stringValue]
                             success:^(NSArray *objects) {
                                 [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                 
                                 _objectsArray = objects;
                                 [self reloadNeededTable];
                             }
                             failure:^(NSError *error, NSString *errorString) {
                                 [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                 [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                     message:errorString];
                             }
                           exception:^(NSString *exceptionString) {
                               [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                               [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                           }];
}

- (void)loadStoresForAllCategory{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [SearchManager loadStoresForAllCategoryWithSuccess:^(NSArray *objects) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        _objectsArray = objects;
        [self reloadNeededTable];
    }
                                               failure:^(NSError *error, NSString *errorString) {
                                                   [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                   [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                                       message:errorString];
                                               }
                                             exception:^(NSString *exceptionString) {
                                                 [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                 [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                             }];
}


- (void)loadLikeForProducts{
   
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [SearchManager loadProductLikesForUser:[DataManager shared].userId
                                   success:^(NSArray *objects) {
                                       [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                       _tableArray = objects;
                                       [_tableView reloadData];
                                   }
                                   failure:^(NSError *error, NSString *errorString) {
                                       [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                       [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                           message:errorString];
                                   }
                                 exception:^(NSString *exceptionString) {
                                     [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                     [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                 }];

}

- (void)setPageTableArray:(NSArray *)pageTableArray{
    _pageTableArray = pageTableArray;
    [_pageTableProfileArray removeAllObjects];
    for (id obj in pageTableArray) {
        [_pageTableProfileArray addObject:@""];
    }
}

@end
