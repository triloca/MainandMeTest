//
//  ServiceRequest.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 29.10.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestError.h"
#import "NSDictionary+Safe.h"
#import "NSMutableDictionary+Safe.h"

@interface ServiceRequest : NSObject

//to override
- (NSString *) acceptableContentType;
- (NSString *) method;
- (NSString *) path;
- (NSDictionary *) requestDictionary;
- (void) processResponse: (NSObject *) response;
- (RequestError *) validateResponse:(NSDictionary*) responseDictionary httpResponse:(NSHTTPURLResponse *) httpResponse;


//response
@property (strong, nonatomic) NSObject *response;
@end
