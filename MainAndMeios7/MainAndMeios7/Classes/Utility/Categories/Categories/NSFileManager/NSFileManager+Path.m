//
//  NSFileManager+Path.m
//  TennisBattle
//
//  Created by Sasha on 10/21/13.
//  Copyright (c) 2013 uniprog. All rights reserved.
//

#import "NSFileManager+Path.h"

@implementation NSFileManager (Path)

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
+ (NSURL *)applicationDocumentsDirectoryURL
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
