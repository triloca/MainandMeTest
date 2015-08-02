//
//  WishlistDetailsVC.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 03.12.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "WishlistDetailsVC.h"
#import "CustomTitleView.h"
#import "HomeStoreCell.h"
#import "HomeItemCell.h"
#import "ProductDetailsVC.h"
#import "StoreDetailsVC.h"
#import "LoadWishlistDetailsRequest.h"
#import "ProductDetailsManager.h"
#import "ProductCell.h"
#import "ProductsStoresManager.h"
#import "ShareView.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
@import Social;

#import "PinterestManager.h"
#import "UIImage+Scaling.h"
#import "FacebookSDK/FacebookSDK.h"



static NSString *kProductCellIdentifier = @"ProductCell";


@interface WishlistDetailsVC ()
<UIActionSheetDelegate,
MFMailComposeViewControllerDelegate,
MFMessageComposeViewControllerDelegate,
UIDocumentInteractionControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *emptyWishlistView;
@property (weak, nonatomic) IBOutlet TMQuiltView *tmQuiltView;
@property (strong, nonatomic) NSMutableArray *items;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) BOOL isEditing;
@property (assign, nonatomic) BOOL isSharing;
@property (weak, nonatomic) IBOutlet UIButton *sharingButton;

@property (strong, nonatomic) NSMutableArray* selectedIndexesArray;
@property (strong, nonatomic) NSMutableArray* sharingObjectsArray;


@property (strong, nonatomic) ShareView* shareView;
@property (strong, nonatomic) NSLayoutConstraint* bottomConstraint;

@property (weak, nonatomic) IBOutlet UIView *bottomShareView;

@property (strong, nonatomic) UIDocumentInteractionController *docController;

@end

@implementation WishlistDetailsVC 

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak WishlistDetailsVC* wSelf = self;
    self.navigationItem.titleView = [[CustomTitleView alloc] initWithTitle:[_wishlist safeStringObjectForKey:@"name"] dropDownIndicator:NO clickCallback:^(CustomTitleView *titleView) {
        [[LayoutManager shared].homeNVC popToRootViewControllerAnimated:NO];
        [[LayoutManager shared] showHomeControllerAnimated:YES];
        [wSelf.navigationController popToRootViewControllerAnimated:YES];
    }];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_button"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addedStoreToProductNotification:)
                                                 name:@"kAddedStoreToProductNotification"
                                               object:nil];
    
    
    self.tmQuiltView.delegate = self;
    self.tmQuiltView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    
    self.selectedIndexesArray = [NSMutableArray new];
    
    self.needUpdateData = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_needUpdateData) {
        _needUpdateData = NO;
        [self loadItems];
    }
}

- (void) deleteItemAtIndex: (NSInteger) index {
    __block TMQuiltViewCell *cell = [_tmQuiltView cellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    [UIView animateWithDuration:0.3 animations:^() {
        cell.alpha = 0;
    } completion:^(BOOL finished) {
        [_tmQuiltView beginUpdates];
        NSDictionary *item = _items[index];
        [_items removeObjectAtIndex:index];
        [_tmQuiltView deleteCellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        cell.alpha = 1;
        [_tmQuiltView endUpdates];
        [ProductDetailsManager deleteProduct:item[@"id"] inWishlist:_wishlist[@"id"]
                                     success:^(NSArray *wishlist) {
                                         
                                     }
                                     failure:^(NSError *error, NSString *errorString) {
                                         [[AlertManager shared] showOkAlertWithTitle:error.localizedDescription];
                                     }
                                   exception:^(NSString *exceptionString) {
                                       [[AlertManager shared] showOkAlertWithTitle:exceptionString];
                                   }];
        
        if (_items.count == 0) {
            self.navigationItem.rightBarButtonItem = nil;
        }
        
    }];
}


//- (void) deleteItemAtIndex: (NSInteger) index {
//    __block TMQuiltViewCell *cell = [_tmQuiltView cellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
//    
//    [UIView animateWithDuration:0.3 animations:^() {
//        cell.alpha = 0;
//    } completion:^(BOOL finished) {
//        [_tmQuiltView beginUpdates];
//        NSDictionary *item = _items[index];
//        [_items removeObjectAtIndex:index];
//        [_tmQuiltView deleteCellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
//        cell.alpha = 1;
//        [_tmQuiltView endUpdates];
//        [ProductDetailsManager deleteProduct:item[@"id"] inWishlist:_wishlist[@"id"] success:nil failure:nil exception:nil];
//        
//        if (_items.count == 0) {
//            self.navigationItem.rightBarButtonItem = nil;
//        }
//        
//    }];
//}

- (void) editAction: (id) sender {
//    [self deleteItemAtIndex:0];
    [_tmQuiltView setEditing:!_tmQuiltView.editing animated:YES];
    
    if (_tmQuiltView.editing) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(editAction:)];

    }else{
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(editAction:)];
    }
}



- (void) backAction: (id) sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) loadItems {
    
    self.navigationItem.rightBarButtonItem = nil;
    [UIView animateKeyframesWithDuration:0.3 delay:0 options:0 animations:^() {
        //_tmQuiltView.alpha = 0;
        _tableView.alpha = 0;
    } completion:nil];
    
    [self showSpinnerWithName:@""];
    LoadWishlistDetailsRequest *request = [[LoadWishlistDetailsRequest alloc] init];
    request.wishlistId = [_wishlist safeObjectForKey:@"id"];
    
    [[MMServiceProvider sharedProvider] sendRequest:request success:^(id _request) {
        
//        if (request.wishlist.count > 0) {
//            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction:)];
//        }else{
//            self.navigationItem.rightBarButtonItem = nil;
//        }
        
        self.items = [request.wishlist mutableCopy];
        [self updateEditButton];
        
        [self reloadQuiltView];
        [self hideAllSpiners];
    } failure:^(id _request, NSError *error) {
        [self reloadQuiltView];
        [self hideAllSpiners];
    }];
}

- (void) reloadQuiltView {
   // [_tmQuiltView reloadData];
    [_tableView reloadData];
    //NSLog(@"Items count: %ld", self.items.count);
    
    if (self.items.count == 0) {
        [UIView animateKeyframesWithDuration:0.3 delay:0 options:0 animations:^() {
            //_tmQuiltView.alpha = 0;
            _tableView.alpha = 0;
            _emptyWishlistView.alpha = 1;
        } completion:nil];
    } else {
        [UIView animateKeyframesWithDuration:0.3 delay:0 options:0 animations:^() {
            //_tmQuiltView.alpha = 1;
            _tableView.alpha = 1;
            _emptyWishlistView.alpha = 0;
        } completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSDictionary *) storeForIndex: (NSUInteger) index {
    NSDictionary *dict = [_items safeDictionaryObjectAtIndex:index];
    if (![[dict safeObjectForKey:@"model_name"] isEqualToString:@"Store"])
        return nil;
    
    NSNumber* store_id = [dict safeNumberObjectForKey:@"store_id"];
    
    if ([store_id intValue] > 0) {
        return dict;
    }
    return nil;
}

- (NSDictionary *) productForIndex: (NSUInteger) index {
    NSDictionary *dict = [_items safeDictionaryObjectAtIndex:index];
    if (![[dict safeObjectForKey:@"model_name"] isEqualToString:@"Product"])
        return nil;
    
    return dict;
}

- (IBAction)onSharingButton:(id)sender {
    self.isSharing = YES;
    [self updateEditButton];
    [self.tableView reloadData];
   
    [self showShare:YES animated:YES];
}


- (void)showShare:(BOOL)value animated:(BOOL)animated{
    
    
    if (self.shareView == nil) {
        
        self.shareView = [ShareView loadViewFromXIB];
        self.shareView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:self.shareView];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.shareView
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeLeading
                                                             multiplier:1.0
                                                               constant:0.0]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.shareView
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1.0
                                                               constant:0.0]];
        
        self.bottomConstraint = [NSLayoutConstraint constraintWithItem:self.shareView
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.0
                                                              constant:self.shareView.frame.size.height];
        
//        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.shareView
//                                                           attribute:NSLayoutAttributeHeight
//                                                           relatedBy:NSLayoutRelationEqual
//                                                              toItem:nil
//                                                           attribute:NSLayoutAttributeNotAnAttribute
//                                                          multiplier:1.0
//                                                            constant:195]];
        
//        [self.shareView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[shareView(==195)]"
//                                                                       options:0
//                                                                       metrics:nil
//                                                                         views:NSDictionaryOfVariableBindings(self.shareView)]];
        [self.view addConstraint:_bottomConstraint];
        
        [self.view layoutIfNeeded];
        
        __weak WishlistDetailsVC* wSelf = self;
        
        self.shareView.didClickCancelButton = ^(ShareView* view, UIButton* button){
            [wSelf showShare:NO animated:YES];
            wSelf.isSharing = NO;
            [wSelf updateShareButtin];
            [wSelf updateEditButton];
            [wSelf.selectedIndexesArray removeAllObjects];
            [wSelf.tableView reloadData];
        };
        
        self.shareView.didClickShareButton = ^(ShareView* view, UIButton* button){
            switch (button.tag) {
                case 1:{
                    
                    [wSelf showSpinnerWithName:@""];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [wSelf shareMessage];
                    });
                    
                }
                    break;
                case 2:{
                    
                    [wSelf showSpinnerWithName:@""];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [wSelf shareMail];
                    });
                }
                    break;
                case 3:{
                    
                    [wSelf showSpinnerWithName:@""];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [wSelf shareFacebook];
                    });
                }
                    break;
                case 4:{
                    [wSelf showSpinnerWithName:@""];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [wSelf shareTwitter];
                    });
                }
                    break;
                case 5:
                    [wSelf sharePinterest];
                    break;
                case 6:{
                    
                    [wSelf showSpinnerWithName:@""];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [wSelf shareInstagrem];
                    });
                }
                    break;
                    
                default:
                    break;
            }
        };
        
    }
    
    [self.view bringSubviewToFront:self.shareView];
    
    
    [UIView animateWithDuration:animated ? 0.3 : 0
                     animations:^{
                         
                         if (value) {
                             _bottomConstraint.constant = 0;
                             self.bottomShareView.hidden = YES;
                             self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.contentInset.top, self.tableView.contentInset.left, self.tableView.contentInset.bottom + self.shareView.frame.size.height, self.tableView.contentInset.right);
                             self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
                         }else{
                             _bottomConstraint.constant = self.shareView.frame.size.height;
                             self.bottomShareView.hidden = NO;
                             
                             self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.contentInset.top, self.tableView.contentInset.left, self.tableView.contentInset.bottom - self.shareView.frame.size.height, self.tableView.contentInset.right);
                             self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
                         }

                         
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
//    [self.view updateConstraintsIfNeeded];
//    [self.view layoutIfNeeded];
    
    //view.constraints
}


- (void)prepareForShare{
    self.sharingObjectsArray = [NSMutableArray new];
    for (NSNumber* index in _selectedIndexesArray) {
       NSDictionary* obj = [self.items safeDictionaryObjectAtIndex:[index integerValue]];
        [self.sharingObjectsArray addObject:obj];
    }
    
    
}

#pragma mark - Share

- (void)shareMessage{
    [self prepareForShare];
    
    
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if (controller) {
        if ([MFMessageComposeViewController canSendText]) {
            controller.messageComposeDelegate = self;
            
            if (self.sharingObjectsArray.count == 0) {
                [[AlertManager shared] showOkAlertWithTitle:@"Select Items for share"];
                [self hideSpinnerWithName:@""];
                return;
            }
            
            NSMutableString* bodyString = [NSMutableString stringWithString:@"Check out this local find I just added to Main&Me.\n"];
            for (NSDictionary* obj in self.sharingObjectsArray) {
                
                [bodyString appendString:[obj safeStringObjectForKey:@"name"]];
                [bodyString appendString:@"\n"];
                NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/products/%@", [[obj safeNumberObjectForKey:@"id"] stringValue]];
                [bodyString appendString:urlString];
                [bodyString appendString:@".\n\n"];
                
                
                NSString* imageURL = [[obj safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
                NSData* photoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
                if (photoData) {
                    [controller addAttachmentData:photoData typeIdentifier:@"public.data" filename:@"image.png"];
                }
            }
            
//            bodyString = [NSString stringWithFormat:@"%@\n%@", bodyString, [_product safeStringObjectForKey:@"name"]];
//            NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/products/%@", [[_product safeNumberObjectForKey:@"id"] stringValue]];
           // bodyString = [NSString stringWithFormat:@"You might like this gem I found in your neck of the woods:\n%@\n%@", bodyString, urlString];
            
            controller.body = bodyString;
        
            
            
            [self presentViewController:controller animated:YES completion:^{}];
        } else {
            [[AlertManager shared] showOkAlertWithTitle:@"Can't Share via SMS"];
        }
    }
    
    [self hideSpinnerWithName:@""];
    
}

- (void)shareMail{
    
    [self prepareForShare];
    
    if ([MFMailComposeViewController canSendMail]){
        
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        
        
        
        if (self.sharingObjectsArray.count == 0) {
            [[AlertManager shared] showOkAlertWithTitle:@"Select Items for share"];
            [self hideSpinnerWithName:@""];
            return;
        }
        
        NSMutableString* bodyString = [NSMutableString stringWithString:@"Check out this local find I just added to Main&Me.:\n"];
        for (NSDictionary* obj in self.sharingObjectsArray) {
            
            [bodyString appendString:[obj safeStringObjectForKey:@"name"]];
            [bodyString appendString:@"\n"];
            NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/products/%@", [[obj safeNumberObjectForKey:@"id"] stringValue]];
            [bodyString appendString:urlString];
            [bodyString appendString:@".\n\n"];
            
            
            NSString* imageURL = [[obj safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
            NSData* photoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
            if (photoData) {
                [controller addAttachmentData:photoData mimeType:@"image/jpg" fileName:[NSString stringWithFormat:@"photo.png"]];
            }
        }

        
        [controller setSubject:@"A friend shared a \"local find\" on MainAndMe"];
        [controller setMessageBody:[NSString stringWithFormat:@"%@", bodyString] isHTML:NO];
        
        [self presentViewController:controller animated:YES completion:^{}];
        
    } else {
        [[AlertManager shared] showOkAlertWithTitle:@"Can't Share via Email"];
    }

    
    [self hideSpinnerWithName:@""];
}

- (void)shareTwitter{
    [self prepareForShare];
    
    // No Twitter Account
    // There are no Twitter acconts configured. You can add or create a Twitter account in Settings
    // Cancel Settings
    
    // Confirm that a Twitter account exists
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        
        if (self.sharingObjectsArray.count == 0) {
            [[AlertManager shared] showOkAlertWithTitle:@"Select Item for share"];
            [self hideSpinnerWithName:@""];
            return;
        }

        
        // Create a compose view controller for the service type Twitter
        SLComposeViewController *twController = ({
            twController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            
           
            
            [twController setCompletionHandler:^(SLComposeViewControllerResult result){
              
                self.isSharing = NO;
                [self updateEditButton];
                [self updateShareButtin];
                [self showShare:NO animated:NO];
                [self.tableView reloadData];

                
                switch (result) {
                    case SLComposeViewControllerResultCancelled:
                        NSLog(@"Compose Result: Post Cancelled");
                        break;
                    case SLComposeViewControllerResultDone:
                        NSLog(@"Compose Result: Post Done");
                    default:
                        break;
                }}];
            
            twController;
        });
        
        
        
        NSMutableString* bodyString = [NSMutableString stringWithString:@"Found this local gem on Main&Me:\n"];
        NSDictionary* obj = self.sharingObjectsArray.firstObject;
        //for (NSDictionary* obj in self.sharingObjectsArray) {
            
            [bodyString appendString:[obj safeStringObjectForKey:@"name"]];
            [bodyString appendString:@"\n"];
            NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/products/%@", [[obj safeNumberObjectForKey:@"id"] stringValue]];
            [bodyString appendString:urlString];
            //[bodyString appendString:@".\n\n"];
            
            
            NSString* imageURL = [[obj safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
            NSData* photoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
            UIImage* image = [UIImage imageWithData:photoData];
            
            if (image) {
                [twController addImage:image];
            }
        //}
        
        
        [twController addURL:[NSURL URLWithString:@"http://www.mainandme.com"]];
        
        // Set the text of the tweet
        [twController setInitialText:bodyString];
        // Set the completion handler to check the result of the post.
        
        // Display the tweet sheet to the user
        [self presentViewController:twController animated:YES completion:nil];
        
        //Memory Management
        twController = nil;
    }
    
    else
    {
        [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (alertView.cancelButtonIndex != buttonIndex) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        }
                                               title:@"No Twitter Account"
                                             message:@"There are no Twitter acconts configured. You can add or create a Twitter account in Settings"
                                   cancelButtonTitle:@"Cancel"
                                   otherButtonTitles:@"Settings", nil];
    }
    
    [self hideSpinnerWithName:@""];

}

- (void)shareFacebook{
    
    [self prepareForShare];
    
    if (self.sharingObjectsArray.count == 1) {
        [self hideSpinnerWithName:@""];
        [self shareButtonClicked:nil];
        return;
    }
    
    
    // No Facebook Account
    // There are no Facebook accont configured. You can add or create a Facebook account in Settings
    // Cancel Settings
    
    SLComposeViewController * fbController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
            
            
            [self hideSpinnerWithName:@""];
            self.isSharing = NO;
            [self updateEditButton];
            [self updateShareButtin];
            [self showShare:NO animated:NO];
            [self.tableView reloadData];
            
            [fbController dismissViewControllerAnimated:YES completion:nil];
            
            switch(result){
                case SLComposeViewControllerResultCancelled:
                default:
                {
                    NSLog(@"Cancelled.");
                    
                }
                    break;
                case SLComposeViewControllerResultDone:
                {
                    NSLog(@"Posted.");
                }
                    break;
            }};
        
        
        if (self.sharingObjectsArray.count == 0) {
            [[AlertManager shared] showOkAlertWithTitle:@"Select Items for share"];
            [self hideSpinnerWithName:@""];
            return;
        }
        
        NSMutableString* bodyString = [NSMutableString stringWithString:@"Found this local gem(s) on Main&Me:\n"];
        for (NSDictionary* obj in self.sharingObjectsArray) {
            
            [bodyString appendString:[obj safeStringObjectForKey:@"name"]];
            [bodyString appendString:@"\n"];
            NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/products/%@", [[obj safeNumberObjectForKey:@"id"] stringValue]];
            [bodyString appendString:urlString];
            [bodyString appendString:@".\n\n"];
            
            
            NSString* imageURL = [[obj safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
            NSData* photoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
            UIImage* image = [UIImage imageWithData:photoData];
            
            if (image) {
                [fbController addImage:image];
            }
        }

        
        [fbController setInitialText:bodyString];
        [fbController addURL:[NSURL URLWithString:@"http://www.mainandme.com"]];
        [fbController setCompletionHandler:completionHandler];
        [self presentViewController:fbController animated:YES completion:nil];
    }else{
    
    
        [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (alertView.cancelButtonIndex != buttonIndex) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        }
                                               title:@"No Facebook Account"
                                             message:@"There are no Facebook acconts configured. You can add or create a Facebook account in Settings"
                                   cancelButtonTitle:@"Cancel"
                                   otherButtonTitles:@"Settings", nil];
    }


}

- (void)sharePinterest{
    [self prepareForShare];
    
    if ([[PinterestManager shared].pinterest canPinWithSDK]) {
        
        if (self.sharingObjectsArray.count == 0) {
            [[AlertManager shared] showOkAlertWithTitle:@"Select Item for share"];
            [self hideSpinnerWithName:@""];
            return;
        }
        
        NSMutableString* bodyString = [NSMutableString stringWithString:@"Found this local gem on Main&Me:\n"];
        NSDictionary* obj = self.sharingObjectsArray.firstObject;
        //for (NSDictionary* obj in self.sharingObjectsArray) {
        
        [bodyString appendString:[obj safeStringObjectForKey:@"name"]];
        [bodyString appendString:@"\n"];
        NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/products/%@", [[obj safeNumberObjectForKey:@"id"] stringValue]];
        [bodyString appendString:urlString];
        [bodyString appendString:@".\n\n"];
        
        
        NSString* imageURLStr = [[obj safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"full"];
        
        //}
        
        
        NSURL* imageURL = [NSURL URLWithString:imageURLStr];
        NSURL* sourceURL = [NSURL URLWithString:@"http://www.mainandme.com"];
        
        [[PinterestManager shared].pinterest createPinWithImageURL:imageURL
                                                         sourceURL:sourceURL
                                                       description:bodyString];
        
    }else{
        
        [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
        }
                                               title:@"Can't share pin"
                                             message:@"Please install last version of Pinterest app"
                                   cancelButtonTitle:@"Ok"
                                   otherButtonTitles:nil];
        
    }
}

- (void)shareInstagrem{
    [self prepareForShare];
    
    if (self.sharingObjectsArray.count == 0) {
        [[AlertManager shared] showOkAlertWithTitle:@"Select Item for share"];
        [self hideSpinnerWithName:@""];
        return;
    }
    
    NSMutableString* bodyString = [NSMutableString stringWithString:@"Found this local gem on Main&Me:\n"];
    NSDictionary* obj = self.sharingObjectsArray.firstObject;
    //for (NSDictionary* obj in self.sharingObjectsArray) {
    
    [bodyString appendString:[obj safeStringObjectForKey:@"name"]];
    //[bodyString appendString:@"\n"];
    //NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/products/%@", [[obj safeNumberObjectForKey:@"id"] stringValue]];
    //[bodyString appendString:urlString];
    //[bodyString appendString:@""];
    
    
    NSString* imageURL = [[obj safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"big"];
    NSData* photoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
    UIImage* image = [UIImage imageWithData:photoData];

    
    image = [image imageScaledToSize:CGSizeMake(640, 640)];
    [NSDictionary dictionaryWithObject:@"Your AppName" forKey:@"InstagramCaption"];
    [self shareImageOnInstagram:image
                     annotation:@{@"InstagramCaption" : bodyString}];

    
    return;
    
//    NSString *jpgPath=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/test.igo"];
//
//    [UIImageJPEGRepresentation(img, 1.0) writeToFile:jpgPath atomically:YES];
//    NSURL *igImageHookFile = [[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"file://%@",jpgPath]];
//    
//    
//    UIDocumentInteractionController *dicont =
//    self.dicont.UTI = @"com.instagram.photo";
//    self.dicont = [self setupControllerWithURL:igImageHookFile usingDelegate:self];
//    self.dicont.annotation = [NSDictionary dictionaryWithObject:@"Your AppName" forKey:@"InstagramCaption"];
//    [self.dicont presentOpenInMenuFromRect: rect  inView: self.view animated: YES ];
//    
//    NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.ig"];
//    [UIImagePNGRepresentation(image) writeToFile:savePath atomically:YES];
//    
//    CGRect rect = CGRectMake(0 ,0 , 0, 0);
//    NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.ig"];
//    NSURL *igImageHookFile = [[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"file://%@", jpgPath]];
//    
//    UIDocumentInteractionController *dic.UTI = @"com.instagram.photo";
//    
//    dic = [self setupControllerWithURL:igImageHookFile usingDelegate:self];
//    self.dic=[UIDocumentInteractionController interactionControllerWithURL:igImageHookFile];
//    [self.dic presentOpenInMenuFromRect: rect    inView: self.view animated: YES ];
//    NSURL *instagramURL = [NSURL URLWithString:@"instagram://media?id=MEDIA_ID"];
//    if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
//    {
//        [self.dic presentOpenInMenuFromRect: rect    inView: self.view animated: YES ];
//    }
//    else
//    {
//        NSLog(@"No Instagram Found");
//
}


-(void)shareImageOnInstagram:(UIImage*)shareImage annotation:(NSDictionary*)annotation
{
    //It is important that image must be larger than 612x612 size if not resize it.
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    
    if([[UIApplication sharedApplication] canOpenURL:instagramURL])
    {
        NSString *documentDirectory=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *saveImagePath=[documentDirectory stringByAppendingPathComponent:@"Image.igo"];
        NSData *imageData=UIImagePNGRepresentation(shareImage);
        [imageData writeToFile:saveImagePath atomically:YES];
        
        NSURL *imageURL=[NSURL fileURLWithPath:saveImagePath];
        
        self.docController = [[UIDocumentInteractionController alloc]init];
        _docController.delegate=self;
        _docController.UTI=@"com.instagram.exclusivegram";
        
        _docController.annotation=[NSDictionary dictionaryWithObjectsAndKeys:@"Image Taken via @App",@"InstagramCaption", nil];
        
        [_docController setURL:imageURL];
        [_docController setAnnotation:annotation];
        
        //[docController presentOpenInMenuFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];  //Here try which one is suitable for u to present the doc Controller. if crash occurs
        
        [_docController presentOpenInMenuFromRect:self.view.frame
                                          inView:self.view
                                        animated: YES ];
    }else{
        [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
        }
                                               title:@"Can't share Item"
                                             message:@"Please install last version of Instagram app"
                                   cancelButtonTitle:@"Ok"
                                   otherButtonTitles:nil];

    }
    
    [self hideSpinnerWithName:@""];
}


#pragma mark -  FB
- (IBAction)shareButtonClicked:(id)sender
{
    
    NSDictionary* product = self.sharingObjectsArray.firstObject;
    
    // if the session is closed, then we open it here, and establish a handler for state changes
    
    [FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:YES completionHandler:^(FBSession *session,FBSessionState state, NSError *error)
     {
         if (error)
         {
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alertView show];
         }
         else if(session.isOpen)
         {
             
             NSString* imageUrl = [[product safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"big"];
             NSString* description = [NSString stringWithFormat:@"%@\n %@",
                                      [product safeStringObjectForKey:@"name"],
                                      [product safeStringObjectForKey:@"description"]];
             
             NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/products/%@", [[product safeNumberObjectForKey:@"id"] stringValue]];
             
             
             //NSString *str_img = [NSString stringWithFormat:@"https://raw.github.com/fbsamples/ios-3.x-howtos/master/Images/iossdk_logo.png"];
             
             NSDictionary *params = @{
                                      @"name" :@"I found this local gem on Main&Me",
                                      @"caption" : [product safeStringObjectForKey:@"store_name"],
                                      @"description" :description,
                                      @"picture" : imageUrl,
                                      @"link" : urlString,
                                      // @"message":
                                      };
             
             // Invoke the dialog
             [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                                    parameters:params
                                                       handler:
              ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                  if (error) {
                      NSLog(@"Error publishing story.");
                  } else {
                      if (result == FBWebDialogResultDialogNotCompleted) {
                          NSLog(@"User canceled story publishing.");
                      } else {
                          NSLog(@"Story published.");
                      }
                  }}];
         }
         
     }];
    
}

#pragma Documents Delegate

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate
{
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    return interactionController;
}
#pragma mark - MFMessageCompose Delegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    switch (result) {
        case MessageComposeResultCancelled: {
            NSLog(@"Cancelled");
        }
            break;
        case MessageComposeResultFailed: {
            [[AlertManager shared] showOkAlertWithTitle:@"Error" message:@"Can't Share SMS"];
        }
            break;
        case MessageComposeResultSent:
            [[AlertManager shared] showOkAlertWithTitle:@"Success" message:@"Shared via SMS"];
            break;
        default:
            break;
    }
    
    self.isSharing = NO;
    [self updateEditButton];
    [self updateShareButtin];
    [self showShare:NO animated:NO];
    [self.tableView reloadData];
    
    [self dismissViewControllerAnimated:YES completion:^{}];
    
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled: {
            NSLog(@"Cancelled");
        }
            break;
        case MFMailComposeResultFailed: {
            [[AlertManager shared] showOkAlertWithTitle:@"Error" message:@"Can't Share via Email"];
        }
            break;
        case MFMailComposeResultSent:
            [[AlertManager shared] showOkAlertWithTitle:@"Success" message:@"Shared via Email"];
            break;
        default:
            break;
    }
    
    
    self.isSharing = NO;
    [self updateEditButton];
    [self updateShareButtin];
    [self showShare:NO animated:NO];
    [self.tableView reloadData];
    
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - TMQuiltViewDelegate


- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)TMQuiltView {
    return _items.count;
}

- (TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary* dict = [_items safeDictionaryObjectAtIndex:indexPath.row];
    
    //! Set cell type
    if ([self productForIndex:indexPath.row]) {
        HomeItemCell *cell = (HomeItemCell *)[quiltView dequeueReusableCellWithReuseIdentifier:@"HomeItemCell"];
        if (!cell) {
            cell = [HomeItemCell loadViewFromXIB];
            [cell setReuseIdentifier:@"HomeItemCell"];
        }
        cell.storeDict = dict;
        
        return cell;
        
    } else if ([self storeForIndex:indexPath.row]){
        HomeStoreCell *cell = (HomeStoreCell *)[quiltView dequeueReusableCellWithReuseIdentifier:@"HomeStoreCell"];
        if (!cell) {
            cell = [HomeStoreCell loadViewFromXIB];
            [cell setReuseIdentifier:@"HomeStoreCell"];
        }
        
        cell.storeDict = dict;
        
        return cell;
        
    }
    return nil;
}

- (void)quiltView:(TMQuiltView *)quiltView didSelectCellAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = [_items objectAtIndex:indexPath.row];
    
    if ([self storeForIndex:indexPath.row]) {
        StoreDetailsVC *vc = [StoreDetailsVC loadFromXIBForScrrenSizes];
        vc.storeDict = dict;
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([self productForIndex:indexPath.row]) {
        ProductDetailsVC *vc = [ProductDetailsVC loadFromXIBForScrrenSizes];
        vc.product = dict;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (NSInteger)quiltViewNumberOfColumns:(TMQuiltView *)quiltView {
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft
        || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        return 2;
    } else {
        return 2;
    }
}

- (CGFloat)quiltView:(TMQuiltView *)quiltView heightForCellAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary* dict = [_items safeDictionaryObjectAtIndex:indexPath.row];
    CGFloat height = 0;
    
    if ([self storeForIndex:indexPath.row]) {
        height = [HomeStoreCell cellHeghtForStore:dict];
    } else if ([self productForIndex:indexPath.row]) {
        height = [HomeItemCell cellHeghtForStore:dict];
    }
    
    return height;
}

- (void) quiltView:(TMQuiltView *)quiltView commitEditingForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self deleteItemAtIndex:indexPath.row];
}


- (void)updateEditButton{
    
    if (_isEditing) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                                  style:UIBarButtonItemStyleBordered
                                                                                 target:self
                                                                                 action:@selector(editButtonClicked)];
    }else{
        if (_items.count > 0) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                                      style:UIBarButtonItemStyleBordered
                                                                                     target:self
                                                                                     action:@selector(editButtonClicked)];
        }else{
            [self.navigationItem setRightBarButtonItem:nil animated:YES];
        }
        
    }
    
    if (_isSharing) {
        [self.navigationItem setRightBarButtonItem:nil animated:NO];
    }
}

- (void)editButtonClicked{
    self.isEditing = !self.isEditing;
    [self.tableView reloadData];
    [self updateEditButton];
    [self updateShareButtin];
}


- (void)updateShareButtin{
    if (_isEditing){
        self.sharingButton.enabled = NO;
    }else{
        self.sharingButton.enabled = YES;
    }
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return tableView.frame.size.width / 3 + 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [_items count];
    NSInteger temp = count % 3;
    NSInteger rowsCount = count / 3;
    if (temp > 0) {
        rowsCount++;
    }
    
    [self updateEditButton];
    
    return rowsCount;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ProductCell* cell = [self productCellForIndexPath:indexPath];
    return cell;
}

- (ProductCell*)productCellForIndexPath:(NSIndexPath*)indexPath{
    ProductCell *cell = [_tableView dequeueReusableCellWithIdentifier:kProductCellIdentifier];
    
    if (_isEditing) {
        [cell.firstView startVibration];
        [cell.secondView startVibration];
        [cell.thirdView startVibration];
    }else{
        [cell.firstView stopVibration];
        [cell.secondView stopVibration];
        [cell.thirdView stopVibration];
    }
    
    if (_isSharing) {
        [cell.firstView hideSelectionImage:NO];
        [cell.secondView hideSelectionImage:NO];
        [cell.thirdView hideSelectionImage:NO];
    }else{
        [cell.firstView hideSelectionImage:YES];
        [cell.secondView hideSelectionImage:YES];
        [cell.thirdView hideSelectionImage:YES];
    }

    
    
    if (cell == nil){
        cell = [ProductCell loadViewFromXIB];
        
        cell.didClickAtIndex = ^(NSInteger selectedIndex){
            NSDictionary* dict = [_items safeObjectAtIndex:selectedIndex];
            if (_isEditing) {
                //! Delete alert
                [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (alertView.cancelButtonIndex == buttonIndex) {
                        
                    }else{
                        [_items removeObject:dict];
                        [_tableView reloadData];
                        [self updateEditButton];
                        //[ProductDetailsManager deleteProduct:dict[@"id"] inWishlist:_wishlist[@"id"] success:nil failure:nil exception:nil];
                        
                        [[ProductsStoresManager shared] deleteProduct:[dict objectForKey:@"id"]
                                                              success:^{
                                                                  
                                                              }
                                                              failure:^(NSError *error, NSString *errorString) {
                                                                  [[AlertManager shared] showOkAlertWithTitle:errorString message:error.localizedDescription];
                                                              }
                                                            exception:^(NSString *exceptionString) {
                                                                [[AlertManager shared] showOkAlertWithTitle:@"Error" message:exceptionString.description];
                                                            }];


                    }
                }
                                                       title:@"Delete this photo?"
                                                     message:@""
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"Delete", nil];
                
                
            }else if (_isSharing){
            
                if ([self.selectedIndexesArray containsObject:@(selectedIndex)]) {
                    [self.selectedIndexesArray removeObject:@(selectedIndex)];
                }else{
                    [self.selectedIndexesArray addObject:@(selectedIndex)];
                }
                
                [self.tableView reloadData];
                
            }else{
                ProductDetailsVC *vc = [ProductDetailsVC loadFromXIBForScrrenSizes];
                vc.product = dict;
                [self.navigationController pushViewController:vc animated:YES];
            }
        };
    }
    
    // Configure the cell...
    
    NSInteger index = indexPath.row * 3;
    
    if ([_items count] > index) {
        NSDictionary* object = [_items safeDictionaryObjectAtIndex:index];
        NSString* imageUrl = nil;
        
        imageUrl = [[object safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
        
        [cell.firstView setImageURLString:imageUrl];
        cell.firstView.hidden = NO;
        
        if ([self.selectedIndexesArray containsObject:@(index)]) {
            [cell.firstView setSelectedPhoto:YES];
        }else{
            [cell.firstView setSelectedPhoto:NO];
        }
        
    }else{
        cell.firstView.hidden = YES;
    }
    cell.firstView.coverButton.tag = index;
    
    if ([_items count] > index + 1) {
        NSDictionary* object = [_items safeDictionaryObjectAtIndex:index + 1];
        NSString* imageUrl = nil;
        
        imageUrl = [[object safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
        
        [cell.secondView setImageURLString:imageUrl];
        cell.secondView.hidden = NO;
        
        if ([self.selectedIndexesArray containsObject:@(index + 1)]) {
            [cell.secondView setSelectedPhoto:YES];
        }else{
            [cell.secondView setSelectedPhoto:NO];
        }
        
    }else{
        cell.secondView.hidden = YES;
    }
    cell.secondView.coverButton.tag = index + 1;
    
    if ([_items count] > index + 2) {
        NSDictionary* object = [_items safeDictionaryObjectAtIndex:index + 2];
        NSString* imageUrl = nil;
        
        imageUrl = [[object safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
        
        [cell.thirdView setImageURLString:imageUrl];
        cell.thirdView.hidden = NO;
        
        if ([self.selectedIndexesArray containsObject:@(index + 2)]) {
            [cell.thirdView setSelectedPhoto:YES];
        }else{
            [cell.thirdView setSelectedPhoto:NO];
        }
        
    }else{
        cell.thirdView.hidden = YES;
    }
    cell.thirdView.coverButton.tag = index + 2;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

- (void)addedStoreToProductNotification:(NSNotification*)motif{
    self.needUpdateData = YES;
}

@end
