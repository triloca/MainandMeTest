//
//  SearchDetailsViewController.m
//  MainAndMe
//
//  Created by Sasha on 3/19/13.
//
//

#import "MyNotificationsViewController.h"
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
#import "NotificationManager.h"
#import "WishlistCell.h"
#import "StoreDetailsManager.h"

@interface MyNotificationsViewController ()
@property (strong, nonatomic) NSArray* tableArray;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;
@end

@implementation MyNotificationsViewController

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
    // Do any additional setup after loading the view from its nib.
   
    _titleTextLabel.font = [UIFont fontWithName:@"Perec-SuperNegra" size:22];
    _titleTextLabel.text = @"My Notifications";
   
   // [self loadLikeForProducts];
    
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_isNeedRefresh) {
       // [self refreshCurrentList:nil];
    }
    [self loadNotifications];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setTitleTextLabel:nil];
    [super viewDidUnload];
}

#pragma mark - Buttons Action
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_tableArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kWishlistCellIdentifier = @"WishlistCell";
    
    WishlistCell *cell = [tableView dequeueReusableCellWithIdentifier:kWishlistCellIdentifier];
    
    if (cell == nil){
        cell = [WishlistCell loadViewFromXIB];
    }
    
    // Configure the cell...
    NSDictionary* object = [_tableArray safeDictionaryObjectAtIndex:indexPath.row];
    
    cell.nameLabel.text = [NSString stringWithFormat:@"New %@",[object safeStringObjectForKey:@"notifiable_type"]];
    
    NSDate* date = [DataManager dateFromString:[object safeStringObjectForKey:@"created_at"]];
    cell.agoLabel.text = [DataManager howLongAgo:date];
    
    return cell;
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary* object = [_tableArray safeDictionaryObjectAtIndex:indexPath.row];
    NSNumber* product_id = [object safeNumberObjectForKey:@"product_id"];
    NSNumber* store_id = [object safeNumberObjectForKey:@"store_id"];
    
    if ([[object safeStringObjectForKey:@"notifiable_type"] isEqualToString:@"Follow"]) {
        [self showRemoveAlertFro:object];
        return;
    }
    
    if ([store_id intValue] > 0) {
        [self loadStoreById:[store_id stringValue]];
    }
    if ([product_id intValue] > 0) {
        [self loadProductById:[product_id stringValue]];
    }

}


#pragma mark - Privat Method

- (void)loadStoreById:(NSString*)storeId{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [StoreDetailsManager loadStoreByStoreId:storeId
                                    success:^(NSDictionary* store) {
                                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                        [self showStoreDetailWithData:store];
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

- (void)loadProductById:(NSString*)productId{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [StoreDetailsManager loadProductByProductId:productId
                                        success:^(NSDictionary* product) {
                                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                            [self showProductDetailsWithData:product];
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

- (void)loadNotifications{
   
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [NotificationManager loadNotificationsWithSuccess:^(NSArray *notif) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        _tableArray =  notif;
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


- (void)showRemoveAlertFro:(NSDictionary*)obj{
    [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
        [self removeNotificationFor:obj];
    }
                                           title:@"Message"
                                         message:@"You have one more folower"
                               cancelButtonTitle:@"Ok"
                               otherButtonTitles:nil];
}

- (void)removeNotificationFor:(NSDictionary*)object{

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [NotificationManager removeNotificationsById:[object safeNumberObjectForKey:@"id"]
                                         success:^(id obj) {
                                             [self loadNotifications];
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


@end
