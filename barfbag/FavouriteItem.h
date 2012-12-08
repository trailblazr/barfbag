//
//  FavouriteItem.h
//  barfbag
//
//  Created by Lincoln Six Echo on 08.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FavouriteItem : NSObject {

    NSString *favouriteName;
    NSNumber* favouriteId;
    FavouriteItemType type;

}

@property( nonatomic, retain ) NSString* favouriteName;
@property( nonatomic, retain ) NSNumber* favouriteId;
@property( nonatomic ) FavouriteItemType type;

+ (FavouriteItem*) storedFavouriteWithId:(NSNumber*)_favouriteId andFavouriteType:(FavouriteItemType)_type;
+ (NSArray*) storedFavouritesForType:(FavouriteItemType)_favouriteType fromArray:(NSArray*)favouritesArray;

- (BOOL) hasType:(FavouriteItemType)itemType;
- (BOOL) hasEqualId:(NSNumber*)_favouriteId;

@end


