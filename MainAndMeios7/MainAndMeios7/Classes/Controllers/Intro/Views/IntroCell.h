//
//  IntroCell.h
//  MainAndMeios7
//
//  Created by Alexanedr on 11/13/16.
//  Copyright © 2016 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *skipButton;

@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (copy, nonatomic) void (^didClickEndTutorial)(IntroCell* obj);

@end
