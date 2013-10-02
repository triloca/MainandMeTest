//
//  UIViewController+Common.m
//  MainAndMe
//
//  Created by Sasha on 3/11/13.
//
//

#import "UIViewController+Common.h"

@implementation UIViewController (Common)

+ (id)loadFromXIB_Or_iPhone5_XIB{
    
    if(IS_IPHONE_5){
        NSString* xibName = [NSString stringWithFormat:@"%@_iPhone5", NSStringFromClass(self)];
        return [[self alloc] initWithNibName:xibName bundle:nil];
    }else{
       
        NSString* xibName = [NSString stringWithFormat:@"%@_iOS7", NSStringFromClass(self)];
        NSString *path = [[NSBundle mainBundle]
                          pathForResource:xibName
                          ofType:@"nib"];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f && path) {
            return [[self alloc] initWithNibName:xibName bundle:nil];
        }else{
            return [[self alloc] initWithNibName:NSStringFromClass(self) bundle:nil];
        }
    }
}

@end
