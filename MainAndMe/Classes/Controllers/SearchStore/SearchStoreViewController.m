//
//  SearchViewController.m
//  MainAndMe
//
//  Created by Sasha on 3/15/13.
//
//

#import "SearchStoreViewController.h"
#import "SearchStoreCell.h"
#import "UIView+Common.h"
#import "WishlistCell.h"
#import "SearchManager.h"
#import "AlertManager.h"
#import "SearchDetailsViewController.h"
#import "MBProgressHUD.h"
#import "ProductsStoresManager.h"
#import "LayoutManager.h"
#import <QuartzCore/QuartzCore.h>
#import "PickerView.h"
#import <MapKit/MapKit.h>
#import "LocationManager.h"

@interface SearchStoreViewController ()
<UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UIActionSheetDelegate,
UIPickerViewDelegate,
UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;
@property (strong, nonatomic) NSArray* tableArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) PickerView* pickerView;
@property (assign, nonatomic) BOOL isPickerVisible;

@property (strong, nonatomic) NSArray* statesArray;
@property (strong, nonatomic) NSDictionary* statesDictionary;
@property (assign, nonatomic) NSInteger stateIndex;


@property (assign, nonatomic) BOOL isKeyBoardVisible;
@property (weak, nonatomic) IBOutlet UILabel *emptyLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *storeScrollView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *addPhotoButton;


@property (weak, nonatomic) IBOutlet UITextField *storefrontNameTextField;

@property (weak, nonatomic) IBOutlet UITextField *stateTextField;
@property (weak, nonatomic) IBOutlet UITextField *streetTextField;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UITextField *postalCodeTextField;
@property (weak, nonatomic) IBOutlet UITextView *storeDescriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *storePhotoImageView;
@property (weak, nonatomic) IBOutlet UITextField *categoryTextField;

@property (strong, nonatomic) UIImage* photo;
@property (strong, nonatomic) NSArray* keyStoresArray;
@property (strong, nonatomic) NSArray* categoryArray;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *searchSpinerView;

@end

@implementation SearchStoreViewController

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = @"Search Store screen";

    // Do any additional setup after loading the view from its nib.
    _titleTextLabel.font = [UIFont fontWithName:@"Perec-SuperNegra" size:22];
    _titleTextLabel.text = @"Select Store";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    CGRect rc = _storeScrollView.frame;
    rc.origin.y += 35;
    _storeScrollView.frame =rc;

    [self.view addSubview:_storeScrollView];
    _storeScrollView.hidden = YES;

   _pickerView = [PickerView loadViewFromXIB];
    
    __weak SearchStoreViewController* weakSelf = self;
    _pickerView.didClickCancel = ^{
        [weakSelf hideCategoryPicker];
    };
    
    _pickerView.didClickDone = ^{
        [weakSelf hideCategoryPicker];
    };
    
    _pickerView.pickerView.delegate = self;
    _pickerView.pickerView.dataSource = self;
    [self.view addSubview:_pickerView];

    
    [self loadStores];
    [self applyFilterWith:@""];
    [self loadAddresses];
    [self loadCategories];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    CGRect rc = _pickerView.frame;
    rc.origin.y = CGRectGetMaxY(self.view.frame);
    _pickerView.frame = rc;
    self.emptyLabel.hidden = YES;
}


- (void)viewDidUnload {
    [self setTitleTextLabel:nil];
    [self setTableView:nil];
    [self setSearchTextField:nil];
    [self setEmptyLabel:nil];
    [self setStoreScrollView:nil];
    [self setDoneButton:nil];
    [self setAddButton:nil];
    [self setAddPhotoButton:nil];
    [self setSearchSpinerView:nil];
    [self setCategoryTextField:nil];
    [super viewDidUnload];
}

#pragma mark - Buttons Action
- (IBAction)backButtonClicked:(id)sender {
    [_searchTextField resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addPhotoButtonClicked:(id)sender {
    [self hideCategoryPicker];
    [self hideKeyboard];
    [self loadPhoto];
}

- (IBAction)addButtonClicked:(id)sender {

    [_searchTextField resignFirstResponder];
    _storefrontNameTextField.text = _searchTextField.text;
    
    _doneButton.hidden = NO;
    _addButton.hidden = YES;
    _storeScrollView.alpha = 0;
    _storeScrollView.hidden = NO;
    [UIView animateWithDuration:0.3
                     animations:^{
                         _storeScrollView.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
}

- (IBAction)doneButtonClicked:(id)sender {
    
    [self hideKeyboard];
    [self hideCategoryPicker];
    if ([self validateStore]) {
        [self uploadStore];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([_tableArray count] == 0 && ![_searchSpinerView isAnimating]) {
        _emptyLabel.hidden = NO;
    }else{
        _emptyLabel.hidden = YES;
    }
    return [_tableArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kSearchStoreCellIdentifier = @"SearchStoreCell";
    
    SearchStoreCell *cell = [tableView dequeueReusableCellWithIdentifier:kSearchStoreCellIdentifier];

    if (cell == nil){
        cell = [SearchStoreCell loadViewFromXIB];
    }
    
    // Configure the cell...
    
    NSDictionary* object = [_tableArray safeDictionaryObjectAtIndex:indexPath.row];
    cell.nameLabel.text = [object safeStringObjectForKey:@"name"];
    cell.addressLabel.text = [object safeStringObjectForKey:@"street"];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSDictionary* object = [_tableArray safeDictionaryObjectAtIndex:indexPath.row];
    
    NSString* message = [NSString stringWithFormat:@"Use '%@' as Store name?", [object safeStringObjectForKey:@"name"]];
    [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            if (_didSelectStoreName) {
                _didSelectStoreName([object safeStringObjectForKey:@"name"]);
                [_searchTextField resignFirstResponder];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }else{
            _searchTextField.text = [object safeStringObjectForKey:@"name"];
            [_tableView reloadData];
        }
    }
                                           title:message
                                         message:nil
                               cancelButtonTitle:@"Ok"
                               otherButtonTitles:@"Cancel", nil];
}


#pragma mark - TextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
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
   
    if (_categoryTextField == textField) {
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

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if ([textField.text length] > 0) {

    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //[textField resignFirstResponder];
    if (textField == _searchTextField) {
        [textField resignFirstResponder];
    }
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

    [_storeScrollView setContentOffset:CGPointMake(0, textView.frame.origin.y - 100) animated:YES];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    return YES;
}


- (IBAction)didChangeValue:(UITextField*)sender {
   [self applyFilterWith:sender.text];
    [self loadStoresForKey:sender.text];
}


#pragma mark - Privat Methods

- (void)loadStores{
    
    [self showSpinnerWithName:@"Load stores"];
    [ProductsStoresManager searchWithSearchType:SearchTypeStores
                                   searchFilter:SearchFilterNone
                                           page:1
                                        success:^(NSArray *objects) {
                                            [self hideSpinnerWithName:@"Load stores"];
                                            
                                            _storesArray = objects;
                                            
                                            [self applyFilterWith:@""];
                                            
                                        }
                                        failure:^(NSError *error, NSString *errorString) {
                                            [self hideSpinnerWithName:@"Load stores"];
                                            [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                                message:errorString];
                                            
                                        }exception:^(NSString *exceptionString) {
                                            [self hideSpinnerWithName:@"Load stores"];
                                            [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                        }];

}

- (void)loadStoresForKey:(NSString*)key{
    [[SearchManager shared] cancelSearch];
    
    if (key.length == 0) {
        _keyStoresArray = [NSArray array];
        [_searchSpinerView stopAnimating];
        [_tableView reloadData];
        return;
    }
    
    [_searchSpinerView startAnimating];
    [_tableView reloadData];
    [SearchManager loadStoresForKey:key
                            success:^(NSArray *objects) {
                                _keyStoresArray = objects;
                                [_searchSpinerView stopAnimating];
                                [self applyFilterWith:_searchTextField.text];
                            }
                            failure:^(NSError *error, NSString *errorString) {
                              [_searchSpinerView stopAnimating];
                                _keyStoresArray = [NSArray array];
                                [self applyFilterWith:_searchTextField.text];
                            }
                          exception:^(NSString *exceptionString) {
                              [_searchSpinerView stopAnimating];
                              _keyStoresArray = [NSArray array];
                              [self applyFilterWith:_searchTextField.text];
                          }];

}

//- (void)updateContentSize{// to privat
//    
//    if (_isKeyBoardVisible) {
//        [UIView animateWithDuration:0.3 animations:^{
//            CGRect rc = _tableView.frame;
//            rc.size.height -= 220;
//            _tableView.frame = rc;
//            
//        } completion:^(BOOL finished) {
//            
//        }];
//    }else{
//        
//        [UIView animateWithDuration:0.3 animations:^{
//            CGRect rc = _tableView.frame;
//            rc.size.height += 220;
//            _tableView.frame = rc;
//            
//        } completion:^(BOOL finished) {
//            
//        }];
//    }
//}

- (void)applyFilterWith:(NSString*)name{
    
    if ([name isEqualToString:@""]) {
        _tableArray = _storesArray;
        _tableArray = [self filterByLocation:_tableArray];
        [_tableView reloadData];
        return;
    }
    
    NSMutableArray* filterdMutableArray = [NSMutableArray array];
    NSMutableArray* surceArray = [NSMutableArray arrayWithArray:_keyStoresArray];
    [surceArray removeObjectsInArray:_storesArray];
    [surceArray addObjectsFromArray:_storesArray];
    
    
    NSArray *searchNames = [[name lowercaseString]componentsSeparatedByString: @" "];
    NSString *firstSearchName = [[searchNames objectAtIndex: 0] lowercaseString];
    NSString *secondSearchName =nil;
    if(searchNames.count>1)secondSearchName =[[searchNames objectAtIndex: 1] lowercaseString];
    
    
    
    for (NSDictionary* friend in surceArray) {
        
        NSString* fixedName =[[friend objectForKey:@"name"] stringByReplacingOccurrencesOfString:@"  " withString:@" "];//some names are separated by double space :(
        
        NSArray *names = [fixedName componentsSeparatedByString: @" "];
        
        NSString *firstName = nil;
        NSString *secondName = nil;
        if ([names count] > 0) {
            firstName = [[names objectAtIndex: 0] lowercaseString];
        }
        if ([names count] > 1) {
            secondName = [[names objectAtIndex: 1] lowercaseString];
        }
        //  NSLog(@"|%@|,|%@|,|%@|",person.name,firstName,secondName);
        if(secondSearchName == nil || secondSearchName.length==0){//search by one name
            if ([firstName hasPrefix: firstSearchName] || [secondName hasPrefix: firstSearchName]) {
                [filterdMutableArray addObject:friend];
            }
        }
        else{
            if ( ([firstName hasPrefix: firstSearchName] && [secondName hasPrefix: secondSearchName])
                || ([firstName hasPrefix: secondSearchName] && [secondName hasPrefix: firstSearchName]) ) {//both searchNames must be contained
                [filterdMutableArray addObject:friend];
            }
        }
        
    }
    
    _tableArray = [NSArray arrayWithArray:filterdMutableArray];
    _tableArray = [self filterByLocation:_tableArray];
    [_tableView reloadData];
    
}


- (NSArray*)filterByLocation:(NSArray*)array{
    
    NSArray *sorteArray = [array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        CLLocation *first = [[CLLocation alloc] initWithLatitude:[[a safeNumberObjectForKey:@"lat"] floatValue]
                                                       longitude:[[a safeNumberObjectForKey:@"lng"] floatValue]];
        CLLocation *second = [[CLLocation alloc] initWithLatitude:[[b safeNumberObjectForKey:@"lat"] floatValue]
                                                       longitude:[[b safeNumberObjectForKey:@"lng"] floatValue]];

        CGFloat firstDistance = [[LocationManager shared].defaultLocation distanceFromLocation:first];
        CGFloat secondDistance = [[LocationManager shared].defaultLocation distanceFromLocation:second];
        return firstDistance < secondDistance;
    }];
    
    return sorteArray;

}

- (void)loadPhoto{
    
    UIActionSheet *shareActionSheet = [[UIActionSheet alloc]
                                       initWithTitle:nil
                                       delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       destructiveButtonTitle:nil
                                       otherButtonTitles:@"Take a New Photo",
                                       @"Choose From Library",nil];
    
    shareActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    UIButton *button = [[shareActionSheet subviews] safeObjectAtIndex:0];
    [button setTitleColor:[UIColor colorWithRed:99/255.0f green:116/255.0f blue:94/255.0f alpha:1]
                 forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:127/255.0f green:166/255.0f blue:94/255.0f alpha:1]
                 forState:UIControlStateHighlighted];
    button = [[shareActionSheet subviews] safeObjectAtIndex:1];
    [button setTitleColor:[UIColor colorWithRed:99/255.0f green:116/255.0f blue:94/255.0f alpha:1]
                 forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:127/255.0f green:166/255.0f blue:94/255.0f alpha:1]
                 forState:UIControlStateHighlighted];
    
    
    [shareActionSheet showInView:[LayoutManager shared].appDelegate.window];
}


- (void)scrollToTextField:(UITextField*)textField {
    if (textField == _storefrontNameTextField) {
        
            [_storeScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        
    }else{
      
            [_storeScrollView setContentOffset:CGPointMake(0, textField.frame.origin.y - 100) animated:YES];
    }
}


- (void)hideKeyboard{
    [_storefrontNameTextField resignFirstResponder];
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

- (void)updateContentSize{
    CGFloat height = _storeScrollView.frame.size.height;
    if (_isKeyBoardVisible || _isPickerVisible) {
        [_storeScrollView setContentSize:CGSizeMake(0, height + 220)];
    }else{
        
        [UIView animateWithDuration:0.3 animations:^{
            [_storeScrollView setContentSize:CGSizeMake(0, height)];
            [_storeScrollView setContentOffset:CGPointMake(0, 0)];
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)updateSearchContentSize{
    
    if (_isKeyBoardVisible) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rc = _tableView.frame;
            rc.size.height -= 210;
            _tableView.frame = rc;
            
        } completion:^(BOOL finished) {
            
        }];
    }else{
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rc = _tableView.frame;
            rc.size.height += 210;
            _tableView.frame = rc;
            
        } completion:^(BOOL finished) {
            
        }];
    }
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

- (void)loadAddresses{
    
    [self showSpinnerWithName:@"SearchStoreViewController"];
    
    [SearchManager loadStatesSuccess:^(NSDictionary* states) {
        [self hideSpinnerWithName:@"SearchStoreViewController"];
        _statesDictionary = states;
        [self convertStates];
    }
                             failure:^(NSError *error, NSString *errorString) {
                                 [self hideSpinnerWithName:@"SearchStoreViewController"];
                                 [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                     message:errorString];
                             }
                           exception:^(NSString *exceptionString) {
                               [self hideSpinnerWithName:@"SearchStoreViewController"];
                               [[AlertManager shared] showOkAlertWithTitle:exceptionString];
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

- (void)jampToNextTextField:(UITextField*)textField{
  
    if (textField == _storefrontNameTextField) {
        
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


- (void)uploadStore{
    
    NSString* statePrefix = [[_statesArray safeDictionaryObjectAtIndex:_stateIndex] safeStringObjectForKey:@"Prefix"];
    
    [self showSpinnerWithName:@"SearchStoreViewController"];
    [ProductsStoresManager uploadStoreWithName:_storefrontNameTextField.text
                                       country:@"US"//_countryTextField.text
                                         state:statePrefix
                                        street:_streetTextField.text
                                          city:_cityTextField.text
                                      category:_categoryTextField.text
                                       zipCode:_postalCodeTextField.text
                                   description:_storeDescriptionTextView.text
                                         image:_photo
                                       success:^(NSDictionary *object) {
                                           [self hideSpinnerWithName:@"SearchStoreViewController"];
                                           [self showAlertForStore];
                                           
                                       }
                                       failure:^(NSError *error, NSString *errorString) {
                                           [self hideSpinnerWithName:@"SearchStoreViewController"];
                                           [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                               message:errorString];
                                           
                                       }
                                     exception:^(NSString *exceptionString) {
                                         [self hideSpinnerWithName:@"SearchStoreViewController"];
                                         [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                     }];
    
}

- (void)setPhoto:(UIImage*)photo{
    _storePhotoImageView.image = photo;
    _photo = photo;
}


- (void)showAlertForStore{
    NSString* message = [NSString stringWithFormat:@"Store '%@' loaded.", _storefrontNameTextField.text];
    [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        [self hideKeyboard];
        [self hideCategoryPicker];
        _storeScrollView.hidden = YES;
       
        if (_didSelectStoreName) {
            _didSelectStoreName(_storefrontNameTextField.text);
            [self.navigationController popViewControllerAnimated:YES];
        }
        [self.navigationController popViewControllerAnimated:YES];
    
    }
                                           title:@"Success"
                                         message:message
                               cancelButtonTitle:@"Ok"
                               otherButtonTitles:nil];
}

#pragma mark - Picker Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView; {
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (pickerView.tag == 1) {
        _categoryTextField.text = [[_categoryArray safeDictionaryObjectAtIndex:row] safeStringObjectForKey:@"name"];
    }else if (pickerView.tag == 2) {
        _stateTextField.text = [[_statesArray safeDictionaryObjectAtIndex:row] safeStringObjectForKey:@"Name"];
        _stateIndex = row;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component; {
    if (pickerView.tag == 1) {
        return [_categoryArray count];
    }else if (pickerView.tag == 2) {
        return [_statesArray count];
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component; {
    if (pickerView.tag == 1) {
        return [[_categoryArray safeDictionaryObjectAtIndex:row] safeObjectForKey:@"name"];
    }else if (pickerView.tag == 2) {
        return [[_statesArray safeDictionaryObjectAtIndex:row] safeObjectForKey:@"Name"];
    }
    return @"";
}


#pragma mark - ActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;
{
    switch (buttonIndex) {
        case 0:
            [self displayImagePickerWithSource:UIImagePickerControllerSourceTypeCamera];
            break;
        case 1:
            [self displayImagePickerWithSource:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
        case 2:
            break;
        default:
            break;
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    UIColor* backColor = [UIColor colorWithRed:205/255.0f green:133/255.0f blue:63/255.0f alpha:0.7];
    [[actionSheet layer] setBackgroundColor:backColor.CGColor];
    
    UIButton *button = [[actionSheet subviews] safeObjectAtIndex:0];
    UIImage* image = [button backgroundImageForState:UIControlStateNormal];
    [button setBackgroundImage:image forState:UIControlStateHighlighted];
}

-(void) displayImagePickerWithSource:(UIImagePickerControllerSourceType)src{
    
    @try {
        if([UIImagePickerController isSourceTypeAvailable:src]) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            [picker setSourceType:src];
            [picker setDelegate:self];
            [[LayoutManager shared].rootNavigationController presentModalViewController:picker animated:YES];
        }
    }
    @catch (NSException *e) {
        NSLog(@"UIImagePickerController NSException");
    }
}

#pragma mark - UIImagePickerController Delegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissModalViewControllerAnimated:YES];
    UIImage *capturedImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    if (capturedImage) {
        self.photo = capturedImage;
        _addPhotoButton.hidden = YES;
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Keyboard Notificastion

- (void)keyboardWillShow:(NSNotification*)nitif{
    _isKeyBoardVisible = YES;
    if ([_searchTextField isFirstResponder]) {
        [self updateSearchContentSize];
    }else{
        [self updateContentSize];
    }
}


- (void)keyboardWillHide:(NSNotification*)nitif{
    _isKeyBoardVisible = NO;
    if ([_searchTextField isFirstResponder]) {
        [self updateSearchContentSize];
    }else{
        [self updateContentSize];
    }
}

@end
