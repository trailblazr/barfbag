//
//  FavouriteItem.h
//  barfbag
//
//  Created by Lincoln Six Echo on 08.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchableItem.h"

@interface FavouriteItem : NSObject {

    NSString *favouriteName;
    NSString *favouriteId;
    FavouriteItemType type;
    SearchableItem *searchableItemAssociated;
    
}

@property( nonatomic, retain ) NSString *favouriteName;
@property( nonatomic, retain ) NSString *favouriteId;
@property( nonatomic, retain ) SearchableItem *searchableItemAssociated;
@property( nonatomic ) FavouriteItemType type;

+ (FavouriteItem*) storedFavouriteWithId:(NSString*)_favouriteId andFavouriteType:(FavouriteItemType)_type;
+ (NSArray*) storedFavouritesForType:(FavouriteItemType)_favouriteType fromArray:(NSArray*)favouritesArray;

- (BOOL) hasType:(FavouriteItemType)itemType;
- (BOOL) hasEqualId:(NSString*)_favouriteId;
- (NSString*) stringRepresentationMail;
- (SearchableItem*)searchableItem;

@end


