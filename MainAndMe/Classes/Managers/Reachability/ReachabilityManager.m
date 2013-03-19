//
//  ReachabilityManager.m
//  MainAndMe
//
//  Created by Sasha on 3/12/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ReachabilityManager.h"
#import "Reachability.h"
#import "AlertManager.h"


@interface ReachabilityManager()
@property (strong, nonatomic) Reachability* reachability;
@end


@implementation ReachabilityManager

#pragma mark - Shared Instance and Init
+ (ReachabilityManager *)shared {
    
    static ReachabilityManager *shared = nil;
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

        [self initializeReachability];
    }
    return self;
}
 
#pragma mark - Reachability
- (void)initializeReachability{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    self.reachability = [Reachability reachabilityForInternetConnection];
    //self.reachability = [Reachability reachabilityWithHostname:@"http://mainandme-test.herokuapp.com"];
    [_reachability startNotifier];
}


-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    
    if([reach isReachable] == NO) {
        
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
    }
}

+ (BOOL)isReachable{
    return [[self shared].reachability isReachable];
}

@end
