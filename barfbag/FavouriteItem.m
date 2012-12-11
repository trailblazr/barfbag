//
//  FavouriteItem.m
//  barfbag
//
//  Created by Lincoln Six Echo on 08.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import "FavouriteItem.h"
#import <Foundation/Foundation.h>

// ADD NSCoding conformnce
@interface NSObject (NSCoding)

- (id) initWithCoder:(NSCoder*)decoder;
- (void) encodeWithCoder:(NSCoder*)encoder;    

@end

@implementation NSObject (NSCoding)

- (id) initWithCoder:(NSCoder*)decoder {
    return [self init];
}

- (void) encodeWithCoder:(NSCoder*)encoder {}
@end



@implementation FavouriteItem

@synthesize favouriteId;
@synthesize favouriteName;
@synthesize type;

- (id)init {
    self = [super init];
    if (self) {
        // Initialization code here.
    }    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:favouriteId forKey:@"favouriteId"];
    [coder encodeObject:favouriteName forKey:@"favouriteName"];
    [coder encodeObject:[NSNumber numberWithFloat:type] forKey:@"favouriteType"];
}

- (id)initWithCoder:(NSCoder *)coder {
    if( (self = [super initWithCoder:coder]) ) {
        self.favouriteId = [coder decodeObjectForKey:@"favouriteId"];
        self.favouriteName = [coder decodeObjectForKey:@"favouriteName"];
        self.type = [[coder decodeObjectForKey:@"favouriteType"] integerValue];
    }
    return self;
}

- (BOOL) hasType:(FavouriteItemType)itemType {
    return ( itemType == type );
}

- (BOOL) hasEqualId:(NSString*)_favouriteId {
    if( !_favouriteId || !self.favouriteId ) return NO;
    return [self.favouriteId isEqualToString:_favouriteId];
}

+ (FavouriteItem*) storedFavouriteWithId:(NSString*)_favouriteId andFavouriteType:(FavouriteItemType)_type {
    FavouriteItem *favouriteItem = [[[FavouriteItem alloc] init] autorelease];
    favouriteItem.favouriteId = _favouriteId;
    favouriteItem.type = _type;
    return favouriteItem;
}

+ (NSArray*) storedFavouritesForType:(FavouriteItemType)_favouriteType fromArray:(NSArray*)favouritesArray {
    NSMutableArray *foundStoredFavourites = [NSMutableArray array];
    for( FavouriteItem *currentFavourite in favouritesArray ) {
        if( currentFavourite.type == _favouriteType ) {
            [foundStoredFavourites addObject:currentFavourite];
        }
    }
    return foundStoredFavourites;
}

@end

