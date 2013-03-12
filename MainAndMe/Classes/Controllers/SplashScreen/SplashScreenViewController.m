//
//  SplashScreenViewController.m
//  MainAndMe
//
//  Created by Sasha on 3/11/13.
//
//

#import "SplashScreenViewController.h"

@interface SplashScreenViewController ()
@property (unsafe_unretained, nonatomic) IBOutlet UIActivityIndicatorView *splashView;
@end

@implementation SplashScreenViewController

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
    [_splashView startAnimating];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [_splashView stopAnimating];
        if (_timeOutBlock) {
            _timeOutBlock();
        }
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setSplashView:nil];
    [super viewDidUnload];
}
@end
