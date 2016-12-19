//
//  StorefrontsHorisontalCollectionView.m
//  MainAndMeios7
//
//  Created by Alexanedr on 11/18/16.
//  Copyright © 2016 Uniprog. All rights reserved.
//

#import "StorefrontsHorisontalCollectionView.h"
#import "StorefrontsHorisontalCollectionCell.h"
#import "StoreDataModel.h"

#import "ProductDetailsVC.h"
#import "StoreDetailsVC.h"

#import "FollowStoreRequest.h"
#import "LoadStoreRequest.h"
#import "ShareView.h"

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "FacebookSDK/FacebookSDK.h"
#import "TwitterManager.h"
@import Social;
#import "PinterestManager.h"
#import "UIImage+Scaling.h"

@interface StorefrontsHorisontalCollectionView ()
<UIActionSheetDelegate,
MFMailComposeViewControllerDelegate,
MFMessageComposeViewControllerDelegate,
UIDocumentInteractionControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) ShareView* shareView;
@property (strong, nonatomic) NSLayoutConstraint* bottomConstraint;
@property (strong, nonatomic) UIDocumentInteractionController *docController;

@end

@implementation StorefrontsHorisontalCollectionView


- (void)awakeFromNib{
    [super awakeFromNib];
    
    UINib *cellNib = [UINib nibWithNibName:@"StorefrontsHorisontalCollectionCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"StorefrontsHorisontalCollectionCell"];
}



- (void)reloadData{

    [self.collectionView reloadData];
    
    [self showShare:NO animated:YES forStore:nil];
}




- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.collectionArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) wSelf = self;
//    NSDictionary* cellInfo = _collectionArray[indexPath.row];
//    
//    NSString *cellType = cellInfo[@"CellType"];
//    NSString *cellIdentifier = cellInfo[@"CellIdentifier"];
//    NSString* imageName = cellInfo[@"ImageName"];
    
    StorefrontsHorisontalCollectionCell *cell = (StorefrontsHorisontalCollectionCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"StorefrontsHorisontalCollectionCell" forIndexPath:indexPath];
    
    cell.didClickProduct = ^(StorefrontsHorisontalCollectionCell* obj, NSDictionary* prod){
        [wSelf onClickWithItemDict:prod];
    };
    
    cell.didClickCall = ^(StorefrontsHorisontalCollectionCell* obj, StoreDataModel* storeDataModel){
        [wSelf callAction:storeDataModel.storeInfo];
    };
    
    cell.didClickFollow = ^(StorefrontsHorisontalCollectionCell* obj, StoreDataModel* storeDataModel){
        
        if ([[storeDataModel.storeInfo safeNumberObjectForKey:@"is_following"] boolValue]) {
            [wSelf followActionUnfollow:YES store:storeDataModel.storeInfo];
        }else{
            [wSelf followActionUnfollow:NO store:storeDataModel.storeInfo];
        }
    };
    
    cell.didClickShare = ^(StorefrontsHorisontalCollectionCell* obj, StoreDataModel* storeDataModel){
        [wSelf shareActionForStore:storeDataModel.storeInfo];
    };


    
    
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
    StorefrontsHorisontalCollectionCell *storefrontsHorisontalCollectionCell = (StorefrontsHorisontalCollectionCell *) cell;
    StoreDataModel* storeDataModel = _collectionArray[indexPath.row];
    [storefrontsHorisontalCollectionCell setStoreDataModel:storeDataModel];
    
    [self showShare:NO animated:YES forStore:nil];

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionView.frame.size;
}


- (void)onClickWithItemDict:(NSDictionary*)itemDict{
    
    if ([itemDict.allKeys containsObject:@"price"]) {
        ProductDetailsVC *vc = [[ProductDetailsVC alloc] initWithProduct:itemDict];
        [self.parrentVC.navigationController pushViewController:vc animated:YES];
        
    }else{
        StoreDetailsVC* storeDetailsVC = [StoreDetailsVC loadFromXIBForScrrenSizes];
        storeDetailsVC.storeDict = itemDict;
        [self.parrentVC.navigationController pushViewController:storeDetailsVC animated:YES];
    }
}

- (void)callAction:(NSDictionary*)store {
    
    NSString* phone = [store safeStringObjectForKey:@"phone"];
    if ([phone isKindOfClass:[NSNull class]] || ![phone isValidate]) {
        
        [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
        }
                                               title:@"A number has not been provided for this store yet"
                                             message:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
        
    }else{
        
        //        NSString* messageString = [NSString stringWithFormat:@"Call %@ at %@?", [[store safeDictionaryObjectForKey:@"user"] safeStringObjectForKey:@"name"], phone];
        
        NSString* messageString = [NSString stringWithFormat:@"Call %@ at %@?", [store safeStringObjectForKey:@"name"], phone];
        
        [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (alertView.cancelButtonIndex != buttonIndex) {
                [self callToAction:phone];
            }
        }
                                               title:messageString
                                             message:nil
                                   cancelButtonTitle:@"Cancel"
                                   otherButtonTitles:@"Call", nil];
        
    }
}

- (void)callToAction:(NSString*)phone {
    
    phone = [phone stringByReplacingOccurrencesOfString:@"(" withString:@""];
    phone = [phone stringByReplacingOccurrencesOfString:@")" withString:@""];
    phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *telLink = [NSString stringWithFormat:@"tel://%@", phone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telLink]];
}


- (void)followActionUnfollow:(BOOL)unfollow store:(NSDictionary*)storeDict{
    
    FollowStoreRequest *request = [[FollowStoreRequest alloc] init];
    request.apiToken = [CommonManager shared].apiToken;
    request.storeId = [[storeDict safeNumberObjectForKey:@"id"] stringValue];
    
    request.unfollow = unfollow;
    
    [self.parrentVC showSpinnerWithName:@""];
    [[MMServiceProvider sharedProvider] sendRequest:request success:^(id _request) {
        
        NSLog(@"store was liked: %@", request.response);
        
        //_storeDetailsCell.followImageView.hidden = NO;
        
        [self loadStore:storeDict comletion:^(NSDictionary* storeDict){
            [self reloadData];
            [self.parrentVC hideSpinnerWithName:@""];
            
            NSString* message = @"";
            if (unfollow) {
                message = @"Store unfollowed successfully";
            }else{
                message = @"Store followed successfully";
            }
            
            [[AlertManager shared] showOkAlertWithTitle:@"Success"
                                                message:message];
            
            [[LayoutManager shared].homeVC updateStore:storeDict];
            
        }];
        
    }failure:^(id _request, NSError *error) {
        [self.parrentVC hideSpinnerWithName:@""];
        NSLog(@"Error: %@", error);
        
        if ([error.localizedDescription isEqualToString:@"You are already following this Store"]) {
            [[AlertManager shared] showOkAlertWithTitle:@"You are already following this store"];
        }else{
            [[AlertManager shared] showOkAlertWithTitle:@"Error"
                                                message:error.localizedDescription];
        }
        
        [self loadStore:storeDict comletion:^(NSDictionary* storeDict){
            [self reloadData];
            [self.parrentVC hideSpinnerWithName:@""];
            
        }];
        
    }];
    
    
}


- (void)shareActionForStore:(NSDictionary*)storeInfo {
    
    [self showShare:YES animated:YES forStore:storeInfo];
    return;
    
    UIActionSheet *shareActionSheet = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self
                                                         cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Email", @"SMS", nil];
    shareActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    
    [shareActionSheet showInView:[LayoutManager shared].appDelegate.window];
}


- (void)loadStore:(NSDictionary*)storeInfo comletion:(void(^)(NSDictionary* storeDict))completion{
    
    
    LoadStoreRequest *storeRequest = [[LoadStoreRequest alloc] init];
    storeRequest.storeId = [storeInfo safeNSNumberObjectForKey:@"id"];
    
    
    [self.parrentVC showSpinnerWithName:@""];
    [[MMServiceProvider sharedProvider] sendRequest:storeRequest success:^(LoadStoreRequest *request) {
        [self.parrentVC hideSpinnerWithName:@""];
        NSLog(@"store: %@", request.storeDetails);
        
        completion(request.storeDetails);
        
    } failure:^(LoadStoreRequest *request, NSError *error) {
        [self.parrentVC hideSpinnerWithName:@""];
        NSLog(@"Error: %@", error);
        //[self updateRightNavigationButton];
        completion(nil);
    }];
    
}


- (void)showShare:(BOOL)value animated:(BOOL)animated forStore:(NSDictionary*)storeInfo{
    
    
    if (self.shareView == nil) {
        
        self.shareView = [ShareView loadViewFromXIB];
        self.shareView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.shareView];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.shareView
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeLeading
                                                             multiplier:1.0
                                                               constant:0.0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.shareView
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1.0
                                                               constant:0.0]];
        
        self.bottomConstraint = [NSLayoutConstraint constraintWithItem:self.shareView
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.0
                                                              constant:self.shareView.frame.size.height];
        
        
        [self addConstraint:_bottomConstraint];
        
        [self layoutIfNeeded];
        
        __weak typeof(self) wSelf = self;
        
        self.shareView.didClickCancelButton = ^(ShareView* view, UIButton* button){
            [wSelf showShare:NO animated:YES forStore:nil];
        };
        
        self.shareView.didClickShareButton = ^(ShareView* view, UIButton* button){
            switch (button.tag) {
                case 1:{
                    
                    [wSelf.parrentVC showSpinnerWithName:@""];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [wSelf shareMessageForStore:storeInfo];
                    });
                    
                }
                    break;
                case 2:{
                    
                    [wSelf.parrentVC showSpinnerWithName:@""];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [wSelf shareMailForStore:storeInfo];
                    });
                }
                    break;
                case 3:{
                    
                    //[wSelf showSpinnerWithName:@""];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                       // [wSelf shareFacebook];
                    });
                }
                    break;
                case 4:{
                    [wSelf.parrentVC showSpinnerWithName:@""];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [wSelf shareTwitterForStore:storeInfo];
                    });
                }
                    break;
                case 5:
                    [wSelf sharePinterestForStore:storeInfo];
                    break;
                case 6:{
                    
                    [wSelf.parrentVC showSpinnerWithName:@""];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [wSelf shareInstagremForStore:storeInfo];
                    });
                }
                    break;
                    
                default:
                    break;
            }
        };
        
    }
    
    [self bringSubviewToFront:self.shareView];
    
    
    [UIView animateWithDuration:animated ? 0.3 : 0
                     animations:^{
                         
                         if (value) {
                             _bottomConstraint.constant = 0;
                             //self.bottomShareView.hidden = YES;
                         }else{
                             _bottomConstraint.constant = self.shareView.frame.size.height;
                             //self.bottomShareView.hidden = NO;
                         }
                         
                         
                         [self layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
}


#pragma mark - Share Actions

- (void)shareMessageForStore:(NSDictionary*)storeInfo{
    //[self prepareForShare];
    
    
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if (controller) {
        if ([MFMessageComposeViewController canSendText]) {
            controller.messageComposeDelegate = self;
            
            NSDictionary* obj = storeInfo;
            
            NSMutableString* bodyString = [NSMutableString stringWithString:@"Found this local gem on Main&Me:\n"];
            
            
            [bodyString appendString:[obj safeStringObjectForKey:@"name"]];
            [bodyString appendString:@"\n"];
            NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/stores/%@", [[obj safeNumberObjectForKey:@"id"] stringValue]];
            [bodyString appendString:urlString];
            //[bodyString appendString:@".\n"];
            
            
            NSString* imageURL = [[obj safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
            NSData* photoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
            if (photoData) {
                [controller addAttachmentData:photoData typeIdentifier:@"public.data" filename:@"image.png"];
            }
            
            controller.body = bodyString;
            
            [self.parrentVC presentViewController:controller animated:YES completion:^{}];
        } else {
            [[AlertManager shared] showOkAlertWithTitle:@"Can't Share via SMS"];
        }
    }
    
    [self.parrentVC hideSpinnerWithName:@""];
    
}

- (void)shareMailForStore:(NSDictionary*)storeInfo{
    
    if ([MFMailComposeViewController canSendMail]){
        
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        
        NSDictionary* obj = storeInfo;
        
        NSMutableString* bodyString = [NSMutableString stringWithString:@"Found this local gem on Main&Me:\n"];
        
        
        [bodyString appendString:[obj safeStringObjectForKey:@"name"]];
        [bodyString appendString:@"\n"];
        NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/stores/%@", [[obj safeNumberObjectForKey:@"id"] stringValue]];
        [bodyString appendString:urlString];
        //[bodyString appendString:@".\n"];
        
        
        NSString* imageURL = [[obj safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
        NSData* photoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
        if (photoData) {
            [controller addAttachmentData:photoData mimeType:@"image/jpg" fileName:[NSString stringWithFormat:@"photo.png"]];
        }
        
        
        
        [controller setSubject:@"A friend shared a \"local find\" on MainAndMe"];
        [controller setMessageBody:[NSString stringWithFormat:@"%@", bodyString] isHTML:NO];
        
        [self.parrentVC presentViewController:controller animated:YES completion:^{}];
        
    } else {
        [[AlertManager shared] showOkAlertWithTitle:@"Can't Share via Email"];
    }
    
    
    [self.parrentVC hideSpinnerWithName:@""];
}

- (void)shareTwitterForStore:(NSDictionary*)storeInfo{
    
    // No Twitter Account
    // There are no Twitter acconts configured. You can add or create a Twitter account in Settings
    // Cancel Settings
    
    // Confirm that a Twitter account exists
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        
        
        // Create a compose view controller for the service type Twitter
        SLComposeViewController *twController = ({
            twController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            
            
            
            [twController setCompletionHandler:^(SLComposeViewControllerResult result){
                
                [self showShare:NO animated:NO forStore:nil];
                
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
        NSDictionary* obj = storeInfo;
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
        [self.parrentVC presentViewController:twController animated:YES completion:nil];
        
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
    
    [self.parrentVC hideSpinnerWithName:@""];
    
}

- (void)shareFacebook{
    // No Facebook Account
    // There are no Facebook accont configured. You can add or create a Facebook account in Settings
    // Cancel Settings
    
    //[self fBbuttonClicked];
    
    return;
    
    /*
    SLComposeViewController *fbController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
        
        SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
            
            
            [self hideSpinnerWithName:@""];
            [self showShare:NO animated:NO];
            
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
        
        
        NSDictionary* obj = _storeDict;
        
        NSMutableString* bodyString = [NSMutableString stringWithString:@"Found this local gem on Main&Me:\n"];
        
        [bodyString appendString:[obj safeStringObjectForKey:@"name"]];
        [bodyString appendString:@"\n"];
        NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/stores/%@", [[obj safeNumberObjectForKey:@"id"] stringValue]];
        [bodyString appendString:urlString];
        //[bodyString appendString:@"."];
        
        
        NSString* imageURL = [[obj safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"mid"];
        NSData* photoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
        UIImage* image = [UIImage imageWithData:photoData];
        
        if (image) {
            [fbController addImage:image];
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
    
    */
}

- (void)sharePinterestForStore:(NSDictionary*)storeInfo{
    
    if ([[PinterestManager shared].pinterest canPinWithSDK]) {
        
        
        NSMutableString* bodyString = [NSMutableString stringWithString:@"Found this local gem on Main&Me:\n"];
        
        NSDictionary* obj = storeInfo;
        //for (NSDictionary* obj in self.sharingObjectsArray) {
        
        [bodyString appendString:[obj safeStringObjectForKey:@"name"]];
        [bodyString appendString:@"\n"];
        NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/stores/%@", [[obj safeNumberObjectForKey:@"id"] stringValue]];
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

- (void)shareInstagremForStore:(NSDictionary*)storeInfo{
    
    
    NSMutableString* bodyString = [NSMutableString stringWithString:@"Found this local gem on Main&Me:\n"];
    
    NSDictionary* obj = storeInfo;
    //for (NSDictionary* obj in self.sharingObjectsArray) {
    
    [bodyString appendString:[obj safeStringObjectForKey:@"name"]];
    [bodyString appendString:@"\n"];
    //NSString* urlString = [NSString stringWithFormat:@"http://www.mainandme.com/stores/%@", [[obj safeNumberObjectForKey:@"id"] stringValue]];
    //[bodyString appendString:urlString];
    //[bodyString appendString:@""];
    
    
    NSString* imageURL = [[obj safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"big"];
    NSData* photoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
    UIImage* image = [UIImage imageWithData:photoData];
    
    
    image = [image imageScaledToSize:CGSizeMake(640, 640)];
    [NSDictionary dictionaryWithObject:@"Your AppName" forKey:@"InstagramCaption"];
    [self shareImageOnInstagram:image
                     annotation:@{@"InstagramCaption" : bodyString}];
    
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
        _docController.delegate = self;
        _docController.UTI=@"com.instagram.exclusivegram";
        
        _docController.annotation=[NSDictionary dictionaryWithObjectsAndKeys:@"Image Taken via @App",@"InstagramCaption", nil];
        
        [_docController setURL:imageURL];
        [_docController setAnnotation:annotation];
        
        //[docController presentOpenInMenuFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];  //Here try which one is suitable for u to present the doc Controller. if crash occurs
        
        [_docController presentOpenInMenuFromRect:self.parrentVC.view.frame
                                           inView:self.parrentVC.view
                                         animated: YES ];
    }else{
        [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
        }
                                               title:@"Can't share Item"
                                             message:@"Please install last version of Instagram app"
                                   cancelButtonTitle:@"Ok"
                                   otherButtonTitles:nil];
        
    }
    
    [self.parrentVC hideSpinnerWithName:@""];
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
    
    [self showShare:NO animated:NO forStore:nil];
    
    [self.parrentVC dismissViewControllerAnimated:YES completion:^{}];
    
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
    
    
    [self showShare:NO animated:NO forStore:nil];
    
    [self.parrentVC dismissViewControllerAnimated:YES completion:^{}];
}


@end
