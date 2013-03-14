//
//  MainViewController.m
//  MainAndMe
//
//  Created by Sasha on 3/12/13.
//
//

#import "MainViewController.h"
#import "LoginSignUpManager.h"
#import "LayoutManager.h"
#import "OverlayView.h"
#import "UIView+Common.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self showOveralyView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)showOveralyView{
    
    OverlayView* overalyView = [OverlayView loadViewFromXIB_or_iPhone5_XIB];
    __unsafe_unretained OverlayView* weak_overlyView = overalyView;
    
    overalyView.didClickOverlay = ^{
        [UIView animateWithDuration:0.3
                         animations:^{
                             weak_overlyView.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             [weak_overlyView removeFromSuperview];
                         }];
    };
    
    [[LayoutManager shared].appDelegate.window addSubview:overalyView];
}
@end
