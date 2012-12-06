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

/**
 * I don't get it why this fucking semantic wiki stuff throws out arrays for single item properties
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

- (NSString*)abstract {
    return [self singlePropertyFromObject:descriptionText];
}

- (NSInteger) numLectureSeats {
    NSNumber *seats = [self singlePropertyFromObject:lectureSeats];
;
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
