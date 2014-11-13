//
//  AFBFriendsViewController.m
//  AllComponents
//
//  Created by Sasha on 4/27/14.
//  Copyright (c) 2014 uniprog. All rights reserved.
//

#import "AFBFriendsViewController.h"
#import "AFBFriendCell.h"
#import "FacebookManager.h"
#import <FacebookSDK/FBGraphUser.h>

@interface AFBFriendsViewController()
@property (strong, nonatomic) NSMutableArray* tableArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSString *nextFBFriendsPageURL;

@end


@implementation AFBFriendsViewController

#pragma mark _______________________ Class Methods _________________________



#pragma mark ____________________________ Init _____________________________

- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization

    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}


- (void)dealloc{

}

#pragma mark _______________________ View Lifecycle ________________________

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadFriendsWithPaging];
}

#pragma mark _______________________ Privat Methods(view)___________________
//! Update views by model
- (void)updateViews{

}

#pragma mark _______________________ Privat Methods ________________________

- (void)loadFriends{
    
    [self showSpinnerWithName:@"Load Friends"];
    
    [[FacebookManager shared] loadFriendsWithSuccess:^(NSArray *friends) {
        [self hideSpinnerWithName:@"Load Friends"];
        
        [FacebookManager shared].friends = friends;
        
        _tableArray = friends;
        [_tableView reloadData];
    }
                                             failure:^(FBRequestConnection *connection, id result, NSError *error) {
                                                 [self hideSpinnerWithName:@"Load Friends"];
                                                 _tableArray = [NSMutableArray array];
                                                 [_tableView reloadData];
                                             }];
}

- (void)loadFriendsWithPaging{
    
    [self showSpinnerWithName:@"Load Friends"];
    id X = [[FacebookManager shared].user performSelector:@selector(id)];
    [[FacebookManager shared] loadFriendsForUser:X
                                       pagingURL:_nextFBFriendsPageURL
                                         success:^(NSArray *friends, NSString *nextPage, NSString *prevPage) {
                                             [self hideSpinnerWithName:@"Load Friends"];
                                             
                                             [[FacebookManager shared].friends addObjectsFromArray:friends];
                                             self.nextFBFriendsPageURL = nextPage;
                                             
                                             _tableArray = [FacebookManager shared].friends;
                                             [_tableView reloadData];
                                         }
                                         failure:^(FBRequestConnection *connection, id result, NSError *error) {
                                             [self hideSpinnerWithName:@"Load Friends"];
                                             FBLog(@"Failed load FB friends page");
                                         }];
}

- (void)resetFriendsPaging{
    self.nextFBFriendsPageURL = nil;
    _tableArray = [NSMutableArray array];
    [_tableView reloadData];
}

#pragma mark _______________________ Buttons Action ________________________



#pragma mark _______________________ Delegates _____________________________

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tableArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kAFBFriendCellIdentifier = @"AFBFriendCell";
    
    AFBFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:kAFBFriendCellIdentifier];

    // Configure the cell...
    
    id<FBGraphUser> friend = [_tableArray safeObjectAtIndex:indexPath.row];
    
    cell.nameLabel.text = friend.name;
    [cell setupAvatarURLString:[[FacebookManager shared] userAvatarURL:friend.id type:@"small"]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


#pragma mark _______________________ Public Methods ________________________



#pragma mark _______________________ Notifications _________________________



@end
