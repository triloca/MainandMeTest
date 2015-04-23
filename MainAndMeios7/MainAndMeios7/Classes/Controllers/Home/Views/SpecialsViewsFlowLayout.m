//
//  SpecialsViewsFlowLayout.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 16.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "SpecialsViewsFlowLayout.h"
#import "SpecialsView.h"

@implementation SpecialsViewsFlowLayout

//i know this is bad but
//i needed somehow to set up the itemWidth after the autolayout process the changes
//So it asks the SpecialsView only when it scrolls
- (SpecialsView *) specialsView {
    SpecialsView *sp = (SpecialsView *) self.collectionView.delegate;
    return sp;
}

- (void)awakeFromNib {
    int padding = 40;
    self.minimumInteritemSpacing = 0.0;
    self.minimumLineSpacing = 10.0;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.sectionInset = UIEdgeInsetsMake(0.0, padding, 0.0, padding);
}

#pragma mark - Pagination
- (CGFloat)pageWidth {
    return [self specialsView].itemSize.width + self.minimumLineSpacing;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    int pageWidth = self.pageWidth;
    CGFloat rawPageValue = self.collectionView.contentOffset.x / pageWidth;
    CGFloat currentPage = (velocity.x > 0.0) ? floor(rawPageValue) : ceil(rawPageValue);
    CGFloat nextPage = (velocity.x > 0.0) ? ceil(rawPageValue) : floor(rawPageValue);
    
    BOOL pannedLessThanAPage = fabs(1 + currentPage - rawPageValue) > 0.5;
    BOOL flicked = fabs(velocity.x) > [self flickVelocity];
    if (pannedLessThanAPage && flicked) {
        proposedContentOffset.x = nextPage * pageWidth;
    } else {
        proposedContentOffset.x = round(rawPageValue) * pageWidth;
    }
    
    return proposedContentOffset;
}

- (CGFloat)flickVelocity {
    return 0.3;
}

@end
