//
//  PinterestManager.h
//  Prototype
//
//  Created by Alexander Bukov on 5/7/15.
//  Copyright (c) 2015 AppCoda. All rights reserved.
//

#import <Pinterest/Pinterest.h>


@interface PinterestManager : NSObject

@property (strong, nonatomic, readonly) Pinterest* pinterest;


+ (PinterestManager*)shared;
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
- (void)share;
@end