//
//  HomeCoverView.h
//  MainAndMeios7
//
//  Created by Alexander Bukov on 4/23/15.
//  Copyright (c) 2015 Uniprog. All rights reserved.
//


@interface HomeCoverView : UIView
@property (copy, nonatomic) void (^didFinishViewing)(HomeCoverView* view);
- (void)setupCampaign:(CKCampaign*)campaign;
@end
