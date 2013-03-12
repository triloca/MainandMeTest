//
//  APIv1_0.m
//  MainAndMe
//
//  Created by Sasha on 2/25/13.
//
//

#import "APIv1_0.h"
//mainandme-staging-s.herokuapp.com
//NSString * const kServerURL = @"http://mainandme-staging-s.herokuapp.com/api/v1";
NSString * const kServerURL = @"http://mainandme-test.herokuapp.com/api/v1";

NSString * const kServerBaseURL = @"http://mainandme-staging-s.herokuapp.com";
NSString * const kServerAPIVersion = @"/api/v1";

@implementation APIv1_0

+ (NSString*)serverUrl{
    return [NSString stringWithFormat:@"%@%@", kServerBaseURL, kServerAPIVersion];
}

@end
