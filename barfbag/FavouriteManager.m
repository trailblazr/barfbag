//
//  FavouriteManager.m
//  barfbag
//
//  Created by Lincoln Six Echo on 08.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import "FavouriteManager.h"
#import "FavouriteItem.h"

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
        }
    }
    return sharedInstance;
}

#pragma mark - Favourite Managemenmt

- (NSArray*) storedFavouritesForItemType:(FavouriteItemType)itemType {
    return [FavouriteItem storedFavouritesForType:itemType fromArray:favouriteCacheArray];
}

// READ PLIST
- (NSArray*) readFavourites {
    
    NSString *filePath = [kFOLDER_DOCUMENTS stringByAppendingPathComponent:kFILE_STORED_FAVOURITES];
    
    if( DEBUG ) NSLog( @"FAVOURITES: READING..." );
    NSArray *arrayRead = nil;
    @try {
        arrayRead = [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfFile:filePath]];
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
    
    NSString *filePath = [kFOLDER_DOCUMENTS stringByAppendingPathComponent:kFILE_STORED_FAVOURITES];
    
    NSArray *favouritesToWrite = favouriteCacheArray;
    
    if( DEBUG ) NSLog( @"FAVOURITES: WRITING..." );
    // WRITE ARRAY
    BOOL wasWritten = NO;
    @try {
        NSData *dataToWrite = [NSKeyedArchiver archivedDataWithRootObject:favouritesToWrite];
        wasWritten = [dataToWrite writeToFile:filePath atomically:YES];
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

- (FavouriteItem*) storedFavouriteWithId:(NSNumber*)itemId andItemType:(FavouriteItemType)itemType {
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

- (BOOL) hasStoredFavouriteForId:(NSNumber*)itemId forItemType:(FavouriteItemType)itemType {
    if( !itemId ) return NO;
    NSArray *storedFavourites = [FavouriteItem storedFavouritesForType:itemType fromArray:favouriteCacheArray];
    for( FavouriteItem *currentFavourite in storedFavourites ) {
        if( [currentFavourite hasEqualId:itemId] ) {
            return YES;
        }
    }
    return NO;
}

- (BOOL) favouriteAddedId:(NSNumber*)itemId forItemType:(FavouriteItemType)itemType name:(NSString*)favouriteName {
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

- (BOOL) favouriteRemovedId:(NSNumber*)itemId forItemType:(FavouriteItemType)itemType {
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

@end
