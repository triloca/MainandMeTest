//
//  IntroCell.h
//  MainAndMeios7
//
//  Created by Alexanedr on 11/13/16.
//  Copyright © 2016 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroEndCell : UICollectionViewCell
    @property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
    @property (copy, nonatomic) void (^didClickEndTutorial)(IntroEndCell* obj);
    
    @property (copy, nonatomic) void (^didClickSeeTowns)(IntroEndCell* obj);
    @property (copy, nonatomic) void (^didClickAddItem)(IntroEndCell* obj);
    @property (copy, nonatomic) void (^didClickAddLocalBussines)(IntroEndCell* obj);
    @property (copy, nonatomic) void (^didClickWindshop)(IntroEndCell* obj);
    @property (copy, nonatomic) void (^didClickSeeBenefits)(IntroEndCell* obj);
    
    @end
