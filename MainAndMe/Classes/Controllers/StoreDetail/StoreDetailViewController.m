//
//  StoreDetailViewController.m
//  MainAndMe
//
//  Created by Sasha on 3/15/13.
//
//

#import "StoreDetailViewController.h"
#import "ProductDetailsManager.h"
#import "StoreDetailsManager.h"
#import "UIView+Common.h"
#import "CommentCell.h"
#import "StoreDetailsCell.h"
#import "MBProgressHUD.h"
#import "AlertManager.h"
#import "DataManager.h"
#import "ProductCell.h"
#import "ProductDetailViewController.h"
#import "StoreMapViewController.h"

static NSString *kProductCellIdentifier = @"ProductCell";


@interface StoreDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray* tableArray;

@property (strong, nonatomic) StoreDetailsCell* storeDetailsCell;

@end

@implementation StoreDetailViewController

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
    _titleTextLabel.font = [UIFont fontWithName:@"Perec-SuperNegra" size:22];
    _titleTextLabel.text = @"Store details";
    
    _storeDetailsCell = [StoreDetailsCell loadViewFromXIB];
    
    NSString* imageUrl = [[_storeInfo safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"full"];
    [_storeDetailsCell setProductImageURLString:imageUrl];
    
    _storeDetailsCell.postedByLabel.text = [_storeInfo safeStringObjectForKey:@"name"];
    _storeDetailsCell.storeNameLabel.text = [_storeInfo safeStringObjectForKey:@"street"];
    
    NSDate* date = [DataManager dateFromString:[_storeInfo safeStringObjectForKey:@"created_at"]];
    _storeDetailsCell.agoLabel.text = [DataManager howLongAgo:date];
    
    BOOL is_following = [[_storeInfo safeNumberObjectForKey:@"is_following"] boolValue];
    
    if (is_following) {
        _storeDetailsCell.followImageView.hidden = NO;
    }else{
        _storeDetailsCell.followImageView.hidden = YES;
    }

    [_storeDetailsCell.mapButton addTarget:self
                                    action:@selector(mapButtonClicked:)
                          forControlEvents:UIControlEventTouchUpInside];
  //  [self loadProfileInfo];
  //  [self loadWithlist];
    [self loadProducts];
    
}

- (void)viewDidUnload {
    [self setTitleTextLabel:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}

#pragma mark - Buttons Action
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)mapButtonClicked:(UIButton*)sender{
    StoreMapViewController* storeMapViewController = [StoreMapViewController new];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[_storeInfo safeNumberObjectForKey:@"lat"] floatValue],
                                                                   [[_storeInfo safeNumberObjectForKey:@"lng"] floatValue]);
    storeMapViewController.coordinate = coordinate;
    [self.navigationController pushViewController:storeMapViewController animated:YES];
}



#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 368;
    }else{
        return 108;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    NSInteger count = [_tableArray count];
    NSInteger temp = count % 3;
    NSInteger rowsCount = count / 3;
    if (temp > 0) {
        rowsCount++;
    }
    return rowsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return _storeDetailsCell;
    }else if (indexPath.section == 1){
        
        ProductCell* cell = [self productCellForIndexPath:indexPath];
        return cell;
        
    }
    return [[UITableViewCell alloc] init];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


#pragma mark - Privat Methods

- (ProductCell*)productCellForIndexPath:(NSIndexPath*)indexPath{
    ProductCell *cell = [_tableView dequeueReusableCellWithIdentifier:kProductCellIdentifier];
    
    if (cell == nil){
        cell = [ProductCell loadViewFromXIB];
        //cell.transform = CGAffineTransformMake(0.0f, 1.0f, 1.0f, 0.0f, 0.0f, 0.0f);
        
        cell.didClickAtIndex = ^(NSInteger selectedIndex){
            
            NSDictionary* itemData = [_tableArray safeDictionaryObjectAtIndex:selectedIndex];
            [self showProductDetailsWithInfo:itemData];
        };
    }
    
    // Configure the cell...
    
    NSInteger index = indexPath.row * 3;
    
    if ([_tableArray count] > index) {
        
        NSDictionary* object = [_tableArray safeDictionaryObjectAtIndex:index];
        NSString* imageUrl = [[object safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
        
        [cell.firstView setImageURLString:imageUrl];
        cell.firstView.hidden = NO;
    }else{
        cell.firstView.hidden = YES;
    }
    cell.firstView.coverButton.tag = index;
    
    if ([_tableArray count] > index + 1) {
        NSDictionary* object = [_tableArray safeDictionaryObjectAtIndex:index + 1];
        NSString* imageUrl = [[object safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
        [cell.secondView setImageURLString:imageUrl];
        cell.secondView.hidden = NO;
    }else{
        cell.secondView.hidden = YES;
    }
    cell.secondView.coverButton.tag = index + 1;
    
    if ([_tableArray count] > index + 2) {
        NSDictionary* object = [_tableArray safeDictionaryObjectAtIndex:index + 2];
        NSString* imageUrl = [[object safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
        [cell.thirdView setImageURLString:imageUrl];
        cell.thirdView.hidden = NO;
    }else{
        cell.thirdView.hidden = YES;
    }
    cell.thirdView.coverButton.tag = index + 2;
    
    return cell;
}


- (void)showProductDetailsWithInfo:(NSDictionary*)data{
    
    ProductDetailViewController* productDetailViewController = [ProductDetailViewController loadFromXIB_Or_iPhone5_XIB];
    productDetailViewController.productInfo = data;
    [self.navigationController pushViewController:productDetailViewController animated:YES];
    
}

- (void)loadProfileInfo{
    
    [self showSpinnerWithName:@"ProductDetailViewController"];
    
    [ProductDetailsManager loadProfileInfoForUserIdNumber:[_storeInfo safeNumberObjectForKey:@"user_id"]
                                                  success:^(NSNumber *userIdNumber, NSDictionary *profile) {
                                                      [self hideSpinnerWithName:@"ProductDetailViewController"];
                                                      _storeDetailsCell.postedByLabel.text = [NSString
                                                                                                stringWithFormat:@"Posted By %@ in", [profile safeStringObjectForKey:@"name"]];
                                                      [_storeDetailsCell setPersonImageURLString:[profile safeStringObjectForKey:@"avatar_url"]];
                                                  }
                                                  failure:^(NSNumber *userIdNumber, NSError *error, NSString *errorString) {
                                                      [self hideSpinnerWithName:@"ProductDetailViewController"];
                                                      [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                                          message:errorString];
                                                  }
                                                exception:^(NSNumber *userIdNumber, NSString *exceptionString) {
                                                    [self hideSpinnerWithName:@"ProductDetailViewController"];
                                                    [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                                }];
    
}

- (void)loadProducts{
    
    [self showSpinnerWithName:@"ProductDetailViewController"];
    [StoreDetailsManager loadProductsForStore:[[_storeInfo safeNumberObjectForKey:@"id"] stringValue]
                                      success:^(NSArray *products) {
                                          [self hideSpinnerWithName:@"ProductDetailViewController"];
                                          _tableArray = products;
                                          [_tableView reloadData];
                                      }
                                      failure:^(NSError *error, NSString *errorString) {
                                          [self hideSpinnerWithName:@"ProductDetailViewController"];
                                          [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                              message:errorString];
                                      }
                                    exception:^(NSString *exceptionString) {
                                        [self hideSpinnerWithName:@"ProductDetailViewController"];
                                        [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                    }];
    
}

@end
