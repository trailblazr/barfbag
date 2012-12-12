//
//  MasterConfig.m
//  barfbag
//
//  Created by Helge on 12.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import "MasterConfig.h"
#import "SinaURLConnection.h"
#import "NSObject+SBJson.h"
#import "JTISO8601DateFormatter.h"

@implementation MasterConfig

@synthesize currentConfigDictionary;
@synthesize configState;
@synthesize delegate;
@synthesize mothershipType;

static MasterConfig *sharedInstance = nil;

#pragma mark - Setup Shared Instance

+ (MasterConfig*) sharedConfiguration {
    @synchronized( sharedInstance ) {
        if( nil == sharedInstance ) {
            sharedInstance = [[super allocWithZone:NULL] init];
            sharedInstance.currentConfigDictionary = nil;
            sharedInstance.mothershipType = MothershipTypeHome;
        }
    }
    return sharedInstance;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.currentConfigDictionary = nil;
    [super dealloc];
}

- (void) useMothershipRelay {
    sharedInstance.mothershipType = MothershipTypeHome;
}

- (void) useMothershipHome {
    sharedInstance.mothershipType = MothershipTypeRelay;
}

- (NSURL*) mothershipRelayCacheStatusUrl {
    NSString* stringUrl = [self urlStringForKey:kURL_KEY_29C3_RELAY_STATUS isMothership:NO];
    return [NSURL URLWithString:stringUrl];
}

- (NSDate*) mothershipRelayDateLastUpdated {
    if( DEBUG ) NSLog( @"MASTERCONFIG: FETCHING RELAY STATUS..." );
    NSString *jsonCacheState = nil;
    @try {
        jsonCacheState = [NSString stringWithContentsOfURL:[self mothershipRelayCacheStatusUrl] encoding:NSUTF8StringEncoding error:nil];
        if( DEBUG ) NSLog( @"MASTERCONFIG: RELAY STATUS FETCHED." );
    }
    @catch (NSException *exception) {
        return nil;
    }
    NSDate *dateLastUpdated = nil;
    if( jsonCacheState ) {
        NSDictionary *cacheStatusDict = [jsonCacheState JSONValue];
        NSString *dateUpdatedString = [cacheStatusDict objectForKey:@"date_last_cached"];
        JTISO8601DateFormatter *df = [[JTISO8601DateFormatter alloc] init];
        dateLastUpdated = [df dateFromString:dateUpdatedString];
    }
    if( dateLastUpdated ) {
        if( DEBUG ) NSLog( @"MASTERCONFIG: RELAY LAST UPDATED %@.", dateLastUpdated );
    }
    else {
        if( DEBUG ) NSLog( @"MASTERCONFIG: RELAY LAST UPDATED UNKNOWN." );
    }
    return dateLastUpdated;
}

- (NSString*) urlStringForKey:(NSString*)key isMothership:(BOOL)isMothership language:(MasterConfigLanguage)language {
    // NSLog( @"------------------------- currentConfigDictionary = %@", currentConfigDictionary );
    if( !currentConfigDictionary ) {
        if( DEBUG ) NSLog( @"MASTERCONFIG: WARNING(!) NOT YET INITIALIZED." );
        [self initialize];
    }
    NSDictionary *shipsDictionary = [currentConfigDictionary objectForKey:@"motherships"];
    if( !shipsDictionary || [shipsDictionary count] == 0 ) {
        if( DEBUG ) NSLog( @"MASTERCONFIG: WARNING(!) EMPTY MASTER CONFIG..." );
        return nil;
    }
    NSDictionary *shipDictionary = [shipsDictionary objectForKey:( isMothership ? @"mothership" : @"mothership_relay" )];
    NSDictionary *languageDictionary = nil;
    NSString *langCode = nil;
    
    switch( language ) {
        case MasterConfigLanguageDe:
            langCode = @"de";
            languageDictionary = [shipDictionary objectForKey:@"port_de"];
            break;
            
        case MasterConfigLanguageEn: {
            langCode = @"en";
            languageDictionary = [shipDictionary objectForKey:@"port_en"];
            break;
        }
        default:
            break;
    }
    // COMPOSE URLS
    NSString *urlString = nil;
    
    if( isMothership ) {
        // WE GET COMPLETE URLS
        NSString *urlFromDictionary = [languageDictionary objectForKey:key];
        urlString = urlFromDictionary;
    }
    else {
        // WE GET PATHS FOR SOME KEYS
        NSString *urlStringRelayFromDictionary = [shipDictionary objectForKey:kURL_KEY_29C3_RELAY_BASE];
        // NSString *pathRelayCache = [shipDictionary objectForKey:kURL_KEY_29C3_RELAY_STATUS];
        NSString *pathFromDictionary = [languageDictionary objectForKey:key];
        urlString = [NSString stringWithFormat:@"%@/%@", urlStringRelayFromDictionary, pathFromDictionary];
    }
    BOOL isSimulation = NO;
    
#if SIMULATE_28C3
    isSimulation = YES;
#endif

    // OVERRIDE FAHRPLAN VALUES TO SIMULATE 28c3
    if( isSimulation ) {
        if( [key isEqualToString:kURL_KEY_29C3_FAHRPLAN] ) {
            urlString = kURL_DATA_28C3_FAHRPLAN_EN;
        }
        if( [key isEqualToString:kURL_KEY_29C3_IMAGES] ) {
            urlString = kURL_DATA_28C3_IMAGE_PATH;
        }
    }
    
    NSLog( @"MASTERCONFIG: Accessing %@ (%@) url[%@]: %@", isMothership ? @"mothership" : @"mothership_relay", langCode, key, urlString  );
    return urlString;
}

- (NSString*) urlStringForKey:(NSString*)key isMothership:(BOOL)isMothership { // DEFAULT USER LANGUAGE
    MasterConfigLanguage language = MasterConfigLanguageEn;
    if( [[[[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleLanguageCode] lowercaseString] containsString:@"de"] ) {
        language = MasterConfigLanguageDe;
    }
    return [self urlStringForKey:key isMothership:isMothership language:language];
}

- (NSString*) urlStringForKey:(NSString*)key { // DEFAULT MOTHERSHIP CONNECT
    MasterConfigLanguage language = MasterConfigLanguageEn;
    BOOL isMothership = ( mothershipType = MothershipTypeHome );
    return [self urlStringForKey:key isMothership:isMothership language:language];
}

#pragma mark - Initialization & Refresh Handling

- (void) initialize {
    if( DEBUG ) NSLog( @"MASTERCONFIG: INITIALIZING..." );
    self.currentConfigDictionary = [NSDictionary dictionary];
    [self initFromCacheOrRemoteOrBundle];
}

- (void) refreshFromMothership {
    if( delegate && [delegate respondsToSelector:@selector(masterConfigFetchRemoteConfig:fromUrl:)] ) {
        if( DEBUG ) NSLog( @"MASTERCONFIG: FETCH REMOTE CONFIG..." );
        [delegate masterConfigFetchRemoteConfig:self fromUrl:kURL_MASTER_CONFIG_29C3];
    }
}

- (void) initFromCacheOrRemoteOrBundle {
    // POSSIBLE SOURCES OF CONFIG
    NSString *pathToCachedConfig = [kFOLDER_DOCUMENTS stringByAppendingPathComponent:kFILE_CACHED_MASTER_CONFIG];
    NSURL *urlConfigBundle = [[NSBundle mainBundle] URLForResource:@"config_remote" withExtension:@"plist"];
    NSURL *urlConfigCached = [NSURL fileURLWithPath:pathToCachedConfig];

    NSDictionary *dictRead = nil;
    BOOL success = NO;
    
    if( DEBUG ) NSLog( @"MASTERCONFIG: READ CACHED..." );
    @try {
        dictRead = [NSDictionary dictionaryWithContentsOfURL:urlConfigCached];
        success = YES;
    }
    @catch (NSException *exception) {
        success = NO;
    }
    if( success && dictRead && [dictRead count] > 0 ) {
        configState = MasterConfigStateCached;
        self.currentConfigDictionary = dictRead;
        if( DEBUG ) NSLog( @"MASTERCONFIG: LOADED FROM CACHE." );
        return;
    }
    else {
        if( DEBUG ) NSLog( @"MASTERCONFIG: NO CACHED CONFIG FOUND." );
    }
    
    if( DEBUG ) NSLog( @"MASTERCONFIG: READ BUNDLE/DEFAULT..." );
    @try {
        dictRead = [NSDictionary dictionaryWithContentsOfURL:urlConfigBundle];
        success = YES;
    }
    @catch (NSException *exception) {
        success = NO;
    }
    if( success && dictRead && [dictRead count] > 0 ) {
        configState = MasterConfigStateBundle;
        self.currentConfigDictionary = dictRead;
        if( DEBUG ) NSLog( @"MASTERCONFIG: LOADED FROM BUNDLE." );
        return;
    }
    else {
        if( DEBUG ) NSLog( @"MASTERCONFIG: NO BUNDLE CONFIG FOUND. WE'RE FUCKED." );
    }
}

@end
