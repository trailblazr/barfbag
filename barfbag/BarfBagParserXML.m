#import "BarfBagParserXML.h"
#import "Event.h"

@implementation BarfBagParserXML

@synthesize parserDelegate;

- (void) dealloc {
    self.parserDelegate = nil;
	[aEvent release];
	[currentElementValue release];
	[super dealloc];
}

- (BarfBagParserXML*) initXMLParserWithDelegate:(id<BarfBagParserXMLDelegate>)_delegate {
	if( self = [super init] ) {
        self.parserDelegate = _delegate;
    }
	return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName 
	attributes:(NSDictionary *)attributeDict {
	
	if([elementName isEqualToString:@"schedule"]) {
		// Empty the array.
        if( parserDelegate && [parserDelegate respondsToSelector:@selector(xmlParser:setAllEvents:)] ) {
            [parserDelegate xmlParser:self setAllEvents:[NSMutableArray array]];
        }
        else {
            NSLog( @"ERROR: XMLParser is supposed to have a parserDelegate to work with." );
        }
	}
	else if([elementName isEqualToString:@"day"]){
		tempString = [attributeDict objectForKey:@"date"];
	}
	else if([elementName isEqualToString:@"event"]) {
		
		//Initialize the event.
		aEvent = [[Event alloc] init];
		
		//Extract the attribute here.
		aEvent.eventID = [[attributeDict objectForKey:@"id"] integerValue];

		//NSLog(@"Reading id value :%i", aEvent.eventID);
	}
	
	
	// NSLog(@"Processing Element: %@", elementName);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string { 
	
	if(!currentElementValue){
		currentElementValue = [[NSMutableString alloc] initWithString:string];
	}
	else{
        [currentElementValue appendString:string];
	}
	
	//NSLog(@"Processing Value: %@", currentElementValue);
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	
	if([elementName isEqualToString:@"schedule"])
		return;
	
	//There is nothing to do if we encounter the Books element here.
	//If we encounter the Book element howevere, we want to add the book object to the array
	// and release the object.
	if( [elementName isEqualToString:@"event"] ) {

        if( parserDelegate && [parserDelegate respondsToSelector:@selector(xmlParser:addEvent:)] ) {
            [parserDelegate xmlParser:self addEvent:aEvent];
        }
        else {
            NSLog( @"ERROR: XMLParser is supposed to have a parserDelegate to work with." );
        }
        
		[aEvent release];
		aEvent = nil;
	}
    else if( [elementName isEqualToString:@"release"] ) { // SAVE UPDATED VERSION TO DEFAULTS
        [[NSUserDefaults standardUserDefaults] setObject:currentElementValue forKey:kUSERDEFAULT_KEY_DATA_VERSION_UPDATED];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
	else {
		NSString *cleanerString = [currentElementValue stringByReplacingOccurrencesOfString:@"\n" withString:@""];
		NSString *theCleanestString = [cleanerString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
		theCleanestString = [theCleanestString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

		if ([elementName isEqualToString:@"title"]){
			[aEvent setValue:theCleanestString forKey:elementName];
		}
		if ([elementName isEqualToString:@"subtitle"]){
			[aEvent setValue:theCleanestString forKey:elementName];
		}
		if ([elementName isEqualToString:@"abstract"]){
			[aEvent setValue:theCleanestString forKey:elementName];
		}
        if ([elementName isEqualToString:@"description"]){
			[aEvent setValue:theCleanestString forKey:elementName];
		}
		if ([elementName isEqualToString:@"duration"]){
			[aEvent setValue:theCleanestString forKey:elementName];
		}
		if ([elementName isEqualToString:@"start"]){
			[aEvent setValue:theCleanestString forKey:elementName];
		}
		if ([elementName isEqualToString:@"room"]){
			[aEvent setValue:theCleanestString forKey:elementName];
		}
		if ([elementName isEqualToString:@"language"]){
			[aEvent setValue:theCleanestString forKey:elementName];
		}
		if ([elementName isEqualToString:@"track"]){
			[aEvent setValue:theCleanestString forKey:elementName];
		}
        if ([elementName isEqualToString:@"person"]){
            if (aEvent.speaker != nil) {
                NSString *speakerTemp = [[aEvent.speaker stringByAppendingString:@", "] stringByAppendingString:theCleanestString];
                [aEvent setValue:speakerTemp forKey:@"speaker"];
            }
            else {
                [aEvent setValue:theCleanestString forKey:@"speaker"];
            }
        }
        
		[aEvent setValue:tempString forKey:@"date"];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSDate *myDate = [df dateFromString: [NSString stringWithFormat:@"%@ %@",aEvent.date,aEvent.start]];
        [aEvent setStartDate:myDate];
        [df release];
        
        NSInteger hour = 0;
        if( myDate ) {
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit fromDate:myDate];
            hour = [components hour];
        }
        
        if (hour < 8){
            [aEvent setRealDate:[myDate dateByAddingTimeInterval:86400]];
        }
        else {
            [aEvent setRealDate:myDate];
        }
	
	[currentElementValue release];
	currentElementValue = nil;
	}
	
}

@end
