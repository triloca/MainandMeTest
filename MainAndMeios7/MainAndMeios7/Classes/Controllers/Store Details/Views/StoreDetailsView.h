//
//  StoreDetailsView.h
//  MainAndMeios7
//
//  Created by Alexander Bukov on 11/15/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoreDetailsView : UIView
@property (strong, nonatomic) NSDictionary* storeDict;

@property (weak, nonatomic) IBOutlet UIButton *wishlistButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *callButton;

@property (weak, nonatomic) IBOutlet UIImageView *gradientImageView;
@property (weak, nonatomic) IBOutlet UIImageView *storeImageView;

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (copy, nonatomic) void (^didSelectFollowButton)(StoreDetailsView* view, UIButton* button);
@property (copy, nonatomic) void (^didSelectShareButton)(StoreDetailsView* view, UIButton* button);
@property (copy, nonatomic) void (^didSelectCallButton)(StoreDetailsView* view, UIButton* button);


@end
