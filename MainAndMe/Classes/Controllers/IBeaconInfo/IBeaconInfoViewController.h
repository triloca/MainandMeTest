//
//  ProductDetailViewController.h
//  MainAndMe
//
//  Created by Sasha on 3/15/13.
//
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"
#import <CampaignKit/CampaignKit.h>

@interface IBeaconInfoViewController : GAITrackedViewController
@property (strong, nonatomic) CKCampaign* campaign;
@end
