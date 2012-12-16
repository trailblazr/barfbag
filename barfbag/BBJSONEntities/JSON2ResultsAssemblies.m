//
//  JSON2ResultsAssemblies.m
//

#import "JSON2ResultsAssemblies.h"
#import "JSON2PrintRequests.h"
#import "JSON2Assembly.h"

@implementation JSON2ResultsAssemblies

@synthesize objId;
@synthesize properties;
@synthesize assemblyItems;

+ (NSDictionary*) objectMapping {
    NSDictionary *mappingDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"objId", @"id",
                                 [JSON2Assembly mappingWithKey:@"assemblyItems" mapping:[JSON2Assembly objectMapping]],@"printouts",
                                 nil];
    return mappingDict;
}

//                                  [JSONProperties mappingWithKey:@"properties" mapping:[JSONProperties objectMapping]],@"properties",


- (NSString*) description {
    NSMutableString *string = [NSMutableString string];
    [string appendFormat:@"id = %@\n", objId];
    [string appendFormat:@"properties = %@\n", properties];
    [string appendFormat:@"assemblyItems = %@\n", assemblyItems];
    return string;
}

@end
