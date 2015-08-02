//
//  PinterestManager.m
//  Prototype
//
//  Created by Alexander Bukov on 5/7/15.
//  Copyright (c) 2015 AppCoda. All rights reserved.
//

#import "PinterestManager.h"
#import <Pinterest/Pinterest.h>

static NSString* const kPinterestClientId = @"1445015";// 1445015
static NSString* const kUrlSchemeSuffix = @"prod";


@interface PinterestManager()

@property (strong, nonatomic) Pinterest* pinterest;

@end


@implementation PinterestManager
#pragma mark _______________________ Class Methods _________________________

#pragma mark - Shared Instance and Init
+ (PinterestManager *)shared {
    
    static PinterestManager *shared = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}

#pragma mark ____________________________ Init _____________________________

-(id)init{
    
    self = [super init];
    if (self) {
   		// your initialization here
            self.pinterest = [[Pinterest alloc] initWithClientId:kPinterestClientId
                                                 urlSchemeSuffix:kUrlSchemeSuffix];
        
    }
    return self;
}

#pragma mark _______________________ Privat Methods ________________________
- (void)share{
    NSURL* imageURL = [NSURL URLWithString:@"http://placekitten.com/g/200/300"];
    NSURL* sourceURL = [NSURL URLWithString:@"http://placekitten.com"];
    
    [self.pinterest createPinWithImageURL:imageURL
                                sourceURL:sourceURL
                              description:@"Test Demo"];
}


#pragma mark _______________________ Delegates _____________________________



#pragma mark _______________________ Public Methods ________________________

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    
    NSString* key = [NSString stringWithFormat:@"pin%@%@", kPinterestClientId, kUrlSchemeSuffix];
    if ([[url absoluteString] containsString:key]) {
        return YES;
    }
    return NO;
}

#pragma mark _______________________ Notifications _________________________



@end

// Button example

//UIButton* pinItButton = [Pinterest pinItButton];
//[pinItButton addTarget:self
//                action:@selector(pinIt:)
//      forControlEvents:UIControlEventTouchUpInside];
//[self.view addSubview:pinItButton];

//- (void)pinIt:(id)sender
//{
//    [_pinterest createPinWithImageURL:@"http://placekitten.com/500/400"
//                            sourceURL:@"http://placekitten.com"
//                          description:@"Pinning from Pin It Demo"];
//}


// Deep Linking

//Pin
//pinterest://pin/285063851385287883/
//Board
//pinterest://board/meaghanror/cats-cats-cats/
//User
//pinterest://user/carlrice/


//info.plist

//<array>
//    <dict>
//        <key>CFBundleTypeRole</key>
//            <string>Editor</string>
//        <key>CFBundleURLSchemes</key>
//            <array>
//            <string>pin1234prod</string> (@"pin" + kPinterestClientId + kUrlSchemeSuffix)
//            </array>
//    </dict>
//</array>


