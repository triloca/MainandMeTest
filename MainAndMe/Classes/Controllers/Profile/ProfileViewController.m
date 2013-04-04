//
//  ProfileViewController.m
//  MainAndMe
//
//  Created by Sasha on 3/12/13.
//
//

#import "ProfileViewController.h"
#import "LoginSignUpManager.h"
#import "LayoutManager.h"
#import "ProfileCell.h"
#import "UIView+Common.h"
#import "ProductDetailsManager.h"
#import "DataManager.h"
#import "AlertManager.h"
#import "MyWishlistViewController.h"
#import "MyLikesViewController.h"
#import "AboutViewController.h"
#import "SettingsViewController.h"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *personImageView;
@property (weak, nonatomic) IBOutlet UILabel *followersLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingLabel;

@property (strong, nonatomic) NSDictionary* profileInfo;

@property (strong, nonatomic) NSArray* tableArray;

@end

@implementation ProfileViewController

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
    _titleTextLabel.text = @"Profile";
    
    _tableArray = [NSArray arrayWithObjects:
                   @"My Likes",
                   @"My Wishlists", @"My Settings",
                   @"About Main And Me", @"Logout", nil];
    
    [self loadProfileInfo];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_tableView reloadData];
    if (_isNeedUpdate) {
        [self loadProfileInfo];
        _isNeedUpdate = NO;
    }
}

- (void)viewDidUnload {
    [self setTitleTextLabel:nil];
    [self setTableView:nil];
    [self setNameLabel:nil];
    [self setPersonImageView:nil];
    [self setFollowersLabel:nil];
    [self setFollowingLabel:nil];
    [super viewDidUnload];
}

#pragma mark - Buttons Action


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_tableArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kProfileCellIdentifier = @"ProfileCell";
    
    ProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:kProfileCellIdentifier];
    
    if (cell == nil){
        cell = [ProfileCell loadViewFromXIB];
    }
    
    // Configure the cell...
    cell.nameLabel.text = [_tableArray safeObjectAtIndex:indexPath.row];
    
    cell.personNameLabel.hidden = YES;
    
    return cell;
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    switch (indexPath.row) {
        case 0:{
            [self showMyLikes];
            break;
        }
        case 1:{
            [self showMyWishlist];
            break;
        }
        case 2:{
            [self showSettings];
            break;
        }
        case 3:{
            [self showAbout];
            break;
        }
        case 4:{
            [self logout];
            break;
        }
        default:
            break;
    }
}


#pragma mark - Privat Methods
- (void)loadProfileInfo{
    
    [self showSpinnerWithName:@"ProfileViewController"];
    NSString* userIdString = [DataManager shared].userId;
    NSNumber* userId = [NSNumber numberWithInt:[userIdString intValue]];
    [ProductDetailsManager loadProfileInfoForUserIdNumber:userId
                                                  success:^(NSNumber *userIdNumber, NSDictionary *profile) {
                                                      [self hideSpinnerWithName:@"ProfileViewController"];
                                                      _profileInfo = profile;
                                                      [self updateViews];
                                                  }
                                                  failure:^(NSNumber *userIdNumber, NSError *error, NSString *errorString) {
                                                      [self hideSpinnerWithName:@"ProfileViewController"];
                                                      [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                                                          message:errorString];
                                                  }
                                                exception:^(NSNumber *userIdNumber, NSString *exceptionString) {
                                                    [self hideSpinnerWithName:@"ProfileViewController"];
                                                    [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                                }];
}


- (void)setPersonImageURLString:(NSString*)imageURLString{
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURLString]
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:30];
    
    [self.personImageView  setImageWithURLRequest:request
                                 placeholderImage:[UIImage imageNamed:@"posted_user_ic@2x.png"]
                                     failureImage:nil
                                 progressViewSize:CGSizeMake(_personImageView.bounds.size.width - 5, 4)
                                progressViewStile:UIProgressViewStyleDefault
                                progressTintColor:[UIColor colorWithRed:109/255.0f green:145/255.0f blue:109/255.0f alpha:1]
                                   trackTintColor:nil
                                       sizePolicy:UNImageSizePolicyScaleAspectFill
                                      cachePolicy:UNImageCachePolicyMemoryAndFileCache
                                          success:nil
                                          failure:nil
                                         progress:nil];
    
}

- (void)logout {
    _isNeedUpdate = YES;
    _nameLabel.text = @"";
    [[LoginSignUpManager shared] logout];
    [[LayoutManager shared] showLogin];
}

- (void)updateViews{

    _nameLabel.text = [_profileInfo safeStringObjectForKey:@"name"];
    _followersLabel.text =
    [NSString stringWithFormat:@"%d Followers", [[_profileInfo safeNumberObjectForKey:@"follower_count"] intValue]];
    _followingLabel.text =
    [NSString stringWithFormat:@"%d Following", [[_profileInfo safeNumberObjectForKey:@"following_count"] intValue]];
    [self setPersonImageURLString:[_profileInfo safeStringObjectForKey:@"avatar_url"]];
}

- (void)showMyWishlist{
    MyWishlistViewController* myWishlistViewController = [MyWishlistViewController loadFromXIB_Or_iPhone5_XIB];
    [self.navigationController pushViewController:myWishlistViewController animated:YES];
}

- (void)showMyLikes{
    MyLikesViewController* myLikesViewController = [MyLikesViewController loadFromXIB_Or_iPhone5_XIB];
    [self.navigationController pushViewController:myLikesViewController animated:YES];
}

- (void)showAbout{
    AboutViewController* aboutViewController = [AboutViewController loadFromXIB_Or_iPhone5_XIB];
    [self.navigationController pushViewController:aboutViewController animated:YES];
}

- (void)showSettings{
    SettingsViewController* settingsViewController = [SettingsViewController loadFromXIB_Or_iPhone5_XIB];
    settingsViewController.profileInfo = _profileInfo;
    [self.navigationController pushViewController:settingsViewController animated:YES];
}

@end
