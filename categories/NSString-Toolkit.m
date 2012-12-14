#import "NSString-Toolkit.h"


@implementation NSString (Toolkit)

- (NSString*)trimmedString {
    NSMutableString *mStr = [self mutableCopy];
    CFStringTrimWhitespace( (CFMutableStringRef)mStr );
    NSString *result = [mStr copy];
    [mStr release];
    return [result autorelease];
}

- (NSString*) normalizedString {
    NSString *unaccentedString = [self stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
    NSString *lowercaseString = [unaccentedString lowercaseString];
    NSString *trimmedString = [lowercaseString trimmedString];
    return trimmedString;
}

- (NSString*)placeHolderWhenEmpty:(NSString*)placeholder {
    NSString *clean = [self trimmedString];
    if( [clean length] == 0 || [[clean lowercaseString] isEqualToString:@"(null)"] ) {
        return placeholder;
    }
    else {
        return self;
    }
}

- (NSString*) httpUrlString {
    NSString* cleanTrailingSpaces = [self trimmedString];
    BOOL isHttp = [cleanTrailingSpaces containsString:@"http://" ignoringCase:YES];
    BOOL isHttps = [cleanTrailingSpaces containsString:@"https://" ignoringCase:YES];
    if( !isHttp && !isHttps && cleanTrailingSpaces && [cleanTrailingSpaces length] > 0 ) {
        return [NSString stringWithFormat:@"http://%@", cleanTrailingSpaces];
    }
    else {
        return cleanTrailingSpaces;
    }
}

+ (NSString*)placeHolder:(NSString*)placeholder forEmptyString:(NSString*)string {
    NSString *clean = [string trimmedString];
    if( !clean || [clean length] == 0 || [[clean lowercaseString] isEqualToString:@"(null)"] ) {
        return placeholder;
    }
    else {
        return clean;
    }
}


+ (BOOL) isEmpty:(NSString*)str {
    if( !str || ![str isKindOfClass:[NSString class]] ) return YES;
    BOOL isEmpty = ( (str == nil) || ([str length] == 0) );
    return( isEmpty );
}

+ (BOOL) isValidEmailAddress:(NSString*)str {
    
    NSError  *error  = NULL;
    NSRegularExpression *emailRegEx = [NSRegularExpression regularExpressionWithPattern:@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}" options:0 error:&error];
    NSArray *components = [emailRegEx matchesInString:str options:NSMatchingReportCompletion range:NSMakeRange(0, [str length])];
    
	// NSString *emailRegEx2 = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
	// NSArray *components = [str componentsMatchedByRegex:emailRegEx];
	return ( [components count] == 1 );
}


- (BOOL) isValidEmailAddress {
    return [NSString isValidEmailAddress:self];
}

- (BOOL) isValidPassword {
    return( [self length] >= 6 );
}

- (BOOL)containsString:(NSString *)stringValue {
    return [self containsString:stringValue ignoringCase:NO];
}

- (BOOL)containsString:(NSString *)stringValue ignoringCase:(BOOL)flag {
    unsigned mask = (flag ? NSCaseInsensitiveSearch : 0);
    return [self rangeOfString:stringValue options:mask].length > 0;
}


- (BOOL) containsLettersFromString:(NSString*)lettersNeeded withoutLettersOfString:(NSString*)lettersDisallowed {
    // CHECK NEEDED
    BOOL shouldSkipNeededCheck = NO;
    if( lettersNeeded == nil || [lettersNeeded length] == 0 ) {
        shouldSkipNeededCheck = YES;
    }
    if( !shouldSkipNeededCheck ) {
        NSInteger neededIndex = 0;
        while( [self rangeOfString:[lettersNeeded substringWithRange:NSMakeRange(neededIndex, 1)]].location != NSNotFound ) {
            neededIndex++;
            if( neededIndex >= [lettersNeeded length] ) {
                break;
            }
        }
        if( neededIndex != [lettersNeeded length] ) { // some needed letter was missing
            return FALSE;
        }
    }
    
    // CHECK DISALLOWED
    if( lettersDisallowed == nil || [lettersDisallowed length] == 0 ) return TRUE;
    NSInteger disallowedIndex = 0;
    while( [self rangeOfString:[lettersDisallowed substringWithRange:NSMakeRange(disallowedIndex, 1)]].location == NSNotFound ) {
        disallowedIndex++;
        if( disallowedIndex >= [lettersDisallowed length] ) {
            break;
        }
    }
    if( disallowedIndex != [lettersDisallowed length] ) { // some disallowed letter was found
        return FALSE;
    }
    return TRUE;
}

@end
