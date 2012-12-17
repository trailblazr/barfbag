//
//  SearchableItem.h
//  barfbag
//
//  Created by Lincoln Six Echo on 14.12.12.
//  Copyright (c) 2012 appdoctors. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchableItem : NSObject {

}

- (NSString*) itemId;
- (NSString*) itemTitle;
- (NSString*) itemSubtitle;
- (NSString*) itemAbstract;
- (NSString*) itemPerson;
- (NSDate*) itemDateStart;
- (NSDate*) itemDateEnd;
- (NSTimeInterval) itemSortNumberDateTime;
- (BOOL) isFavourite;
@end
