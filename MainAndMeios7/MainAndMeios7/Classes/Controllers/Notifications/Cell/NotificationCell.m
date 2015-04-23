//
//  NotificationCell.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 14.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "NotificationCell.h"

@implementation NotificationCell

- (void) setNotification: (NSDictionary *) notification {
    NSLog(@"Notification: %@", notification);
    self.titleLabel.text = [NSString stringWithFormat:@"New %@",[[notification safeStringObjectForKey:@"notifiable_type"] lowercaseString]];
    self.eventLabel.text = nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    
    NSLocale *usLocale = [NSLocale currentLocale];
    [dateFormatter setLocale:usLocale];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSDate *date = [dateFormatter dateFromString:[notification safeStringObjectForKey:@"created_at"]];
    
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate:date];
    date = [NSDate dateWithTimeInterval: seconds sinceDate:date];

    self.descriptionLabel.text = [date howLongAgoString];
    _iconImageView.image = [UIImage imageNamed:@"info_logo.png"];
}


- (void)setCampaign:(CKCampaign *)campaign{
    _campaign = campaign;
    self.titleLabel.text = _campaign.content.alertMessage;
    self.eventLabel.text = nil;
    self.descriptionLabel.text = _campaign.foundAt.name;
    _iconImageView.image = [UIImage imageNamed:@"ibeacon-logo-300x300.png"];
}

@end
