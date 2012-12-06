//
//  JSONAssemblies.h
//

#import <Foundation/Foundation.h>
#import "NSObject+JTObjectMapping.h"

#import "JSONArtist.h"
#import "JSONEventimPicture.h"

@class JSONArray;

@interface JSONAssemblies : NSObject {

}

@property (nonatomic, retain) NSNumber *objId;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSDate *time;
@property (nonatomic, assign) BOOL isSoldOut;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSDate *updatedAt;
@property (nonatomic, retain) JSONArtist *artist;
@property (nonatomic, retain) JSONEventimPicture *eventimPicture;

+ (NSDictionary*) objectMapping;
- (NSString*) description;
- (NSString*) persistentUrlString;
- (BOOL) hasValidEventimPictureForType:(EventimPictureType)pictureType;

@end