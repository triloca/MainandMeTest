//
//  IntroCell.h
//  MainAndMeios7
//
//  Created by Alexanedr on 11/13/16.
//  Copyright © 2016 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroPresentEndCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (copy, nonatomic) void (^didClickEndTutorial)(IntroPresentEndCell* obj);

@property (copy, nonatomic) void (^didClickReadGetStarted)(IntroPresentEndCell* obj);
@property (copy, nonatomic) void (^didClickAddItem)(IntroPresentEndCell* obj);
@property (copy, nonatomic) void (^didClickAddLocalBussines)(IntroPresentEndCell* obj);
@property (copy, nonatomic) void (^didClickWindshop)(IntroPresentEndCell* obj);
@property (copy, nonatomic) void (^didClickChat)(IntroPresentEndCell* obj);

@end
