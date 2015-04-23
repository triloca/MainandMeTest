//
//  WishlistPickerVC.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.12.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "WishlistPickerVC.h"
#import "LoadAllWishistsRequest.h"
#import "CustomTitleView.h"
#import "WishlistCell.h"
#import "CreateWishlistRequest.h"
#import "ProductDetailsManager.h"
#import "FollowingsRequest.h"
#import "PeopleCell.h"
#import "ProductDetailsVC.h"
#import "JSON.h"
#import "NSURLConnectionDelegateHandler.h"


@interface WishlistPickerVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation WishlistPickerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_button"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_plus_button"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(addWishlistAction)];
    

    self.navigationItem.titleView = [[CustomTitleView alloc] initWithTitle:@"MY WISHLISTS" dropDownIndicator:NO clickCallback:^(CustomTitleView *titleView) {
    }];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"WishlistCell" bundle:nil] forCellReuseIdentifier:@"WishlistCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PeopleCell" bundle:nil] forCellReuseIdentifier:@"PeopleCell"];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor clearColor];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self
                            action:@selector(reload)
                  forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:self.refreshControl];
    
    self.items = [NSMutableArray new];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self loadWishlists];
}

- (void) reload {
    [self loadWishlists];
}

- (void) endRefreshing {
    [self.refreshControl endRefreshing];
}


- (void) loadFollowings {

    [self showSpinnerWithName:@""];
    
    FollowingsRequest *request = [FollowingsRequest new];
    request.userId = _userId;
    request.followableType = FollowableUser;
    
    [[MMServiceProvider sharedProvider] sendRequest:request success:^(FollowingsRequest *request) {
        NSArray* items = request.followings;
        [self.items addObjectsFromArray:items];
        [self loadTable];
        [self hideSpinnerWithName:@""];
    } failure:^(id _request, NSError *error) {
        [[AlertManager shared] showOkAlertWithTitle:@"Main and me" message:error.localizedDescription];
        [self loadTable];
       [self hideSpinnerWithName:@""];
    }];
}


- (void) loadWishlists {
//    LoadAllWishistsRequest *request = [[LoadAllWishistsRequest alloc] init];
//    request.userId = _userId;
    
//    [ProductDetailsManager loadWishlistInfoForUser:_userId
//                                           success:^(NSString *userId, NSArray *wishlist) {
//                                               
//                                           }
//                                           failure:^(NSString *userId, NSError *error, NSString *errorString) {
//                                               
//                                           }
//                                         exception:^(NSString *userId, NSString *exceptionString) {
//                                             
//                                         }];
//    
//    
//    return;
    [self showSpinnerWithName:@""];
    
    NSString* urlString =
    [NSString stringWithFormat:@"http://www.mainandme.com/api/v1/users/%@/product_lists?_token=%@", _userId, [CommonManager shared].apiToken];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:20];
    [request setHTTPMethod:@"GET"];
    
    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", returnString);
        id value = [returnString JSONValue];
       
        if ([value isKindOfClass:[NSArray class]]) {
            self.items = [value mutableCopy];
            [self loadTable];
            [self endRefreshing];
            //[self loadFollowings];
            [self hideSpinnerWithName:@""];
        }else{
            [[AlertManager shared] showOkAlertWithTitle:@"Error"];
            [self endRefreshing];
            //[self loadFollowings];
            [self hideSpinnerWithName:@""];
        }

        
    } failure:^(NSURLConnection *connection, NSError *error) {

        [[AlertManager shared] showOkAlertWithTitle:error.localizedDescription];
        [self loadFollowings];
        [self hideSpinnerWithName:@""];
        
    }eception:^(NSURLConnection *connection, NSString *exceptionMessage) {
        
        [[AlertManager shared] showOkAlertWithTitle:@"Error"];
        [self loadFollowings];
        [self hideSpinnerWithName:@""];
        
    }];
    
    NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:handler];
    [connection start];

    
//    [self showSpinnerWithName:@""];
//    [[MMServiceProvider sharedProvider] sendRequest:request success:^(id _req) {
//        self.items = [request.wishlist mutableCopy];
//        [self loadFollowings];
//        [self hideSpinnerWithName:@""];
//    } failure:^(id _req, NSError *error) {
//        [[AlertManager shared] showOkAlertWithTitle:@"Main and me" message:error.localizedDescription];
//        [self loadFollowings];
//        [self hideSpinnerWithName:@""];
//    }];
}

- (void) loadTable {
    [self.tableView reloadData];
    if (_items.count == 0) {
        [UIView animateWithDuration:0.3 animations:^() {
            _tableView.alpha = 0;
            _emptyView.alpha = 1;
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^() {
            _tableView.alpha = 1;
            _emptyView.alpha = 0;
        }];
    }
}

- (void) addWishlistAction {
    [self showWishlistAlert];
}


- (void) backAction: (id) sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showWishlistAlert{
    
    
    [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, UITextField *firstTextField, UITextField *secondTextField, NSInteger buttonIndex) {
        
        if (buttonIndex == 0) {
            if (firstTextField.text.length > 0) {
                [self createNewWishlistWithName:firstTextField.text];
            }
        }
        
    }
                                           title:@"Required"
                                         message:@"Please Enter Wishlist Name"
                                firstPlaceholder:@"<enter Wishlistname>"
                               secondPlaceholder:nil
                                  alertViewStyle:UIAlertViewStylePlainTextInput
                               cancelButtonTitle:@"Ok"
                               otherButtonTitles:@"Cancel", nil];
    
    
    //    [[AlertManager shared] showTextFieldAlertWithCallBack:^(UIAlertView *alertView, UITextField *textField, NSInteger buttonIndex) {
    //
    //        if (buttonIndex == 0) {
    //            if (textField.text.length > 0) {
    //                [self createNewWishlistWithName:textField.text];
    //            }
    //        }
    //    }
    //                                                    title:@"Required"
    //                                                  message:@"Please Enter Email"
    //                                              placeholder:@"<enter Wishlistname>"
    //                                                   active:YES
    //                                        cancelButtonTitle:@"Ok"
    //                                        otherButtonTitles:@"Cancel", nil];
    
}


- (void)createNewWishlistWithName:(NSString*)name{
    
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    
    [self showSpinnerWithName:@"MyWishlistViewController"];
    __weak WishlistPickerVC *wself = self;
    [ProductDetailsManager createWishlist:name
                                  success:^(NSDictionary *newWishlist){
                                      [wself hideSpinnerWithName:@"MyWishlistViewController"];
                                      [wself.tableView beginUpdates];
                                      [wself.items addObject:newWishlist];
                                      [wself.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_items.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                                      [wself.tableView endUpdates];

//
//                                      [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                                      }
//                                                                             title:@"Success"
//                                                                           message:@"Wishlist created successfully"
//                                                                 cancelButtonTitle:@"Ok"
//                                                                 otherButtonTitles:nil];
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

#pragma mark - TableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}



- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary* item = [_items safeDictionaryObjectAtIndex:indexPath.row];
    
    if ([item.allKeys containsObject:@"user_followings_count"]){
        PeopleCell *cell = (PeopleCell *) [tableView dequeueReusableCellWithIdentifier:@"PeopleCell"];
        [cell setUser:_items[indexPath.row]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
        
    }else{
        WishlistCell *cell = (WishlistCell *) [tableView dequeueReusableCellWithIdentifier:@"WishlistCell"];
        cell.titleLabel.text = _items[indexPath.row][@"name"];
        return cell;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary* item = [_items safeDictionaryObjectAtIndex:indexPath.row];
    
    if ([item.allKeys containsObject:@"user_followings_count"]){
        //[self wishlistActionForId:[item safeStringObjectForKey:@"id"]];
    }else{
        if (self.onSelectWishlistCallback) {
            self.onSelectWishlistCallback(_items[indexPath.row]);
        }
    }
}


- (void)wishlistActionForId:(NSString*)userId {
    
    WishlistPickerVC *picker = [WishlistPickerVC loadFromXIB_Or_iPhone5_XIB];
    picker.userId = userId;
    picker.onSelectWishlistCallback = ^(NSDictionary *dict) {
//        if (dict == nil) {
//            [[AlertManager shared] showOkAlertWithTitle:@"MAIN AND ME" message:@"Unable to load wishlists. Please try again later"];
//            return ;
//        } else {
//            __weak WishlistPickerVC *wself = self;
//            [self showSpinnerWithName:@"Loading"];
//            [ProductDetailsManager addToWishlist:dict[@"id"] productId:_product[@"id"] success:^() {
//                [[AlertManager shared] showOkAlertWithTitle:@"Product was added to wishlist successfully"];
//                [wself hideAllSpiners];
//            } failure:^(NSError *error, NSString *errorString) {
//                
//                if ([errorString isEqualToString:@"This product is already added to this wishlist."]) {
//                    errorString = @"You already added this item to this wish list";
//                }
//                [[AlertManager shared] showOkAlertWithTitle:errorString];
//                
//                
//                [wself hideAllSpiners];
//            } exception:^(NSString *exeptionString) {
//                [[AlertManager shared] showOkAlertWithTitle:@"Error occured while adding item to wishlist. Please try again later"];
//                [wself hideAllSpiners];
//            }];
//            //            AddToWishlistRequest *request = [[AddToWishlistRequest alloc] init];
//            //            request.wishlistId = dict[@"id"];
//            //            request.productId = _product[@"id"];
//            //
//            //            __weak ProductDetailsVC *wself = self;
//            //            [[MMServiceProvider sharedProvider] sendRequest:request success:^(id _request) {
//            //                [[AlertManager shared] showOkAlertWithTitle:@"Product was added to wishlist successfully"];
//            //                [wself hideAllSpiners];
//            //            } failure:^(id _request, NSError *error) {
//            //                [[AlertManager shared] showOkAlertWithTitle:@"Error occured while adding item to wishlist. Please try again later"];
//            //                [wself hideAllSpiners];
//            //            }];
//        }
    };
    
    [self.navigationController pushViewController:picker animated:YES];
}

@end
