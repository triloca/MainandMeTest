//
//  HomeItemCell.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 11/3/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "HomeItemCell.h"
#import "NSString+Price.h"

@interface HomeItemCell ()

@property (weak, nonatomic) IBOutlet UILabel *storeLabel;
@property (weak, nonatomic) IBOutlet UIButton *storeButton;
@property (weak, nonatomic) IBOutlet UIButton *priceButton;

@end

@implementation HomeItemCell

+ (CGFloat)cellHeghtForStore:(NSDictionary*)storeDict{
    
    NSDictionary* imagesDict = [storeDict safeDictionaryObjectForKey:@"image"];
    
    CGFloat imageHeight = 100;
//    "height_300" = 401;
//    "height_450" = 601;
    
    
    if (IS_IPHONE_6 || IS_IPHONE_6P) {
        imageHeight = [[imagesDict safeNumberObjectForKey:@"height_450"] floatValue];
    }else{
        imageHeight = [[imagesDict safeNumberObjectForKey:@"height_300"] floatValue];
    }
    return imageHeight + 218 - 148 + 20;
}


- (void)awakeFromNib{
    [super awakeFromNib];
    
    self.layer.cornerRadius = 3;
    self.clipsToBounds = YES;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGRect rc = _mainImageView.frame;
    rc.size.height = self.frame.size.height - (218 - 148 + 20);
    _mainImageView.frame = rc;
}

- (void)setUserImageURLString:(NSString*)imageURLString{
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURLString]
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:30];
    
    [self.userImageView  setImageWithURLRequest:request
                                  placeholderImage:[UIImage imageNamed:@"dash_icon_placeholder_110.png"]
                                      failureImage:nil
                                  progressViewSize:CGSizeMake(_userImageView.bounds.size.width - 5, 4)
                                 progressViewStile:UIProgressViewStyleDefault
                                 progressTintColor:[UIColor colorWithRed:109/255.0f green:145/255.0f blue:109/255.0f alpha:1]
                                    trackTintColor:nil
                                        sizePolicy:UNImageSizePolicyScaleAspectFit
                                       cachePolicy:UNImageCachePolicyMemoryAndFileCache
                                           success:nil
                                           failure:nil
                                          progress:nil];
    
}

- (void)setupImageURL:(NSString*)urlString{
    
    NSURL* url = [NSURL URLWithString:urlString];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:30];
    
    
    [_mainImageView setImageWithURLRequest:request
                                              placeholderImage:nil
                                                  failureImage:nil
                                              progressViewSize:CGSizeMake(_mainImageView.frame.size.width - 16, 10)
                                             progressViewStile:UIProgressViewStyleDefault
                                             progressTintColor:[UIColor colorWithRed:136/255.0f green:173/255.0f blue:230/255.0f alpha:1]
                                                trackTintColor:[UIColor whiteColor]
                                                    sizePolicy:UNImageSizePolicyOriginalSize
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


- (void)setStoreDict:(NSDictionary *)storeDict{

    _storeDict = storeDict;
    
    
    NSDictionary* imagesDict = [storeDict safeDictionaryObjectForKey:@"image"];
    
    NSString* mainImageURL = @"";
    if (IS_IPHONE_6 || IS_IPHONE_6P) {
        mainImageURL = [imagesDict safeStringObjectForKey:@"scale450"];
    }else{
        mainImageURL = [imagesDict safeStringObjectForKey:@"scale300"];
    }
    
    [self setupImageURL:mainImageURL];
    
    _descrLabel.text = [storeDict safeStringObjectForKey:@"name"];
    _itemNameLabel.text = [storeDict safeStringObjectForKey:@"category"];

    NSString* price = [storeDict safeStringObjectForKey:@"price"];
    if (price.length == 0 || [price isEqualToString:@"0.0"]) {
        //price = @"Call for price";
        _priceButton.hidden = NO;
    }else{
        _priceButton.hidden = YES;
    }

    _userNameLabel.text = [price priceString];
    
    
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    _storeLabel.attributedText = [[NSAttributedString alloc] initWithString:[storeDict safeStringObjectForKey:@"store_name"]
                                                                 attributes:underlineAttribute];
}

- (IBAction)storeButtonClicked:(id)sender {
    if (_didClickStoreButton) {
        _didClickStoreButton(self, sender, _storeDict);
    }
}


- (IBAction)priceButtonClicked:(id)sender {
    if (_didClickPriceButton) {
        _didClickPriceButton(self, sender, _storeDict);
    }

}

@end
