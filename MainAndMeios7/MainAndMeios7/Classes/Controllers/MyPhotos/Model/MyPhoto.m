//
//  MyPhoto.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 4/28/15.
//  Copyright (c) 2015 Uniprog. All rights reserved.
//

#import "MyPhoto.h"



@implementation MyPhoto

+ (void)saveMyPhotos:(NSArray*)array{
    
    NSString * path = [self pathForDataFile:@"myphotos"];
    
    NSMutableDictionary * rootObject;
    rootObject = [NSMutableDictionary dictionary];
    
    [rootObject setValue:array forKey:@"myPhotos"];
    [NSKeyedArchiver archiveRootObject:rootObject toFile:path];
}

+ (NSArray*)loadDataFromDisk{
    
    NSString     * path         = [self pathForDataFile:@"myphotos"];
    NSDictionary * rootObject;
    
    rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    return [rootObject valueForKey:@"myPhotos"];
}


+ (NSString*)storePath{
    
    NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    
    NSString *librarysDir = [libraryPaths objectAtIndex:0];
    NSString *folder = [librarysDir stringByAppendingPathComponent:@"Caches/MyPhotos"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if (![fileManager fileExistsAtPath:folder]) {
        [fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:&error];
        
        //! Remove iCloud sync
        NSURL *url = [NSURL fileURLWithPath:folder];
        [self addSkipBackupAttributeToItemAtURL:url];
        
    }
    if (error != nil) {
        NSLog(@"Some error: %@", error);
        return librarysDir;
    }
    return folder;
}

+ (NSString*)pathForDataFile:(NSString*)name{
    
    NSString *theFileName = [NSString stringWithFormat:@"%@.data", name];
    
    NSString *databasePath = [[self storePath] stringByAppendingPathComponent:theFileName];
    
    return databasePath;
}

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL{
    
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}


+ (NSString*)saveImage:(UIImage*)image{
    
    if (image) {
        NSString* fileName = [NSUUID UUID].UUIDString;
        NSString* fullFilePath = [[self storePath] stringByAppendingPathComponent:fileName];
        
        [UIImagePNGRepresentation(image) writeToFile:fullFilePath atomically:YES];
        return fileName;
    }
    return nil;
}

+ (void)removeFileWithName:(NSString*)name{
    NSString* fullFilePath = [[self storePath] stringByAppendingPathComponent:name];
    [[NSFileManager defaultManager] removeItemAtPath:fullFilePath error:nil];
}

- (id) initWithCoder: (NSCoder *)coder{
    
    if (self = [super init]){
        
        [self setImagePath:[coder decodeObjectForKey:@"imagePath"]];
        [self setStoreName:[coder decodeObjectForKey:@"storeName"]];
        [self setCreatedAt:[coder decodeObjectForKey:@"createdAt"]];
        [self setGuid:[coder decodeObjectForKey:@"guid"]];
        
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *)coder{
    
    [coder encodeObject:self.imagePath forKey:@"imagePath"];
    [coder encodeObject:self.storeName forKey:@"storeName"];
    [coder encodeObject:self.createdAt forKey:@"createdAt"];
    [coder encodeObject:self.guid forKey:@"guid"];

}


- (void)addToStore{

    if (self.guid == nil) {
        self.guid = [NSUUID UUID].UUIDString;
    }
    
    NSArray* photos = [MyPhoto loadDataFromDisk];
    NSMutableArray* temp = [NSMutableArray arrayWithArray:photos];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"guid == %@", self.guid];
    MyPhoto* myPhoto = [[temp filteredArrayUsingPredicate:predicate] firstObject];
   
    if (myPhoto) {
        [temp replaceObjectAtIndex:[temp indexOfObject:myPhoto]
                        withObject:self];
    }else{
        [temp insertObject:self atIndex:0];
    }
    
    
    [MyPhoto saveMyPhotos:[NSArray arrayWithArray:temp]];
    
}

- (void)removeFromStore{
    
    NSArray* photos = [MyPhoto loadDataFromDisk];
    NSMutableArray* temp = [NSMutableArray arrayWithArray:photos];
    for (MyPhoto* photo in photos) {
        if ([photo.imagePath isEqualToString:self.imagePath]) {
            
            [MyPhoto removeFileWithName:photo.imagePath];
            [temp removeObject:photo];
        }
    }
    
    [MyPhoto saveMyPhotos:[NSArray arrayWithArray:temp]];

}

- (NSString*)pathForLocalImage{
    return [[MyPhoto storePath] stringByAppendingPathComponent:self.imagePath];
}


@end
