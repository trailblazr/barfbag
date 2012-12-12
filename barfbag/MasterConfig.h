//
//  MasterConfig.h
//  barfbag
//
//  Created by Helge on 12.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    
    MasterConfigStateUndefined = 0,
    MasterConfigStateBundle = 1,
    MasterConfigStateCached = 2,
    MasterConfigStateRemote = 3,
    
} MasterConfigState;

typedef enum {
    
    MasterConfigLanguageUndefined = 0,
    MasterConfigLanguageDe = 1,
    MasterConfigLanguageEn = 2,
    
} MasterConfigLanguage;

typedef enum {
    
    MothershipTypeUndefined = 0,
    MothershipTypeHome = 1,
    MothershipTypeRelay = 2,
    
} MothershipType;

@protocol MasterConfigDelegate;

@interface MasterConfig : NSObject {

    id<MasterConfigDelegate> delegate;
    NSDictionary *currentConfigDictionary;
    MasterConfigState configState;
    MothershipType mothershipType;
}

@property( nonatomic, assign ) id<MasterConfigDelegate> delegate;
@property( nonatomic, assign ) MasterConfigState configState;
@property( nonatomic, assign ) MothershipType mothershipType;
@property( nonatomic, retain ) NSDictionary *currentConfigDictionary;

+ (MasterConfig*) sharedConfiguration;
- (void) initialize;
- (void) refreshFromMothership;
- (NSDate*) mothershipRelayDateLastUpdated;

- (NSString*) urlStringForKey:(NSString*)key isMothership:(BOOL)isMothership language:(MasterConfigLanguage)language;
- (NSString*) urlStringForKey:(NSString*)key isMothership:(BOOL)isMothership;
- (NSString*) urlStringForKey:(NSString*)key;

@end

@protocol MasterConfigDelegate <NSObject>

- (void) masterConfigFetchRemoteConfig:(MasterConfig*)config fromUrl:(NSString*)urlString;
- (void) masterConfigFetchCompleted;

@end
