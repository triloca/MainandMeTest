//
//  PlacesFollowVC.m
//  MainAndMeios7
//
//  Created by Max on 11/8/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "PlacesFollowVC.h"
#import "PlacesFollowCell.h"

@interface PlacesFollowVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
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
  //  _tableView.tableFooterView = [UIView new];
    [self loadData];
    [self updateViews];
   
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    UIBarButtonItem *anchorLeftButton  = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(anchorRight)];
    self.navigationItem.leftBarButtonItem = anchorLeftButton;
}

#pragma mark _______________________ Private Methods ________________________

- (void)loadData{
    _tableArray = @[@"First place",
                    @"Second place",
                    @"Third place",
                    @"Fourth plase",
                    @"Fifth place",
                    @"Sixth place"];
}

- (void)updateViews{
    [_tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tableArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kPlacesFollowCellIdentifier = @"PlacesFollowCell";
    
    PlacesFollowCell *cell = [tableView dequeueReusableCellWithIdentifier:kPlacesFollowCellIdentifier];
    
    if (cell == nil){
        cell = [PlacesFollowCell loadViewFromXIB];
    }
    
    // Configure the cell...
    
    cell.nameLabel.text = [_tableArray safeStringObjectAtIndex:indexPath.row];
        
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
}


- (void)anchorRight {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

@end
