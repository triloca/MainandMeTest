//
//  PlacesFollowVC.m
//  MainAndMeios7
//
//  Created by Max on 11/8/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "PlacesFollowVC.h"
#import "PlacesFollowCell.h"
#import "SearchTypeView.h"
#import "CustomTitleView.h"

@interface PlacesFollowVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) SearchTypeView *searchTypeView;
@property (strong, nonatomic) NSIndexPath *editingIndexPath;
@property (strong, nonatomic) NSArray *tableArray;

@end

@implementation PlacesFollowVC

#pragma mark _______________________ Class Methods _________________________
#pragma mark ____________________________ Init _____________________________
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark _______________________ View Lifecycle ________________________
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _tableView.tableFooterView = [UIView new];
    
    UIButton* menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setImage:[UIImage imageNamed:@"menu_button.png"] forState:UIControlStateNormal];
    menuButton.frame = CGRectMake(0, 0, 40, 40);
    [menuButton addTarget:self action:@selector(anchorRight) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *anchorLeftButton  = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    
    self.navigationItem.titleView = [[CustomTitleView alloc] initWithTitle:@"PLACES I FOLLOW" dropDownIndicator:NO clickCallback:^(CustomTitleView *titleView) {
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.navigationItem.leftBarButtonItem = anchorLeftButton;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_az_button"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(sortButtonAction)];

    [self configSearchBar];
    [self loadData];
    [self updateViews];
    [self.tableView registerNib:[UINib nibWithNibName:@"PlacesFollowCell" bundle:nil] forCellReuseIdentifier:@"PlacesFollowCell"];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

#pragma mark _______________________ Private Methods ________________________

- (void)loadData{
    _tableArray = @[
                    @{@"name":@"Roslindale, MA", @"isViewed": [NSNumber numberWithBool:YES]},
                    @{@"name":@"Berkely, CA", @"isViewed": [NSNumber numberWithBool:YES]},
                    @{@"name":@"Boulder, CO", @"isViewed": [NSNumber numberWithBool:YES]},
                    @{@"name":@"Madison, NJ", @"isViewed": [NSNumber numberWithBool:YES]},
                    @{@"name":@"Beaujolais Wine", @"isViewed": [NSNumber numberWithBool:NO]},
                    @{@"name":@"Cory's Clothing", @"isViewed": [NSNumber numberWithBool:NO]},
                    @{@"name":@"Dennis Haircutters", @"isViewed": [NSNumber numberWithBool:NO]},
                    @{@"name":@"Elizabeth's Backery", @"isViewed": [NSNumber numberWithBool:NO]}
                    ];
}

- (void)updateViews{
    [_tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_tableArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kPlacesFollowCellIdentifier = @"PlacesFollowCell";
    
    PlacesFollowCell *cell = [tableView dequeueReusableCellWithIdentifier:kPlacesFollowCellIdentifier];
    
    NSDictionary* itemDict = [_tableArray safeDictionaryObjectAtIndex:indexPath.row];
    
    cell.titleLabel.text = [itemDict safeStringObjectForKey:@"name"];
    BOOL isViewed = [[itemDict safeNumberObjectForKey:@"isViewed"] boolValue];
    
    cell.backlighted = isViewed;
    if (isViewed)
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;

    
    
    return cell;
}

#pragma mark - Table view delegate


- (void)anchorRight {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

- (void) sortButtonAction {
    
}

- (void)configSearchBar {
    
    UIView* topCoverView = [UIView new];
    topCoverView.backgroundColor = [UIColor colorWithRed:0.929f green:0.925f blue:0.925f alpha:1.00f];
    topCoverView.frame = CGRectMake(0, 0, _searchBar.frame.size.width, 1);
    topCoverView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_searchBar addSubview:topCoverView];
    
    UIView* bottomCoverView = [UIView new];
    bottomCoverView.backgroundColor = [UIColor colorWithRed:0.929f green:0.925f blue:0.925f alpha:1.00f];
    bottomCoverView.frame = CGRectMake(0, _searchBar.frame.size.height - 1, _searchBar.frame.size.width, 1);
    bottomCoverView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_searchBar addSubview:bottomCoverView];
    
    [_searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"scope_bar_background.png"]forState:UIControlStateNormal];
    
    CGRect rc = _searchBar.frame;
    rc.origin.y = CGRectGetMaxY(_searchTypeView.frame);
    _searchBar.frame = rc;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        contentInsets = UIEdgeInsetsMake(0, 0, (keyboardSize.height), 0);
    } else {
        contentInsets = UIEdgeInsetsMake(0, 0, (keyboardSize.width), 0);
    }
    
    _tableView.contentInset = contentInsets;
    _tableView.scrollIndicatorInsets = contentInsets;
    [_tableView scrollToRowAtIndexPath:_editingIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    _tableView.contentInset = UIEdgeInsetsZero;
    _tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self.searchBar resignFirstResponder];
    return YES;
}


@end
