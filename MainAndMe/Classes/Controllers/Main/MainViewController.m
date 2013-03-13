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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logoutButtonClicked:(id)sender {
    [[LoginSignUpManager shared] logout];
    [[LayoutManager shared] showLogin];
}

@end
