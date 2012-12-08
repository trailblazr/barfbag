//
//  JSONAssembly.m
//

#import "JSONAssembly.h"

@implementation JSONAssembly

@synthesize objId;
@synthesize label;
@synthesize descriptionText;
@synthesize lectureSeats;
@synthesize webLinks;
@synthesize bringsStuff;
@synthesize plannedWorkshops;
@synthesize planningNotes;
@synthesize nameOfLocation;
@synthesize orgaContact;
@synthesize locationOpenedAt;
@synthesize personOrganizing;

+ (NSDictionary*) objectMapping {
    NSDictionary *mappingDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"objId", @"id",
                                 @"label", @"label",
                                 @"descriptionText", @"description",
                                 @"lectureSeats", @"lecture_seats",
                                 @"webLinks", @"weblink",
                                 @"bringsStuff", @"brings_stuff",
                                 @"plannedWorkshops", @"planned_workshops",
                                 @"planningNotes", @"planning_notes",
                                 @"nameOfLocation", @"name_of_location",
                                 @"orgaContact", @"orga_contact",
                                 @"locationOpenedAt", @"location_opened_at",
                                 @"personOrganizing", @"person_organizing",
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
    [string appendFormat:@"webLinks = %@\n", webLinks];
    [string appendFormat:@"bringsStuff = %@\n", bringsStuff];
    [string appendFormat:@"plannedWorkshops = %@\n", plannedWorkshops];
    [string appendFormat:@"planningNotes = %@\n", planningNotes];
    [string appendFormat:@"nameOfLocation = %@\n", nameOfLocation];
    [string appendFormat:@"orgaContact = %@\n", orgaContact];
    [string appendFormat:@"locationOpenedAt = %@\n", locationOpenedAt];
    [string appendFormat:@"personOrganizing = %@\n", personOrganizing];
    return string;
}

@end
