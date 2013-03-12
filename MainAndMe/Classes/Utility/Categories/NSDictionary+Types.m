//
//  NSDictionary+Types.m
//  MainAndMe
//
//  Created by Sasha on 3/11/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


#import "NSDictionary+Types.h"


@implementation NSDictionary(Types)


- (id) objectForKey: (id)        key
					 withType: (NSString*) type
{
	id object = [self objectForKey: key];
	
	Class class = NSClassFromString(type);
	
	if ([object isKindOfClass: class])
		return object;
	else
	if ([type isEqualToString: @"NSString"] && ![object isKindOfClass: [NSNull class]])
		return [object description];
	
	return nil;
}


@end