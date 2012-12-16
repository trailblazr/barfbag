//
//  JSON2ResultsWorkshops.h
//

#import <Foundation/Foundation.h>
#import "NSObject+JTObjectMapping.h"

@interface JSON2ResultsWorkshops : NSObject

@property (nonatomic, retain) NSNumber *objId;
@property (nonatomic, retain) NSArray *properties;
@property (nonatomic, retain) NSArray *workshopItems;

+ (NSDictionary*) objectMapping;
- (NSString*) description;

@end
