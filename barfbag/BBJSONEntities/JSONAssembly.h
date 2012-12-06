//
//  JSONAssembly.h
//

#import <Foundation/Foundation.h>
#import "NSObject+JTObjectMapping.h"

@interface JSONAssembly : NSObject

@property (nonatomic, retain) NSNumber *objId;
@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy) NSString *descriptionText;
@property(nonatomic, retain) NSNumber *lectureSeats;

+ (NSDictionary*) objectMapping;
- (NSString*) description;

- (NSInteger) numLectureSeats;
- (NSString*)abstract;

@end
