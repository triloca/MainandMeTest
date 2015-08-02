//
//  StoreNamePickerView.h
//  MainAndMeios7
//
//  Created by Alexander Bukov on 5/4/15.
//  Copyright (c) 2015 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoreNamePickerView : UIView

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (copy, nonatomic) void (^onOkButton)(StoreNamePickerView* view, NSDictionary* store, UIButton* button);
@property (copy, nonatomic) void (^onCancelButton)(StoreNamePickerView* view, UIButton* button);
@property (copy, nonatomic) void (^onPickerSelectValue)(StoreNamePickerView* view, UIPickerView* picker, NSInteger row);

- (void)setPickerArray:(NSArray *)pickerArray;

@end
