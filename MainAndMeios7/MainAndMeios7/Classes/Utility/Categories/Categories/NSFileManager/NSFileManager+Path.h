//
//  NSFileManager+Path.h
//  TennisBattle
//
//  Created by Sasha on 10/21/13.
//  Copyright (c) 2013 uniprog. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Path)
#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
+ (NSURL *)applicationDocumentsDirectoryURL;

@end
