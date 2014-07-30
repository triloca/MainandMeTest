//
//  WishlistDetailsViewController.h
//  MainAndMe
//
//  Created by Sasha on 3/19/13.
//
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface WishlistDetailsViewController : GAITrackedViewController
@property (assign, nonatomic) BOOL isNeedRefresh;
@property (strong, nonatomic) NSDictionary* wishlistInfo;
@property (assign, nonatomic) BOOL isAllState;
@end
