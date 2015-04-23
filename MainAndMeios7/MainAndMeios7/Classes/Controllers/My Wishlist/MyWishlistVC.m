//
//  MyWishlistVC.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 14.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "MyWishlistVC.h"
#import "WishlistDetailsVC.h"
#import "ProductDetailsManager.h"

@interface MyWishlistVC ()

@end

@implementation MyWishlistVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton* menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setImage:[UIImage imageNamed:@"menu_button.png"] forState:UIControlStateNormal];
    menuButton.frame = CGRectMake(0, 0, 40, 40);
    [menuButton addTarget:self action:@selector(anchorRight) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *anchorLeftButton  = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    self.navigationItem.leftBarButtonItem = anchorLeftButton;
    

    __weak MyWishlistVC *wself = self;
    self.onSelectWishlistCallback = ^(NSDictionary *dict) {
        WishlistDetailsVC *vc = [WishlistDetailsVC loadFromXIB_Or_iPhone5_XIB];
        vc.wishlist = dict;
        [wself.navigationController pushViewController:vc animated:YES];
    };
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView beginUpdates];
    
    NSDictionary *wishlistToDelete = [self.items objectAtIndex:indexPath.row];
    
    [self.items removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self showSpinnerWithName:@"DeleteWishlist"];
    [ProductDetailsManager deleteWishlistInfoForUser:[CommonManager shared].userId productID:wishlistToDelete[@"id"] success:^(NSString *userId, NSArray *wishlists) {
        [self hideSpinnerWithName:@"DeleteWishlist"];
    } failure:^(NSString *userId, NSError *error, NSString *errorString) {
        [self hideSpinnerWithName:@"DeleteWishlist"];
    } exception:^(NSString *userId, NSString *exception) {
        [self hideSpinnerWithName:@"DeleteWishlist"];        
    }];
    
    [tableView endUpdates];
}

- (void) anchorRight {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

@end
