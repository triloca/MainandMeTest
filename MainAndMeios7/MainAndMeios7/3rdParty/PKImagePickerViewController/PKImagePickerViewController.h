//
//  MyImagePickerViewController.h
//  cameratestapp
//
//  Created by pavan krishnamurthy on 6/24/14.
//  Copyright (c) 2014 pavan krishnamurthy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PKImagePickerViewControllerDelegate <NSObject>

-(void)imageSelected:(UIImage*)img;
-(void)imageSelectionCancelled;

@end

@interface PKImagePickerViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property(nonatomic,strong, readonly) UIImageView *capturedImageView;
@property(nonatomic,strong, readonly) UIView *imageSelectedView;
@property(nonatomic,strong, readonly) UIImage *selectedImage;

@property(nonatomic,weak) id<PKImagePickerViewControllerDelegate> delegate;

-(void)capturePhotoCompetion:(void (^)(UIImage* image, NSError* error))completion;

@end
