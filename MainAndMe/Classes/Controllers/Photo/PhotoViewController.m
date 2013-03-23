//
//  PhotoViewController.m
//  MainAndMe
//
//  Created by Sasha on 3/21/13.
//
//

#import "PhotoViewController.h"
#import "LayoutManager.h"
#import "PickerView.h"
#import "UIView+Common.h"
#import "SearchManager.h"
#import "AlertManager.h"
#import "ProductsStoresManager.h"

@interface PhotoViewController ()<UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIButton *itemButton;
@property (weak, nonatomic) IBOutlet UIButton *storefrontButton;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *priceTextField;
@property (weak, nonatomic) IBOutlet UITextField *categoryTextField;
@property (weak, nonatomic) IBOutlet UITextField *storeNameTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UITextField *storefrontNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *countryTextField;
@property (weak, nonatomic) IBOutlet UITextField *stateTextField;
@property (weak, nonatomic) IBOutlet UITextField *streetTextField;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UITextField *postalCodeTextField;
@property (weak, nonatomic) IBOutlet UITextView *storeDescriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *storePhotoImageView;

@property (assign, nonatomic) BOOL isStoreState;

@property (strong, nonatomic) PickerView* pickerView;
@property (strong, nonatomic) NSArray* priceRangeArray;
@property (strong, nonatomic) NSArray* categoryArray;

@property (assign, nonatomic) BOOL isKeyBoardVisible;
@property (assign, nonatomic) BOOL isPickerVisible;

@property (strong, nonatomic) UIImage* photo;

@property (strong, nonatomic) IBOutlet UIScrollView *storeScrollView;
@end

@implementation PhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _titleTextLabel.font = [UIFont fontWithName:@"Perec-SuperNegra" size:22];
    _titleTextLabel.text = @"Add/Edit Photo";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    _priceRangeArray = [NSArray arrayWithObjects:
                        @"$50-$100", @"$100-$200", @"$200-$300",
                        @"$300-$400", @">500", nil];
      
    _pickerView = [PickerView loadViewFromXIB];
    
    __weak PhotoViewController* weakSelf = self;
    _pickerView.didClickCancel = ^{
        [weakSelf hideCategoryPicker];
    };
    
    _pickerView.didClickDone = ^{
        [weakSelf hideCategoryPicker];
    };
    
    _pickerView.pickerView.delegate = self;
    _pickerView.pickerView.dataSource = self;
    [self.view addSubview:_pickerView];
    
    [_itemButton setBackgroundImage:[_itemButton backgroundImageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted | UIControlStateSelected];
    [_storefrontButton setBackgroundImage:[_storefrontButton backgroundImageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted | UIControlStateSelected];
    
    _itemButton.selected = YES;
    
    [self.view addSubview:_storeScrollView];
    _storeScrollView.hidden = YES;
    _storeScrollView.frame = _scrollView.frame;
    
    [self loadCategories];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   
    CGRect rc = _pickerView.frame;
    rc.origin.y = CGRectGetMaxY(self.view.frame);
    _pickerView.frame = rc;
}

- (void)viewDidUnload {
    [self setTitleTextLabel:nil];
    [self setDoneButton:nil];
    [self setPhotoImageView:nil];
    [self setItemButton:nil];
    [self setStorefrontButton:nil];
    [self setNameTextField:nil];
    [self setPriceTextField:nil];
    [self setCategoryTextField:nil];
    [self setStoreNameTextField:nil];
    [self setDescriptionTextView:nil];
    [self setScrollView:nil];
    [self setStoreScrollView:nil];
    [self setStorefrontNameTextField:nil];
    [self setCountryTextField:nil];
    [self setStateTextField:nil];
    [self setStreetTextField:nil];
    [self setCityTextField:nil];
    [self setPostalCodeTextField:nil];
    [self setStorePhotoImageView:nil];
    [self setStoreDescriptionTextView:nil];
    [super viewDidUnload];
}

#pragma mark - Buttons Action
- (IBAction)backButtonClicked:(id)sender {
    [self hideKeyboard];
    [self hideCategoryPicker];
    [[LayoutManager shared].rootTabBarController hidePhotoView];
}

- (IBAction)doneButtonClicked:(id)sender {
    [self hideKeyboard];
    [self hideCategoryPicker];
    [self uploadItem];
}

- (IBAction)itemButtonClicked:(id)sender {
    [self hideKeyboard];
    [self hideCategoryPicker];
    [self.view bringSubviewToFront:_scrollView];
    [self.view bringSubviewToFront:_pickerView];
    [UIView animateWithDuration:0.3
                     animations:^{
                         _storeScrollView.alpha = 0;
                         _scrollView.hidden = NO;
                         _scrollView.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         _storeScrollView.hidden = YES;
                         _storeScrollView.alpha = 1;
                         _isStoreState = NO;
                     }];
}

- (IBAction)storefrontButtonClicked:(id)sender {
    [self hideKeyboard];
    [self hideCategoryPicker];
    [self.view bringSubviewToFront:_storeScrollView];
    [self.view bringSubviewToFront:_pickerView];
    [UIView animateWithDuration:0.3
                     animations:^{
                         _scrollView.alpha = 0;
                         _storeScrollView.hidden = NO;
                         _storeScrollView.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         _scrollView.hidden = YES;
                         _scrollView.alpha = 1;
                         _isStoreState = YES;
                     }];
}

#pragma mark - Public Methods
- (void)setPhoto:(UIImage*)photo{
    _photoImageView.image = photo;
    _storePhotoImageView.image = photo;
    _photo = photo;
}

#pragma mark - Keyboard Notificastion

- (void)keyboardWillShow:(NSNotification*)nitif{
    _isKeyBoardVisible = YES;
    [self updateContentSize];
}


- (void)keyboardWillHide:(NSNotification*)nitif{
    _isKeyBoardVisible = NO;
    [self updateContentSize];
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if (_categoryTextField == textField) {
        _pickerView.pickerView.tag = 1;
        [_pickerView.pickerView reloadAllComponents];
        [_pickerView.pickerView selectRow:0 inComponent:0 animated:NO];
        [self showCategoryPicker];
        [self hideKeyboard];
        [self scrollToTextField:textField];
        return NO;
    }
    if (_priceTextField == textField) {
        _pickerView.pickerView.tag = 0;
        [_pickerView.pickerView reloadAllComponents];
        [_pickerView.pickerView selectRow:0 inComponent:0 animated:NO];
        [self showCategoryPicker];
        [self hideKeyboard];
        [self scrollToTextField:textField];
        return NO;
    }
    [self hideCategoryPicker];
    [self scrollToTextField:textField];
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldDidBeginEditing");
    _isKeyBoardVisible = YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldEndEditing");
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //[textField resignFirstResponder];
    [self jampToNextTextField:textField];
    return YES;
}

#pragma mark - TextView Delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    [self hideCategoryPicker];
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if (_isStoreState) {
        [_storeScrollView setContentOffset:CGPointMake(0, textView.frame.origin.y - 100) animated:YES];
    }else{
        [_scrollView setContentOffset:CGPointMake(0, textView.frame.origin.y - 100) animated:YES];
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    return YES;
}


#pragma mark - Picker Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView; {
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {

    if (pickerView.tag == 0) {
       _priceTextField.text = [_priceRangeArray safeStringObjectAtIndex:row];
    }else{
        _categoryTextField.text = [[_categoryArray safeDictionaryObjectAtIndex:row] safeStringObjectForKey:@"name"];
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component; {
    if (pickerView.tag == 0) {
        return [_priceRangeArray count];
    }else {
        return [_categoryArray count];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component; {
    if (pickerView.tag == 0) {
        return [_priceRangeArray objectAtIndex:(NSUInteger) row];
    }
    else {
        return [[_categoryArray objectAtIndex:(NSUInteger) row] objectForKey:@"name"];
    }
}

#pragma mark - Privat Methods

- (void)updateContentSize{
    CGFloat height = _scrollView.frame.size.height;
    if (_isKeyBoardVisible || _isPickerVisible) {
        [_scrollView setContentSize:CGSizeMake(0, height + 220)];
        [_storeScrollView setContentSize:CGSizeMake(0, height + 220)];
    }else{
        
        [UIView animateWithDuration:0.3 animations:^{
            [_scrollView setContentSize:CGSizeMake(0, height)];
            [_scrollView setContentOffset:CGPointMake(0, 0)];
            [_storeScrollView setContentSize:CGSizeMake(0, height)];
            [_storeScrollView setContentOffset:CGPointMake(0, 0)];
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)scrollToTextField:(UITextField*)textField {
    if (textField == _nameTextField || textField == _storefrontNameTextField) {
        if (_isStoreState) {
           [_storeScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        }else{
            [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
    
    }else{
        if (_isStoreState) {
            [_storeScrollView setContentOffset:CGPointMake(0, textField.frame.origin.y - 100) animated:YES];
        }else{
            [_scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y - 100) animated:YES];
        }
    }
}

- (void)jampToNextTextField:(UITextField*)textField{
    if (textField == _nameTextField) {
        
        [_storeNameTextField becomeFirstResponder];
    }else if (textField == _storeNameTextField) {
        
        [_descriptionTextView becomeFirstResponder];
    }else if (textField == _storefrontNameTextField) {
        
        [_countryTextField becomeFirstResponder];
    }else if (textField == _countryTextField) {
        
        [_stateTextField becomeFirstResponder];
    }else if (textField == _stateTextField) {
        
        [_streetTextField becomeFirstResponder];
    }else if (textField == _streetTextField) {
        
        [_cityTextField becomeFirstResponder];
    }else if (textField == _cityTextField) {
        
        [_postalCodeTextField becomeFirstResponder];
    }else if (textField == _postalCodeTextField) {
        
        [_storeDescriptionTextView becomeFirstResponder];
    }
    
}


- (void)hideKeyboard{
    [_nameTextField resignFirstResponder];
    [_storeNameTextField resignFirstResponder];
    [_descriptionTextView resignFirstResponder];
    
    [_storefrontNameTextField resignFirstResponder];
    [_countryTextField resignFirstResponder];
    [_stateTextField resignFirstResponder];
    [_streetTextField resignFirstResponder];
    [_cityTextField resignFirstResponder];
    [_postalCodeTextField resignFirstResponder];
}

- (void)showCategoryPicker{
    _isPickerVisible = YES;
    [self updateContentSize];
    [UIView animateWithDuration:0.3
                     animations:^{
                         CGRect rc = _pickerView.frame;
                         rc.origin.y = CGRectGetMaxY(self.view.frame) - 260;
                         _pickerView.frame = rc;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)hideCategoryPicker{
    _isPickerVisible = NO;
    [self updateContentSize];
    [UIView animateWithDuration:0.3
                     animations:^{
                         CGRect rc = _pickerView.frame;
                         rc.origin.y = CGRectGetMaxY(self.view.frame);
                         _pickerView.frame = rc;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}


- (void)loadCategories{
    [self showSpinnerWithName:@"PhotoViewController"];
    [SearchManager loadCcategiriesSuccess:^(NSArray *categories) {
        [self hideSpinnerWithName:@"PhotoViewController"];
        _categoryArray = categories;
    }
                                  failure:^(NSError *error, NSString *errorString) {
                                      [self hideSpinnerWithName:@"PhotoViewController"];
                                      [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                          message:errorString];
                                  }
                                exception:^(NSString *exceptionString) {
                                    [self hideSpinnerWithName:@"PhotoViewController"];
                                    [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                }];
}


- (void)uploadItem{
    
    [self showSpinnerWithName:@"PhotoViewController"];
    [ProductsStoresManager uploadItemWithType:@""
                                        price:@"100"
                                     category:_categoryTextField.text
                                         name:_nameTextField.text
                                    storeName:_storeNameTextField.text
                                  description:_descriptionTextView.text
                                        image:_photo
                                      success:^(NSDictionary *object) {
                                          [self hideSpinnerWithName:@"PhotoViewController"];
                                          
                                      }
                                      failure:^(NSError *error, NSString *errorString) {
                                          [self hideSpinnerWithName:@"PhotoViewController"];
                                          [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                              message:errorString];
                                      }
                                    exception:^(NSString *exceptionString) {
                                        [self hideSpinnerWithName:@"PhotoViewController"];
                                        [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                    }];

}


@end
