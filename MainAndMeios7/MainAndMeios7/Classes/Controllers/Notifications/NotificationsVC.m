//
//  NoticationsVC.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 14.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "NotificationsVC.h"
#import "CustomTitleView.h"
#import "NotificationCell.h"
#import "GetNotificationsRequest.h"
#import "RemoveNotificationRequest.h"
#import "ProximityKitManager.h"
#import "LoadStoreRequest.h"
#import "LoadProductById.h"
#import "StoreDetailsVC.h"
#import "ProductDetailsVC.h"


@interface NotificationsVC () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *noNotificationsView;

@property (strong, nonatomic) NSMutableArray* tableArray;
@property (strong, nonatomic) NSArray* serverNotifications;


@end

@implementation NotificationsVC

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton* menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setImage:[UIImage imageNamed:@"menu_button.png"] forState:UIControlStateNormal];
    menuButton.frame = CGRectMake(0, 0, 40, 40);
    [menuButton addTarget:self action:@selector(anchorRight) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *anchorLeftButton  = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    self.navigationItem.leftBarButtonItem = anchorLeftButton;
    
    [self showEditButton];
    
    self.navigationItem.titleView = [[CustomTitleView alloc] initWithTitle:@"NOTIFICATIONS" dropDownIndicator:NO clickCallback:^(CustomTitleView *titleView) {
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveCampaignNotification:) name:kNewCampaignNotification object:nil];
    
    
    [self updateData];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"NotificationCell" bundle:nil] forCellReuseIdentifier:@"NotificationCell"];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //    self.tableView.alpha = 0;
    //    self.noNotificationsView.alpha = 0;
    
    [self loadServerNotifications];
    
    //[self updateData];
    
}


- (void)loadServerNotifications{
    
    [self showSpinnerWithName:@""];
    GetNotificationsRequest *request = [[GetNotificationsRequest alloc] init];
    __weak NotificationsVC *wself = self;
    [[MMServiceProvider sharedProvider] sendRequest:request success:^(id _request) {
        
        wself.serverNotifications = request.notifications;
        
        [self updateData];
        
        [self hideAllSpiners];
    } failure:^(id _request, NSError *error) {
        [self hideAllSpiners];
        [[AlertManager shared] showOkAlertWithTitle:@"Error" message:error.localizedDescription];
    }];

}

- (void)updateData{
    
    self.tableArray = [NSMutableArray new];
    
    [_tableArray addObjectsFromArray:[ProximityKitManager shared].compaignArray];
    [_tableArray addObjectsFromArray:_serverNotifications];
    
    [_tableView reloadData];
    
    [self updateViews];
    
}

- (void)removeNotification: (NSDictionary *) item callback: (void (^)())callback  {
    RemoveNotificationRequest *request = [[RemoveNotificationRequest alloc] init];
    request.notificationId = [item safeObjectForKey:@"id"];
    [[MMServiceProvider sharedProvider] sendRequest:request success:^(id _request) {
        NSLog(@"Successfully deleted notification: %@", item);
        if (callback)
            callback();
    }failure:^(id _request, NSError *error) {
        NSLog(@"Remove notification failed with error: %@", error);
        if (callback)
            callback();
    }];
}

- (void)updateViews{
    [UIView animateWithDuration:0.3f delay:0 options:0 animations:^() {
        if (_tableArray.count == 0) {
            self.noNotificationsView.alpha = 1;
            self.tableView.alpha = 0;
        } else {
            self.noNotificationsView.alpha = 0;
            self.tableView.alpha = 1;
        }
        
    }completion:^(BOOL finished) {
        
    }];
}



- (void) readAllAction {

    NSArray* itemsToDelete = [NSArray arrayWithArray:_tableArray];
    
    [itemsToDelete enumerateObjectsUsingBlock:^(id item, NSUInteger idx, BOOL *stop) {
        
        if ([item isKindOfClass:[CKCampaign class]]) {
            CKCampaign* campaign = (CKCampaign *)item;
            [[ProximityKitManager shared] deleteCompaign:campaign];
            
            [self updateData];
            
        } else {
            
            [self showSpinnerWithName:@""];
            [self removeNotification:(NSDictionary*)item callback:^{
                [self hideSpinnerWithName:@""];
                [self loadServerNotifications];
            }];
        }
    }];

}

- (void) anchorRight {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}


- (void)editButtonClicked{
    [self showDoneButton];
    [_tableView setEditing:YES animated:YES];
}

- (void)doneButtonClicked{
    [self showEditButton];
    [_tableView setEditing:NO animated:YES];
}


- (void)showEditButton{
    //
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editButtonClicked)];
    //
}

- (void)showDoneButton{
    //
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonClicked)];
    //
}


#pragma mark - TableView

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tableArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationCell *cell = (NotificationCell *) [tableView dequeueReusableCellWithIdentifier:@"NotificationCell"];
    
    
    if ([[_tableArray safeObjectAtIndex:indexPath.row] isKindOfClass:[CKCampaign class]]) {
        CKCampaign* camaign = [_tableArray safeObjectAtIndex:indexPath.row];
        
        [cell setCampaign:camaign];
    } else {
        [cell setNotification:[_tableArray safeObjectAtIndex:indexPath.row]];
    }
    
    
    
    //if (indexPath.row == 4 || indexPath.row == 0) {
    cell.backlighted = NO;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //} else {
    //    cell.backlighted = NO;
    //    cell.accessoryType = UITableViewCellAccessoryNone;
    //}
    
    return cell;
}

- (void) showStore: (NSDictionary *) store {
    StoreDetailsVC *vc = [StoreDetailsVC loadFromXIB_Or_iPhone5_XIB];
    vc.storeDict = store;
    [self.navigationController pushViewController:vc animated:YES];

}

- (void) showProduct: (NSDictionary *) product {
    ProductDetailsVC *vc = [ProductDetailsVC loadFromXIB_Or_iPhone5_XIB];
    vc.product = product;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSObject *item = [_tableArray safeObjectAtIndex:indexPath.row];
    
    
    if ([item isKindOfClass:[CKCampaign class]]) {
        CKCampaign* campaign = (CKCampaign *) item;
        
        [[LayoutManager shared] showSpecialDetails:campaign];
    } else {
        NSDictionary *object = (NSDictionary *) item;
        NSNumber* product_id = [object safeNumberObjectForKey:@"product_id"];
        NSNumber* store_id = [object safeNumberObjectForKey:@"store_id"];
        NSNumber *objId = [object safeNSNumberObjectForKey:@"id"];
        
        //if ([[object safeStringObjectForKey:@"notifiable_type"] isEqualToString:@"Follow"]) {
            //[tableView beginUpdates];
            
            //[self.items removeObjectAtIndex:indexPath.row];
//            [self readNotification:(NSDictionary *) item callback:^{
//                [self reload];
//            }];
        
        [self removeNotification:(NSDictionary *)item callback:^{
            [self loadServerNotifications];
        }];
        
            //[tableView endUpdates];
            //[self reload];

        //    return;
        //}
        
        
    
        
        ServiceRequest *request = nil;
        if ([store_id intValue] > 0) {
            
            request = [[LoadStoreRequest alloc] initWithStoreId:store_id];
         } else if ([product_id intValue] > 0) {
             
             request = [[LoadProductById alloc] initWithProductId:product_id];
        }
        
        
        [self showSpinnerWithName:@""];
        __weak NotificationsVC *wself = self;
        [[MMServiceProvider sharedProvider] sendRequest:request success:^(id request) {
            if ([store_id intValue] > 0) {
                
                [wself showStore:[(LoadStoreRequest *)request storeDetails]];
            } else if ([product_id intValue] > 0) {
                
                [wself showProduct:[(LoadProductById *)request product]];
            }
            [wself hideAllSpiners];
        } failure:^(id _request, NSError *error) {
            [wself hideAllSpiners];            
        }];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSObject *item = [_tableArray safeObjectAtIndex:indexPath.row];

        //[tableView beginUpdates];
        
        
        
        if ([item isKindOfClass:[CKCampaign class]]) {
            CKCampaign* campaign = (CKCampaign *)item;
            [[ProximityKitManager shared] deleteCompaign:campaign];
            
            [self updateData];
            
        } else {
            
            [self showSpinnerWithName:@""];
            [self removeNotification:(NSDictionary*)item callback:^{
                [self hideSpinnerWithName:@""];
                [self loadServerNotifications];
            }];
        }
        
        //[tableView endUpdates];
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
}

//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
//}
//
//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
// return YES;
//}

- (void)didReceiveCampaignNotification:(NSNotification*)notification{
    [self updateData];
}

@end
