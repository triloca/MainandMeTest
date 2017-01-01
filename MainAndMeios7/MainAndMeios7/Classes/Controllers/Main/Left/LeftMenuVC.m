//
//  LeftMenuVC.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 10/19/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "LeftMenuVC.h"
#import "LeftMenuCell.h"
#import "GetNotificationsRequest.h"
#import "IntroPresentViewController.h"
#import "ReadGetStartedViewController.h"

@interface LeftMenuVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray* tableArray;
@property (assign, nonatomic) NSInteger notificationCount;

@end

@implementation LeftMenuVC


#pragma mark _______________________ Class Methods _________________________
#pragma mark ____________________________ Init _____________________________

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark _______________________ View Lifecycle ________________________

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.tableFooterView = [UIView new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveCampaignNotification:) name:kNewCampaignNotification object:nil];

    [self loadData];
    [self updateViews];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   
    [self loadNotificationCount];
}

#pragma mark _______________________ Privat Methods(view)___________________
#pragma mark _______________________ Privat Methods ________________________

- (void)loadData{
    _tableArray = @[@"Sales & Events",
                    @"Home",
                    @"Search",
                    @"All Places",
                    @"My wishlists",
                    @"Places I Follow",
                    @"Notifications",
                    @"Edit my profile",
                    @"Benefits to towns",
                    @"Get started",
                    @"Sponsor page",
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
    
    if ([cell.nameLabel.text isEqualToString:@"\"Sales & Events\""]) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:1.000f green:0.984f blue:0.686f alpha:1.00f];
    }else{
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    if ([cell.nameLabel.text isEqualToString:@"Notifications"]) {
        cell.badgeView.hidden = NO;
        
       NSInteger count = [ProximityKitManager shared].compaignArray.count;
        count += _notificationCount;
        
        [cell setupBageString:[NSString stringWithFormat:@"%d", count]];
        
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
 
            [LayoutManager shared].slidingVC.topViewController = [LayoutManager shared].specialNVC;
            [[LayoutManager shared].slidingVC resetTopViewAnimated:YES onComplete:^{}];
            
            break;
        }
        case 1:{
            
            [LayoutManager shared].slidingVC.topViewController = [LayoutManager shared].homeNVC;
            [[LayoutManager shared].slidingVC resetTopViewAnimated:YES onComplete:^{}];
            
            break;
        }
        case 2:{
            
            [LayoutManager shared].slidingVC.topViewController = [LayoutManager shared].searchNVC;
            [[LayoutManager shared].slidingVC resetTopViewAnimated:YES onComplete:^{}];
            
            break;
        }
        case 3:{
            [LayoutManager shared].slidingVC.topViewController = [LayoutManager shared].storesByNameNVC;
            [[LayoutManager shared].slidingVC resetTopViewAnimated:YES onComplete:^{}];
            
            break;
        }
        case 4:{
            [LayoutManager shared].slidingVC.topViewController = [LayoutManager shared].myWishlistNVC;
            [[LayoutManager shared].slidingVC resetTopViewAnimated:YES onComplete:^{}];
            
            break;
        }
        case 5:{
            [LayoutManager shared].slidingVC.topViewController = [LayoutManager shared].placesFollowNVC;
            [[LayoutManager shared].slidingVC resetTopViewAnimated:YES onComplete:^{}];
            
            break;
        }
        case 6:{
            [LayoutManager shared].slidingVC.topViewController = [LayoutManager shared].notificationsNVC;
            [[LayoutManager shared].slidingVC resetTopViewAnimated:YES onComplete:^{}];
            
            break;
        }
        case 7:{
            //ProfileVC* vc =
            [LayoutManager shared].slidingVC.topViewController = [LayoutManager shared].profileNVC;
            [[LayoutManager shared].slidingVC resetTopViewAnimated:YES onComplete:^{}];
            
            break;
        }
        case 8:{
            
            [self showIntroPresentationView];
            
            break;
        }
            
        case 9:{
            [self showReadGetStartedView];
            
            break;
        }
        case 10:{
            [LayoutManager shared].slidingVC.topViewController = [LayoutManager shared].sponsoredByNVC;
            [[LayoutManager shared].slidingVC resetTopViewAnimated:YES onComplete:^{}];
            
            break;
        }
        case 11:{
            [LayoutManager shared].slidingVC.topViewController = [LayoutManager shared].privacyPolicyNVC;
            [[LayoutManager shared].slidingVC resetTopViewAnimated:YES onComplete:^{}];
            
            break;
        }
        case 12:{
            [[CommonManager shared] logout];
            [LayoutManager createSlidingVC];
            break;
        }
        default:
            break;
    }
    
    
}


#pragma mark _______________________ Public Methods ________________________

- (void)loadNotificationCount{

    GetNotificationsRequest *request = [[GetNotificationsRequest alloc] init];

    [[MMServiceProvider sharedProvider] sendRequest:request success:^(id _request) {
        
       _notificationCount = request.notifications.count;
        [self.tableView reloadData];
        
    } failure:^(id _request, NSError *error) {
       
    }];
}

- (void)showReadGetStartedView{
    ReadGetStartedViewController* readGetStartedViewController = [ReadGetStartedViewController loadFromXIBForScrrenSizes];

    UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:readGetStartedViewController];
    navVC.navigationBarHidden = YES;
    
    
    readGetStartedViewController.didClickHomeButton = ^(ReadGetStartedViewController* sender){
        
        [LayoutManager shared].slidingVC.topViewController = [LayoutManager shared].homeNVC;
        [[LayoutManager shared].slidingVC resetTopViewAnimated:YES onComplete:^{}];
        
        [sender dismissViewControllerAnimated:YES completion:^{
            
        }];
    };
    
    readGetStartedViewController.didClickPhotoButton = ^(ReadGetStartedViewController* sender){
       
        [LayoutManager shared].slidingVC.topViewController = [LayoutManager shared].homeNVC;
        [[LayoutManager shared].homeNVC popToRootViewControllerAnimated:NO];
        HomeVC* homeVC = [LayoutManager shared].homeNVC.viewControllers.firstObject;
        [homeVC removeCoverViewAnimated:NO];
        [[LayoutManager shared].slidingVC anchorTopViewToLeftAnimated:NO];

        [sender dismissViewControllerAnimated:YES completion:^{
        }];
        
        [[LayoutManager shared].homeVC cameraButtinCliced:nil];

    };

    
    readGetStartedViewController.didClickHomeButton = ^(ReadGetStartedViewController* sender){
        [LayoutManager shared].slidingVC.topViewController = [LayoutManager shared].homeNVC;
        [[LayoutManager shared].slidingVC resetTopViewAnimated:YES onComplete:^{}];
        
        [sender dismissViewControllerAnimated:YES completion:^{}];
    };
    
    /*
    introPresentViewController.didClickAddItem = ^(IntroPresentViewController* obj){
        
        [LayoutManager shared].slidingVC.topViewController = [LayoutManager shared].homeNVC;
        [[LayoutManager shared].homeNVC popToRootViewControllerAnimated:NO];
        HomeVC* homeVC = [LayoutManager shared].homeNVC.viewControllers.firstObject;
        [homeVC removeCoverViewAnimated:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
        
        [[LayoutManager shared].slidingVC resetTopViewAnimated:YES onComplete:^{
            [obj dismissViewControllerAnimated:YES completion:^{
                [homeVC cameraButtinCliced:nil];
            }];
        }];
        
    };
    
    introPresentViewController.didClickAddLocalBussines = ^(IntroPresentViewController* obj){
        [LayoutManager shared].slidingVC.topViewController = [LayoutManager shared].homeNVC;
        [[LayoutManager shared].homeNVC popToRootViewControllerAnimated:NO];
        HomeVC* homeVC = [LayoutManager shared].homeNVC.viewControllers.firstObject;
        [homeVC removeCoverViewAnimated:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [homeVC showAddressController];
        });
        
        [[LayoutManager shared].slidingVC resetTopViewAnimated:YES onComplete:^{
            [obj dismissViewControllerAnimated:YES completion:^{}];
        }];
        
    };
    
    introPresentViewController.didClickWindshop = ^(IntroPresentViewController* obj){
        [LayoutManager shared].slidingVC.topViewController = [LayoutManager shared].homeNVC;
        [[LayoutManager shared].homeNVC popToRootViewControllerAnimated:NO];
        HomeVC* homeVC = [LayoutManager shared].homeNVC.viewControllers.firstObject;
        [homeVC removeCoverViewAnimated:NO];
        
        [[LayoutManager shared].slidingVC resetTopViewAnimated:YES onComplete:^{
            [obj dismissViewControllerAnimated:YES completion:^{}];
        }];
    };
    
     */
    
    [[LayoutManager shared].slidingVC presentViewController:navVC animated:YES completion:^{
        
    }];
    
    //[LayoutManager shared].slidingVC.topViewController = [LayoutManager shared].aboutNVC;
    //[[LayoutManager shared].slidingVC resetTopViewAnimated:YES onComplete:^{}];
    
    
}

- (void)showIntroPresentationView{
    IntroPresentViewController* introPresentViewController = [IntroPresentViewController loadFromXIBForScrrenSizes];
    UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:introPresentViewController];
    navVC.navigationBarHidden = YES;
    
    introPresentViewController.didClickAddItem = ^(IntroPresentViewController* obj){
        
        [LayoutManager shared].slidingVC.topViewController = [LayoutManager shared].homeNVC;
        [[LayoutManager shared].homeNVC popToRootViewControllerAnimated:NO];
        HomeVC* homeVC = [LayoutManager shared].homeNVC.viewControllers.firstObject;
        [homeVC removeCoverViewAnimated:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
        
        [[LayoutManager shared].slidingVC resetTopViewAnimated:YES onComplete:^{
            [obj dismissViewControllerAnimated:YES completion:^{
                [homeVC cameraButtinCliced:nil];
            }];
        }];
        
    };
    
    introPresentViewController.didClickAddLocalBussines = ^(IntroPresentViewController* obj){
        [LayoutManager shared].slidingVC.topViewController = [LayoutManager shared].homeNVC;
        [[LayoutManager shared].homeNVC popToRootViewControllerAnimated:NO];
        HomeVC* homeVC = [LayoutManager shared].homeNVC.viewControllers.firstObject;
        [homeVC removeCoverViewAnimated:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [homeVC showAddressController];
        });
        
        [[LayoutManager shared].slidingVC resetTopViewAnimated:YES onComplete:^{
            [obj dismissViewControllerAnimated:YES completion:^{}];
        }];
        
    };
    
    introPresentViewController.didClickWindshop = ^(IntroPresentViewController* obj){
        [LayoutManager shared].slidingVC.topViewController = [LayoutManager shared].homeNVC;
        [[LayoutManager shared].homeNVC popToRootViewControllerAnimated:NO];
        HomeVC* homeVC = [LayoutManager shared].homeNVC.viewControllers.firstObject;
        [homeVC removeCoverViewAnimated:NO];
        
        [[LayoutManager shared].slidingVC resetTopViewAnimated:YES onComplete:^{
            [obj dismissViewControllerAnimated:YES completion:^{}];
        }];
    };
    
    introPresentViewController.didClickHome = ^(IntroPresentViewController* obj){
        [LayoutManager shared].slidingVC.topViewController = [LayoutManager shared].homeNVC;
        [[LayoutManager shared].slidingVC resetTopViewAnimated:YES onComplete:^{}];
        
        [obj dismissViewControllerAnimated:YES completion:^{}];

    };

    
    [[LayoutManager shared].slidingVC presentViewController:navVC animated:YES completion:^{
        
    }];
    
    //[LayoutManager shared].slidingVC.topViewController = [LayoutManager shared].aboutNVC;
    //[[LayoutManager shared].slidingVC resetTopViewAnimated:YES onComplete:^{}];
    

}
#pragma mark _______________________ Notifications _________________________

- (void)didReceiveCampaignNotification:(NSNotification*)notification{
    [self updateViews];
}

@end
