//
//  LayoutManager.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 10/17/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LayoutManager.h"


@interface LayoutManager()

@end


@implementation LayoutManager
#pragma mark _______________________ Class Methods _________________________

#pragma mark - Shared Instance and Init
+ (LayoutManager *)shared {
    
    static LayoutManager *shared = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}

#pragma mark ____________________________ Init _____________________________

-(id)init{
    
    self = [super init];
    if (self) {
   		// your initialization here
        
        
    }
    return self;
}

#pragma mark _______________________ Privat Methods ________________________



#pragma mark _______________________ Delegates _____________________________



#pragma mark _______________________ Public Methods ________________________

+ (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //! Set Application Delegate
    [self shared].appDelegate = (AppDelegate*)application.delegate;
    
    //! Set Winodw
    [self shared].window = [self shared].appDelegate.window;
    [self shared].window.backgroundColor = [UIColor purpleColor];
    
    //! Set Storyboard
    [self shared].mainStoryboard = [self shared].window.rootViewController.storyboard;
    
    //! Set root navigation controller
    [self shared].rootNVC = (RootNavigationController*)[self shared].window.rootViewController;

}



#pragma mark _______________________ Notifications _________________________



@end
