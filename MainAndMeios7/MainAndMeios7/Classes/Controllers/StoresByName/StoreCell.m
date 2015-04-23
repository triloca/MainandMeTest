//
//  StoreCell.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 14.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "StoreCell.h"

@implementation StoreCell

- (void) setStore: (NSDictionary *) store {
    self.titleLabel.text = [store safeObjectForKey:@"name"];
}

@end
