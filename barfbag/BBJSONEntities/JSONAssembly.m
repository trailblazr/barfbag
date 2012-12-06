//
//  JSONAssembly.m
//

#import "JSONAssembly.h"

@implementation JSONAssembly

@synthesize objId;
@synthesize label;
@synthesize descriptionText;
@synthesize lectureSeats;

+ (NSDictionary*) objectMapping {
    NSDictionary *mappingDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"objId", @"id",
                                 @"label", @"label",
                                 @"descriptionText", @"description",
                                 @"lectureSeats", @"lecture_seats",
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

- (NSInteger) numLectureSeats {
    NSNumber *seats = nil;
    @try {
        seats = [(NSArray*)lectureSeats lastObject];
    }
    @catch (NSException *exception) {
        //
    }
    if( seats ) {
        return [seats integerValue];
    }
    else {
        return 0;
    }
}

- (NSString*) description {
    NSMutableString *string = [NSMutableString string];
    [string appendFormat:@"id = %@\n", objId];
    [string appendFormat:@"label = %@\n", label];
    [string appendFormat:@"descriptionText = %@\n", descriptionText];
    [string appendFormat:@"lectureSeats = %@\n", lectureSeats];
    return string;
}

@end
