//
//  PickerView.h
//  MainAndMe
//
//  Created by Sasha on 3/22/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


@interface PickerView : UIView
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;


@property (copy, nonatomic) void (^didClickCancel)();
@property (copy, nonatomic) void (^didClickDone)();
@end
