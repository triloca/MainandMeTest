//
//  MyPhoto.h
//  MainAndMeios7
//
//  Created by Alexander Bukov on 4/28/15.
//  Copyright (c) 2015 Uniprog. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface MyPhoto : NSObject
@property (strong, nonatomic) NSString* imagePath;
@property (strong, nonatomic) NSString* storeName;
@property (strong, nonatomic) NSDate* createdAt;
@property (strong, nonatomic) NSString* guid;


+ (void)saveMyPhotos:(NSArray*)array;
+ (NSArray*)loadDataFromDisk;

+ (NSString*)saveImage:(UIImage*)image;
+ (void)removeFileWithName:(NSString*)name;

- (void)addToStore;
- (void)removeFromStore;

- (NSString*)pathForLocalImage;

@end
