//
//  SearchViewController.h
//  MainAndMe
//
//  Created by Sasha on 3/15/13.
//
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface SearchStoreViewController : GAITrackedViewController
@property (copy, nonatomic) void (^didSelectStoreName)(NSString* name);
@property (strong, nonatomic) NSArray* storesArray;
@end
