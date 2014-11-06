//
//  UploadProductRequest.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "FileRequest.h"

@interface UploadProductRequest : FileRequest

//request
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *price;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSString *storeName;
@property (strong, nonatomic) NSString *productDescription;

//authorization
@property (strong, nonatomic) NSString *apiToken;

@end
