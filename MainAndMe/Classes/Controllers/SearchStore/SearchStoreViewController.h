//
//  SearchViewController.h
//  MainAndMe
//
//  Created by Sasha on 3/15/13.
//
//

#import <UIKit/UIKit.h>

@interface SearchStoreViewController : UIViewController
@property (copy, nonatomic) void (^didSelectStoreName)(NSString* name);
@end
