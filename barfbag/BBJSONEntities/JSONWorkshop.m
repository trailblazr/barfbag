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

- (NSString*)eventLocation {
    NSString *locationName = nil;
    @try {
        locationName = [(NSArray*)location lastObject];
    }
    @catch (NSException *exception) {
        //
    }
    return locationName;
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
