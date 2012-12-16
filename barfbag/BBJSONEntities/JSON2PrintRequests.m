//
//  JSON2PrintRequests.m
//

#import "JSON2PrintRequests.h"

@implementation JSON2PrintRequests

@synthesize objId;
@synthesize descriptionValueType;
@synthesize dateTimeStartValueType;
@synthesize dateTimeEndValueType;
@synthesize locationValueType;

+ (NSDictionary*) objectMapping {
    NSDictionary *mappingDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"objId", @"id",
                                 @"descriptionValueType", @"description",
                                 @"dateTimeStartValueType", @"start_time",
                                 @"dateTimeEndValueType", @"end_time",
                                 @"locationValueType", @"entry_location",
                                 nil];
    return mappingDict;
}

- (NSString*) description {
    NSMutableString *string = [NSMutableString string];
    [string appendFormat:@"descriptionValueType = %@\n", descriptionValueType];
    [string appendFormat:@"dateTimeStartValueType = %@\n", dateTimeStartValueType];
    [string appendFormat:@"dateTimeEndValueType = %@\n", dateTimeEndValueType];
    [string appendFormat:@"locationValueType = %@\n", locationValueType];
    return string;
}

@end
