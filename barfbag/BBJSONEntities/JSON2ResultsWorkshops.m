//
//  JSON2ResultsWorkshops.h
//

#import "JSON2ResultsWorkshops.h"
#import "JSON2PrintRequests.h"
#import "JSON2Workshop.h"

@implementation JSON2ResultsWorkshops

@synthesize objId;
@synthesize properties;
@synthesize workshopItems;

+ (NSDictionary*) objectMapping {
    NSDictionary *mappingDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"objId", @"id",
                                 [JSON2Workshop mappingWithKey:@"workshopItems" mapping:[JSON2Workshop objectMapping]],@"printouts",
                                 nil];
    return mappingDict;
}

//                                  [JSONProperties mappingWithKey:@"properties" mapping:[JSONProperties objectMapping]],@"properties",


- (NSString*) description {
    NSMutableString *string = [NSMutableString string];
    [string appendFormat:@"id = %@\n", objId];
    [string appendFormat:@"properties = %@\n", properties];
    [string appendFormat:@"workshopItems = %@\n", workshopItems];
    return string;
}

@end
