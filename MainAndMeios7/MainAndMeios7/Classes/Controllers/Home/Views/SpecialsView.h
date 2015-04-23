//
//  SpecialsView.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 16.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProximityKitManager.h"


@interface SpecialsView : UIView

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@property (copy, nonatomic) void (^didSelectCampaign)(SpecialsView* view, CKCampaign* campaign);

@property (strong, nonatomic) NSArray *items;
@property (readonly) CGSize itemSize;

@end
