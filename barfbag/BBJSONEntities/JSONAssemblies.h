//
//  JSONAssemblies.h
//

#import <Foundation/Foundation.h>
#import "NSObject+JTObjectMapping.h"

@interface JSONAssemblies : NSObject

@property (nonatomic, retain) NSNumber *objId;
@property (nonatomic, retain) NSArray *properties;
@property (nonatomic, retain) NSArray *assemblyItems;

+ (NSDictionary*) objectMapping;
- (NSString*) description;
- (NSArray*) assemblyItemsSorted;

@end
