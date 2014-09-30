//
//  SearchViewController.m
//  MainAndMe
//
//  Created by Sasha on 3/15/13.
//
//

#import "SearchViewController.h"
#import "SearchCell.h"
#import "UIView+Common.h"
#import "WishlistCell.h"
#import "SearchManager.h"
#import "AlertManager.h"
#import "SearchDetailsViewController.h"
#import "ProductCell.h"
#import "ProductDetailViewController.h"
#import "StoreDetailViewController.h"
#import "ProductsStoresManager.h"
#import <CoreLocation/CoreLocation.h>
#import "LocationManager.h"

static NSString *kProductCellIdentifier = @"ProductCell";

@interface SearchViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;

@property (strong, nonatomic) NSArray* tableArray;
@property (strong, nonatomic) NSArray* categoriesArray;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

@property (strong, nonatomic) NSArray* searchArray;
@property (strong, nonatomic) NSArray* itemsArray;

@property (assign, nonatomic) BOOL isKeyBoardVisible;
@property (assign, nonatomic) BOOL isAllCategories;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *searchSpinerView;

@end

@implementation SearchViewController

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.screenName = @"Search screen";

    
    //_titleTextLabel.font = [UIFont fontWithName:@"Perec-SuperNegra" size:22];
    if (_isStoreState) {
        _titleTextLabel.font = [UIFont fontWithName:@"Perec-SuperNegra" size:20];
        _titleTextLabel.text = @"Search Category or Store";
    }else{
        _titleTextLabel.font = [UIFont fontWithName:@"Perec-SuperNegra" size:20];
        _titleTextLabel.text = @"Search Category or Product";
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    _isAllCategories = NO;
    [self loadCategories];
    
//    if (_isStoreState) {
//        [self searchWithSearchType:SearchTypeStores searchFilter:SearchFilterNone];
//    }else{
//        [self searchWithSearchType:SearchTypeProducts searchFilter:SearchFilterNone];
//    }

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_tableView reloadData];
}

- (void)viewDidUnload {
    [self setTitleTextLabel:nil];
    [self setTableView:nil];
    [self setSearchTextField:nil];
    [self setSearchSpinerView:nil];
    [super viewDidUnload];
}

#pragma mark - Buttons Action
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    switch (indexPath.section) {
        case 0:
        case 1:
            return 44;
            break;
        case 2:{
            if (_isStoreState) {
                return 144;
            }else{
                return 108;
            }
            
            break;
        }
            
        default:
            break;
    }
    return 44;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    switch (section) {
        case 0:{
            if (_isAllCategories) {
                return 1;
            }else{
                return 0;
            }
            break;
        }
        case 1:{
            return [_tableArray count];
            break;
        }
        case 2:{
            NSInteger count = [_itemsArray count];
            NSInteger temp = count % 3;
            NSInteger rowsCount = count / 3;
            if (temp > 0) {
                rowsCount++;
            }
            return rowsCount;

            break;
        }
            
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kSearchCellIdentifier = @"SearchCell";
    
    if (indexPath.section == 0 || indexPath.section == 1) {
        SearchCell *cell = [tableView dequeueReusableCellWithIdentifier:kSearchCellIdentifier];

        if (cell == nil){
            cell = [SearchCell loadViewFromXIB];
        }
        
        // Configure the cell...
        
        if (indexPath.section == 0) {
            cell.nameLabel.text = @"All Categories";
        }else{
            NSDictionary* object = [_tableArray safeDictionaryObjectAtIndex:indexPath.row];
            cell.nameLabel.text = [object safeStringObjectForKey:@"name"];
        }

        return cell;
    
    }else{
        ProductCell* cell = [self productCellForIndexPath:indexPath];
        return cell;
    }
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 || indexPath.section == 1) {
         SearchDetailsViewController* searchDetailsViewController = [SearchDetailsViewController loadFromXIB_Or_iPhone5_XIB];
        if (indexPath.section == 0) {
            searchDetailsViewController.isAllState = YES;
        }else{
            NSDictionary* object = [_tableArray safeDictionaryObjectAtIndex:indexPath.row];
            searchDetailsViewController.categoryInfo = object;
            searchDetailsViewController.isAllState = NO;
        }
        searchDetailsViewController.isStoreState = _isStoreState;
        [_searchTextField resignFirstResponder];
        [self.navigationController pushViewController:searchDetailsViewController animated:YES];
    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
   
}


#pragma mark - TextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldDidBeginEditing");
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldEndEditing");
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if ([textField.text length] > 0) {

    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)didChangeValue:(UITextField*)sender {
    if (sender.text.length > 0) {
        _isAllCategories = NO;
    }else{
        _isAllCategories = YES;
    }
    [self applyFilterWith:sender.text];
    //[self applyItemsFilterWith:sender.text];
    if (_isStoreState) {
        [self searchStoreByKeyWord:_searchTextField.text];
    }else{
        [self searchProductByKeyWord:_searchTextField.text];
    }
}


#pragma mark - Privat Methods

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


- (void)loadCategories{
    [self showSpinnerWithName:@"SearchViewController"];
    [SearchManager loadCcategiriesSuccess:^(NSArray *categories) {
        [self hideSpinnerWithName:@"SearchViewController"];
        _categoriesArray = categories;
        _isAllCategories = YES;
        [self applyFilterWith:@""];
        
    }
                                  failure:^(NSError *error, NSString *errorString) {
                                      [self hideSpinnerWithName:@"SearchViewController"];
                                      [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                          message:errorString];
                                  }
                                exception:^(NSString *exceptionString) {
                                    [self hideSpinnerWithName:@"SearchViewController"];
                                    [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                }];
}

- (void)updateContentSize{// to privat
    
    if (_isKeyBoardVisible) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rc = _tableView.frame;
            rc.size.height -= 160;
            _tableView.frame = rc;
            
        } completion:^(BOOL finished) {
            
        }];
    }else{
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rc = _tableView.frame;
            rc.size.height += 160;
            _tableView.frame = rc;
            
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)applyFilterWith:(NSString*)name{
    
    if ([name isEqualToString:@""]) {
        _tableArray = _categoriesArray;
        [_tableView reloadData];
        return;
    }
    
    NSMutableArray* filterdMutableArray = [NSMutableArray array];
    
    
    
    NSArray *searchNames = [[name lowercaseString]componentsSeparatedByString: @" "];
    NSString *firstSearchName = [[searchNames objectAtIndex: 0] lowercaseString];
    NSString *secondSearchName =nil;
    if(searchNames.count>1)secondSearchName =[[searchNames objectAtIndex: 1] lowercaseString];
    
    
    
    for (NSDictionary* friend in _categoriesArray) {
        
        NSString* fixedName =[[friend objectForKey:@"name"] stringByReplacingOccurrencesOfString:@"  " withString:@" "];//some names are separated by double space :(
        
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

- (void)applyItemsFilterWith:(NSString*)name{
    
    if ([name isEqualToString:@""]) {
        _itemsArray = _searchArray;
        [_tableView reloadData];
        return;
    }
    
    NSMutableArray* filterdMutableArray = [NSMutableArray array];
    
    NSArray *searchNames = [[name lowercaseString]componentsSeparatedByString: @" "];
    NSString *firstSearchName = [[searchNames objectAtIndex: 0] lowercaseString];
    NSString *secondSearchName =nil;
    if(searchNames.count>1)secondSearchName =[[searchNames objectAtIndex: 1] lowercaseString];
    
    
    
    for (NSDictionary* friend in _searchArray) {
        
        NSString* fixedName =[[friend objectForKey:@"name"] stringByReplacingOccurrencesOfString:@"  " withString:@" "];//some names are separated by double space :(
        
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
    _itemsArray = [NSArray arrayWithArray:filterdMutableArray];
    [_tableView reloadData];
    
}


- (ProductCell*)productCellForIndexPath:(NSIndexPath*)indexPath{
    ProductCell *cell = [_tableView dequeueReusableCellWithIdentifier:kProductCellIdentifier];
    
    if (cell == nil){
        cell = [ProductCell loadViewFromXIB];
        //cell.transform = CGAffineTransformMake(0.0f, 1.0f, 1.0f, 0.0f, 0.0f, 0.0f);
        
        cell.didClickAtIndex = ^(NSInteger selectedIndex){
            NSDictionary* itemData = [_itemsArray safeDictionaryObjectAtIndex:selectedIndex];
            
            if (_isStoreState) {
                [self showStoreDetailWithData:itemData];
            }else{
                [self showProductDetailsWithData:itemData];
            }
        };
    }
    
    // Configure the cell...
    
    NSInteger index = indexPath.row * 3;
    
    if ([_itemsArray count] > index) {
        NSDictionary* object = [_itemsArray safeDictionaryObjectAtIndex:index];
        NSString* imageUrl = nil;
        
        imageUrl = [[object safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
        if (_isStoreState) {
            cell.firstView.textLabel.text = [object safeStringObjectForKey:@"name"];
            cell.firstView.backgroundColor = [UIColor whiteColor];
        }else{
            cell.firstView.textLabel.text = @"";
            cell.firstView.backgroundColor = [UIColor clearColor];
        }
        
        [cell.firstView setImageURLString:imageUrl];
        cell.firstView.hidden = NO;
        
    }else{
        cell.firstView.hidden = YES;
    }
    cell.firstView.coverButton.tag = index;
    
    if ([_itemsArray count] > index + 1) {
        NSDictionary* object = [_itemsArray safeDictionaryObjectAtIndex:index + 1];
        NSString* imageUrl = nil;
        
        imageUrl = [[object safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
        if (_isStoreState) {
            cell.secondView.textLabel.text = [object safeStringObjectForKey:@"name"];
            cell.secondView.backgroundColor = [UIColor whiteColor];
        }else{
            cell.secondView.textLabel.text = @"";
            cell.secondView.backgroundColor = [UIColor clearColor];
        }
        [cell.secondView setImageURLString:imageUrl];
        cell.secondView.hidden = NO;
    }else{
        cell.secondView.hidden = YES;
    }
    cell.secondView.coverButton.tag = index + 1;
    
    if ([_itemsArray count] > index + 2) {
        NSDictionary* object = [_itemsArray safeDictionaryObjectAtIndex:index + 2];
        NSString* imageUrl = nil;
        
        imageUrl = [[object safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
        if (_isStoreState) {
            cell.thirdView.textLabel.text = [object safeStringObjectForKey:@"name"];
            cell.thirdView.backgroundColor = [UIColor whiteColor];
        }else{
            cell.thirdView.textLabel.text = @"";
            cell.thirdView.backgroundColor = [UIColor clearColor];
        }
        [cell.thirdView setImageURLString:imageUrl];
        cell.thirdView.hidden = NO;
    }else{
        cell.thirdView.hidden = YES;
    }
    cell.thirdView.coverButton.tag = index + 2;
    
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

- (void)searchWithSearchType:(SearchType)type searchFilter:(SearchFilter)filter{
    
    [self showSpinnerWithName:@"SearchViewCntroller"];
    [ProductsStoresManager searchWithSearchType:type
                                   searchFilter:filter
                                           page:1
                                        success:^(NSArray *objects) {
                                            [self hideSpinnerWithName:@"SearchViewCntroller"];

                                            _searchArray = objects;
                                            [self applyItemsFilterWith:@""];
                                            
                                        }
                                        failure:^(NSError *error, NSString *errorString) {
                                            [self hideSpinnerWithName:@"SearchViewCntroller"];
                                            [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                                message:errorString];
                                            
                                            _searchArray = [NSArray array];
                                            [self applyItemsFilterWith:@""];
                                        }exception:^(NSString *exceptionString) {
                                            [self hideSpinnerWithName:@"SearchViewCntroller"];
                                            [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                        }];
}

- (void)searchProductByKeyWord:(NSString*)key{
    [[SearchManager shared] cancelSearch];
    
    if (key.length == 0) {
        _itemsArray = [NSArray array];
        [_searchSpinerView stopAnimating];
        [_tableView reloadData];
        return;
    }
    
    [_searchSpinerView startAnimating];
    [_tableView reloadData];

    [SearchManager loadProductsForKey:key
                              success:^(NSArray *objects) {
                                  [_searchSpinerView stopAnimating];
                                  _itemsArray = [self filterByLocation:objects];
                                  [_tableView reloadData];
                              }
                              failure:^(NSError *error, NSString *errorString) {
                                  [_searchSpinerView stopAnimating];
                                  [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                      message:errorString];
                              }
                            exception:^(NSString *exceptionString) {
                                [_searchSpinerView stopAnimating];
                                [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                            }];
}


- (void)searchStoreByKeyWord:(NSString*)key{
    [[SearchManager shared] cancelSearch];
    
    if (key.length == 0) {
        _itemsArray = [NSArray array];
        [_searchSpinerView stopAnimating];
        [_tableView reloadData];
        return;
    }
    
    [_searchSpinerView startAnimating];
    [_tableView reloadData];
    
    [SearchManager loadStoresForKey:key
                              success:^(NSArray *objects) {
                                  [_searchSpinerView stopAnimating];
                                  _itemsArray = [self filterByLocation:objects];
                                  [_tableView reloadData];
                              }
                              failure:^(NSError *error, NSString *errorString) {
                                  [_searchSpinerView stopAnimating];
                                  [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                      message:errorString];
                              }
                            exception:^(NSString *exceptionString) {
                                [_searchSpinerView stopAnimating];
                                [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                            }];
}


#pragma mark - Keyboard Notificastion

- (void)keyboardWillShow:(NSNotification*)nitif{
    _isKeyBoardVisible = YES;
    [self updateContentSize];
}


- (void)keyboardWillHide:(NSNotification*)nitif{
    _isKeyBoardVisible = NO;
    [self updateContentSize];
}

@end
