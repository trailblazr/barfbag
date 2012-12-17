//
//  JSONWorkshop.m
//

#import "JSONWorkshop.h"
#import "FavouriteManager.h"

@implementation JSONWorkshop

@synthesize objId;
@synthesize label;
@synthesize descriptionText;
@synthesize location;
@synthesize dateTimeStart; // 2012-12-28 18:00:00
@synthesize dateTimeEnd; // 2012-12-28 19:30:00
@synthesize personOrganizing;
@synthesize contactOrganizing;
@synthesize duration;

+ (NSDictionary*) objectMapping {
    NSDictionary *mappingDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"objId", @"id",
                                 @"label", @"label",
                                 @"descriptionText", @"description",
                                 @"location", @"entry_location",
                                 @"dateTimeStart", @"start_time",
                                 @"dateTimeEnd", @"end_time",
                                 @"duration", @"duration",
                                 @"personOrganizing", @"person_organizing",
                                 @"contactOrganizing", @"orga_contact",
                                 nil];
    return mappingDict;
}

/**
 * I don't get it why this fucking semantic wiki stuff throws out arrays for single item properties like start_time
 * this is such a huge data structure fuckup... *throwingmyheadagainstthewall* *facepalm*
 * It is also completely in the blue which timezone these dates are in... this will get very funny...
 */

- (NSArray*) arrayForPropertyWithName:(NSString*)propertyName {
    SEL selector = NSSelectorFromString(propertyName);
    id value = [self performSelector:selector];
    if( [value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSMutableArray class]] ) {
        return value;
    }
    else if( value ) {
        return [NSArray arrayWithObject:value];
    }
    else {
        return [NSArray array];
    }
}

- (id) singlePropertyFromObject:(id)arrayOrObject {
    if( [arrayOrObject isKindOfClass:[NSArray class]] || [arrayOrObject isKindOfClass:[NSMutableArray class]] ) {
        return [arrayOrObject lastObject];
    }
    else {
        return arrayOrObject;
    }
}

- (NSDate*) dateExtracted:(id)dateOrString {
    // NSLog( @"DATE = %@ (CLASS = %@)", dateOrString, NSStringFromClass( [dateOrString class] ) );
    NSDate *date = nil;
    if( [dateOrString isKindOfClass:[NSString class]] ) {
        @try {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+01"]; // FIXING SHIT OF SEMANTIC WIKI
            df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            date = [df dateFromString:dateOrString];
            [df release];
        }
        @catch (NSException *exception) {
            // I am not interested.
        }
    }
    else if( [dateOrString isKindOfClass:[NSDate class]] ) {
        date = dateOrString;
    }
    else {
        date = nil; // FUCK YOU ALL! THERE WILL BE NO DATE!
    }
    return date;
}

#pragma mark - Decrypted Semantic Wiki Data

- (NSString*) eventLocation {
    return [self singlePropertyFromObject:location];
}

- (NSDate*) startTime {
    return [self dateExtracted:[self singlePropertyFromObject:dateTimeStart]];
}

- (NSDate*) endTime {
    return [self dateExtracted:[self singlePropertyFromObject:dateTimeEnd]];
}

- (NSString*)abstract {
    NSString *text = nil;
    @try {
        text = [(NSArray*)descriptionText lastObject];
    }
    @catch (NSException *exception) {
        //
    }
    return text;
}

/*
 [NSDate mappingWithKey:@"dateTimeStart" dateFormatString:@"yyyy-MM-dd hh:mm:ssZ"], @"start_time",
 [NSDate mappingWithKey:@"dateTimeEnd" dateFormatString:@"yyyy-MM-dd hh:mm:ssZ"], @"end_time",
 */

- (NSString*) stringRepresentationMail {
    return [NSString stringWithFormat:@"<b>%@</b><br>%@<br>%@", [NSString placeHolder:@"(Kein Titel)" forEmptyString:[self singlePropertyFromObject:label]],[self startTime],[NSString placeHolder:@"(Kein Ort)" forEmptyString:[self singlePropertyFromObject:location]]];
}

- (NSString*) stringRepresentationTwitter {
    return [NSString stringWithFormat:@"\"%@\"", [NSString placeHolder:@"(Kein Titel)" forEmptyString:[self singlePropertyFromObject:label]]];
}

- (NSString*) description {
    NSMutableString *string = [NSMutableString string];
    [string appendFormat:@"id = %@\n", objId];
    [string appendFormat:@"label = %@\n", label];
    [string appendFormat:@"descriptionText = %@\n", descriptionText];
    [string appendFormat:@"location = %@\n", location];
    [string appendFormat:@"dateTimeStart = %@\n", dateTimeStart];
    [string appendFormat:@"dateTimeEnd = %@\n", dateTimeEnd];
    [string appendFormat:@"duration = %@\n", duration];
    [string appendFormat:@"personOrganizing = %@\n", personOrganizing];
    [string appendFormat:@"contactOrganizing = %@\n", contactOrganizing];
    return string;
}

// SEARCHABLE ITEM

- (NSString*) itemId {
    return [[self singlePropertyFromObject:label] normalizedString];
}

- (NSString*) itemTitle {
    return [self singlePropertyFromObject:label];
}

- (NSString*) itemSubtitle {
    return [self singlePropertyFromObject:location];
}
- (NSString*) itemAbstract {
    return [self singlePropertyFromObject:descriptionText];
}

- (NSString*) itemPerson {
    NSMutableString *personsString = [NSMutableString string];
    if (personOrganizing && [personOrganizing isKindOfClass:[NSString class]]) {
        [personsString appendString:personOrganizing];
    }
    else if( personOrganizing && [personOrganizing isKindOfClass:[NSArray class]]) {
        [personsString appendString:[(NSArray*)personOrganizing objectAtIndex:0]];
    }
    if( contactOrganizing && [contactOrganizing isKindOfClass:[NSString class]] ) {
        if( [personsString length] > 0 ) {
            [personsString appendString:@","];
        }
        [personsString appendString:contactOrganizing];
    }
    if( contactOrganizing && [contactOrganizing isKindOfClass:[NSArray class]] ) {
        if( [personsString length] > 0 ) {
            [personsString appendString:@","];
        }
        [personsString appendString:[(NSArray*)contactOrganizing objectAtIndex:0]];
    }
    return personsString;
}

- (NSDate*) itemDateStart {
    return [self startTime];
}

- (NSDate*) itemDateEnd {
    return [self endTime];
}

- (BOOL) isFavourite {
    return [[FavouriteManager sharedManager] hasStoredFavourite:self];
}

@end
