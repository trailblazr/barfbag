//
//  JSONWorkshop.h
//

#import <Foundation/Foundation.h>
#import "NSObject+JTObjectMapping.h"

@interface JSONWorkshop : NSObject

@property (nonatomic, retain) NSNumber *objId;
@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy) NSString *descriptionText;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, retain) NSDate *dateTimeStart;
@property (nonatomic, retain) NSDate *dateTimeEnd;

+ (NSDictionary*) objectMapping;
- (NSString*) description;

- (NSString*)abstract;
- (NSString*)eventLocation;

@end
