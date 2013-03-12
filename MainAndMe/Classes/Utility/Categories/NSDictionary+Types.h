//
//  NSDictionary+Types.h
//  MainAndMe
//
//  Created by Sasha on 3/11/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


@interface NSDictionary(Types)

//! Returns object for the given key with given type
- (id) objectForKey: (id)        key
					 withType: (NSString*) type;

@end