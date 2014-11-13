//
//  ProductDetailsVC.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 11.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "ProductDetailsVC.h"
#import "CustomTitleView.h"
#import "AddToWishlistRequest.h"

@interface ProductDetailsVC ()
@property (weak, nonatomic) IBOutlet UIView *gradientView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) NSString *phone;
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
@property (strong, nonatomic) CAGradientLayer *gradient;

@end

@implementation ProductDetailsVC

- (id) initWithProduct: (NSDictionary *) product {
    if (self = [super initWithNibName:@"ProductDetailsVC" bundle:nil]) {
        self.product = product;
    }
    return self;
}

- (void) backAction: (id) sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) viewDidLayoutSubviews {
    if (self.gradient)
        return;
    
    self.gradient = [CAGradientLayer layer];
    _gradient.frame = CGRectMake(0, 0, _gradientView.frame.size.width, _gradientView.frame.size.height);
    _gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor colorWithWhite:0 alpha:0.8] CGColor], nil];
    
    [_gradientView.layer insertSublayer:_gradient atIndex:0];
    [self.view sendSubviewToBack:_gradientView];
    [self.view sendSubviewToBack:_imageView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.phone = [_product safeObjectForKey:@"phone"];
    if (![_phone isValidate])
        self.phone = [_product safeObjectForKey:@"phone_number"];
    if ([_phone isKindOfClass:[NSNull class]] || ![_phone isValidate]) {
        self.phone = nil;
        self.phoneButton.hidden = YES;
    }

    
    self.navigationItem.titleView = [[CustomTitleView alloc] initWithTitle:@"ITEM DETAIL" dropDownIndicator:NO clickCallback:nil];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_button"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_map_button"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(mapAction:)];
    
    _titleLabel.text = [_product safeStringObjectForKey:@"name"];
    _descriptionLabel.text = [_product safeStringObjectForKey:@"description"];
    _descriptionLabel.text = @"sdkjsdfksdbkjf dslhbdsk;bvskd dsfg dfsjgvfds;bg;fdskb dgdhlfsv;ksdf vdib";
    
    NSString* price = [_product safeStringObjectForKey:@"price"];
    if (price.length == 0) {
        price = @"---";
    }
    _priceLabel.textColor = kAppColorGreen;
    _priceLabel.text = price;

    NSDictionary* imagesDict = [_product safeDictionaryObjectForKey:@"image"];
    
    NSString* mainImageURL = @"";
    if (IS_IPHONE_6 || IS_IPHONE_6P) {
        mainImageURL = [imagesDict safeStringObjectForKey:@"scale450"];
    }else{
        mainImageURL = [imagesDict safeStringObjectForKey:@"scale300"];
    }
    
    [self setupImageURL:mainImageURL];
}



- (void)setupImageURL:(NSString*)urlString{
    
    NSURL* url = [NSURL URLWithString:urlString];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:30];
    
    
    [_imageView setImageWithURLRequest:request
                          placeholderImage:nil
                              failureImage:nil
                          progressViewSize:CGSizeMake(_imageView.frame.size.width - 16, 10)
                         progressViewStile:UIProgressViewStyleDefault
                         progressTintColor:[UIColor colorWithRed:136/255.0f green:173/255.0f blue:230/255.0f alpha:1]
                            trackTintColor:[UIColor whiteColor]
                                sizePolicy:UNImageSizePolicyScaleAspectFill
                               cachePolicy:UNImageCachePolicyMemoryAndFileCache
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       NSLog(@"Image Loaded");
                                       
                                       NSLog(@"%@", NSStringFromCGSize(image.size));
                                       
                                   }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       NSLog(@"Image Failed");
                                       
                                   }
                                  progress:^(NSURLRequest *request, NSHTTPURLResponse *response, float progress) {
                                      
                                  }];

}



- (IBAction)callAction:(id)sender {
    NSString *telLink = [NSString stringWithFormat:@"tel://%@", _phone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telLink]];
}

- (IBAction)shareAction:(id)sender {
    //TODO: implement
}

- (IBAction)wishlistAction:(id)sender {
//    AddToWishlistRequest *request = [[AddToWishlistRequest alloc] init];
//    request.productId = [_product safeObjectForKey:@"id"];
//    request.wishlistId = @(1);
//    
//    [[MMServiceProvider sharedProvider] sendRequest:request success:^(id _request) {
//        //Success
//        NSLog(@"Success");
//    } failure:^(id _request, NSError *error) {
//        //Failed
//    }];

}

- (void) mapAction: (id) sender {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end