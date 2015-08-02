//
//  AppDelegate.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 10/16/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "AppDelegate.h"
#import "LocationManager.h"
#import <AddressBook/AddressBook.h>

#import "FacebookManager.h"

#import "RegistrationRequest.h"
#import "LoginRequest.h"
#import "MMServiceProvider.h"
#import "SearchRequest.h"
#import "LoadProfileRequest.h"
#import "LoadCommentsRequest.h"
#import "LoadStoreRequest.h"
#import "LoadProductsByStoreRequest.h"
#import "ForgotPasswordRequest.h"
#import "LoginTrackerRequest.h"
#import "AddDeviceTokenRequest.h"
#import "GetNotificationsRequest.h"
#import "RemoveNotificationRequest.h"
#import "LoadAllWishistsRequest.h"
#import "LoadStoreCommentsForUser.h"
#import "LikeProductRequest.h"
#import "CreateWishlistRequest.h"
#import "LoadCategoriesRequest.h"
#import "LoadStoresForCategory.h"
#import "LoadProductsForCategory.h"
#import "LoadProductLikesForUserRequest.h"
#import "LoadStoresRequest.h"
#import "LoadProductsRequest.h"
#import "LoadNearbyProductsRequest.h"
#import "LoadStatesRequest.h"
#import "LoadCurrentUserRequest.h"
#import "SaveCurrentUserRequest.h"
#import "LikeStoreRequest.h"
#import "FollowStoreRequest.h"
#import "RateStoreRequest.h"

#import "ProximityKitManager.h"

#import "SearchManager.h"

#import "PinterestManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];

    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitDiskImageCacheEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [ReachabilityManager shared];
    [SearchManager shared];

    [LayoutManager application:application didFinishLaunchingWithOptions:launchOptions];
//    [[LocationManager sharedManager] setUpdatePeriod:10];//10 seconds
//    [[LocationManager sharedManager] setDistanceFilter:10];//10 meters
//    [[LocationManager sharedManager] start];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:LOCATION_CHANGED_NOTIFICATION_NAME object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        
        CLLocation *loc = (CLLocation *) notification.userInfo;
        NSLog(@"--- LOCATION UPDATED: %@ ----", loc);
    }];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:REGION_CHANGED_NOTIFICATION_NAME object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        
        CLLocation *loc = (CLLocation *) notification.userInfo;
        NSLog(@"--- REGION CHANGED: %@ ----", loc);
    }];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:GEOCODING_INFO_UPDATED_NOTIFICATION_NAME object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        
        CLPlacemark *placemark = (CLPlacemark *) notification.userInfo;
        NSLog(@"Placemark name: %@", placemark.name);
//        NSDictionary *dict = placemark.addressDictionary;
//        NSString *locationName = [NSString stringWithFormat:@"%@", [dict objectForKey:(NSString *) kABPersonAddressStreetKey]];
    }];
    
//    [[LocationManager sharedManager] updateWithCompletionBlock:^(CLLocation * loc) {
//        NSLog(@"Forced udpate location: %@", loc);
//    }];
//    
    [LocationManager sharedManager].updatePeriod = 10 * 60;
    [[LocationManager sharedManager] start];
    
    
    [[ProximityKitManager shared] application:application didFinishLaunchingWithOptions:launchOptions];

    
//    RegistrationRequest *request = [[RegistrationRequest alloc] init];
//    request.username = @"test12";
//    request.password = @"passwd";
//    request.email = @"ee1@ee.com";
//    
//    [[MMServiceProvider sharedProvider] sendRequest:request success:^(RegistrationRequest *request) {
//        NSLog(@"Registration complete! %@", request.response);
//    } failure:^(RegistrationRequest *request, NSError *error) {
//        NSLog(@"Registration failed: %@", error);
//        NSLog(@"Response: %@", request.response);
//    }];

/* 
    LoginRequest *loginRequest = [[LoginRequest alloc] init];
    loginRequest.email = @"test@test.com";
    loginRequest.password = @"testtest";
    [[MMServiceProvider sharedProvider] sendRequest:loginRequest success:^(LoginRequest *_loginRequest) {
        NSString *apiToken = _loginRequest.apiToken;
        NSLog(@"login completed: %@", apiToken);
//        
//        AddDeviceTokenRequest *addDeviceRequest = [[AddDeviceTokenRequest alloc] init];
//        addDeviceRequest.apiToken = apiToken;
//        addDeviceRequest.deviceToken = apiToken;
//        
//        [[MMServiceProvider sharedProvider] sendRequest:addDeviceRequest success:^(AddDeviceTokenRequest *request) {
//            NSLog(@"device token added");
//        }failure:^(AddDeviceTokenRequest *request, NSError *error) {
//            NSLog(@"Error: %@", error);
//        }];
        
//        GetNotificationsRequest *notificationsRequest = [[GetNotificationsRequest alloc] init];
//        notificationsRequest.apiToken = apiToken;
//        
//        [[MMServiceProvider sharedProvider] sendRequest:notificationsRequest success:^(GetNotificationsRequest *request) {
//            NSLog(@"notifications: %@", notificationsRequest.notifications);
//        }failure:^(GetNotificationsRequest *request, NSError *error) {
//            NSLog(@"Error: %@", error);
//        }];
        
//        RemoveNotificationRequest *removeNotificationsRequest = [[RemoveNotificationRequest alloc] init];
//        removeNotificationsRequest.apiToken = apiToken;
//        removeNotificationsRequest.notificationId = @(555);
//        [[MMServiceProvider sharedProvider] sendRequest:removeNotificationsRequest success:^(RemoveNotificationRequest *request) {
//            NSLog(@"notifications cleared");
//        }failure:^(RemoveNotificationRequest *request, NSError *error) {
//            NSLog(@"Error: %@", error);
//        }];
        
//        LoadWishistRequest *wishlistRequest = [[LoadWishistRequest alloc] init];
//        wishlistRequest.userId = @(50);
//        
//        [[MMServiceProvider sharedProvider] sendRequest:wishlistRequest success:^(LoadWishistRequest *request) {
//            NSLog(@"wishlist: %@", wishlistRequest.wishlist);
//        }failure:^(LoadWishistRequest *request, NSError *error) {
//            NSLog(@"Error: %@", error);
//        }];

//        LikeProductRequest *request = [[LikeProductRequest alloc] init];
//        request.apiToken = apiToken;
//        
//        [[MMServiceProvider sharedProvider] sendRequest:request success:^(id _request) {
//            NSLog(@"product was liked: %@", request.response);
//        }failure:^(id _request, NSError *error) {
//            NSLog(@"Error: %@", error);
//        }];
        
//        LikeStoreRequest *request = [[LikeStoreRequest alloc] init];
//        request.apiToken = apiToken;
//        request.storeId = @"50";
//        
//        [[MMServiceProvider sharedProvider] sendRequest:request success:^(id _request) {
//            NSLog(@"store was liked: %@", request.response);
//        }failure:^(id _request, NSError *error) {
//            NSLog(@"Error: %@", error);
//        }];
        
//        FollowStoreRequest *request = [[FollowStoreRequest alloc] init];
//        request.apiToken = apiToken;
//        request.storeId = @"50";
//
//        [[MMServiceProvider sharedProvider] sendRequest:request success:^(id _request) {
//            NSLog(@"store was liked: %@", request.response);
//        }failure:^(id _request, NSError *error) {
//            NSLog(@"Error: %@", error);
//        }];

//        RateStoreRequest *request = [[RateStoreRequest alloc] init];
//        request.apiToken = apiToken;
//        request.storeId = @"50";
//        request.rate = 5;
//
//        [[MMServiceProvider sharedProvider] sendRequest:request success:^(id _request) {
//            NSLog(@"store was rated: %@", request.response);
//        }failure:^(id _request, NSError *error) {
//            NSLog(@"Error: %@", error);
//        }];
        
        //WARNING: This request if failing with '{name: can't be black error}' i dont know why.
        //Obviously, there is another key for 'name' field.
        //So just feel free to go to request realization and take a loot at 'userRequestDictionary' method.
//        CreateWishlistRequest *request = [[CreateWishlistRequest alloc] init];
//        request.name = @"My wishlist1";
//        request.userId = @(50);
//        request.apiToken = apiToken;
//        
//        [[MMServiceProvider sharedProvider] sendRequest:request success:^(id _request) {
//            NSLog(@"wishlist was created: %@", request.response);
//        }failure:^(id _request, NSError *error) {
//            NSLog(@"Error: %@, %@", error.userInfo[NSLocalizedDescriptionKey], request.response);
//        }];

//        LoadCurrentUserRequest *loadCurrentUserRequest = [[LoadCurrentUserRequest alloc] init];
//        loadCurrentUserRequest.apiToken = apiToken;
//        
//        [[MMServiceProvider sharedProvider] sendRequest:loadCurrentUserRequest success:^(id _request) {
//            NSLog(@"current user: %@", loadCurrentUserRequest.user);
//            NSDictionary *user = loadCurrentUserRequest.user;
//            
//            
//            SaveCurrentUserRequest *request = [[SaveCurrentUserRequest alloc] init];
//            request.apiToken = apiToken;
//            request.userId = user[@"id"];
//            request.username = user[@"name"];
//            request.password = loginRequest.password;
//            request.birthday = user[@"date_of_birth"];
//            request.address = user[@"address"];
//            request.phoneNumber = user[@"phone_number"];
//            request.emailCommunities = user[@"email_communities"];
//            request.emailStores = user[@"email_stores"];
//            request.emailPeople = user[@"email_people"];
//            request.wishlist = user[@"1"];
//            
//            [[MMServiceProvider sharedProvider] sendRequest:request success:^(id _request) {
//                NSLog(@"current user saved: %@", request.user);
//                
//                
//            } failure:^(id _request, NSError *error) {
//                NSLog(@"error: %@", error);
//            }];
//        } failure:^(id _request, NSError *error) {
//            NSLog(@"error: %@", error);
//        }];

    } failure:^(LoginRequest *request, NSError *error) {
        NSLog(@"login failed: %@", error);
        NSLog(@"Response: %@", request.response);
    }];
/* */
//
//    
//    ForgotPasswordRequest *forgotPswdRequest = [[ForgotPasswordRequest alloc] init];
//    forgotPswdRequest.email = @"ee@ee.com";
//    
//    [[MMServiceProvider sharedProvider] sendRequest:forgotPswdRequest success:^(ForgotPasswordRequest *request) {
//        NSLog(@"Password recovery email sent");
//    } failure:^(ForgotPasswordRequest *request, NSError* error) {
//        NSLog(@"Password recovery failed with error: %@", error);
//    }];
//
    
//    SearchRequest *searchRequest = [[SearchRequest alloc] initWithSearchType:SearchTypeStores searchFilter:SearchFilterNewlyAll];
//    searchRequest.coordinate = CLLocationCoordinate2DMake(42.283215, -71.123029);
//    searchRequest.city = @"Roslindale";
//    searchRequest.state = @"MA";
//    
//    [[MMServiceProvider sharedProvider] sendRequest:searchRequest success:^(id _request) {
//        NSLog(@"Succceess!");
//    } failure:^(id _request, NSError *error) {
//        NSLog(@"Fail: %@", error);
//    }];
    
//    LoadProfileRequest *loadProfileRequest = [[LoadProfileRequest alloc] init];
//    loadProfileRequest.userId = @(50);
//    
//    [[MMServiceProvider sharedProvider] sendRequest:loadProfileRequest success:^(LoadProfileRequest *request) {
//        NSLog(@"Profile: %@", request.profile);
//    } failure:^(LoadProfileRequest *request, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
    
//    LoadCommentsRequest *commentsRequest = [[LoadCommentsRequest alloc] init];
//    commentsRequest.userId = @(50);
//    
//    [[MMServiceProvider sharedProvider] sendRequest:commentsRequest success:^(LoadCommentsRequest *request) {
//        NSLog(@"comments: %@", commentsRequest.comments);
//    } failure:^(LoadCommentsRequest *request, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
    
//    LoadStoreRequest *storeRequest = [[LoadStoreRequest alloc] init];
//    storeRequest.storeId = @(50);
//
//    [[MMServiceProvider sharedProvider] sendRequest:storeRequest success:^(LoadStoreRequest *request) {
//        NSLog(@"store: %@", request.storeDetails);
//    } failure:^(LoadCommentsRequest *request, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];

//    LoadProductsByStoreRequest *productsRequest = [[LoadProductsByStoreRequest alloc] init];
//    productsRequest.storeId = @(50);
//
//    [[MMServiceProvider sharedProvider] sendRequest:productsRequest success:^(LoadProductsByStoreRequest *request) {
//        NSLog(@"products: %@", request.products);
//    } failure:^(LoadProductsByStoreRequest *request, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];

//    LoginTrackerRequest *trackerRequest = [[LoginTrackerRequest alloc] init];
//    trackerRequest.communityId = @"50";
//    
//    [[MMServiceProvider sharedProvider] sendRequest:trackerRequest success:^(LoginTrackerRequest *request) {
//        NSLog(@"Tracking success");
//    } failure:^(LoginTrackerRequest *request, NSError *error) {
//        NSLog(@"Tracking failed: %@", error);
//    }];
//
    
//    LoadStoreCommentsForUser *storeCommentsRequest = [[LoadStoreCommentsForUser alloc] init];
//    storeCommentsRequest.userId = @(50);
//    [[MMServiceProvider sharedProvider] sendRequest:storeCommentsRequest success:^(LoadStoreCommentsForUser *request) {
//        NSLog(@"comments for user: %@", storeCommentsRequest.comments);
//    } failure:^(LoadStoreCommentsForUser *request, NSError *error) {
//        NSLog(@"Tracking failed: %@", error);
//    }];
    
//    LoadCategoriesRequest *request = [[LoadCategoriesRequest alloc] init];
//    
//    [[MMServiceProvider sharedProvider] sendRequest:request success:^(id _request) {
//        NSLog(@"categories loaded %@", request.categories);
//    } failure:^(id _request, NSError *error) {
//        NSLog(@"error: %@", error);
//    }];

//    LoadStoresForCategory *request = [[LoadStoresForCategory alloc] init];
//    request.categoryId = @"59";
//    
//    [[MMServiceProvider sharedProvider] sendRequest:request success:^(id _request) {
//        NSLog(@"stores: %@", request.stores);
//    } failure:^(id _request, NSError *error) {
//        NSLog(@"error: %@", error);
//    }];

//    LoadProductsForCategory *request = [[LoadProductsForCategory alloc] init];
//    request.categoryId = @"59";
////    request.communityId = @"1";
//    
//    [[MMServiceProvider sharedProvider] sendRequest:request success:^(id _request) {
//        NSLog(@"products: %@", request.products);
//    } failure:^(id _request, NSError *error) {
//        NSLog(@"error: %@", error);
//    }];

//    LoadProductLikesForUserRequest *request = [[LoadProductLikesForUserRequest alloc] init];
//    request.userId = @(50);
//    
//    [[MMServiceProvider sharedProvider] sendRequest:request success:^(id _request) {
//        NSLog(@"likes: %@", request.likes);
//    } failure:^(id _request, NSError *error) {
//        NSLog(@"error: %@", error);
//    }];

//    LoadStoresRequest *request = [[LoadStoresRequest alloc] init];
//    request.keywords = @"find";
//    
//    [[MMServiceProvider sharedProvider] sendRequest:request success:^(id _request) {
//        NSLog(@"stores: %@", request.stores);
//    } failure:^(id _request, NSError *error) {
//        NSLog(@"error: %@", error);
//    }];

//    LoadProductsRequest *request = [[LoadProductsRequest alloc] init];
//    request.keywords = @"find";
//
//    [[MMServiceProvider sharedProvider] sendRequest:request success:^(id _request) {
//        NSLog(@"products: %@", request.products);
//    } failure:^(id _request, NSError *error) {
//        NSLog(@"error: %@", error);
//    }];
    
//    LoadNearbyProductsRequest *request = [[LoadNearbyProductsRequest alloc] init];
//    request.coordinate = CLLocationCoordinate2DMake(42.283215, -71.123029);
//
//    [[MMServiceProvider sharedProvider] sendRequest:request success:^(id _request) {
//        NSLog(@"products: %@", request.products);
//    } failure:^(id _request, NSError *error) {
//        NSLog(@"error: %@", error);
//    }];

//    LoadStatesRequest *request = [[LoadStatesRequest alloc] init];
//    
//    [[MMServiceProvider sharedProvider] sendRequest:request success:^(id _request) {
//        NSLog(@"states: %@", request.states);
//    } failure:^(id _request, NSError *error) {
//        NSLog(@"error: %@", error);
//    }];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application: (UIApplication *)application  openURL: (NSURL *)url  sourceApplication: (NSString *)sourceApplication
         annotation: (id)annotation
{
    
    BOOL isFBManagerHandle = [[FacebookManager shared] handleOpenURL:url sourceApplication:sourceApplication];
    BOOL pin = [[PinterestManager shared] application:application handleOpenURL:url];
    return isFBManagerHandle || pin;
}

@end
