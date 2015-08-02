//
//  StoreNamePickerView.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 5/4/15.
//  Copyright (c) 2015 Uniprog. All rights reserved.
//

#import "StoreNamePickerView.h"

@interface StoreNamePickerView ()
@property (strong, nonatomic) NSArray* pickerArray;
@end

@implementation StoreNamePickerView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
        [self load];
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self load];
    }
    return self;
}

- (void)load{
    
    UIView* content = [[[NSBundle bundleForClass:[self class]] loadNibNamed:NSStringFromClass([self class])
                                                                      owner:self
                                                                    options:nil] firstObject];
    [self addSubview:content];
    
    content.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[content]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(content)]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[content]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(content)]];
    
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    self.okButton.layer.cornerRadius = 5;
    self.okButton.layer.borderColor = [UIColor grayColor].CGColor;
    self.okButton.layer.borderWidth = 1;
    
    self.cancelButton.layer.cornerRadius = 5;
    self.cancelButton.layer.borderColor = [UIColor grayColor].CGColor;
    self.cancelButton.layer.borderWidth = 1;
    
    
}


- (void)setPickerArray:(NSArray *)pickerArray{

    _pickerArray = pickerArray;
    [self.pickerView reloadAllComponents];
}

- (IBAction)onCancelButton:(id)sender {
    if (_onCancelButton) {
        _onCancelButton(self, sender);
    }
}

- (IBAction)onOkButton:(id)sender {
    NSInteger row = [self.pickerView selectedRowInComponent:0];
    NSDictionary* store = [self.pickerArray safeDictionaryObjectAtIndex:row];
    
    if (_onOkButton) {
        _onOkButton(self, store, sender);
    }
}

#pragma mark - Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return _pickerArray.count;
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    NSDictionary* store = [_pickerArray safeDictionaryObjectAtIndex:row];
    return [store safeStringObjectForKey:@"name"];
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if (_onPickerSelectValue) {
        _onPickerSelectValue(self, pickerView, row);
    }

}

@end
