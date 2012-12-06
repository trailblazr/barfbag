//
//  JSONAssemblies.m
//

#import "JSONAssemblies.h"
#import "NSString+Magistrix.h"

@implementation JSONAssemblies

@synthesize objId;
@synthesize city;
@synthesize path;
@synthesize time;
@synthesize isSoldOut;
@synthesize createdAt;
@synthesize updatedAt;
@synthesize artist;
@synthesize eventimPicture;

+ (NSDictionary*) objectMapping {
    NSDictionary *mappingDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"objId", @"id",
                                 @"city", @"city",
                                 @"path", @"path",
                                 [NSDate mappingWithKey:@"time" dateFormatString:@"yyyy-MM-dd'T'hh:mm:ssZ"], @"time",
                                 @"isSoldOut", @"sold_out",
                                 [NSDate mappingWithKey:@"createdAt" dateFormatString:@"yyyy-MM-dd'T'hh:mm:ssZ"], @"created_at",
                                 [NSDate mappingWithKey:@"updatedAt" dateFormatString:@"yyyy-MM-dd'T'hh:mm:ssZ"], @"updated_at",
                                 [JSONArtist mappingWithKey:@"artist" mapping:[JSONArtist objectMapping]],@"artist",
                                 [JSONEventimPicture mappingWithKey:@"eventimPicture" mapping:[JSONEventimPicture objectMapping]],@"eventim_picture_urls",
                                 nil];
    return mappingDict;
}

- (BOOL) hasValidEventimPictureForType:(EventimPictureType)pictureType {
    if( !eventimPicture ) return NO;
    return [eventimPicture hasValidUrlForType:pictureType];
}

- (NSString*) persistentUrlString {
    return [path stringByCreatingAbsolutePersistentUrlString];
}

- (NSString*) description {
    NSMutableString *string = [NSMutableString string];
    [string appendFormat:@"objId = %@\n", objId];
    [string appendFormat:@"city = %@\n", city];
    [string appendFormat:@"time = %@\n", time];
    [string appendFormat:@"isSoldOut = %@\n", isSoldOut ? @"YES" : @"NO" ];
    [string appendFormat:@"createdAt = %@\n", createdAt];
    [string appendFormat:@"updatedAt = %@\n", updatedAt];
    [string appendFormat:@"artist = %@\n", artist];
    [string appendFormat:@"path = %@\n", path];
    [string appendFormat:@"eventimPicture = %@\n", eventimPicture];
    [string appendFormat:@"pers. URL = %@\n", [self persistentUrlString]];
    return string;
}

@end
