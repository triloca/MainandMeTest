//
//  NSString+Common.h
//  POGO
//
//  Created by Sergey Smyk on 26.09.12.
//
//

#import <Foundation/Foundation.h>

@interface NSString (Common)

+ (NSString*)md5:(NSString*)value;
+ (NSString*)md5HexDigest:(NSString*)input;
- (BOOL) isValidEmail;
- (NSString*)stringWithCapitalizedFirstCharacter;
@end
