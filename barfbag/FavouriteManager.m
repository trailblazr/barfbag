//
//  FavouriteManager.m
//  barfbag
//
//  Created by Lincoln Six Echo on 08.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import "FavouriteManager.h"
#import "FavouriteItem.h"
#import "Event.h"
#import "JSONAssembly.h"
#import "JSONWorkshop.h"

#import "MKiCloudSync.h"

#define kITEM_TYPE_KEY_PREFIX @"itemType_"

static FavouriteManager *sharedInstance = nil;

@implementation FavouriteManager

@synthesize favouriteCacheArray;
@synthesize timerSaveFavourites;
@synthesize hasPendingChangesFavouriteCache;

#pragma mark - Setup Shared Instance

+ (FavouriteManager*) sharedManager {
    @synchronized( sharedInstance ) {
        if( nil == sharedInstance ) {
            sharedInstance = [[super allocWithZone:NULL] init];
            // CONFIGURE / SETUP
            [sharedInstance rebuildFavouriteCache];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rebuildFavouriteCache) name:kMKiCloudSyncNotification object:nil];
        }
    }
    return sharedInstance;
}

- (void)dealloc {
    [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Favourite Managemenmt

- (NSArray*) storedFavouritesForItemType:(FavouriteItemType)itemType {
    return [FavouriteItem storedFavouritesForType:itemType fromArray:favouriteCacheArray];
}

// READ PLIST
- (NSArray*) readFavourites {
    
    if( DEBUG ) NSLog( @"FAVOURITES: READING..." );
    NSArray *arrayRead = nil;
    @try {
        arrayRead = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] dataForKey:@"favourites"]];
    }
    @catch (NSException *exception) {
        //
    }
    @finally {
        //
    }
    if( arrayRead && [arrayRead count] > 0 ) {
        if( DEBUG ) NSLog( @"FAVOURITES: DATA OK" );
        // TODO: store in cache and track changes which need save actions
        return arrayRead;
    }
    else {
        if( DEBUG ) NSLog( @"FAVOURITES: DATA *NOT* FOUND!" );
        return nil;
    }
}

// WRITE PLIST
- (NSArray*) savedFavourites {
        
    NSArray *favouritesToWrite = favouriteCacheArray;
    
    if( DEBUG ) NSLog( @"FAVOURITES: WRITING..." );
    // WRITE ARRAY
    BOOL wasWritten = NO;
    @try {
        NSData *dataToWrite = [NSKeyedArchiver archivedDataWithRootObject:favouritesToWrite];
//        wasWritten = [dataToWrite writeToFile:filePath atomically:YES];
        [[NSUserDefaults standardUserDefaults] setObject:dataToWrite forKey:@"favourites"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        wasWritten = YES;
        
    }
    @catch (NSException *exception) {
        //
    }
    @finally {
        //
    }
    if( DEBUG ) NSLog( @"FAVOURITES: DATA %@", wasWritten ? @"WRITTEN" : @"*ERROR* WRITING!" );
    
    return favouritesToWrite;
}

// BUILD CACHE READING MANY PLIST FILES
- (void) rebuildFavouriteCache {
    self.favouriteCacheArray = [NSMutableArray array];
    NSArray *readFavourites = [self readFavourites];
    if( readFavourites && [readFavourites count] > 0 ) {
        self.favouriteCacheArray = [NSMutableArray arrayWithArray:readFavourites];
    }
}

- (NSArray*) favouritedItemsOfType:(FavouriteItemType)itemType {
    return [FavouriteItem storedFavouritesForType:itemType fromArray:favouriteCacheArray];
}

- (void) setNeedsFavouriteCacheSave {
    if( timerSaveFavourites && [timerSaveFavourites isValid] ) { // WILL SAVE ON NEXT ALREADY
        return; // SAVING WILL TAKE PLACE ANYWAY
    }
    self.hasPendingChangesFavouriteCache = YES;
    self.timerSaveFavourites = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(timerWritePendingChanges:) userInfo:nil repeats:NO];
}

- (void) timerWritePendingChanges:(NSTimer*)timer {
    NSArray *savedFavourites = [self savedFavourites];
    if( DEBUG ) NSLog( @"FAVOURITES: SAVED %i ITEMS.", [savedFavourites count] );
    self.hasPendingChangesFavouriteCache = NO;
    self.timerSaveFavourites = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_FAVOURITE_CHANGED object:nil];
}

- (FavouriteItem*) storedFavouriteWithId:(NSString*)itemId andItemType:(FavouriteItemType)itemType {
    if( !itemId ) return nil;
    if( ![self hasStoredFavouriteForId:itemId forItemType:itemType] ) return nil;
    NSArray *storedFavourites = [FavouriteItem storedFavouritesForType:itemType fromArray:favouriteCacheArray];
    for( FavouriteItem *currentFavourite in storedFavourites ) {
        if( [currentFavourite hasEqualId:itemId] ) {
            return currentFavourite;
        }
    }
    return nil;
}

- (BOOL) hasStoredFavouriteForId:(NSString*)itemId forItemType:(FavouriteItemType)itemType {
    if( !itemId ) return NO;
    NSArray *storedFavourites = [FavouriteItem storedFavouritesForType:itemType fromArray:favouriteCacheArray];
    for( FavouriteItem *currentFavourite in storedFavourites ) {
        if( [currentFavourite hasEqualId:itemId] ) {
            return YES;
        }
    }
    return NO;
}

- (BOOL) favouriteAddedId:(NSString*)itemId forItemType:(FavouriteItemType)itemType name:(NSString*)favouriteName {
    if( !itemId ) return NO;
    if( ![self hasStoredFavouriteForId:itemId forItemType:itemType] ) {
        FavouriteItem *freshFavourite = [FavouriteItem storedFavouriteWithId:itemId andFavouriteType:itemType];
        freshFavourite.favouriteName = favouriteName;
        [favouriteCacheArray addObject:freshFavourite];
        [self setNeedsFavouriteCacheSave]; // MARK AS NEED FOR SAVE
        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_FAVOURITE_ADDED object:nil];
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL) favouriteRemovedId:(NSString*)itemId forItemType:(FavouriteItemType)itemType {
    if( !itemId ) return NO;
    FavouriteItem *favouriteToRemove = [self storedFavouriteWithId:itemId andItemType:itemType];
    if( favouriteToRemove ) {
        [favouriteCacheArray removeObject:favouriteToRemove];
        [self setNeedsFavouriteCacheSave]; // MARK AS NEED FOR SAVE
        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_FAVOURITE_REMOVED object:nil];
        return YES;
    }
    else {
        return NO;
    }
}

- (NSString*) favouriteIdFromItem:(id)item {
    if( [item isKindOfClass:[Event class]] ) {
        return [NSString stringWithFormat:@"%i", [(Event*)item eventId]];
    }
    if( [item isKindOfClass:[JSONAssembly class]] ) {
        return [[(JSONAssembly*)item label] normalizedString];
    }
    if( [item isKindOfClass:[JSONWorkshop class]] ) {
        return [[(JSONWorkshop*)item label] normalizedString];
    }
    return nil;
}

- (NSString*) favouriteNameFromItem:(id)item {
    if( [item isKindOfClass:[Event class]] ) {
        return [(Event*)item title];
    }
    if( [item isKindOfClass:[JSONAssembly class]] ) {
        return [(JSONAssembly*)item label];
    }
    if( [item isKindOfClass:[JSONWorkshop class]] ) {
        return [(JSONWorkshop*)item label];
    }
    return nil;
}

- (FavouriteItemType) favouriteTypeForItem:(id)item {
    if( [item isKindOfClass:[Event class]] ) {
        return FavouriteItemTypeEvent;
    }
    if( [item isKindOfClass:[JSONAssembly class]] ) {
        return FavouriteItemTypeAssembly;
    }
    if( [item isKindOfClass:[JSONWorkshop class]] ) {
        return FavouriteItemTypeWorkshop;
    }
    return FavouriteItemTypeUndefined;
}

- (BOOL) isFavouriteIdFromItem:(id)item1 identicalToId:(NSString*)id2 {
    NSString *id1 = [self favouriteIdFromItem:item1];
    return [id1 isEqualToString:id2];
}

- (BOOL) hasStoredFavourite:(id)item {
    return [self hasStoredFavouriteForId:[self favouriteIdFromItem:item] forItemType:[self favouriteTypeForItem:item]];
}

- (BOOL) favouriteAdded:(id)item {
    return [self favouriteAddedId:[self favouriteIdFromItem:item] forItemType:[self favouriteTypeForItem:item] name:[self favouriteNameFromItem:item]];
}

- (BOOL) favouriteRemoved:(id)item {
    return [self favouriteRemovedId:[self favouriteIdFromItem:item] forItemType:[self favouriteTypeForItem:item]];
}

@end
