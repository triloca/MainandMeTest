//
//  AlertManager.m
//  MainAndMe
//
//  Created by Sasha on 3/12/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "AlertManager.h"


@interface AlertManager()
@property (assign, nonatomic) NSInteger alertsCount;
@end


@implementation AlertManager

#pragma mark - Shared Instance and Init
+ (AlertManager *)shared {
    
    static AlertManager *shared = nil;
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
        _alertsCount = 0;
    }
    return self;
}

#pragma mark -

- (void)showAlertWithCallBack:(void (^)())callBack
                        title:(NSString*)title
                      message:(NSString*)message
            cancelButtonTitle:(NSString*)cancelButtonTitle
            otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION
             {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    
    [alertView show];

}
@end
