//
//  SpecialsItemCell.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 16.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "ProximityKitManager.h"


@interface SpecialsItemCell : UICollectionViewCell<UIWebViewDelegate>

@property (copy, nonatomic) void (^didClickCoverButton)(SpecialsItemCell* cell, UIButton* button, CKCampaign* campaign);

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (void) setItemURL: (NSURL *) url;
- (void)setupCampaign:(CKCampaign*)campaign;

@end
