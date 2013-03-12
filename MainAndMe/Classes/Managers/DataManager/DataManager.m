//
//  DataManager.m
//  MainAndMe
//
//  Created by Sasha on 3/12/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "DataManager.h"


@interface DataManager()

@end


@implementation DataManager

#pragma mark - Shared Instance and Init
+ (DataManager *)shared {
    
    static DataManager *shared = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}

-(id)init{
    
    self = [super init];
    if (self) {
   		// your initialization here
    }
    return self;
}

#pragma mark - 

- (void)setUserId:(NSString *)userId{

    NSLog(@"yourObject is a: %@", NSStringFromClass([userId class]));
    _userId = userId;
}
@end
