//
//  AddPhotoViewController.h
//  MainAndMeios7
//
//  Created by Alexander Bukov on 4/30/15.
//  Copyright (c) 2015 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKImagePickerViewController.h"

@interface AddPhotoViewController : PKImagePickerViewController
@property (strong, nonatomic) UIImage *photoImage;
@property (copy, nonatomic) void (^didClickCancel)(AddPhotoViewController* obj);
@property (copy, nonatomic) void (^didClickFinish)(AddPhotoViewController* obj);
@property (copy, nonatomic) void (^didClickShare)(AddPhotoViewController* obj, NSDictionary* prod, NSArray *wishlists);

@end
