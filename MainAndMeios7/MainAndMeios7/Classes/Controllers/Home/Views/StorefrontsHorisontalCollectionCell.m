//
//  StorefrontsHorisontalCollectionCell.m
//  MainAndMeios7
//
//  Created by Alexanedr on 11/18/16.
//  Copyright © 2016 Uniprog. All rights reserved.
//

#import "StorefrontsHorisontalCollectionCell.h"
#import "StorefrontView.h"

@interface StorefrontsHorisontalCollectionCell ()
@property (weak, nonatomic) StorefrontView* storefrontView;
@end

@implementation StorefrontsHorisontalCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    StorefrontView* storefrontView = [StorefrontView loadViewFromXIB];
    self.storefrontView = storefrontView;
    
    self.storefrontView.frame = self.bounds;
    [self addSubview:self.storefrontView];
    
    __weak typeof(self) wSelf = self;
    self.storefrontView.didClickProduct = ^(StorefrontView* obj, NSDictionary* prod){
        if (wSelf.didClickProduct) {
            wSelf.didClickProduct(wSelf, prod);
        }
    };
    
    self.storefrontView.didClickCall = ^(StorefrontView* obj, StoreDataModel* storeDataModel){
        if (wSelf.didClickCall) {
            wSelf.didClickCall(wSelf, storeDataModel);
        }
    };
    
    self.storefrontView.didClickShare = ^(StorefrontView* obj, StoreDataModel* storeDataModel){
        if (wSelf.didClickShare) {
            wSelf.didClickShare(wSelf, storeDataModel);
        }
    };
    
    self.storefrontView.didClickFollow = ^(StorefrontView* obj, StoreDataModel* storeDataModel){
        if (wSelf.didClickFollow) {
            wSelf.didClickFollow(wSelf, storeDataModel);
        }
    };

    

}

- (void)setStoreDataModel:(StoreDataModel *)storeDataModel{
    _storeDataModel = storeDataModel;
    [self.storefrontView setStoreDataModel:_storeDataModel];
}

@end
