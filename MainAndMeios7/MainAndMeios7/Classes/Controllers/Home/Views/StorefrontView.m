//
//  StorefrontView.m
//  MainAndMeios7
//
//  Created by Alexanedr on 11/19/16.
//  Copyright © 2016 Uniprog. All rights reserved.
//

#import "StorefrontView.h"
#import "StoreDetailsView.h"
#import "ProductCollectionCell.h"
#import "LoadProductsByStoreRequest.h"

@interface StorefrontView ()<UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) StoreDetailsView* storeDetailsView;
@property (strong, nonatomic) NSArray* collectionArray;
@end

@implementation StorefrontView

- (void)awakeFromNib{
    [super awakeFromNib];
    
    UINib *cellNib = [UINib nibWithNibName:@"ProductCollectionCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"ProductCollectionCell"];
    
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];

}


- (void)setStoreDataModel:(StoreDataModel *)storeDataModel{
    _storeDataModel = storeDataModel;
    [self.collectionView reloadData];
    [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];

    if (_storeDataModel.products == nil) {
        [self loadProductsForModel:_storeDataModel];
    }
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.storeDataModel.products count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ProductCollectionCell";
    
    ProductCollectionCell *cell = (ProductCollectionCell *) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSDictionary* productInfo = self.storeDataModel.products[indexPath.row];
    [cell setProductInfo:productInfo];
    
    return cell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width = self.collectionView.frame.size.width;
    return CGSizeMake(width / 3, width / 3);
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *header = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        
        header = [collectionView dequeueReusableSupplementaryViewOfKind: UICollectionElementKindSectionHeader withReuseIdentifier: @"header" forIndexPath: indexPath];
        __weak typeof(self) wSelf = self;
        if (!self.storeDetailsView) {
            self.storeDetailsView = [StoreDetailsView loadViewFromXIB];
            self.storeDetailsView.frame = header.bounds;
            [header addSubview: self.storeDetailsView];
            
            self.storeDetailsView.didSelectCallButton = ^(StoreDetailsView* view, UIButton* button){
                if (wSelf.didClickCall) {
                    wSelf.didClickCall(wSelf, wSelf.storeDataModel);
                }
            };
            self.storeDetailsView.didSelectShareButton = ^(StoreDetailsView* view, UIButton* button){
                if (wSelf.didClickShare) {
                    wSelf.didClickShare(wSelf, wSelf.storeDataModel);
                }
            };
            self.storeDetailsView.didSelectFollowButton = ^(StoreDetailsView* view, UIButton* button){
                if (wSelf.didClickFollow) {
                    wSelf.didClickFollow(wSelf, wSelf.storeDataModel);
                }
            };
            
        }
        
    }
    return header;
}


- (void)collectionView:(UICollectionView *)collectionView
willDisplaySupplementaryView:(UICollectionReusableView *)view
        forElementKind:(NSString *)elementKind
           atIndexPath:(NSIndexPath *)indexPath{
    [self.storeDetailsView setStoreDict:self.storeDataModel.storeInfo];
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    
    CGFloat width = self.collectionView.frame.size.width;
    return CGSizeMake(width, width);
}


- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary* productInfo = self.storeDataModel.products[indexPath.row];
    if (_didClickProduct) {
        _didClickProduct(self, productInfo);
    }
}

- (void)loadProductsForModel:(StoreDataModel*)storeDataModel{
    
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    
    
    LoadProductsByStoreRequest *productsRequest = [[LoadProductsByStoreRequest alloc] init];
    productsRequest.storeId = [storeDataModel.storeInfo safeNumberObjectForKey:@"id"];
    productsRequest.latest = YES;
    
    //[self showSpinnerWithName:@""];
    [[MMServiceProvider sharedProvider] sendRequest:productsRequest success:^(LoadProductsByStoreRequest *request) {
        //[self hideSpinnerWithName:@""];
        NSLog(@"products: %@", request.products);
        
        storeDataModel.products = [NSMutableArray arrayWithArray:request.products];
        //[self.quiltView reloadData];
        [self.collectionView reloadData];
        
    } failure:^(LoadProductsByStoreRequest *request, NSError *error) {
        //[self hideSpinnerWithName:@""];
        NSLog(@"Error: %@", error);
        
        self.collectionArray = [NSMutableArray new];
        //[_quiltView reloadData];
        [self.collectionView reloadData];
        [[AlertManager shared] showOkAlertWithTitle:@"Error" message:error.localizedDescription];
    }];
}

@end
