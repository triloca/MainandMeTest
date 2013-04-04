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

@interface SearchStoreViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;
@property (strong, nonatomic) NSArray* tableArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

@property (assign, nonatomic) BOOL isKeyBoardVisible;

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
    
   // [self loadStores];
    [self applyFilterWith:@""];
}

- (void)viewDidUnload {
    [self setTitleTextLabel:nil];
    [self setTableView:nil];
    [self setSearchTextField:nil];
    [super viewDidUnload];
}

#pragma mark - Buttons Action
- (IBAction)backButtonClicked:(id)sender {
    [_searchTextField resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldDidBeginEditing");
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
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)didChangeValue:(UITextField*)sender {
   [self applyFilterWith:sender.text];
}

- (IBAction)addButtonClicked:(id)sender {
    if (_searchTextField.text.length == 0) {
        [[AlertManager shared] showOkAlertWithTitle:@"Message"
                                            message:@"Enter Store name."];
    }else{
        NSString* message = [NSString stringWithFormat:@"Use '%@' as Store name?", _searchTextField.text];
        [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                if (_didSelectStoreName) {
                    _didSelectStoreName(_searchTextField.text);
                    [_searchTextField resignFirstResponder];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
        }
                                               title:message
                                             message:nil
                                   cancelButtonTitle:@"Ok"
                                   otherButtonTitles:@"Cancel", nil];
    }
}

#pragma mark - Privat Methods

- (void)loadStores{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ProductsStoresManager searchWithSearchType:SearchTypeStores
                                   searchFilter:SearchFilterNone
                                        success:^(NSArray *objects) {
                                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                            
                                            _storesArray = objects;
                                            
                                            [self applyFilterWith:@""];
                                            
                                        }
                                        failure:^(NSError *error, NSString *errorString) {
                                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                            [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                                message:errorString];
                                            
                                        }exception:^(NSString *exceptionString) {
                                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                            [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                        }];

}

- (void)updateContentSize{// to privat
    
    if (_isKeyBoardVisible) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rc = _tableView.frame;
            rc.size.height -= 220;
            _tableView.frame = rc;
            
        } completion:^(BOOL finished) {
            
        }];
    }else{
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rc = _tableView.frame;
            rc.size.height += 220;
            _tableView.frame = rc;
            
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)applyFilterWith:(NSString*)name{
    
    if ([name isEqualToString:@""]) {
        _tableArray = _storesArray;
        [_tableView reloadData];
        return;
    }
    
    NSMutableArray* filterdMutableArray = [NSMutableArray array];
    
    
    
    NSArray *searchNames = [[name lowercaseString]componentsSeparatedByString: @" "];
    NSString *firstSearchName = [[searchNames objectAtIndex: 0] lowercaseString];
    NSString *secondSearchName =nil;
    if(searchNames.count>1)secondSearchName =[[searchNames objectAtIndex: 1] lowercaseString];
    
    
    
    for (NSDictionary* friend in _storesArray) {
        
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
    [_tableView reloadData];
    
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

@end
