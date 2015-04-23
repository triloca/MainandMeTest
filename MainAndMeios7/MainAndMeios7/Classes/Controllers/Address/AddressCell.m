//
//  AddressCell.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 14.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "AddressCell.h"

@implementation AddressCell

- (void) setAddress: (NSDictionary *) address {
    self.titleLabel.text = [address safeObjectForKey:@"Name"];
}

@end
