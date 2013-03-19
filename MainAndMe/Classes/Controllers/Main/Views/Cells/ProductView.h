//
//  ProductView.h
//  MainAndMe
//
//  Created by Sasha on 2/26/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


@interface ProductView : UIView
@property (retain, nonatomic) IBOutlet UIButton *textLabel;
@property (retain, nonatomic) IBOutlet UIButton *coverButton;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;

- (void)setImageURLString:(NSString*)imageURLString;
@end
