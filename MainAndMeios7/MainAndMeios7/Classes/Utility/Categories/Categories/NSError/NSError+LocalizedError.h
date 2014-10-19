//
//  NSError+LocalizedError.h
//  iC
//
//  Created by Alexander on 4/3/14.
//  Copyright (c) 2014 quadecco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (LocalizedError)


+ (NSError*)localizedErrorWithDomain:(NSString*)domain
                                code:(NSInteger)code
                      andDescription:(NSString*)description;



@end
