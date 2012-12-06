#import <UIKit/UIKit.h>


@interface NSString (Toolkit)

- (NSString*) trimmedString;
- (NSString*)placeHolderWhenEmpty:(NSString*)placeholder;

+ (BOOL) isEmpty:(NSString*)str;
+ (BOOL) isValidEmailAddress:(NSString*)str;
+ (NSString*)placeHolder:(NSString*)placeholder forEmptyString:(NSString*)string;

- (BOOL) isValidEmailAddress;
- (BOOL) isValidPassword;
- (BOOL) containsString:(NSString *)stringValue;
- (BOOL) containsString:(NSString *)stringValue ignoringCase:(BOOL)flag;
- (BOOL) containsLettersFromString:(NSString*)lettersNeeded withoutLettersOfString:(NSString*)lettersDisallowed;

@end
