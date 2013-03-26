//
//  ProductDetailViewController.m
//  MainAndMe
//
//  Created by Sasha on 3/15/13.
//
//

#import "AboutViewController.h"
#import "UIView+Common.h"

@interface AboutViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;
@end

@implementation AboutViewController

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
    _titleTextLabel.text = @"About";

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}


- (void)viewDidUnload {
    [self setTitleTextLabel:nil];
    [super viewDidUnload];
}

#pragma mark - Buttons Action
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
