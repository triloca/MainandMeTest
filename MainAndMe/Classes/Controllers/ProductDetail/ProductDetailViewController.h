//
//  ProductDetailViewController.h
//  MainAndMe
//
//  Created by Sasha on 3/15/13.
//
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface ProductDetailViewController : GAITrackedViewController
@property (strong, nonatomic) NSDictionary* productInfo;
@end
