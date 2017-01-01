//
//  IntroCell.h
//  MainAndMeios7
//
//  Created by Alexanedr on 11/13/16.
//  Copyright © 2016 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroPresentCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;

@property (copy, nonatomic) void (^didClickChatButton)(IntroPresentCell* sender);

@property (copy, nonatomic) void (^didClickHomeButton)(IntroPresentCell* sender);
@end
