//
//  UploadStoreRequest.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 04.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "FileRequest.h"

@interface UploadStoreRequest : FileRequest

//request
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *street;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSString *zipCode;
@property (strong, nonatomic) NSString *storeDescription;
@property (strong, nonatomic) UIImage *image;

@property (strong, nonatomic) NSString *apiToken;
@end
