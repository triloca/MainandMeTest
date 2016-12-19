//
//  ProductCollectionCell.m
//  MainAndMeios7
//
//  Created by Alexanedr on 11/19/16.
//  Copyright © 2016 Uniprog. All rights reserved.
//

#import "ProductCollectionCell.h"

@implementation ProductCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.productView = [ProductView loadViewFromXIB];
    _productView.frame = self.productContentView.bounds;
    [self.productContentView addSubview:_productView];
    _productView.coverButton.hidden = YES;
}

- (void)setProductInfo:(NSDictionary *)productInfo{
    _productInfo = productInfo;
    
    NSString* imageUrl = nil;
    imageUrl = [[productInfo safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
    self.productView.textLabel.text = @"";
    [self.productView setImageURLString:imageUrl];
}

@end
