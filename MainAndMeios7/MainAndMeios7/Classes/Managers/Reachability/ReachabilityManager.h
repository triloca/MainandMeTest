//
//  ReachabilityManager.h
//  MainAndMe
//
//  Created by Sasha on 3/12/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


@interface ReachabilityManager : NSObject

+ (ReachabilityManager*)shared;
+ (BOOL)isReachable;
@end