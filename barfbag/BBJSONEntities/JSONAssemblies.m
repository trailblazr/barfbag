//
//  JSONAssemblies.m
//

#import "JSONAssemblies.h"
#import "JSONProperties.h"
#import "JSONAssembly.h"

@implementation JSONAssemblies

@synthesize objId;
@synthesize properties;
@synthesize assemblyItems;

+ (NSDictionary*) objectMapping {
    NSDictionary *mappingDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"objId", @"id",
                                 [JSONAssembly mappingWithKey:@"assemblyItems" mapping:[JSONAssembly objectMapping]],@"items",
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

- (NSArray*) assemblyItemsSorted {
    NSMutableArray *itemsUnsorted = [NSMutableArray arrayWithArray:assemblyItems];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemSortNumberDateTime" ascending:TRUE];
    [itemsUnsorted sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSArray *itemsSorted = [NSArray arrayWithArray:itemsUnsorted];
    return itemsSorted;
}

@end
