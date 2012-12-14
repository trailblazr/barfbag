//
//  JSONWorkshop.h
//

#import <Foundation/Foundation.h>
#import "NSObject+JTObjectMapping.h"
#import "SearchableItem.h"

@interface JSONWorkshop : SearchableItem

@property (nonatomic, retain) NSNumber *objId;
@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy) NSString *descriptionText;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *personOrganizing;
@property (nonatomic, copy) NSString *contactOrganizing;
@property (nonatomic, retain) NSNumber *duration;
@property (nonatomic, retain) NSDate *dateTimeStart;
@property (nonatomic, retain) NSDate *dateTimeEnd;

+ (NSDictionary*) objectMapping;
- (NSString*) description;

- (NSArray*) arrayForPropertyWithName:(NSString*)propertyName;
- (id) singlePropertyFromObject:(id)arrayOrObject;

- (NSString*)abstract;
- (NSString*)eventLocation;
- (NSDate*) startTime;
- (NSDate*) endTime;

- (NSString*) stringRepresentationMail;
- (NSString*) stringRepresentationTwitter;

@end
