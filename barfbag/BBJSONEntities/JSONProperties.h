//
//  JSONProperties.h
//

#import <Foundation/Foundation.h>
#import "NSObject+JTObjectMapping.h"

@interface JSONProperties : NSObject

@property (nonatomic, retain) NSNumber *objId;
@property (nonatomic, copy) NSString *descriptionValueType;
@property (nonatomic, copy) NSString *dateTimeStartValueType;
@property (nonatomic, copy) NSString *dateTimeEndValueType;
@property (nonatomic, copy) NSString *locationValueType;

+ (NSDictionary*) objectMapping;
- (NSString*) description;

@end
