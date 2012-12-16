//
//  MKiCloudSync.m
//  iCloud1
//
//  Created by Mugunth Kumar (@mugunthkumar) on 20/11/11.
//  Copyright (C) 2011-2020 by Steinlogic

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

//  As a side note, you might also consider 
//	1) tweeting about this mentioning @mugunthkumar
//	2) A paypal donation to mugunth.kumar@gmail.com


#import "MKiCloudSync.h"


@implementation MKiCloudSync

static MKiCloudSync *sharedInstance = nil;

@synthesize isActivatedRightNow;

#pragma mark - Setup Shared Instance

+ (MKiCloudSync*) instance {
    @synchronized( sharedInstance ) {
        if( nil == sharedInstance ) {
            sharedInstance = [[super allocWithZone:NULL] init];
            sharedInstance.isActivatedRightNow = NO;
        }
    }
    return sharedInstance;
}

/*
- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSUserDefaultsDidChangeNotification
                                                  object:nil];
    [super dealloc];
}
 */


- (void) updateToiCloud:(NSNotification*) notificationObject {
    
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        [[NSUbiquitousKeyValueStore defaultStore] setObject:obj forKey:key];
    }];
    
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
}

- (void) updateFromiCloud:(NSNotification*) notificationObject {
    
    NSUbiquitousKeyValueStore *iCloudStore = [NSUbiquitousKeyValueStore defaultStore];
    NSDictionary *dict = [iCloudStore dictionaryRepresentation];
    
    // prevent NSUserDefaultsDidChangeNotification from being posted while we update from iCloud
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:NSUserDefaultsDidChangeNotification 
                                                  object:nil];

    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];
    }];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kUSERDEFAULT_KEY_DATE_LAST_SYNCED];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // enable NSUserDefaultsDidChangeNotification notifications again

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(updateToiCloud:) 
                                                 name:NSUserDefaultsDidChangeNotification                                                    
												object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMKiCloudSyncNotification object:nil];
}

- (NSDate*) dateLastSynced {
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:kUSERDEFAULT_KEY_DATE_LAST_SYNCED];
    return date;
}

- (BOOL) hasDeviceCloudSupport {
    if( ! NSClassFromString(@"NSUbiquitousKeyValueStore") ) {
        if( DEBUG ) NSLog( @"CLOUD: NOT AVAILABLE (PRE iOS 5 DEVICE)." );
        return NO;
    }
    else {
        return YES;
    }
}

- (BOOL) hasValidCloudToken {
    NSFileManager *fm = [NSFileManager defaultManager];
    if( ![fm respondsToSelector:@selector(ubiquityIdentityToken)] ) return NO;
    id cloudToken = [fm ubiquityIdentityToken];
    if( cloudToken ) {
        NSData *tokenAsData = [NSKeyedArchiver archivedDataWithRootObject:cloudToken];
        [[NSUserDefaults standardUserDefaults] setObject:tokenAsData forKey: @"com.apple.MyAppName.UbiquityIdentityToken"];
        return YES;
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"com.apple.MyAppName.UbiquityIdentityToken"];
        return NO;
    }
}

- (BOOL) isDeviceCloudEnabled {
    if( ![self hasDeviceCloudSupport] ) {
        if( DEBUG ) NSLog( @"CLOUD: NOT AVAILABLE (PRE iOS 5 DEVICE)." );
        return NO;
    }
    if( ![NSUbiquitousKeyValueStore defaultStore] ) {
        if( DEBUG ) NSLog( @"CLOUD: NOT ENABLED BY USER." );
        return NO;
    }
    else {
        return YES;
    }
    // return [self hasValidCloudToken];
}

- (BOOL) isCloudSyncActivated {
    return isActivatedRightNow;
}

- (void) start {
    if( [self hasDeviceCloudSupport] ) { // is iOS 5?
        
        if( [self isDeviceCloudEnabled] ) {  // is iCloud enabled
            // ADD LISTENDER TO NOTIFICATIONS
            [[NSNotificationCenter defaultCenter] addObserver:self 
                                                     selector:@selector(updateFromiCloud:) 
                                                         name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification 
                                                       object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(updateToiCloud:)
                                                         name:NSUserDefaultsDidChangeNotification                                                    object:nil];            
            if( DEBUG ) NSLog( @"CLOUD: STARTED SYNC." );
            self.isActivatedRightNow = YES;
        } else {
            self.isActivatedRightNow = NO;
            if( DEBUG ) NSLog( @"CLOUD: NOT ENABLED." );
        }
    }
    else {
        if( DEBUG ) NSLog( @"CLOUD: NOT AVAILABLE (PRE iOS 5 DEVICE)." );
    }
}

- (void) stop {
    if(NSClassFromString(@"NSUbiquitousKeyValueStore")) { // is iOS 5?
        
        if([NSUbiquitousKeyValueStore defaultStore]) {  // is iCloud enabled
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            self.isActivatedRightNow = NO;
            if( DEBUG ) NSLog( @"CLOUD: STOPPED SYNC." );
            
        } else {
            self.isActivatedRightNow = NO;
            if( DEBUG ) NSLog( @"CLOUD: NOT ENABLED." );
        }
    }
    else {
        if( DEBUG ) NSLog( @"CLOUD: NOT AVAILABLE (PRE iOS 5 DEVICE)." );
    }
}

@end
