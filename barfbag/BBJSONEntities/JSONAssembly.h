//
//  JSONAssembly.h
//

#import <Foundation/Foundation.h>
#import "NSObject+JTObjectMapping.h"
#import "SearchableItem.h"

@interface JSONAssembly : SearchableItem

@property (nonatomic, retain) NSNumber *objId;
@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy) NSString *descriptionText;
@property (nonatomic, retain) NSNumber *lectureSeats;
@property (nonatomic, retain) NSArray* webLinks;
@property (nonatomic, copy) NSString *bringsStuff;
@property (nonatomic, copy) NSString *plannedWorkshops;
@property (nonatomic, copy) NSString *planningNotes;
@property (nonatomic, copy) NSString *nameOfLocation;
@property (nonatomic, copy) NSString *orgaContact;
@property (nonatomic, copy) NSString *locationOpenedAt;
@property (nonatomic, copy) NSString *personOrganizing;

+ (NSDictionary*) objectMapping;
- (NSString*) description;

- (id) singlePropertyFromObject:(id)arrayOrObject;
- (NSArray*) arrayForPropertyWithName:(NSString*)propertyName;

- (NSInteger) numLectureSeats;
- (NSString*)abstract;
- (NSString*) stringRepresentationMail;
- (NSString*) stringRepresentationTwitter;

@end
