#import "NSString-Toolkit.h"


@implementation NSString (Toolkit)

- (NSString*)trimmedString {
    NSMutableString *mStr = [self mutableCopy];
    CFStringTrimWhitespace( (CFMutableStringRef)mStr );
    NSString *result = [mStr copy];
    [mStr release];
    return [result autorelease];
}

- (NSString*)placeHolderWhenEmpty:(NSString*)placeholder {
    if( [[self trimmedString] length] == 0 ) {
        return placeholder;
    }
    else {
        return self;
    }
}

@end
