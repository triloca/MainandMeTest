//
//  FacebookManager.m
//  AllComponents
//
//  Created by Sasha on 4/5/14.
//  Copyright (c) 2014 uniprog. All rights reserved.
//


#import "FacebookManager.h"


@interface FacebookManager()
@end


@implementation FacebookManager
#pragma mark _____________________________________________________ Class Methods

#pragma mark - Shared Instance and Init
+ (FacebookManager *)shared {
    
    static FacebookManager *shared = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}

#pragma mark _____________________________________________________ Init

-(id)init{
    
    self = [super init];
    if (self) {
   		// your initialization here
        
        self.friends = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillTerminate:)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark _____________________________________________________ Privat Methods

- (FBSession*)createSessionWithPermissions:(NSArray *)permissions{
    
    FBSessionTokenCachingStrategy *tokenCachingStrategy =
    [[FBSessionTokenCachingStrategy alloc] initWithUserDefaultTokenInformationKeyName:kFBUserDefaultsTokenInfoKey];

    FBSession *session = [[FBSession alloc] initWithAppID:nil
                                              permissions:permissions
                                          urlSchemeSuffix:nil
                                       tokenCacheStrategy:tokenCachingStrategy];
    return session;
}

#pragma mark _____________________________________________________ Delegates

#pragma mark _____________________________________________________ Public Methods

#pragma mark Login
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI
{
    NSArray *permission = [[NSArray alloc] initWithObjects:@"user_likes",@"publish_actions", nil];
    
    BOOL isOpened = [FBSession openActiveSessionWithPublishPermissions:permission
                                                       defaultAudience:FBSessionDefaultAudienceFriends
                                                          allowLoginUI:allowLoginUI
                                                     completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                                         [self sessionStateChanged:session state:status error:error];
                                                     }];
    
    return isOpened;
}


- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                NSLog(@"User session found");
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kFBSessionStateChangedNotification
     object:session];
    
    if (error) {
        FBLog(@"Error : %@", error.localizedDescription);
    }
}


- (void)login{

    [FBSession openActiveSessionWithReadPermissions:@[@"basic_info",@"user_birthday"]
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                      
                                  }];
}


- (void)loginWithReadPermissions:(NSArray*)permissions
                    allowLoginUI:(BOOL)allowLoginUI
                  success:(void (^)(FBSession *session, FBSessionState status))success
                  failure:(void (^)(FBSession *session, FBSessionState status, NSError *error))failure
            olreadyLogged:(void (^)(FBSession *session, FBSessionState status))olreadyLogged{
    
    FBLog(@"FB Start Login");
    
    //! Check is session already opened
    if (FBSession.activeSession.isOpen) {
        FBLog(@"FB Olready Logged In");
        olreadyLogged(FBSession.activeSession, FBSession.activeSession.state);
        return;
    }
    
    
    //! Open session
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:allowLoginUI
                                  completionHandler:^(FBSession *session,
                                                      FBSessionState status,
                                                      NSError *error) {
                                      // if login fails for any reason, we alert
                                      if (error) {
                                          FBLog(@"FB Login Failed");

                                          failure(session, status, error);
                                          // if otherwise we check to see if the session is open, an alternative to
                                          // to the FB_ISSESSIONOPENWITHSTATE helper-macro would be to check the isOpen
                                          // property of the session object; the macros are useful, however, for more
                                          // detailed state checking for FBSession objects
                                      } else if (FB_ISSESSIONOPENWITHSTATE(status)) {
                                          // send our requests if we successfully logged in
                                          FBLog(@"FB Did Login");

                                          success(session, status);
                                      }
                                  }];
}

#pragma mark Logout
- (void)logOut{
    FBLog(@"FB Start Logout");
    
    [FBSession.activeSession closeAndClearTokenInformation];
    self.user = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kFacebookManagerDidLogoutNotification
                                                        object:nil];
    FBLog(@"FB Did Logout");
}


#pragma mark - Request permissions
- (void)requestNewPublishPermissions:(NSArray*)permissions                      //@"publish_actions"
                     defaultAudience:(FBSessionDefaultAudience)defaultAudience
                             success:(void (^)(FBSession *session))success
                             failure:(void (^)(NSError *error))failure
                              cancel:(void (^)(NSError *error))cancel{
    
    FBLog(@"Start requestNewPublishPermissions");
    [FBSession.activeSession requestNewPublishPermissions:permissions
                                          defaultAudience:defaultAudience
                                        completionHandler:^(FBSession *session, NSError *error) {
                                            if (!error) {
                                                
                                                FBLog(@"New Publish Permissions = %@", FBSession.activeSession.permissions);
                                                success(session);
                                                
                                            } else if (error) {
                                                
                                                FBLog(@"%@", error);
                                                // if the operation is user cancelled
                                                if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                                                    cancel(error);
                                                }else{
                                                    failure(error);
                                                }
                                                
                                                //! Error handling example
                                                //if ([FBErrorUtility shouldNotifyUserForError:error]) {[FBErrorUtility userMessageForError:error];}
                                            }
                                        }];
}

- (void)requestNewReadPermissions:(NSArray*)permissions
                             success:(void (^)(FBSession *session))success
                             failure:(void (^)(NSError *error))failure
                              cancel:(void (^)(NSError *error))cancel{
    
    FBLog(@"Start requestNewReadPermissions");
    [FBSession.activeSession requestNewReadPermissions:permissions
                                     completionHandler:^(FBSession *session, NSError *error) {
                                         if (!error) {
                                             
                                             FBLog(@"New Read Permissions = %@", FBSession.activeSession.permissions);
                                             success(session);
                                             
                                         } else if (error) {
                                             
                                             FBLog(@"%@", error);
                                             // if the operation is user cancelled
                                             if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                                                 cancel(error);
                                             }else{
                                                 failure(error);
                                             }
                                             
                                             //! Error handling example
                                             //if ([FBErrorUtility shouldNotifyUserForError:error]) {[FBErrorUtility userMessageForError:error];}
                                         }
                                     }];
}


- (void)loadMeWithSuccess:(void(^)(id<FBGraphUser> user))success
                  failure:(void(^)(FBRequestConnection *connection, id result, NSError *error))failure{

    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser>* result, NSError *error) {
        if (!error) {
            //! Success
            FBLog(@"FB user info: %@", result);
            
            success(result);
            
        } else {
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
            failure(connection, result, error);
        }
    }];
}

- (void)loadFriendsWithSuccess:(void(^)(NSArray* friends))success
                       failure:(void(^)(FBRequestConnection *connection, id result, NSError *error))failure{
    
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, NSArray* result, NSError *error) {
        if (!error) {
            //! Success
            FBLog(@"FB friends info: %@", result);
            
            if ([result isKindOfClass:[NSArray class]]) {
                
                NSMutableArray* friends = [NSMutableArray new];
                
                [result enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL *stop) {
                    if ([obj isKindOfClass:[NSDictionary class]]) {
                        
//                        FBFriend* friend = [FBFriend new];
//                        [friends safeAddObject:friend];
                    }
                }];
                
                success([NSArray arrayWithArray:friends]);
                
            }else{
                
                //! Wrong data format
                NSError* error = [NSError localizedErrorWithDomain:@"FacebookManager"
                                                              code:-1
                                                    andDescription:@"Can't load FB friends"];
                
                failure(connection, result, error);
            }
            
        } else {
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
            failure(connection, result, error);
        }
    }];
}


- (void)loadFriendsForUser:(NSString*)userID
                 pagingURL:(NSString*)paginURL
                   success:(void(^)(NSArray* friends, NSString* nextPage, NSString* prevPage))success
                   failure:(void(^)(FBRequestConnection *connection, id result, NSError *error))failure{

    
    if (paginURL == nil) {
        paginURL = [NSString stringWithFormat:@"%@/taggable_friends?fields=name,picture,birthday,location", userID];
    }
    
    [FBRequestConnection startWithGraphPath:paginURL
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              
                              if (!error) {
                                  if ([result isKindOfClass:[NSDictionary class]]) {
                                      
                                      NSArray* friends = [result safeArrayObjectForKey:@"data"];
                                      
                                      NSDictionary* paging = [result safeDictionaryObjectForKey:@"paging"];
                                      NSString* next = [paging safeStringObjectForKey:@"next"];
                                      NSString* previous = [paging safeStringObjectForKey:@"previous"];
                                      
                                      success(friends, next, previous);
                                      
                                  }else{
                                      NSError* error = [NSError localizedErrorWithDomain:@"com.FacebookManager"
                                                                                    code:-1
                                                                          andDescription:@"FB frriends - wrong response format"];
                                      failure(connection, result, error);
                                  }
                                 
                              } else {
                                  // An error occurred, we need to handle the error
                                  // See: https://developers.facebook.com/docs/ios/errors
                                  failure(connection, result, error);
                              }
                          }];

}

- (void)loadAvatarPhotoInfoForUserId:(NSString*)userId
                                size:(CGSize)size
                             success:(void(^)())success
                             failure:(void(^)(FBRequestConnection *connection, id result, NSError *error))failure{
//https://graph.facebook.com/redbull/picture?width=140&height=110
//    http://graph.facebook.com/517267866/picture?type=large
    NSString* path = [NSString stringWithFormat:@"%@/picture?width=%d&height=%d", userId, (int)size.width, (int)size.height];
    
    [FBRequestConnection startWithGraphPath:path
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error) {
                                  // Success! Include your code to handle the results here
                                  NSLog(@"user events: %@", result);
                                  success(); //! TODO add result
                              } else {
                                  // An error occurred, we need to handle the error
                                  // See: https://developers.facebook.com/docs/ios/errors
                                  
                                  FBLog(@"ERROR: %@", error.localizedDescription);
                                  failure(connection, result, error);
                              }
                          }];

}

- (NSString*)userAvatarURL:(NSString*)userID type:(NSString*)type{ //! type=large
    
    NSString* path = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=%@", userID, type];
    return path;
}



- (void)avatarImageForUser:(NSString*)fbID
                   success:(void (^)(UIImage* image))success
                   failure:(void (^)(NSError* error))failure{
    
    NSString* urlString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", fbID];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:30];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue new]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               if (!connectionError && data) {
                                   //! Create image
                                   UIImage* image = [UIImage imageWithData:data];
                                   
                                   //! Upload image as user profile avatar
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       success(image);
                                   });
                                   
                               }else{
                                   
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       failure(connectionError);
                                   });
                               }
                               
                           }];
    
}

- (void)events{

    [FBRequestConnection startWithGraphPath:@"me/events?fields=cover,name,start_time"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error) {
                                  // Success! Include your code to handle the results here
                                  NSLog(@"user events: %@", result);
                              } else {
                                  // An error occurred, we need to handle the error
                                  // See: https://developers.facebook.com/docs/ios/errors   
                              }
                          }];
}

#pragma mark - Post
- (void)postToFriend:(NSString*)fID
                name:(NSString*)name
               title:(NSString*)title
         description:(NSString*)description
                link:(NSString*)link
         pictureLink:(NSString*)pictureLink
             success:(void(^)(FBRequestConnection *connection, id result, NSError *error))success
             failure:(void(^)(FBRequestConnection *connection, id result, NSError *error))failure

{
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params safeSetObject:name              forKey:@"name"];
    [params safeSetObject:title             forKey:@"caption"];
    [params safeSetObject:description       forKey:@"description"];
    [params safeSetObject:link              forKey:@"link"];
    [params safeSetObject:pictureLink       forKey:@"picture"];
    
    //Post to friend's wall.
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/feed", fID]
                                 parameters:params HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error){
                              
                              if (!error) {
                                  //! Success
                                  FBLog(@"FB postToFriend: %@", result);
                                  
                                  success(connection, result, error);
                                  
                              } else {
                                  // An error occurred, we need to handle the error
                                  // See: https://developers.facebook.com/docs/ios/errors
                                  failure(connection, result, error);
                              }
                          }];
}

#pragma mark handleOpenURL
- (BOOL)handleOpenURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication{

    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    FBLog(@"FB handleOpenURL and return %d", wasHandled);
    
    return wasHandled;
}

#pragma mark _____________________________________________________ Notifications
- (void)applicationDidBecomeActive:(NSNotification*)notif{
    [FBAppEvents activateApp];
    
    FBLog(@"Notification: applicationDidBecomeActive");
    // FBSample logic
    // We need to properly handle activation of the application with regards to SSO
    //  (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
    [FBAppCall handleDidBecomeActiveWithSession:FBSession.activeSession];

}

// FBSample logic
// Whether it is in applicationWillTerminate, in applicationDidEnterBackground, or in some other part
// of your application, it is important that you close an active session when it is no longer useful
// to your application; if a session is not properly closed, a retain cycle may occur between the block
// and an object that holds a reference to the session object; close releases the handler, breaking any
// inadvertant retain cycles
- (void)applicationWillTerminate:(UIApplication *)application {
    FBLog(@"Notification: applicationWillTerminate");
    // FBSample logic
    // if the app is going away, we close the session if it is open
    // this is a good idea because things may be hanging off the session, that need
    // releasing (completion block, etc.) and other components in the app may be awaiting
    // close notification in order to do cleanup
    [FBSession.activeSession close];
}

@end
