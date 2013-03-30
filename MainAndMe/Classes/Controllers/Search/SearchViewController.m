//
//  SearchViewController.m
//  MainAndMe
//
//  Created by Sasha on 3/15/13.
//
//

#import "SearchViewController.h"
#import "SearchCell.h"
#import "UIView+Common.h"
#import "WishlistCell.h"
#import "SearchManager.h"
#import "AlertManager.h"
#import "SearchDetailsViewController.h"

@interface SearchViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;
@property (strong, nonatomic) NSArray* tableArray;
@property (strong, nonatomic) NSArray* categoriesArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

@property (assign, nonatomic) BOOL isKeyBoardVisible;
@property (assign, nonatomic) BOOL isAllCategories;
@end

@implementation SearchViewController

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
    //_titleTextLabel.font = [UIFont fontWithName:@"Perec-SuperNegra" size:22];
    if (_isStoreState) {
        _titleTextLabel.font = [UIFont fontWithName:@"Perec-SuperNegra" size:20];
        _titleTextLabel.text = @"Search Store By Category";
    }else{
        _titleTextLabel.font = [UIFont fontWithName:@"Perec-SuperNegra" size:20];
        _titleTextLabel.text = @"Search Product By Category";
        
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    _isAllCategories = NO;
    [self loadCategories];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_tableView reloadData];
}

- (void)viewDidUnload {
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (_isAllCategories) {
            return 1;
        }else{
            return 0;
        }
    }
    return [_tableArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kSearchCellIdentifier = @"SearchCell";
    
    SearchCell *cell = [tableView dequeueReusableCellWithIdentifier:kSearchCellIdentifier];

    if (cell == nil){
        cell = [SearchCell loadViewFromXIB];
    }
    
    // Configure the cell...
    
    if (indexPath.section == 0) {
        cell.nameLabel.text = @"All Categories";
    }else{
        NSDictionary* object = [_tableArray safeDictionaryObjectAtIndex:indexPath.row];
        cell.nameLabel.text = [object safeStringObjectForKey:@"name"];
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    SearchDetailsViewController* searchDetailsViewController = [SearchDetailsViewController loadFromXIB_Or_iPhone5_XIB];
    if (indexPath.section == 0) {
        searchDetailsViewController.isAllState = YES;
    }else{
        NSDictionary* object = [_tableArray safeDictionaryObjectAtIndex:indexPath.row];
        searchDetailsViewController.categoryInfo = object;
        searchDetailsViewController.isAllState = NO;
    }
    searchDetailsViewController.isStoreState = _isStoreState;
    [_searchTextField resignFirstResponder];
    [self.navigationController pushViewController:searchDetailsViewController animated:YES];
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
    if (sender.text.length > 0) {
        _isAllCategories = NO;
    }else{
        _isAllCategories = YES;
    }
    [self applyFilterWith:sender.text];
}


#pragma mark - Privat Methods

- (void)loadCategories{
    [self showSpinnerWithName:@"SearchViewController"];
    [SearchManager loadCcategiriesSuccess:^(NSArray *categories) {
        [self hideSpinnerWithName:@"SearchViewController"];
        _categoriesArray = categories;
        _isAllCategories = YES;
        [self applyFilterWith:@""];
        
    }
                                  failure:^(NSError *error, NSString *errorString) {
                                      [self hideSpinnerWithName:@"SearchViewController"];
                                      [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                          message:errorString];
                                  }
                                exception:^(NSString *exceptionString) {
                                    [self hideSpinnerWithName:@"SearchViewController"];
                                    [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                }];
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
        _tableArray = _categoriesArray;
        [_tableView reloadData];
        return;
    }
    
    NSMutableArray* filterdMutableArray = [NSMutableArray array];
    
    
    
    NSArray *searchNames = [[name lowercaseString]componentsSeparatedByString: @" "];
    NSString *firstSearchName = [[searchNames objectAtIndex: 0] lowercaseString];
    NSString *secondSearchName =nil;
    if(searchNames.count>1)secondSearchName =[[searchNames objectAtIndex: 1] lowercaseString];
    
    
    
    for (NSDictionary* friend in _categoriesArray) {
        
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
