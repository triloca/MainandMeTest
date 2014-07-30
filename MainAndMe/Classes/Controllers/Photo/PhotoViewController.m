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
#import "ProductDetailViewController.h"
#import "SearchStoreViewController.h"

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
@property (weak, nonatomic) IBOutlet UITextField *storeCategoryTextField;

@property (weak, nonatomic) IBOutlet UITextField *storefrontNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *countryTextField;
@property (weak, nonatomic) IBOutlet UITextField *stateTextField;
@property (weak, nonatomic) IBOutlet UITextField *streetTextField;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UITextField *postalCodeTextField;
@property (weak, nonatomic) IBOutlet UITextView *storeDescriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *storePhotoImageView;

@property (strong, nonatomic) NSString* priceValue;


@property (assign, nonatomic) BOOL isStoreState;
@property (strong, nonatomic) NSArray* storesArray;

@property (strong, nonatomic) PickerView* pickerView;
@property (strong, nonatomic) NSArray* priceRangeArray;
@property (strong, nonatomic) NSArray* categoryArray;
@property (strong, nonatomic) NSArray* statesArray;
@property (strong, nonatomic) NSDictionary* statesDictionary;
@property (assign, nonatomic) NSInteger stateIndex;

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
    
    self.screenName = @"Photo screen";

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
                        @"$0-$25", @"$25-$50",
                        @"$50-$100", @"$100-$200", @"$200-$500",
                        @"$500-$1000", @"$1000 and up", nil];
    
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
    [self loadAddresses];
    //[self loadStores];
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
    [self setStoreCategoryTextField:nil];
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
    if (_scrollView.hidden == NO) {
        if ([self validateProduct]) {
            [self uploadProducts];
        }
    }else if (_storeScrollView.hidden == NO) {
        if ([self validateStore]) {
            [self uploadStore];
        }
    }
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
    
    if (_categoryTextField == textField || _storeCategoryTextField == textField) {
        _pickerView.pickerView.tag = 1;
        [_pickerView.pickerView reloadAllComponents];
        [_pickerView.pickerView selectRow:0 inComponent:0 animated:NO];
        if ([_categoryArray count] > 0) {
            [self pickerView:_pickerView.pickerView didSelectRow:0 inComponent:0];
            [self showCategoryPicker];
            [self hideKeyboard];
            [self scrollToTextField:textField];
        }else{
            [[AlertManager shared] showOkAlertWithTitle:@"Category list is empty.\nPlease reload page."];
        }
        return NO;
    }
    if (_priceTextField == textField) {
        _pickerView.pickerView.tag = 0;
        [_pickerView.pickerView reloadAllComponents];
        [_pickerView.pickerView selectRow:0 inComponent:0 animated:NO];
        [self pickerView:_pickerView.pickerView didSelectRow:0 inComponent:0];
        [self showCategoryPicker];
        [self hideKeyboard];
        [self scrollToTextField:textField];
        return NO;
    }
    
    if (_stateTextField == textField) {
        _pickerView.pickerView.tag = 2;
        [_pickerView.pickerView reloadAllComponents];
        [_pickerView.pickerView selectRow:0 inComponent:0 animated:NO];
        if ([_statesArray count] > 0) {
            [self pickerView:_pickerView.pickerView didSelectRow:0 inComponent:0];
            [self showCategoryPicker];
            [self hideKeyboard];
            [self scrollToTextField:textField];
        }else{
            [[AlertManager shared] showOkAlertWithTitle:@"State list is empty.\nPlease reload page."];
        }
        return NO;
    }

    if (_storeNameTextField == textField) {
        [self hideKeyboard];
        [self hideCategoryPicker];
        [self showStoreSearch];
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
        switch (row) {
            case 0:
                _priceValue = @"25";
                break;
            case 1:
                _priceValue = @"50";
                break;
            case 2:
                _priceValue = @"100";
                break;
            case 3:
                _priceValue = @"200";
                break;
            case 4:
                _priceValue = @"500";
                break;
            case 5:
                _priceValue = @"1000";
                break;
            case 6:
                _priceValue = @"10000";
                break;
                
            default:
                break;
        }
    }else if (pickerView.tag == 1) {
        _categoryTextField.text = [[_categoryArray safeDictionaryObjectAtIndex:row] safeStringObjectForKey:@"name"];
        _storeCategoryTextField.text = [[_categoryArray safeDictionaryObjectAtIndex:row] safeStringObjectForKey:@"name"];
    }else if (pickerView.tag == 2) {
        _stateTextField.text = [[_statesArray safeDictionaryObjectAtIndex:row] safeStringObjectForKey:@"Name"];
        _stateIndex = row;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component; {
    if (pickerView.tag == 0) {
        return [_priceRangeArray count];
    }else if (pickerView.tag == 1) {
        return [_categoryArray count];
    }else if (pickerView.tag == 2) {
        return [_statesArray count];
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component; {
    if (pickerView.tag == 0) {
        return [_priceRangeArray safeStringObjectAtIndex:row];
    }else if (pickerView.tag == 1) {
        return [[_categoryArray safeDictionaryObjectAtIndex:row] safeObjectForKey:@"name"];
    }else if (pickerView.tag == 2) {
        return [[_statesArray safeDictionaryObjectAtIndex:row] safeObjectForKey:@"Name"];
    }
    return @"";
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
        
        [_nameTextField resignFirstResponder];
    }else if (textField == _storeNameTextField) {
        
        [_descriptionTextView becomeFirstResponder];
    }else if (textField == _storefrontNameTextField) {
        
        [_streetTextField becomeFirstResponder];
    }else if (textField == _cityTextField) {
        
        [_stateTextField becomeFirstResponder];
    }else if (textField == _stateTextField) {
        
        [_postalCodeTextField becomeFirstResponder];
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
        [_pickerView.pickerView reloadAllComponents];
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


- (void)uploadProducts{
    
    [self showSpinnerWithName:@"PhotoViewController"];
    [ProductsStoresManager uploadProductWithName:_nameTextField.text
                                        price:_priceValue
                                     category:_categoryTextField.text
                                    storeName:_storeNameTextField.text
                                  description:_descriptionTextView.text
                                        image:_photo
                                      success:^(NSDictionary *object) {
                                          [self hideSpinnerWithName:@"PhotoViewController"];
                                          [self showAlertForProduct];
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


- (void)uploadStore{
    
    NSString* statePrefix = [[_statesArray safeDictionaryObjectAtIndex:_stateIndex] safeStringObjectForKey:@"Prefix"];
    
    [self showSpinnerWithName:@"PhotoViewController"];
    [ProductsStoresManager uploadStoreWithName:_storefrontNameTextField.text
                                       country:@"US"//_countryTextField.text
                                         state:statePrefix
                                        street:_streetTextField.text
                                          city:_cityTextField.text
                                      category:_storeCategoryTextField.text
                                       zipCode:_postalCodeTextField.text
                                   description:_storeDescriptionTextView.text
                                         image:_photo
                                       success:^(NSDictionary *object) {
                                           [self hideSpinnerWithName:@"PhotoViewController"];
                                           [self showAlertForStore];

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


- (BOOL)validateProduct{
    
    if (_nameTextField.text.length == 0) {
        [[AlertManager shared] showOkAlertWithTitle:@"Enter name."];
        return NO;
    }
    if (_priceTextField.text.length == 0) {
        [[AlertManager shared] showOkAlertWithTitle:@"Enter price."];
        return NO;
    }
    return YES;
}

- (BOOL)validateStore{
    
    if (_storefrontNameTextField.text.length == 0) {
        [[AlertManager shared] showOkAlertWithTitle:@"Enter name."];
        return NO;
    }
    if (_stateTextField.text.length == 0) {
        [[AlertManager shared] showOkAlertWithTitle:@"Select state."];
        return NO;
    }
    return YES;
}


- (void)showAlertForProduct{
    
    [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        [self hideKeyboard];
        [self hideCategoryPicker];
        [[LayoutManager shared].mainViewController refreshCurrentList:nil];
        [[LayoutManager shared].rootTabBarController hidePhotoView];
    }
                                           title:@"Success"
                                         message:@"Product loaded."
                               cancelButtonTitle:@"Ok"
                               otherButtonTitles:nil];
}

- (void)showAlertForStore{
    
    [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        [self hideKeyboard];
        [self hideCategoryPicker];
        [[LayoutManager shared].mainViewController refreshCurrentList:nil];
        [[LayoutManager shared].rootTabBarController hidePhotoView];
    }
                                           title:@"Success"
                                         message:@"Store loaded."
                               cancelButtonTitle:@"Ok"
                               otherButtonTitles:nil];
}


- (void)showStoreSearch{
    SearchStoreViewController* searchStoreViewController = [SearchStoreViewController loadFromXIB_Or_iPhone5_XIB];
    //searchStoreViewController.storesArray = _storesArray;
    searchStoreViewController.didSelectStoreName = ^(NSString* name){
        _storeNameTextField.text = name;
        [self loadStores];
    };
    [[LayoutManager shared].rootNavigationController pushViewController:searchStoreViewController animated:YES];
    
}

- (void)loadAddresses{
    
    [self showSpinnerWithName:@"PhotoViewController"];
    
    [SearchManager loadStatesSuccess:^(NSDictionary* states) {
        [self hideSpinnerWithName:@"PhotoViewController"];
        _statesDictionary = states;
        [self convertStates];
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

- (void)convertStates{
    
    NSMutableArray* resultArray = [NSMutableArray new];
    NSArray* keys = [_statesDictionary allKeys];
    for (id obj in keys){
        if ([obj isKindOfClass:[NSString class]]) {
            NSString* state = [_statesDictionary safeStringObjectForKey:obj];
            NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  obj, @"Prefix",
                                  state, @"Name",
                                  nil];
            [resultArray addObject:dict];
        }
        
    }
    
    _statesArray = [NSArray safeArrayWithArray:resultArray];
    _statesArray = [self sortAddresses:_statesArray];
    [_pickerView.pickerView reloadAllComponents];
    
}

- (NSArray*)sortAddresses:(NSArray*)array{
    NSArray *sorteArray = [array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [a safeStringObjectForKey:@"Name"];
        NSString *second = [b safeStringObjectForKey:@"Name"];
        return [first caseInsensitiveCompare:second];
    }];
    
    return sorteArray;
    
}

- (void)loadStores{
    
   [self showSpinnerWithName:@"PhotoViewController"];
    [ProductsStoresManager searchWithSearchType:SearchTypeStores
                                   searchFilter:SearchFilterNone
                                           page:1
                                        success:^(NSArray *objects) {
                                            [self hideSpinnerWithName:@"PhotoViewController"];
                                            
                                            _storesArray = objects;
                                        }
                                        failure:^(NSError *error, NSString *errorString) {
                                            [self hideSpinnerWithName:@"PhotoViewController"];
                                            [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                                message:errorString];
                                            
                                        }exception:^(NSString *exceptionString) {
                                            [self hideSpinnerWithName:@"PhotoViewController"];
                                            [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                        }];
    
}


@end
