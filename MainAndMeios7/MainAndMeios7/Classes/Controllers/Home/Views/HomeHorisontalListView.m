//
//  HomeHorisontalListView.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 11/15/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "HomeHorisontalListView.h"
#import "ItemHorisontalCell.h"

@interface HomeHorisontalListView () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property BOOL loading;

@end

@implementation HomeHorisontalListView

- (void)awakeFromNib{
    [super awakeFromNib];
    
    UINib *cellNib = [UINib nibWithNibName:@"ItemHorisontalCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"ItemHorisontalCell"];
    _collectionView.allowsSelection = YES;
}

- (void) reloadData {
    [self.activityIndicator stopAnimating];
    [self.collectionView reloadData];
    self.loading = NO;
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.tableArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ItemHorisontalCell";
    
    ItemHorisontalCell *cell = (ItemHorisontalCell *) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell setProduct:[_tableArray safeObjectAtIndex:indexPath.row]];
    
    return cell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionView.frame.size;
}

- (void)scrollViewDidEndDecelerating: (UIScrollView *)scrollView {
    
    // Calculate where the collection view should be at the right-hand end item
    float contentOffsetWhenFullyScrolledRight = self.collectionView.frame.size.width * ([self.tableArray count] -1);
    
    if (scrollView.contentOffset.x == contentOffsetWhenFullyScrolledRight && !_loading) {
        self.loading = YES;
        if (_delegate)
            [_delegate horisontalListViewdidScrollToEnd:self];
        [_activityIndicator startAnimating];
    }
}


 
@end
