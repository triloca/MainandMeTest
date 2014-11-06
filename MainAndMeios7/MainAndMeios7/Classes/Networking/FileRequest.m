//
//  FileRequest.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "FileRequest.h"

@implementation FileRequest

- (NSString *) filePath {
    return nil;
}

- (void) setImage:(UIImage *)image {
    if (image == _image)
        return;
    
    _image = image;
    [self setFileData:UIImageJPEGRepresentation(image, 0.8)];
}

- (NSString *) acceptableContentType {
    return self.isUpload ? [super acceptableContentType] : nil;
}

- (NSString *) formFileField {
    return @"product[image]";
}


@end
