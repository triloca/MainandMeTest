//
//  SpecialsView.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 16.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "SpecialsView.h"
#import "SpecialsItemCell.h"

@implementation SpecialsView

- (void)awakeFromNib{
    [super awakeFromNib];
    
    UINib *cellNib = [UINib nibWithNibName:@"SpecialsItemCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"SpecialsItemCell"];
    
    self.collectionView.allowsSelection = YES;
    
}

- (void) reloadData {
    [self.collectionView reloadData];
}

- (void) setItems:(NSArray *)items {
    if (items == _items)
        return;
    
    _items = items;
    [self reloadData];
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.items count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SpecialsItemCell";
    
    SpecialsItemCell *cell = (SpecialsItemCell *) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    //[cell setItemURL:_items[indexPath.row]];
    
    cell.didClickCoverButton = ^(SpecialsItemCell* cell, UIButton* button, CKCampaign* campaign){
        if (_didSelectCampaign) {
            _didSelectCampaign(self, campaign);
        }
    };
    
    [cell setupCampaign:[_items safeObjectAtIndex:indexPath.row]];
    
    cell.layer.cornerRadius = 5;
    
    return cell;
}

- (CGSize) itemSize {
    return CGSizeMake(self.frame.size.width - 80, self.frame.size.height - 20);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.itemSize;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CKCampaign* campaign = [self.items safeObjectAtIndex:indexPath.row];
    if (_didSelectCampaign) {
        _didSelectCampaign(self, campaign);
    }
}
@end
