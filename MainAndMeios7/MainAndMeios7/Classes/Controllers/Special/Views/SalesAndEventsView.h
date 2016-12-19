//
//  SalesAndEventsView.h
//  MainAndMeios7
//
//  Created by Alexanedr on 12/18/16.
//  Copyright © 2016 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SalesAndEventsView : UIView

@property (strong, nonatomic) NSArray* collectionArray;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


- (void)loadDataComletion:(void (^)(NSError* error))completion;
@property (copy, nonatomic) void (^didSelectItem)(SalesAndEventsView* sender, NSDictionary* cellInfo, NSArray* collectionArray);

@end
