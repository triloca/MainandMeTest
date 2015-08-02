//
//  AddPhotoViewController.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 4/30/15.
//  Copyright (c) 2015 Uniprog. All rights reserved.
//

#import "AddPhotoViewController.h"
#import "CustomTitleView.h"
#import "MyPhoto.h"
#import "StoreNamePickerView.h"
#import "SearchRequest.h"
#import "SearchManager.h"
#import "UIImage+Common.h"
#import "ProductsStoresManager.h"
#import "CustomIOSAlertView.h"
#import "CustomAlertContentView.h"
#import "NSURLConnectionDelegateHandler.h"
#import "JSON.h"
#import "UIImage+ResizeAdditions.h"

@interface AddPhotoViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;


@property (weak, nonatomic) IBOutlet UIView *bottomContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomContentViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *addStoreNameButton;
@property (weak, nonatomic) IBOutlet UIButton *notNowButton;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@property (weak, nonatomic) IBOutlet StoreNamePickerView *storeNamePickerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storePickerConstraint;

@property (strong, nonatomic) MyPhoto* myPhoto;

@property (weak, nonatomic) IBOutlet UIView *cameraContentView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cameraControlsBottomConstraint;

@property (weak, nonatomic) IBOutlet UIView *retakeContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *retakeViewBottomConstraint;

@property (strong, nonatomic) NSArray* storesArray;

@end

@implementation AddPhotoViewController

#pragma mark _______________________ Class Methods _________________________

#pragma mark ____________________________ Init _____________________________

#pragma mark _______________________ View Lifecycle ________________________

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBarHidden = NO;
    
    
    UIBarButtonItem* leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonClicked)];
    
    __weak AddPhotoViewController* wSelf = self;

    
    _navItem.titleView = [[CustomTitleView alloc] initWithTitle:@"Add a photo" dropDownIndicator:NO clickCallback:^(CustomTitleView *titleView) {
        [wSelf cancelButtonClicked];
    }];
    
    self.navItem.leftBarButtonItem = leftButton;
    
    
    self.addStoreNameButton.layer.cornerRadius = 4;
    self.addStoreNameButton.layer.borderColor = [[UIColor grayColor] CGColor];
    self.addStoreNameButton.layer.borderWidth = 1;
    
    self.notNowButton.layer.cornerRadius = 4;
    self.notNowButton.layer.borderColor = [[UIColor grayColor] CGColor];
    self.notNowButton.layer.borderWidth = 1;
    
    [self.view layoutIfNeeded];
    
    self.photoImageView.image = self.photoImage;
    
//    if (self.photoImage) {
//        [self saveToStore];
//        [[AlertManager shared] showOkAlertWithTitle:@"Saved to store"];
//    }
    
    
    self.storeNamePickerView.onOkButton = ^(StoreNamePickerView* view, NSDictionary* store ,UIButton* button){
        
        NSString* title = @"Success!";
        NSString* messge = [NSString stringWithFormat:@"Your photo will be added to \n%@.\nWhat would you like to do next?", [store safeStringObjectForKey:@"name"]];
        
        NSString* storeName = [store safeStringObjectForKey:@"name"];
        
        CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
        
        CustomAlertContentView* contentView = [CustomAlertContentView loadViewFromXIB];
        contentView.titleLabel.text = title;
        contentView.messageLabel.text = messge;
        [contentView.messageLabel sizeToFit];
        [contentView layoutIfNeeded];
        
        [alertView setContainerView:contentView];

        contentView.didClickCloseButton = ^(CustomAlertContentView* view, UIButton* button){
            
            [alertView close];
            
            [self showSpinnerWithName:@""];
            [self createItemWithStoreName:storeName completion:^(NSDictionary *object, NSError *error) {
                [self hideSpinnerWithName:@""];
                if (self.didClickFinish) {
                    self.didClickFinish(self);
                }
            }];
        };
        
        [alertView setContainerView:contentView];
        
        [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Share it", @"Add another", nil]];
        //[alertView setDelegate:self];
        
        [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
            
            [alertView close];
            
            if (0 == buttonIndex) {
                
                [self showSpinnerWithName:@""];
                [self createItemWithStoreName:storeName completion:^(NSDictionary *object, NSError *error) {
                    [self loadWishlistsWithCompletion:^(NSArray *wishlists) {
                        [self hideSpinnerWithName:@""];
                        
                        if (self.didClickShare) {
                            self.didClickShare(self, object, wishlists);
                        }
                    }];
                }];
                
            }else{
                
                [self onRetakeButton:nil];
                
                [self createItemWithStoreName:storeName completion:^(NSDictionary *object, NSError *error) {
                    //                [self hideSpinnerWithName:@""];
                    //
                    //                if (self.didClickFinish) {
                    //                    self.didClickFinish(self);
                    //                }
                }];
            }
            
        }];

        
        [alertView setUseMotionEffects:true];
        
        [alertView show];
        
        [wSelf show:NO pickerAnimated:YES];
        
    };
    
    self.storeNamePickerView.onCancelButton = ^(StoreNamePickerView* view, UIButton* button){
        [wSelf show:NO pickerAnimated:YES];
    };
    
    //[self.view addSubview:_addStoreNameButton];
    [self.view bringSubviewToFront:_bottomContentView];
    [self.view bringSubviewToFront:_cameraContentView];
    
    [self show:NO bottomControlsAnimated:NO];
    [self show:NO retakeControlsAnimated:NO];
    [self show:YES cameraControlsAnimated:NO];
    
    [self.view bringSubviewToFront:_navBar];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"kFirstCameraView"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kFirstCameraView"];
        [[AlertManager shared] showOkAlertWithTitle:@"Thanks for using the new camera feature! Adding photos of your favorite local discoveries helps others enjoy the best your city offers, too"];
    }
}


#pragma mark _______________________ Buttons Action ________________________

- (void)cancelButtonClicked{
    
    if (self.didClickCancel) {
        self.didClickCancel(self);
    }
}

- (IBAction)onAddStoreNameButton:(id)sender {
    
    if (_storesArray) {
        [self.storeNamePickerView setPickerArray:self.storesArray];
        [self show:YES pickerAnimated:YES];
        return;
    }
    
    if (![ReachabilityManager isReachable]) {
        [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
        return;
    }
    
    SearchRequest *searchRequest = [[SearchRequest alloc] initWithSearchType:SearchTypeStores searchFilter:SearchFilterRandom];
    //searchRequest.coordinate = CLLocationCoordinate2DMake(42.283215, -71.123029);
    
    searchRequest.city = [SearchManager shared].city;
    searchRequest.state = [SearchManager shared].state;
    searchRequest.page = 1;//_page;
    //searchRequest.searchKey = _searchBar.text;
    //searchRequest.name = _searchBar.text;
    
    searchRequest.perPage = 100;
    
    //    if (_page == 1) {
    [self showSpinnerWithName:@""];
    //    }
    
    // self.searchOperation =
    [[MMServiceProvider sharedProvider] sendRequest:searchRequest success:^(SearchRequest* request) {
        NSLog(@"Succceess!");
        
        [self hideSpinnerWithName:@""];
        
        if ([request.objects isKindOfClass:[NSArray class]]) {
            self.storesArray = request.objects;
            [self.storeNamePickerView setPickerArray:self.storesArray];
            [self show:YES pickerAnimated:YES];
        }
        
//        [self.storeNamePickerView setPickerArray:request.objects];
//        [self show:YES pickerAnimated:YES];
        
    } failure:^(id _request, NSError *error) {
        NSLog(@"Fail: %@", error);
        [self hideSpinnerWithName:@""];
        [[AlertManager shared] showOkAlertWithTitle:@"Can't load stores" message:error.localizedDescription];
        
    }];
    
    
}

- (IBAction)onNotNowButton:(id)sender {
    
    NSString* title = @"Success!";
    NSString* messge = @"Your photo has been added to your My photos wish list. What would you like to do next?";
    
    
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    
    CustomAlertContentView* contentView = [CustomAlertContentView loadViewFromXIB];
    contentView.titleLabel.text = title;
    contentView.messageLabel.text = messge;
    [contentView.messageLabel sizeToFit];
    [contentView layoutIfNeeded];
    
    contentView.didClickCloseButton = ^(CustomAlertContentView* view, UIButton* button){
        
         [alertView close];
        
        [self showSpinnerWithName:@""];
        [self createItemWithStoreName:nil completion:^(NSDictionary *object, NSError *error) {
            [self hideSpinnerWithName:@""];
            if (self.didClickFinish) {
                self.didClickFinish(self);
            }
        }];
    };
    
    [alertView setContainerView:contentView];
    
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Share it", @"Add another", nil]];
    //[alertView setDelegate:self];
    
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        
        [alertView close];
        
        if (0 == buttonIndex) {
            
            [self showSpinnerWithName:@""];
            [self createItemWithStoreName:nil completion:^(NSDictionary *object, NSError *error) {
                [self loadWishlistsWithCompletion:^(NSArray *wishlists) {
                    [self hideSpinnerWithName:@""];
                    
                    if (self.didClickShare) {
                        self.didClickShare(self, object, wishlists);
                    }
                }];
            }];
            
        }else{
            
            [self onRetakeButton:nil];
            
            [self createItemWithStoreName:nil completion:^(NSDictionary *object, NSError *error) {
                //                [self hideSpinnerWithName:@""];
                //
                //                if (self.didClickFinish) {
                //                    self.didClickFinish(self);
                //                }
            }];
        }

    }];
    
    [alertView setUseMotionEffects:true];
    
    [alertView show];
    
}

- (void)loadWishlistsWithCompletion:(void(^)(NSArray* wishlists))completion {
    
    [self showSpinnerWithName:@""];
    
    NSString* urlString =
    [NSString stringWithFormat:@"http://www.mainandme.com/api/v1/users/%@/product_lists?_token=%@", [CommonManager shared].userId, [CommonManager shared].apiToken];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:20];
    [request setHTTPMethod:@"GET"];
    
    NSURLConnectionDelegateHandler* handler = [NSURLConnectionDelegateHandler handlerWithSuccess:^(NSURLConnection *connection, id data) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", returnString);
        id value = [returnString JSONValue];
        
        if ([value isKindOfClass:[NSArray class]]) {
           
            completion(value);
            
        }else{
            [[AlertManager shared] showOkAlertWithTitle:@"Error"];
            completion(nil);
        }
        
        
    } failure:^(NSURLConnection *connection, NSError *error) {
        
        [[AlertManager shared] showOkAlertWithTitle:error.localizedDescription];
        completion(nil);
        
    }eception:^(NSURLConnection *connection, NSString *exceptionMessage) {
        
        [[AlertManager shared] showOkAlertWithTitle:@"Error"];
        completion(nil);
        
    }];
    
    NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:handler];
    [connection start];
    
}



- (IBAction)onCameraButton:(id)sender {
    
    [self capturePhotoCompetion:^(UIImage *image, NSError *error) {
        [self.view bringSubviewToFront:_navBar];
        [self show:NO cameraControlsAnimated:YES];
        [self show:YES retakeControlsAnimated:NO];

    }];
    
}


- (IBAction)onRetakeButton:(id)sender {
    
    self.capturedImageView.image = nil;
    [self.imageSelectedView removeFromSuperview];
    
    [self show:NO retakeControlsAnimated:YES];
    [self show:YES cameraControlsAnimated:YES];
}

- (IBAction)onAddToMyPhotosButton:(id)sender {
    [self show:NO retakeControlsAnimated:YES];
    [self show:YES bottomControlsAnimated:YES];
}

#pragma mark _______________________ Privat Methods(view)___________________

- (void)show:(BOOL)value pickerAnimated:(BOOL)animated{
    
    [self.view bringSubviewToFront:self.storeNamePickerView];
    
    if (value) {
        self.storePickerConstraint.constant = 216;
    }else{
        self.storePickerConstraint.constant = 0;
    }
    
    [UIView animateWithDuration:animated ? 0.3 : 0
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)show:(BOOL)value cameraControlsAnimated:(BOOL)animated{

    [self.view bringSubviewToFront:self.cameraContentView];
    
    if (value) {
        self.cameraControlsBottomConstraint.constant = 0;
    }else{
        self.cameraControlsBottomConstraint.constant = -self.cameraContentView.frame.size.height;
    }
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)show:(BOOL)value retakeControlsAnimated:(BOOL)animated{
    
    [self.view bringSubviewToFront:self.retakeContentView];
    
    if (value) {
        self.retakeViewBottomConstraint.constant = 0;
    }else{
        self.retakeViewBottomConstraint.constant = -self.retakeContentView.frame.size.height;
    }
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)show:(BOOL)value bottomControlsAnimated:(BOOL)animated{
    
    [self.view bringSubviewToFront:self.bottomContentView];
    
    if (value) {
        self.bottomContentViewBottomConstraint.constant = 0;
    }else{
        self.bottomContentViewBottomConstraint.constant = -self.bottomContentView.frame.size.height;
    }
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}



- (UIView *)createAlertContentViewWithTitle:(NSString*)title message:(NSString*)message
{
    
    CustomAlertContentView* view = [CustomAlertContentView loadViewFromXIB];
    view.titleLabel.text = title;
    view.messageLabel.text = message;
    [view.messageLabel sizeToFit];
    [view layoutIfNeeded];
    
    return view;
    
    UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 200)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 270, 180)];
    [imageView setImage:[UIImage imageNamed:@"demo"]];
    [demoView addSubview:imageView];
    
    return demoView;
}


#pragma mark _______________________ Privat Methods ________________________


- (void)saveToStoreWithName:(NSString*)storeName{
    
    UIImage *afterFixingOrientation = [self.selectedImage rotatedUIImage];
    
    NSString* imageName = [MyPhoto saveImage:afterFixingOrientation];
    self.myPhoto = [MyPhoto new];
    _myPhoto.imagePath = imageName;
    _myPhoto.createdAt = [NSDate date];
    
    [_myPhoto addToStore];
}

- (void)createItemWithStoreName:(NSString*)storeName completion:(void (^)(NSDictionary *object, NSError *error))completion{
    
    //UIImage *afterFixingOrientation = [self.selectedImage rotatedUIImage];
    
    CGFloat scale = 640 / self.selectedImage.size.width;
    
    UIImage *afterFixingOrientation = [self.selectedImage resizedImage:CGSizeMake(self.selectedImage.size.width * scale, self.selectedImage.size.height * scale) interpolationQuality:kCGInterpolationDefault];
    
    [ProductsStoresManager uploadProductWithName:nil
                                           price:nil
                                        category:nil
                                       storeName:storeName
                                     description:nil
                                           image:afterFixingOrientation
                                            type:@"pending"
                                         success:^(NSDictionary *object) {
                                             completion(object, nil);
                                         }
                                         failure:^(NSError *error, NSString *errorString) {
                                             completion(nil, error);
                                         }
                                       exception:^(NSString *exceptionString) {
                                           completion(nil, [NSError errorWithDomain:exceptionString code:-1 userInfo:nil]);
                                       }];
}

#pragma mark _______________________ Public Methods ________________________

#pragma mark _______________________ Delegates _____________________________

#pragma mark _______________________ Notifications _________________________










@end
