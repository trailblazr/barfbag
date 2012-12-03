#import <Foundation/Foundation.h>

@interface UIDevice (Versions)

- (NSString*) platform;
- (NSString*) platformString;
- (NSString*) udid;
- (BOOL) isOS_2;
- (BOOL) isOS_3;
- (BOOL) isOS_4;
- (BOOL) isOS_5;
- (BOOL) isLowerThanOS_3;
- (BOOL) isLowerThanOS_4;
- (BOOL) isLowerThanOS_5;
- (BOOL) isDevice4Inches;
- (BOOL) isPad;
- (BOOL) isFon5;

@end
