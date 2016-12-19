//
//  YourGPSCityViewController.m
//  MainAndMeios7
//
//  Created by Alexanedr on 11/26/16.
//  Copyright © 2016 Uniprog. All rights reserved.
//

#import "YourGPSCityViewController.h"
#import "SearchManager.h"

@interface YourGPSCityViewController ()
    @property (weak, nonatomic) IBOutlet UIButton *cityAndMeButton;
    @property (weak, nonatomic) IBOutlet UILabel *cityLabel;


@property (weak, nonatomic) IBOutlet UIButton *startBrowsingButton;

@end

@implementation YourGPSCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self updateViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateViews{

    NSString* city = [SearchManager shared].city;
    NSString* state = [SearchManager shared].state;
    
    self.cityLabel.text = [NSString stringWithFormat:@"According to our best GPS\nestimate, you appear to be\n in\n%@, %@\nIs that correct?", city, state];
    
    [self.cityAndMeButton setTitle:[NSString stringWithFormat:@"%@&Me", city]
                          forState:UIControlStateNormal];
}

- (IBAction)startBrowsingButtonClicked:(id)sender {
    if (_didClickStartBrowsing) {
        _didClickStartBrowsing(self);
    }
}
- (IBAction)editCityButtonClicked:(id)sender {
    if (_didClickEditCity) {
        _didClickEditCity(self);
    }
}
- (IBAction)windowShopButtonClicked:(id)sender {
    if (_didClickWindowShop) {
        _didClickWindowShop(self);
    }
}
- (IBAction)benefitsButtonClicked:(id)sender {
    if (_didClickBenefits) {
        _didClickBenefits(self);
    }
}

@end
