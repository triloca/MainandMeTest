//
//  ItemStoreVC.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 10/19/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ItemStoreVC.h"
#import "UIFont+All.h"
#import "TMQuiltView.h"
#import "HomeItemCell.h"
#import "LoadProductsRequest.h"
#import "CustomTitleView.h"
#import "LoadProductsByStoreRequest.h"
#import "ProductDetailsVC.h"
#import "HomeStoreCell.h"
#import "SearchView.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "FacebookSDK/FacebookSDK.h"
#import "TwitterManager.h"
#import "FollowStoreRequest.h"

#import "StoreMapViewController.h"
#import "SearchRequest.h"
#import "StoreDetailsVC.h"

#import "LoadProductsForCategory.h"
#import "LoadStoresForCategory.h"
#import "LoadStoresRequest.h"
#import "LoadProductsRequest.h"

#import "SearchManager.h"

@interface ItemStoreVC ()
<TMQuiltViewDataSource,
TMQuiltViewDelegate>

@property (strong, nonatomic) TMQuiltView *quiltView;
@property (strong, nonatomic) NSMutableArray* collectionArray;

@end

@implementation ItemStoreVC

#pragma mark _______________________ Class Methods _________________________
#pragma mark ____________________________ Init _____________________________

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc{

}
#pragma mark _______________________ View Lifecycle ________________________

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_button"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClicked)];
    

    [self setupNavigationTitle];
 
    [self setupCollection];
    
    
    self.collectionArray = [NSMutableArray new];
    
    if (_isAllCategories) {
        [self startSearchAll];
    }else{
        [self startSearch];
    }
    

 }

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
  
    [_quiltView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];


}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    [self configureCollectionFrame];

}


- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}

#pragma mark _______________________ Privat Methods(view)___________________


- (void)anchorRight {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}


- (void)setupCollection{
    
    self.quiltView = [[TMQuiltView alloc] initWithFrame:CGRectZero];
    _quiltView.delegate = self;
    _quiltView.dataSource = self;
    _quiltView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_quiltView];
    _quiltView.backgroundColor = [UIColor clearColor];
    

}


- (void)configureCollectionFrame{
    
    CGRect rc = self.view.bounds;
    
    _quiltView.frame = rc;
    _quiltView.backgroundColor  =[UIColor clearColor];
    
 }

- (void)setupNavigationTitle{
    
    NSString* titleString = @"";
    
    if (_isAllCategories) {
        titleString = @"All Categories";
    }else{
        titleString = [NSString stringWithFormat:@"%@", [_category safeStringObjectForKey:@"name"]];
    }
    
    self.navigationItem.titleView = [[CustomTitleView alloc] initWithTitle:titleString
                                                         dropDownIndicator:NO
                                                             clickCallback:^(CustomTitleView *titleView) {}];

}

- (void)onClickWithItemDict:(NSDictionary*)itemDict{
    
    if ([itemDict.allKeys containsObject:@"price"]) {
        ProductDetailsVC *vc = [[ProductDetailsVC alloc] initWithProduct:itemDict];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else{
        StoreDetailsVC* storeDetailsVC = [StoreDetailsVC loadFromXIBForScrrenSizes];
        storeDetailsVC.storeDict = itemDict;
        [self.navigationController pushViewController:storeDetailsVC animated:YES];
    }
}


#pragma mark _______________________ Privat Methods ________________________


- (void)loadProducts{
    
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    
    
    LoadProductsByStoreRequest *productsRequest = [[LoadProductsByStoreRequest alloc] init];
    //productsRequest.storeId = [_storeDict safeNumberObjectForKey:@"id"];
    productsRequest.latest = YES;
    
    [self showSpinnerWithName:@""];
    [[MMServiceProvider sharedProvider] sendRequest:productsRequest success:^(LoadProductsByStoreRequest *request) {
        [self hideSpinnerWithName:@""];
        NSLog(@"products: %@", request.products);
        
        self.collectionArray = [NSMutableArray arrayWithArray:request.products];
        [self.quiltView reloadData];
        
    } failure:^(LoadProductsByStoreRequest *request, NSError *error) {
        [self hideSpinnerWithName:@""];
        NSLog(@"Error: %@", error);
        
        self.collectionArray = [NSMutableArray new];
        [_quiltView reloadData];
        [[AlertManager shared] showOkAlertWithTitle:@"Error" message:error.localizedDescription];
    }];
}


- (void)startSearch{
    
    
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    
    [self searchItemsRequest:^(NSArray* items, NSError* error){
        [self searchStoresRequest:^(NSArray* stores, NSError* error){
            
            self.collectionArray = [NSMutableArray new];
            
            for (int i = 0; i < items.count && i < stores.count; i++) {
                [_collectionArray safeAddObject:[stores safeObjectAtIndex:i]];
                [_collectionArray safeAddObject:[items safeObjectAtIndex:i]];
            }
            
            [_quiltView reloadData];
            
            if (_collectionArray.count > 0) {
                [_quiltView setContentOffset:CGPointMake(0, 0) animated:YES];
            }
            
        }];
    }];
}
- (void)searchStoresRequest:(void (^)(NSArray* objects, NSError* error))completion{
    
    LoadStoresForCategory *request = [[LoadStoresForCategory alloc] init];
    request.categoryId = [_category safeStringObjectForKey:@"id"];
    request.communityId = [SearchManager shared].communityID;
//    request.page = 1;
//    request.perPage = 20;
    
    [self showSpinnerWithName:@""];
    
    [[MMServiceProvider sharedProvider] sendRequest:request success:^(LoadStoresForCategory* request) {
        NSLog(@"Succceess!");
        [self hideSpinnerWithName:@""];
        
        completion(request.stores, nil);
        
    } failure:^(id _request, NSError *error) {
        NSLog(@"Fail: %@", error);
        [self hideSpinnerWithName:@""];
        
        NSLog(@"error: %@", error);
        completion(@[], error);
    }];
}


- (void)searchItemsRequest:(void (^)(NSArray* objects, NSError* error))completion{
    
    LoadProductsForCategory *request = [[LoadProductsForCategory alloc] init];
    request.categoryId = [_category safeStringObjectForKey:@"id"];
    request.communityId = [SearchManager shared].communityID;
    
    [self showSpinnerWithName:@""];
    
    [[MMServiceProvider sharedProvider] sendRequest:request success:^(LoadProductsForCategory* request) {
        NSLog(@"Succceess!");
        [self hideSpinnerWithName:@""];
    
         completion(request.products, nil);
        
    } failure:^(id _request, NSError *error) {
        NSLog(@"Fail: %@", error);
        [self hideSpinnerWithName:@""];
        
        NSLog(@"error: %@", error);
        completion(@[], error);
    }];
}



- (void)startSearchAll{
    
    
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    
    [self searchAllItemsRequest:^(NSArray* items, NSError* error){
        [self searchAllStoresRequest:^(NSArray* stores, NSError* error){
            
            self.collectionArray = [NSMutableArray new];
            
            for (int i = 0; i < items.count && i < stores.count; i++) {
                [_collectionArray safeAddObject:[stores safeObjectAtIndex:i]];
                [_collectionArray safeAddObject:[items safeObjectAtIndex:i]];
            }
            
            [_quiltView reloadData];
            
            if (_collectionArray.count > 0) {
                [_quiltView setContentOffset:CGPointMake(0, 0) animated:YES];
            }
            
        }];
    }];
}

- (void)searchAllStoresRequest:(void (^)(NSArray* objects, NSError* error))completion{
    
    
    LoadStoresRequest *request = [[LoadStoresRequest alloc] init];
    request.communityId = [SearchManager shared].communityID;
    //    request.page = 1;
    //    request.perPage = 20;
    
    [self showSpinnerWithName:@""];
    
    [[MMServiceProvider sharedProvider] sendRequest:request success:^(LoadStoresRequest* request) {
        NSLog(@"Succceess!");
        [self hideSpinnerWithName:@""];
        
        completion(request.stores, nil);
        
    } failure:^(id _request, NSError *error) {
        NSLog(@"Fail: %@", error);
        [self hideSpinnerWithName:@""];
        
        NSLog(@"error: %@", error);
        completion(@[], error);
    }];
}


- (void)searchAllItemsRequest:(void (^)(NSArray* objects, NSError* error))completion{
    
    LoadProductsRequest *request = [[LoadProductsRequest alloc] init];
    request.communityId = [SearchManager shared].communityID;
    [self showSpinnerWithName:@""];
    
    [[MMServiceProvider sharedProvider] sendRequest:request success:^(LoadProductsRequest* request) {
        NSLog(@"Succceess!");
        [self hideSpinnerWithName:@""];
        
        completion(request.products, nil);
        
    } failure:^(id _request, NSError *error) {
        NSLog(@"Fail: %@", error);
        [self hideSpinnerWithName:@""];
        
        NSLog(@"error: %@", error);
        completion(@[], error);
    }];
}


#pragma mark _______________________ Buttons Action ________________________

- (void)backButtonClicked{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)customBackButtinClicked:(id)sender {
     [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark _______________________ Delegates _____________________________

#pragma mark - TMQuiltView

- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)TMQuiltView {
    return _collectionArray.count;
}

- (TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary* objDict = [_collectionArray safeDictionaryObjectAtIndex:indexPath.row];
    
    
    //! Set cell type
    if ([objDict.allKeys containsObject:@"price"]) {
        
        HomeItemCell *cell = (HomeItemCell *)[quiltView dequeueReusableCellWithReuseIdentifier:@"HomeItemCell"];
        if (!cell) {
            cell = [HomeItemCell loadViewFromXIB];
            [cell setReuseIdentifier:@"HomeItemCell"];
        }
        
        
        NSDictionary* storeDict = [_collectionArray safeDictionaryObjectAtIndex:indexPath.row];
        
        cell.storeDict = storeDict;
        
        return cell;
        
    }else{
        
        HomeStoreCell *cell = (HomeStoreCell *)[quiltView dequeueReusableCellWithReuseIdentifier:@"HomeStoreCell"];
        if (!cell) {
            cell = [HomeStoreCell loadViewFromXIB];
            [cell setReuseIdentifier:@"HomeStoreCell"];
        }
        
        
        NSDictionary* storeDict = [_collectionArray safeDictionaryObjectAtIndex:indexPath.row];
        
        cell.storeDict = storeDict;
        
        return cell;
        
    }
    return nil;
}

#pragma mark - TMQuiltViewDelegate

- (void)quiltView:(TMQuiltView *)quiltView didSelectCellAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dict = [_collectionArray safeDictionaryObjectAtIndex:indexPath.row];
    
    [self onClickWithItemDict:dict];
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
    
    NSDictionary* storeDict = [_collectionArray safeDictionaryObjectAtIndex:indexPath.row];
    
    CGFloat height = [HomeStoreCell cellHeghtForStore:storeDict];
    
    return height;
}

#pragma mark _______________________ Public Methods ________________________


#pragma mark _______________________ Notifications _________________________

@end