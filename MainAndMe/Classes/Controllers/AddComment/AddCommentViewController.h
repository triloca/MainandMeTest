//
//  AddCommentViewController.h
//  MainAndMe
//
//  Created by Sasha on 3/16/13.
//
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface AddCommentViewController : GAITrackedViewController
@property (strong, nonatomic) NSDictionary* productInfo;
@property (assign, nonatomic) BOOL isStoreState;
@end
