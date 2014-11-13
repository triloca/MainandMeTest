//
//  LeftMenuVC.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 10/19/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LeftMenuVC.h"
#import "LeftMenuCell.h"

@interface LeftMenuVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray* tableArray;

@end

@implementation LeftMenuVC


#pragma mark _______________________ Class Methods _________________________
#pragma mark ____________________________ Init _____________________________

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark _______________________ View Lifecycle ________________________

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.tableFooterView = [UIView new];
    
    [self loadData];
    [self updateViews];
    
}
#pragma mark _______________________ Privat Methods(view)___________________
#pragma mark _______________________ Privat Methods ________________________

- (void)loadData{
    _tableArray = @[@"Specials & Events",
                    @"Search",
                    @"Find stores by name",
                    @"My wishlists",
                    @"People I follow",
                    @"Places I follow",
                    @"Notifications",
                    @"Edit my profile",
                    @"Invite friends",
                    @"About Main and Me",
                    @"Privacy Policy",
                    @"Log out"];
}

- (void)updateViews{
    [_tableView reloadData];
}

#pragma mark _______________________ Buttons Action ________________________
#pragma mark _______________________ Delegates _____________________________

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tableArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kLeftMenuCellIdentifier = @"LeftMenuCell";
    
    LeftMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:kLeftMenuCellIdentifier];

    if (cell == nil){
        cell = [LeftMenuCell loadViewFromXIB];
        //cell.transform = CGAffineTransformMake(0.0f, 1.0f, 1.0f, 0.0f, 0.0f, 0.0f);
    }
    
    // Configure the cell...
    
    cell.nameLabel.text = [_tableArray safeStringObjectAtIndex:indexPath.row];
    
    if ([cell.nameLabel.text isEqualToString:@"Notifications"]) {
        cell.badgeView.hidden = NO;
        
        [cell setupBageString:@"12"];
        
    }else{
        cell.badgeView.hidden = YES;
    }
    
    if ([cell.nameLabel.text isEqualToString:@"Log out"]) {
        cell.arrowImageView.hidden = YES;
    }else{
        cell.arrowImageView.hidden = NO;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0:{
            
            [LayoutManager shared].slidingVC.topViewController = [LayoutManager shared].homeNVC;
            [[LayoutManager shared].slidingVC resetTopViewAnimated:YES onComplete:^{}];
            
            break;
        }
        case 1:{
            
            [LayoutManager shared].slidingVC.topViewController = [LayoutManager shared].shopCategoryNVC;
            [[LayoutManager shared].slidingVC resetTopViewAnimated:YES onComplete:^{}];
            
            break;
        }
        case 5:{
            [LayoutManager shared].slidingVC.topViewController = [LayoutManager shared].placesFollowNVC;
            [[LayoutManager shared].slidingVC resetTopViewAnimated:YES onComplete:^{}];
            
            break;
        }
        case 10:{
            [LayoutManager shared].slidingVC.topViewController = [LayoutManager shared].privacyPolicyNVC;
            [[LayoutManager shared].slidingVC resetTopViewAnimated:YES onComplete:^{}];
            
            break;
        }
            
        case 11:{
            
            [[CommonManager shared] logout];
            [LayoutManager createSlidingVC];
            break;
        }
            
        default:
            break;
    }
    
    
}


#pragma mark _______________________ Public Methods ________________________
#pragma mark _______________________ Notifications _________________________

@end
