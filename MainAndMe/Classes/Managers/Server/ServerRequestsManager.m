//
//  ServerRequestsManager.m
//  MainAndMe
//
//  Created by Sasha on 3/12/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ServerRequestsManager.h"


@interface ServerRequestsManager()

@end


@implementation ServerRequestsManager

#pragma mark - Shared Instance and Init
+ (ServerRequestsManager *)shared {
    
    static ServerRequestsManager *shared = nil;
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
@end
