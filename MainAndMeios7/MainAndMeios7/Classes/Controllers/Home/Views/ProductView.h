//
//  ProductView.h
//  MainAndMe
//
//  Created by Sasha on 2/26/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


@interface ProductView : UIView

@property (retain, nonatomic) IBOutlet UILabel *textLabel;
@property (retain, nonatomic) IBOutlet UIButton *coverButton;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UIImageView *badgeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;

- (void)setImageURLString:(NSString*)imageURLString;
- (void)setimagePath:(NSString*)path;

- (void)startVibration;
- (void)stopVibration;


- (void)setSelectedPhoto:(BOOL)selected;
- (void)hideSelectionImage:(BOOL)value;

@end
