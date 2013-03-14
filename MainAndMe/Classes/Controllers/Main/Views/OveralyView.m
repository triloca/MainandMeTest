//
//  OveralyView.m
//  MainAndMe
//
//  Created by Sasha on 3/13/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "OveralyView.h"


@interface OveralyView()

@end


@implementation OveralyView

- (void)awakeFromNib{
    // Init code
}


- (IBAction)overalyButtonClicked:(id)sender {
    if (_didClickOveraly) {
        _didClickOveraly();
    }
}

@end
