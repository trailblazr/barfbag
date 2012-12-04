#import "NSString-Toolkit.h"


@implementation NSString (Toolkit)

- (NSString*)trimmedString {
    NSMutableString *mStr = [self mutableCopy];
    CFStringTrimWhitespace( (CFMutableStringRef)mStr );
    NSString *result = [mStr copy];
    [mStr release];
    return [result autorelease];
}

@end
