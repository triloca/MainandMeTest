//
//  ProductDetailViewController.m
//  MainAndMe
//
//  Created by Sasha on 3/15/13.
//
//

#import "MyWishlistViewController.h"
#import "UIView+Common.h"
#import "ProductDetailsManager.h"
#import "MBProgressHUD.h"
#import "AlertManager.h"
#import "DataManager.h"
#import "ReachabilityManager.h"
#import "LayoutManager.h"
#import "WishlistCell.h"
#import "WishlistDetailsViewController.h"

@interface MyWishlistViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray* tableArray;


@end

@implementation MyWishlistViewController

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
    
    self.screenName = @"My Wishlist screen";

    _titleTextLabel.font = [UIFont fontWithName:@"Perec-SuperNegra" size:22];
    _titleTextLabel.text = @"My Wishlists";
    
//    NSDate* date = [DataManager dateFromString:[_productInfo safeStringObjectForKey:@"created_at"]];
//    [DataManager howLongAgo:date];
    
//    if (![ReachabilityManager isReachable]) {
//        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
//        return;
//    }
    
//    [self loadProfileInfo];
    [self loadWithlist];
       
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_tableView reloadData];
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

- (IBAction)addButtonClicked:(id)sender {
    [self showWishlistAlert];
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
    
    cell.nameLabel.text = [object safeStringObjectForKey:@"name"];
    
    NSDate* date = [DataManager dateFromString:[object safeStringObjectForKey:@"created_at"]];
    cell.agoLabel.text = [DataManager howLongAgo:date];
    
    return cell;
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:   (UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary* obj = [_tableArray safeDictionaryObjectAtIndex:indexPath.row];
        [_tableArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil]   withRowAnimation:UITableViewRowAnimationFade];
        [self deleteWishlist:[[obj safeNumberObjectForKey:@"id"] stringValue]];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    WishlistCell* cell = (WishlistCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.agoLabel.hidden = YES;
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView
didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    WishlistCell* cell = (WishlistCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.agoLabel.hidden = NO;

    [tableView reloadData];
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//        if (buttonIndex == 0) {
//            NSDictionary* object = [_tableArray safeDictionaryObjectAtIndex:indexPath.row];
//            [self addToWishlist:object];
//        }
//    }
//                                           title:@"Add product to selected wishlist?"
//                                         message:nil
//                               cancelButtonTitle:@"Add"
//                               otherButtonTitles:@"Cancel", nil];

    WishlistDetailsViewController* wishlistDetailsViewController = [WishlistDetailsViewController loadFromXIB_Or_iPhone5_XIB];
    
    NSDictionary* object = [_tableArray safeDictionaryObjectAtIndex:indexPath.row];
    wishlistDetailsViewController.wishlistInfo = object;
    [self.navigationController pushViewController:wishlistDetailsViewController animated:YES];
}


#pragma mark - Privat Methods

- (void)loadWithlist{
    
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }

    [self showSpinnerWithName:@"WishlistViewController"];
    [ProductDetailsManager loadWishlistInfoForUser:[DataManager shared].userId
                                           success:^(NSString *userId, NSArray *wishlists) {
                                               [self hideSpinnerWithName:@"WishlistViewController"];
                                               _tableArray = [NSMutableArray arrayWithArray:[self sortWishlist:wishlists]];
                                               [_tableView reloadData];
                                               
                                           }
                                           failure:^(NSString *userId, NSError *error, NSString *errorString) {
                                               [self hideSpinnerWithName:@"WishlistViewController"];
                                               [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                                   message:errorString];
                                           }
                                         exception:^(NSString *userId, NSString *exceptionString) {
                                             [self hideSpinnerWithName:@"WishlistViewController"];
                                             [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                         }];
    
}

- (void)deleteWishlist:(NSString*)wishlistId{

    [self showSpinnerWithName:@"WishlistViewController"];
    [ProductDetailsManager deleteWishlistInfoForUser:[DataManager shared].userId
                                           productID:wishlistId
                                             success:^(NSString *userId, NSArray *wishlist) {
                                                 [self hideSpinnerWithName:@"WishlistViewController"];
                                                 [[AlertManager shared] showOkAlertWithTitle:@"Success"
                                                                                     message:@"Wishlist deleted"];
                                             }
                                             failure:^(NSString *userId, NSError *error, NSString *errorString) {
                                                 [self hideSpinnerWithName:@"WishlistViewController"];
                                                 [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                                     message:errorString];
                                                 [self loadWithlist];
                                             }
                                           exception:^(NSString *userId, NSString *exceptionString) {
                                               [self hideSpinnerWithName:@"WishlistViewController"];
                                               [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                           }];
}

- (void)addToWishlist:(NSDictionary*)wishlist{
   
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
   
    [self showSpinnerWithName:@"WishlistViewController"];
    [ProductDetailsManager addToWishlist:[[wishlist safeNumberObjectForKey:@"id"] stringValue]
                               productId:[[_productInfo safeNumberObjectForKey:@"id"] stringValue]
                                 success:^{
                                     [self hideSpinnerWithName:@"WishlistViewController"];
                                     
                                     [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                         [self.navigationController popViewControllerAnimated:YES];
                                     }
                                                                            title:@"Success"
                                                                          message:@"Item added successfully to wishlist"
                                                                cancelButtonTitle:@"Ok"
                                                                otherButtonTitles:nil];                                     
                                 }
                                 failure:^(NSError *error, NSString *errorString) {
                                     [self hideSpinnerWithName:@"WishlistViewController"];
                                     [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                         message:errorString];
                                 }
                               exception:^(NSString *exceptionString) {
                                   [self hideSpinnerWithName:@"WishlistViewController"];
                                   [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                               }];
}

- (NSArray*)sortWishlist:(NSArray*)wishlists{
    
    NSArray *sorteArray = [wishlists sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [a safeStringObjectForKey:@"name"];
        NSString *second = [b safeStringObjectForKey:@"name"];
        return [first caseInsensitiveCompare:second];
    }];

    return sorteArray;
}

- (void)showWishlistAlert{
    
    [[AlertManager shared] showTextFieldAlertWithCallBack:^(UIAlertView *alertView, UITextField *textField, NSInteger buttonIndex) {
        
        if (buttonIndex == 0) {
            if (textField.text.length > 0) {
                [self createNewWishlistWithName:textField.text];
            }
        }
    }
                                                    title:@"Required"
                                                  message:@"Please Enter Email"
                                              placeholder:@"<enter Wishlistname>"
                                                   active:YES
                                        cancelButtonTitle:@"Ok"
                                        otherButtonTitles:@"Cancel", nil];
    
}

- (void)createNewWishlistWithName:(NSString*)name{
    
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    
    [self showSpinnerWithName:@"MyWishlistViewController"];
    [ProductDetailsManager createWishlist:name
                                  success:^{
                                      [self hideSpinnerWithName:@"MyWishlistViewController"];
                                      
                                      [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                          [self loadWithlist];
                                      }
                                                                             title:@"Success"
                                                                           message:@"Wishlist created successfully"
                                                                 cancelButtonTitle:@"Ok"
                                                                 otherButtonTitles:nil];
                                  }
                                  failure:^(NSError *error, NSString *errorString) {
                                      [self hideSpinnerWithName:@"MyWishlistViewController"];
                                      [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                          message:errorString];
                                  }
                                exception:^(NSString *exceptionString) {
                                    [self hideSpinnerWithName:@"MyWishlistViewController"];
                                    [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                }];
    
}

@end
