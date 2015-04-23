//
//  WishlistDetailsVC.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.12.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "WishlistDetailsVC.h"
#import "CustomTitleView.h"
#import "HomeStoreCell.h"
#import "HomeItemCell.h"
#import "ProductDetailsVC.h"
#import "StoreDetailsVC.h"
#import "LoadWishlistDetailsRequest.h"
#import "ProductDetailsManager.h"
@interface WishlistDetailsVC ()

@property (weak, nonatomic) IBOutlet UIView *emptyWishlistView;
@property (weak, nonatomic) IBOutlet TMQuiltView *tmQuiltView;
@property (strong, nonatomic) NSMutableArray *items;
@end

@implementation WishlistDetailsVC 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[CustomTitleView alloc] initWithTitle:[_wishlist safeStringObjectForKey:@"name"] dropDownIndicator:NO clickCallback:nil];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_button"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];

    self.tmQuiltView.delegate = self;
    self.tmQuiltView.dataSource = self;
    [self loadItems];
}

- (void) deleteItemAtIndex: (NSInteger) index {
    __block TMQuiltViewCell *cell = [_tmQuiltView cellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    [UIView animateWithDuration:0.3 animations:^() {
        cell.alpha = 0;
    } completion:^(BOOL finished) {
        [_tmQuiltView beginUpdates];
        NSDictionary *item = _items[index];
        [_items removeObjectAtIndex:index];
        [_tmQuiltView deleteCellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        cell.alpha = 1;
        [_tmQuiltView endUpdates];
        [ProductDetailsManager deleteProduct:item[@"id"] inWishlist:_wishlist[@"id"] success:nil failure:nil exception:nil];
        
        if (_items.count == 0) {
            self.navigationItem.rightBarButtonItem = nil;
        }
        
    }];
}

- (void) editAction: (id) sender {
//    [self deleteItemAtIndex:0];
    [_tmQuiltView setEditing:!_tmQuiltView.editing animated:YES];
    
    if (_tmQuiltView.editing) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(editAction:)];

    }else{
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(editAction:)];
    }
}



- (void) backAction: (id) sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) loadItems {
    
    self.navigationItem.rightBarButtonItem = nil;
    [UIView animateKeyframesWithDuration:0.3 delay:0 options:0 animations:^() {
        _tmQuiltView.alpha = 0;
    } completion:nil];
    
    [self showSpinnerWithName:@""];
    LoadWishlistDetailsRequest *request = [[LoadWishlistDetailsRequest alloc] init];
    request.wishlistId = [_wishlist safeObjectForKey:@"id"];
    
    [[MMServiceProvider sharedProvider] sendRequest:request success:^(id _request) {
        
        if (request.wishlist.count > 0) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction:)];
        }else{
            self.navigationItem.rightBarButtonItem = nil;
        }
        
        self.items = [request.wishlist mutableCopy];
        [self reloadQuiltView];
        [self hideAllSpiners];
    } failure:^(id _request, NSError *error) {
        [self reloadQuiltView];
        [self hideAllSpiners];
    }];
}

- (void) reloadQuiltView {
    [_tmQuiltView reloadData];
    NSLog(@"Items count: %ld", self.items.count);
    
    if (self.items.count == 0) {
        [UIView animateKeyframesWithDuration:0.3 delay:0 options:0 animations:^() {
            _tmQuiltView.alpha = 0;
            _emptyWishlistView.alpha = 1;
        } completion:nil];
    } else {
        [UIView animateKeyframesWithDuration:0.3 delay:0 options:0 animations:^() {
            _tmQuiltView.alpha = 1;
            _emptyWishlistView.alpha = 0;
        } completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSDictionary *) storeForIndex: (NSUInteger) index {
    NSDictionary *dict = [_items safeDictionaryObjectAtIndex:index];
    if (![[dict safeObjectForKey:@"model_name"] isEqualToString:@"Store"])
        return nil;
    
    NSNumber* store_id = [dict safeNumberObjectForKey:@"store_id"];
    
    if ([store_id intValue] > 0) {
        return dict;
    }
    return nil;
}

- (NSDictionary *) productForIndex: (NSUInteger) index {
    NSDictionary *dict = [_items safeDictionaryObjectAtIndex:index];
    if (![[dict safeObjectForKey:@"model_name"] isEqualToString:@"Product"])
        return nil;
    
    return dict;
}

#pragma mark - TMQuiltViewDelegate


- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)TMQuiltView {
    return _items.count;
}

- (TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary* dict = [_items safeDictionaryObjectAtIndex:indexPath.row];
    
    //! Set cell type
    if ([self productForIndex:indexPath.row]) {
        HomeItemCell *cell = (HomeItemCell *)[quiltView dequeueReusableCellWithReuseIdentifier:@"HomeItemCell"];
        if (!cell) {
            cell = [HomeItemCell loadViewFromXIB];
            [cell setReuseIdentifier:@"HomeItemCell"];
        }
        cell.storeDict = dict;
        
        return cell;
        
    } else if ([self storeForIndex:indexPath.row]){
        HomeStoreCell *cell = (HomeStoreCell *)[quiltView dequeueReusableCellWithReuseIdentifier:@"HomeStoreCell"];
        if (!cell) {
            cell = [HomeStoreCell loadViewFromXIB];
            [cell setReuseIdentifier:@"HomeStoreCell"];
        }
        
        cell.storeDict = dict;
        
        return cell;
        
    }
    return nil;
}

- (void)quiltView:(TMQuiltView *)quiltView didSelectCellAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = [_items objectAtIndex:indexPath.row];
    
    if ([self storeForIndex:indexPath.row]) {
        StoreDetailsVC *vc = [StoreDetailsVC loadFromXIB_Or_iPhone5_XIB];
        vc.storeDict = dict;
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([self productForIndex:indexPath.row]) {
        ProductDetailsVC *vc = [ProductDetailsVC loadFromXIB_Or_iPhone5_XIB];
        vc.product = dict;
        [self.navigationController pushViewController:vc animated:YES];
    }
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
    
    NSDictionary* dict = [_items safeDictionaryObjectAtIndex:indexPath.row];
    CGFloat height = 0;
    
    if ([self storeForIndex:indexPath.row]) {
        height = [HomeStoreCell cellHeghtForStore:dict];
    } else if ([self productForIndex:indexPath.row]) {
        height = [HomeItemCell cellHeghtForStore:dict];
    }
    
    return height;
}

- (void) quiltView:(TMQuiltView *)quiltView commitEditingForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self deleteItemAtIndex:indexPath.row];
}

@end
