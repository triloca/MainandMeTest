//
//  ProductCell.h
//  MainAndMe
//
//  Created by Sasha on 2/26/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ProductView.h"

@interface ProductCell : UITableViewCell
@property (retain, nonatomic) ProductView *firstView;
@property (retain, nonatomic) ProductView *secondView;
@property (retain, nonatomic) ProductView *thirdView;

@property (copy, nonatomic) void (^didClickAtIndex)(NSInteger index);

@end
