//
//  RootViewController.m
//  qwe
//
//  Created by Sasha Bukov on 4/30/12.
//  Copyright (c) 2012 Company. All rights reserved.
//

#import "RootViewController.h"
#import "TabBarView.h"
#import "UIView+Common.h"
#import "LayoutManager.h"
#import "PhotoViewController.h"
#import "QuartzCore/QuartzCore.h"

@interface RootViewController ()
<UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UIActionSheetDelegate>

@property (strong, nonatomic) TabBarView* tabBarView;
@property (strong, nonatomic) PhotoViewController* photoViewController;
@end


@implementation RootViewController

@synthesize rootTabBarController;

- (id)init
{
    self = [super init];
    if (self) {
        self.rootTabBarController = [[UITabBarController alloc] init];
    }
    return self;
}

- (void) loadView {
    
    [super loadView];
}

- (UIView*) view {
    
    [super view];
    
    return self.rootTabBarController.view;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.tabBarView = [TabBarView loadViewFromXIB];
    
    __unsafe_unretained RootViewController* weakSelf = self;
    _tabBarView.tabButtonDown = ^(UIButton* sender, NSInteger index){
        [weakSelf.rootTabBarController setSelectedIndex:index];
//        UINavigationController* navVC = [weakSelf.rootTabBarController.viewControllers safeObjectAtIndex:index];
//        [navVC popToRootViewControllerAnimated:NO]; //! Add if needed
    };

    _tabBarView.tabPhotoButtonClicked = ^(UIButton* sender){
        [weakSelf loadPhotoButtonClicked:sender];
    };

    
    [rootTabBarController.tabBar addSubview:_tabBarView];
    CGRect rc = _tabBarView.frame;

    rc.origin.y -= rc.size.height - rootTabBarController.tabBar.frame.size.height;
    _tabBarView.frame =rc;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return NO;
}

- (void)loadPhotoButtonClicked:(id)sender{
    
    UIActionSheet *shareActionSheet = [[UIActionSheet alloc]
                                       initWithTitle:nil
                                       delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       destructiveButtonTitle:nil
                                       otherButtonTitles:@"Take a New Photo",
                                       @"Choose From Library",nil];
    
    shareActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    UIButton *button = [[shareActionSheet subviews] safeObjectAtIndex:0];
    [button setTitleColor:[UIColor colorWithRed:99/255.0f green:116/255.0f blue:94/255.0f alpha:1]
                 forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:127/255.0f green:166/255.0f blue:94/255.0f alpha:1]
                 forState:UIControlStateHighlighted];
    button = [[shareActionSheet subviews] safeObjectAtIndex:1];
    [button setTitleColor:[UIColor colorWithRed:99/255.0f green:116/255.0f blue:94/255.0f alpha:1]
                 forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:127/255.0f green:166/255.0f blue:94/255.0f alpha:1]
                 forState:UIControlStateHighlighted];
    
    
    [shareActionSheet showInView:[LayoutManager shared].appDelegate.window];
}

#pragma mark - ActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;
{
    switch (buttonIndex) {
        case 0:
            [self displayImagePickerWithSource:UIImagePickerControllerSourceTypeCamera];
            break;
        case 1:
            [self displayImagePickerWithSource:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
        case 2:
            break;
        default:
            break;
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    UIColor* backColor = [UIColor colorWithRed:205/255.0f green:133/255.0f blue:63/255.0f alpha:0.7];
    [[actionSheet layer] setBackgroundColor:backColor.CGColor];
    
    UIButton *button = [[actionSheet subviews] safeObjectAtIndex:0];
    UIImage* image = [button backgroundImageForState:UIControlStateNormal];
    [button setBackgroundImage:image forState:UIControlStateHighlighted];
}

-(void) displayImagePickerWithSource:(UIImagePickerControllerSourceType)src{
    
    if (_photoViewController == nil) {
        self.photoViewController = [PhotoViewController loadFromXIB_Or_iPhone5_XIB];
    }

    @try {
        if([UIImagePickerController isSourceTypeAvailable:src]) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            [picker setSourceType:src];
            [picker setDelegate:self];
            [[LayoutManager shared].rootNavigationController presentModalViewController:picker animated:YES];
        }
    }
    @catch (NSException *e) {
        NSLog(@"UIImagePickerController NSException");
    }
    
    _photoViewController.view.hidden = YES;
    [self.view addSubview:_photoViewController.view];
}

#pragma mark - UIImagePickerController Delegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissModalViewControllerAnimated:YES];
    UIImage *capturedImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    if (capturedImage) {
        [_photoViewController setPhoto:capturedImage];
        _photoViewController.view.hidden = NO;
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [_photoViewController.view removeFromSuperview];
    self.photoViewController = nil;
    [self dismissModalViewControllerAnimated:YES];
}

- (void)hidePhotoView{

    [UIView animateWithDuration:0.3
                     animations:^{
                         CGRect rc = _photoViewController.view.frame;
                         rc.origin.y = CGRectGetMaxY(self.view.frame);
                         _photoViewController.view.frame = rc;
                     }
                     completion:^(BOOL finished) {
                         [_photoViewController.view removeFromSuperview];
                         self.photoViewController = nil;
                     }];
}

@end
