//
//  TwitterManager.h
//  MainAndMeios7
//
//  Created by Alexander Bukov on 10/21/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "FHSTwitterEngine.h"

@interface TwitterManager : NSObject

+ (TwitterManager*)shared;

- (void)loginVCPresentation:(void (^)(UIViewController* twitterLoginVC))presentation
                    success:(void (^)(UIViewController* twitterLoginVC, FHSToken* token))success
                    failure:(void (^)(UIViewController* twitterLoginVC, NSError* error))failure
                     cancel:(void (^)(UIViewController* twitterLoginVC))cancel
            alreadyLoggedIn:(void (^)(UIViewController* twitterLoginVC, FHSToken* token))alreadyLoggedIn;

- (void)logout;

@end