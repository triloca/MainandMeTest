//
//  PageCell.m
//  MainAndMe
//
//  Created by Sasha on 3/14/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "PageCell.h"
#import "DataManager.h"

@interface PageCell()
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *pageImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *personImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *nameLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UILabel *agoLabel;


@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *backImageView;

@end


@implementation PageCell

- (void)awakeFromNib{
    // Init code
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


- (void) layoutSubviews {
    [super layoutSubviews];
    
    //    if(UI_USER_INTERFACE_IDIOM()!=UIUserInterfaceIdiomPad)
    //    {
    //    }
    //    
    
    //    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    //    
    //    if (UIInterfaceOrientationIsLandscape(orientation))
    //    {
    //    }
    
    //    self.customImageView.frame = CGRectMake(2, 2, 40, 40);
    //    self.customLable.frame = CGRectMake(50, 2, 100, 40);
    
}

- (void)setCellData:(NSDictionary *)cellData{

    _personImageView.image = [UIImage imageNamed:@"posted_user_ic@2x.png"];
    
    NSString* imageUrl = [[cellData safeDictionaryObjectForKey:@"image"] safeStringObjectForKey:@"full"];
    [self setImageURLString:imageUrl];
    
    NSString* name = [cellData safeStringObjectForKey:@"name"];
    _nameLabel.text = name;
    _descriptionLabel.text = [cellData safeStringObjectForKey:@"store_name"];
    _likesLabel.text = [[cellData safeNumberObjectForKey:@"like_count"] stringValue];
    _commentsLabel.text = [[cellData safeNumberObjectForKey:@"comments_size"] stringValue];
    _rateLabel.text = [[cellData safeNumberObjectForKey:@"rate"] stringValue];
    _priceLabel.text = [cellData safeStringObjectForKey:@"price"];
    
    NSDate* date = [DataManager dateFromString:[cellData safeStringObjectForKey:@"created_at"]];
    _agoLabel.text = [DataManager howLongAgo:date];
    
    _nameLabel.text = [NSString stringWithFormat:@"Posted By %@", @""];
    
    _cellData = cellData;
    
}

- (void)setCellProfileData:(NSDictionary *)cellProfileData{
    [self setPersonImageURLString:[cellProfileData safeStringObjectForKey:@"avatar_url"]];
    _nameLabel.text = [NSString stringWithFormat:@"Posted By %@", [cellProfileData safeStringObjectForKey:@"name"]];
}


- (void)setImageURLString:(NSString*)imageURLString{
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURLString]
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:30];
    
    [self.pageImageView  setImageWithURLRequest:request
                           placeholderImage:nil
                               failureImage:nil
                           progressViewSize:CGSizeMake(_pageImageView.bounds.size.width - 30, 8)
                          progressViewStile:UIProgressViewStyleDefault
                          progressTintColor:[UIColor colorWithRed:109/255.0f green:145/255.0f blue:109/255.0f alpha:1]
                             trackTintColor:nil
                                 sizePolicy:UNImageSizePolicyScaleAspectFill
                                cachePolicy:UNImageCachePolicyMemoryCache
                                    success:nil
                                    failure:nil
                                   progress:nil];
    
}

- (void)setPersonImageURLString:(NSString*)imageURLString{
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURLString]
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:30];
    
    [self.personImageView  setImageWithURLRequest:request
                                 placeholderImage:[UIImage imageNamed:@"posted_user_ic@2x.png"]
                                     failureImage:nil
                                 progressViewSize:CGSizeMake(_personImageView.bounds.size.width - 5, 4)
                                progressViewStile:UIProgressViewStyleDefault
                                progressTintColor:[UIColor colorWithRed:109/255.0f green:145/255.0f blue:109/255.0f alpha:1]
                                   trackTintColor:nil
                                       sizePolicy:UNImageSizePolicyScaleAspectFill
                                      cachePolicy:UNImageCachePolicyMemoryAndFileCache
                                          success:nil
                                          failure:nil
                                         progress:nil];
    
}

#pragma mark - Buttons Action
- (IBAction)coverButtonClicked:(id)sender {
    _backImageView.alpha = 1;
    if (_didClickAtIndex) {
        _didClickAtIndex(self.tag);
    }
}

- (IBAction)coverButtonTouchDown:(UIButton *)sender {
    _backImageView.alpha = 0.3;
}

- (IBAction)coverButtonUpOutSide:(id)sender {
    _backImageView.alpha = 1;
}

@end
