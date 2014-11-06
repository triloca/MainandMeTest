//
//  FileRequest.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ServiceRequest.h"

@interface FileRequest : ServiceRequest

@property (nonatomic) BOOL isUpload;

//if filePath returns nil, all data should be here
@property (nonatomic, strong) NSData *fileData;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) UIImage *image;

- (NSString *) formFileField;
- (NSString *) filePath;


@end
