//
//  HighlightingTableViewCell.h
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 14.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CellFontHighlighted @"HelveticaNeue-Medium"
#define CellFontNormal @"HelveticaNeue-Light"
#define CellFontSize 18.f

@interface HighlightingTableViewCell : UITableViewCell

@property (nonatomic) BOOL backlighted;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@end
