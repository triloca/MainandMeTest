//
//  ProductDetailViewController.m
//  MainAndMe
//
//  Created by Sasha on 3/15/13.
//
//

#import "IBeaconInfoViewController.h"
#import "UIView+Common.h"

@interface IBeaconInfoViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIWebView *contentWebView;

@end

@implementation IBeaconInfoViewController

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
    
    self.screenName = @"iBeacon screen";

    // Do any additional setup after loading the view from its nib.
    _titleTextLabel.font = [UIFont fontWithName:@"Perec-SuperNegra" size:22];
    _titleTextLabel.text = @"iBeacon";
    
 //   [_contentWebView loadHTMLString:@"<html><body>YOUR-TEXT-HERE</body></html>" baseURL:nil];
    
    
//    NSString* path = [[NSBundle mainBundle] pathForResource:@"test"
//                                                     ofType:@"html"];
//    NSError* error = nil;
//    NSString* html = [NSString stringWithContentsOfFile:path
//                                                  encoding:NSUTF8StringEncoding
//                                                     error:&error];
//    if(error) { // If error object was instantiated, handle it.
//        NSLog(@"ERROR while loading from file: %@", error);
//        // …
//    }
    if (_campaign.content.body.length > 0) {
        NSMutableString* my_string = [NSMutableString stringWithString:_campaign.content.body];
        
        //    [my_string replaceOccurrencesOfString:@"&gt;" withString:@">" options:NSLiteralSearch range:NSMakeRange(0, [my_string length])];
        //    [my_string replaceOccurrencesOfString:@"&lt;" withString:@"<" options:NSLiteralSearch range:NSMakeRange(0, [my_string length])];
        
        [_contentWebView loadHTMLString:my_string baseURL:nil];
    }
    
    _messageLabel.text = _campaign.content.alertMessage;

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
