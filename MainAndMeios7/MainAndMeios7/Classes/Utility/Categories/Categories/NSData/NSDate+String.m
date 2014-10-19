//
//  NSData+String.m
//  TennisBattle
//
//  Created by Sasha on 10/20/13.
//  Copyright (c) 2013 uniprog. All rights reserved.
//

#import "NSDate+String.h"

@implementation NSDate (String)

- (NSString*)howLongAgoString {
    
    unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;
    NSDateComponents *breakdownInfo = [[NSCalendar currentCalendar] components:unitFlags
                                                                      fromDate:[NSDate date]
                                                                        toDate:self
                                                                       options:0];
    
    NSString *intervalString;
    if ([breakdownInfo month]) {
        if (-[breakdownInfo month] > 1)
            intervalString = [NSString stringWithFormat:@"%ld months ago", (long)-[breakdownInfo month]];
        else
            intervalString = @"1 month ago";
    }
    else if ([breakdownInfo day]) {
        if (-[breakdownInfo day] > 1)
            intervalString = [NSString stringWithFormat:@"%ld days ago", (long)-[breakdownInfo day]];
        else
            intervalString = @"1 day ago";
    }
    else if ([breakdownInfo hour]) {
        if (-[breakdownInfo hour] > 1)
            intervalString = [NSString stringWithFormat:@"%ld hours ago", (long)-[breakdownInfo hour]];
        else
            intervalString = @"1 hour ago";
    }
    else {
        if (-[breakdownInfo minute] > 1)
            intervalString = [NSString stringWithFormat:@"%ld minutes ago", (long)-[breakdownInfo minute]];
        else
            intervalString = @"1 minute ago";
    }
    
    return intervalString;
}

- (NSDate*)yearsAgo:(NSInteger)years{
    
    NSDateComponents *days = [NSDateComponents new];
    [days setYear:-years];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *yearsAgo = [cal dateByAddingComponents:days toDate:self options:0];
    
    return yearsAgo;
}

- (NSInteger)age{
    NSDate* birthday = self;
    
    NSDate* now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                       components:NSYearCalendarUnit
                                       fromDate:birthday
                                       toDate:now
                                       options:0];
    NSInteger age = [ageComponents year];
    return age;
}

@end
