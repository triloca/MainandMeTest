//
//  AddressViewController.m
//  MainAndMe
//
//  Created by Sasha on 3/15/13.
//
//

#import "AddressViewController.h"
#import "SearchCell.h"
#import "UIView+Common.h"
#import "SearchManager.h"
#import "AlertManager.h"
#import "SearchDetailsViewController.h"
#import "AddressCell.h"
#import "CommunityViewController.h"


@interface AddressViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;
@property (strong, nonatomic) NSArray* tableArray;
@property (strong, nonatomic) NSArray* statesArray;
@property (strong, nonatomic) NSArray* statesShortArray;
@property (strong, nonatomic) NSDictionary* statesDictionary;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

@property (assign, nonatomic) BOOL isKeyBoardVisible;

@end

@implementation AddressViewController

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
    _titleTextLabel.text = @"Select Address";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self loadAddresses];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setTitleTextLabel:nil];
    [self setTableView:nil];
    [self setSearchTextField:nil];
    [super viewDidUnload];
}

#pragma mark - Buttons Action
- (IBAction)backButtonClicked:(id)sender {
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
    static NSString *kAddressCellIdentifier = @"AddressCell";
    
    AddressCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddressCellIdentifier];
    
    if (cell == nil){
        cell = [AddressCell loadViewFromXIB];
    }
    
    // Configure the cell...
    
    
    cell.nameLabel.text = [[_tableArray safeDictionaryObjectAtIndex:indexPath.row] safeStringObjectForKey:@"Name"];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString* statePrefix = [[_tableArray safeDictionaryObjectAtIndex:indexPath.row] safeStringObjectForKey:@"Prefix"];
    NSString* stateName = [[_tableArray safeDictionaryObjectAtIndex:indexPath.row] safeStringObjectForKey:@"Name"];
    CommunityViewController* communityViewController = [CommunityViewController loadFromXIB_Or_iPhone5_XIB];
    communityViewController.statePrefix = statePrefix;
    communityViewController.stateName = stateName;
    [self.navigationController pushViewController:communityViewController animated:YES];
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

- (IBAction)didChangeValue:(UITextField *)sender {
    [self applyFilterWith:sender.text];
}

#pragma mark - Privat Methods

- (void)loadAddresses{
    
    [self showSpinnerWithName:@"AddressViewController"];
    
    [SearchManager loadStatesSuccess:^(NSDictionary* states) {
        [self hideSpinnerWithName:@"AddressViewController"];
        _statesDictionary = states;
        [self convertStates];
    }
                             failure:^(NSError *error, NSString *errorString) {
                                 [self hideSpinnerWithName:@"AddressViewController"];
                                 [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                     message:errorString];
                             }
                           exception:^(NSString *exceptionString) {
                               [self hideSpinnerWithName:@"AddressViewController"];
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
    [self applyFilterWith:@""];
}

- (void)updateContentSize{// to privat
    
    if (_isKeyBoardVisible) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rc = _tableView.frame;
            rc.size.height -= 160;
            _tableView.frame = rc;
            
        } completion:^(BOOL finished) {
            
        }];
    }else{
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rc = _tableView.frame;
            rc.size.height += 160;
            _tableView.frame = rc;
            
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)applyFilterWith:(NSString*)name{
    
    if ([name isEqualToString:@""]) {
        _tableArray = [self sortAddresses:_statesArray];
        [_tableView reloadData];
        return;
    }
    
    NSMutableArray* filterdMutableArray = [NSMutableArray array];
    
    NSArray *searchNames = [[name lowercaseString]componentsSeparatedByString: @" "];
    NSString *firstSearchName = [[searchNames objectAtIndex: 0] lowercaseString];
    NSString *secondSearchName =nil;
    if(searchNames.count>1)secondSearchName =[[searchNames objectAtIndex: 1] lowercaseString];
    
    
    
    for (NSDictionary* friend in _statesArray) {
        
        NSString* fixedName =[[friend objectForKey:@"Name"] stringByReplacingOccurrencesOfString:@"  " withString:@" "];//some names are separated by double space :(
        
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

- (NSArray*)sortAddresses:(NSArray*)array{
    NSArray *sorteArray = [array sortedArrayUsingComparator:^(id a, id b) {
        NSString *first = [a safeStringObjectForKey:@"Name"];
        NSString *second = [b safeStringObjectForKey:@"Name"];
        return [first caseInsensitiveCompare:second];
    }];
    
    return sorteArray;

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
