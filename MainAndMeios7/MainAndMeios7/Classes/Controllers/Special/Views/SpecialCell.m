//
//  SpecialCell.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 11/15/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "SpecialCell.h"

@interface SpecialCell()

@property (strong, nonatomic) NSDictionary *product;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (weak, nonatomic) IBOutlet UIImageView *bottomGradiendView;
@property (weak, nonatomic) IBOutlet UIImageView *topGradientImageView;


@end
@implementation SpecialCell

- (void) awakeFromNib {
    [self.contentView sendSubviewToBack:_imageView];
    [super awakeFromNib];
    
    self.topGradientImageView.transform = CGAffineTransformMakeRotation( ( 180 * M_PI ) / 180 );
    
}

- (void)setCellInfo:(NSDictionary *)cellInfo{
    _cellInfo = cellInfo;
    
    
    NSString* name = [_cellInfo safeStringObjectForKey:@"name"];
    NSString* description = [_cellInfo safeStringObjectForKey:@"description"];
    NSString* link = [_cellInfo safeStringObjectForKey:@"link"];
    NSString* start_date = [_cellInfo safeStringObjectForKey:@"start_date"];
    NSString* end_date = [_cellInfo safeStringObjectForKey:@"end_date"];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    
    NSLocale *usLocale = [NSLocale currentLocale];
    [dateFormatter setLocale:usLocale];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSDate *startDate = [dateFormatter dateFromString:start_date];
    NSDate *endDate = [dateFormatter dateFromString:end_date];

    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"E, d MMM"];

    NSString* dateString = [NSString stringWithFormat:@"%@ - %@", [dateFormatter stringFromDate:startDate], [dateFormatter stringFromDate:endDate]];
    
    self.titleLabel.text = name;
    self.descriptionLabel.text = description;
    self.dateLabel.text = dateString;
    
    
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    self.linkLabel.attributedText = [[NSAttributedString alloc] initWithString:link
                                                             attributes:underlineAttribute];
    
    NSDictionary* imagesDict = [_cellInfo safeDictionaryObjectForKey:@"image"];
    NSString* mainImageURL = @"";
    mainImageURL = [imagesDict safeStringObjectForKey:@"full"];
    
    [self setupImageURL:mainImageURL];
    [self.contentView setNeedsLayout];

    /*
    {
        community =     {
            city = Roslindale;
            country = US;
            "created_at" = "2013-05-28T17:45:28Z";
            description = "Windowshop independent Roslindale businesses all in this one place. Click on any storefront to discover what\U2019s inside. Create Roslindale-only wish lists & gift registries. Get news of sales & events by following Roslindale or any store in it. (Merchants: claim your store page to edit content & add photos of what you sell.) Download the app on iTunes. Questions? 413-250-8800";
            email = "<null>";
            featured = 0;
            "follower_count" = 12;
            id = 17005;
            image =         {
                big =             {
                    url = "https://mainandme-production.s3.amazonaws.com/uploads/community/image/17005/big_Rozzy_cover.png";
                };
                mid =             {
                    url = "https://mainandme-production.s3.amazonaws.com/uploads/community/image/17005/mid_Rozzy_cover.png";
                };
                thumb =             {
                    url = "https://mainandme-production.s3.amazonaws.com/uploads/community/image/17005/thumb_Rozzy_cover.png";
                };
                url = "https://mainandme-production.s3.amazonaws.com/uploads/community/image/17005/Rozzy_cover.png";
            };
            "info_hash" = 6bcdca60520997f2fdda48b410a00507;
            lat = "42.2832142";
            "list_items_count" = 39;
            lng = "-71.1270268";
            phone = "617.327.4066";
            "postal_code" = 02131;
            "products_count" = 479;
            slug = "roslindale-ma";
            state = MA;
            "state_name" = Massachusetts;
            "stores_count" = 55;
            "updated_at" = "2015-06-05T18:05:45Z";
            "user_id" = "<null>";
            website = "http://www.roslindale.net";
        };
        description = Description;
        "end_date" = "2016-12-15T20:11:00Z";
        id = 5;
        image =     {
            big = "https://mainandme-production.s3.amazonaws.com/uploads/event/image/5/big_petro_03.jpg";
            full = "https://mainandme-production.s3.amazonaws.com/uploads/event/image/5/petro_03.jpg";
            mid = "https://mainandme-production.s3.amazonaws.com/uploads/event/image/5/mid_petro_03.jpg";
            scale300 = "https://mainandme-production.s3.amazonaws.com/uploads/event/image/5/scale300_petro_03.jpg";
            scale450 = "https://mainandme-production.s3.amazonaws.com/uploads/event/image/5/scale450_petro_03.jpg";
            thumb = "https://mainandme-production.s3.amazonaws.com/uploads/event/image/5/thumb_petro_03.jpg";
        };
        link = "http://google.com";
        name = "Test Event 1";
        permissions =     {
            create = 1;
            destroy = 1;
            manage = 1;
            read = 1;
            update = 1;
        };
        "start_date" = "2016-12-13T20:11:00Z";
        "user_id" = 479;
    }
    */
}

- (void) setProduct: (NSDictionary *) product {
    if (_product == product)
        return;
    
    _product = product;
    _descriptionLabel.text = @"Loading...";
    _titleLabel.text = @"";
    NSDictionary* imagesDict = [_product safeDictionaryObjectForKey:@"image"];

    NSString* mainImageURL = @"";
    mainImageURL = [imagesDict safeStringObjectForKey:@"full"];

    [self setupImageURL:mainImageURL];
    [self.contentView setNeedsLayout];
}

- (void)setupImageURL:(NSString*)urlString{
    
    NSURL* url = [NSURL URLWithString:urlString];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:30];
    
    __weak SpecialCell *wself = self;
    [_imageView setImageWithURLRequest:request
                      placeholderImage:nil
                          failureImage:nil
                      progressViewSize:CGSizeMake(_imageView.frame.size.width - 16, 10)
                     progressViewStile:UIProgressViewStyleDefault
                     progressTintColor:[UIColor colorWithRed:136/255.0f green:173/255.0f blue:230/255.0f alpha:1]
                        trackTintColor:[UIColor whiteColor]
                            sizePolicy:UNImageSizePolicyOriginalSize
                           cachePolicy:UNImageCachePolicyMemoryAndFileCache
                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//                                   wself.titleLabel.text = [wself.product safeStringObjectForKey:@"name"];
//                                   wself.descriptionLabel.text = [[wself.product safeStringObjectForKey:@"description"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

                                   
                               }
                               failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                   NSLog(@"Image Failed");
                               }
                              progress:^(NSURLRequest *request, NSHTTPURLResponse *response, float progress) {
                                  
                              }];
    
}



- (void)setupCampaign:(CKCampaign*)campaign{

    if (campaign.content.body.length > 0) {
        NSMutableString* my_string = [NSMutableString stringWithString:campaign.content.body];

        // NSString* temp  = [my_string stringByReplacingOccurrencesOfString:@"width=\"300\"" withString:@"width=\"300\""];

        [self.webView loadHTMLString:my_string baseURL:nil];
    }

    //_messageLabel.text = _campaign.content.alertMessage;
}


- (void) setItemURL: (NSURL *) url {
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void) webViewDidStartLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    webView.scrollView.maximumZoomScale = 2; // set as you want.
    webView.scrollView.minimumZoomScale = 0.3; // set as you want.

    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //     //   [self zoomToFit];
    //    });
    
//    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
//        [self performSelector:@selector(clearBackground:) withObject:webView afterDelay:0.1];
//    }

}


- (void)clearBackground:(id)obj {
    UIView *v = obj;
    while (v) {
        //v.backgroundColor = [UIColor whiteColor];
        v = [v.subviews firstObject];
        
        if ([NSStringFromClass([v class]) isEqualToString:@"UIWebPDFView"]) {
            [v setBackgroundColor:[UIColor whiteColor]];
            
            // background set to white so fade view in and exit
            [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 v.alpha = 1.0;
                             }
                             completion:nil];
            return;
        }
    }
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSLog(@"Webview request %@ failed to load with error: %@", webView.request, error);
}


-(void)zoomToFit
{

    if ([self.webView respondsToSelector:@selector(scrollView)])
    {
        UIScrollView *scroll=[self.webView scrollView];

        float zoom=self.webView.bounds.size.width/scroll.contentSize.width;
        //zoom *= 0.98;
        [scroll setZoomScale:zoom animated:NO];
    }
}

- (IBAction)linkCoverButtonClicked:(id)sender {
    
    NSString* link = [self.cellInfo safeStringObjectForKey:@"link"];
    NSURL* url = [NSURL URLWithString:link];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }

}

@end
