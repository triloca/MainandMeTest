//
//  SalesAndEventsView.m
//  MainAndMeios7
//
//  Created by Alexanedr on 12/18/16.
//  Copyright © 2016 Uniprog. All rights reserved.
//

#import "SalesAndEventsView.h"
#import "LoadSalesEventsRequest.h"
#import "SearchManager.h"
#import "SpecialCell.h"

@interface SalesAndEventsView ()
@property (weak, nonatomic) IBOutlet UILabel *salesCountLabel;


@end

@implementation SalesAndEventsView

- (void)awakeFromNib{
    [super awakeFromNib];
    
    UINib *cellNib = [UINib nibWithNibName:@"SpecialCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"SpecialCell"];
    [self updatePageLabel];
}

- (void)loadDataComletion:(void (^)(NSError* error))completion{
    
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    
    
    LoadSalesEventsRequest *productsRequest = [[LoadSalesEventsRequest alloc] init];
    productsRequest.communityId = [SearchManager shared].communityID;
    
    [[MMServiceProvider sharedProvider] sendRequest:productsRequest success:^(LoadSalesEventsRequest *request) {

        NSLog(@"products: %@", request.events);
        
        self.collectionArray = [NSMutableArray arrayWithArray:request.events];
        [self.collectionView reloadData];
        [self updatePageLabel];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kSetStoreBageValueNotification" object:@(self.collectionArray.count)];
        
        if (completion) {
            completion(nil);
        }
        
    } failure:^(LoadSalesEventsRequest *request, NSError *error) {
        //[self hideSpinnerWithName:@""];
        NSLog(@"Error: %@", error);
        
        self.collectionArray = [NSMutableArray new];
        [self.collectionView reloadData];
        [[AlertManager shared] showOkAlertWithTitle:@"Error" message:error.localizedDescription];
        [self updatePageLabel];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kSetStoreBageValueNotification" object:@(0)];
        if (completion) {
            completion(error);
        }
    }];
    
}


#pragma mark Page control
- (void)updatePageLabel{
    NSInteger currentPage = (NSInteger)((self.collectionView.contentOffset.x + self.collectionView.frame.size.width / 2)/ self.collectionView.frame.size.width);
    
    NSString* pageString = [NSString stringWithFormat:@"%d of %d", currentPage + 1, self.collectionArray.count];
    self.salesCountLabel.text = pageString;
    
    if (self.collectionArray.count) {
        self.salesCountLabel.hidden = NO;
    }else{
        self.salesCountLabel.hidden = YES;
    }
}



#pragma mark - Privat Methods


- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSInteger count = [self.collectionArray count];
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SpecialCell";
    
    SpecialCell *cell = (SpecialCell *) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSDictionary* cellInfo = self.collectionArray[indexPath.row];
    cell.cellInfo = cellInfo;
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    return cell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionView.frame.size;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self updatePageLabel];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    SpecialCell *cell = (SpecialCell*)[collectionView cellForItemAtIndexPath:indexPath];
    NSDictionary* cellInfo = cell.cellInfo;
    
    if (_didSelectItem) {
        _didSelectItem(self, cellInfo, self.collectionArray);
    }
}
@end
