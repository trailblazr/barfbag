//
//  JSONWorkshop.m
//

#import "JSONWorkshop.h"

@implementation JSONWorkshop

@synthesize objId;
@synthesize label;
@synthesize descriptionText;
@synthesize location;
@synthesize dateTimeStart; // 2012-12-28 18:00:00
@synthesize dateTimeEnd; // 2012-12-28 19:30:00

+ (NSDictionary*) objectMapping {
    NSDictionary *mappingDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"objId", @"id",
                                 @"label", @"label",
                                 @"descriptionText", @"description",
                                 @"location", @"location",
                                 @"dateTimeStart", @"start_time",
                                 @"dateTimeEnd", @"end_time",
                                 nil];
    return mappingDict;
}

/**
 * I don't get it why this fucking semantic wiki stuff throws out arrays for single item properties like start_time
 * this is such a huge data structure fuckup... *throwingmyheadagainstthewall* *facepalm*
 * It is also completely in the blue which timezone these dates are in... this will get very funny...
 */

- (id) singlePropertyFromObject:(id)arrayOrObject {
    if( [arrayOrObject isKindOfClass:[NSArray class]] || [arrayOrObject isKindOfClass:[NSMutableArray class]] ) {
        return [arrayOrObject lastObject];
    }
    else {
        return arrayOrObject;
    }
}

- (NSDate*) dateExtracted:(id)dateOrString {
    // NSLog( @"DATE = %@ (CLASS = %@)", dateOrString, NSStringFromClass( [dateOrString class] ) );
    NSDate *date = nil;
    if( [dateOrString isKindOfClass:[NSString class]] ) {
        @try {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"]; // GOING WITH GMT here in hope someone has done his job right!
            df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            date = [df dateFromString:dateOrString];
            [df release];
        }
        @catch (NSException *exception) {
            // I am not interested.
        }
    }
    else if( [dateOrString isKindOfClass:[NSDate class]] ) {
        date = dateOrString;
    }
    else {
        date = nil; // FUCK YOU ALL! THERE WILL BE NO DATE!
    }
    return date;
}

#pragma mark - Decrypted Semantic Wiki Data

- (NSString*) eventLocation {
    return [self singlePropertyFromObject:location];
}

- (NSDate*) startTime {
    return [self dateExtracted:[self singlePropertyFromObject:dateTimeStart]];
}

- (NSDate*) endTime {
    return [self dateExtracted:[self singlePropertyFromObject:dateTimeEnd]];
}

- (NSString*)abstract {
    NSString *text = nil;
    @try {
        text = [(NSArray*)descriptionText lastObject];
    }
    @catch (NSException *exception) {
        //
    }
    return text;
}

/*
 [NSDate mappingWithKey:@"dateTimeStart" dateFormatString:@"yyyy-MM-dd hh:mm:ssZ"], @"start_time",
 [NSDate mappingWithKey:@"dateTimeEnd" dateFormatString:@"yyyy-MM-dd hh:mm:ssZ"], @"end_time",
 */

- (NSString*) description {
    NSMutableString *string = [NSMutableString string];
    [string appendFormat:@"id = %@\n", objId];
    [string appendFormat:@"label = %@\n", label];
    [string appendFormat:@"descriptionText = %@\n", descriptionText];
    [string appendFormat:@"location = %@\n", location];
    [string appendFormat:@"dateTimeStart = %@\n", dateTimeStart];
    [string appendFormat:@"dateTimeEnd = %@\n", dateTimeEnd];
    return string;
}

@end
