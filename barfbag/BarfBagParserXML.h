#import <UIKit/UIKit.h>

@class Event;

@protocol BarfBagParserXMLDelegate;

@interface BarfBagParserXML : NSObject <NSXMLParserDelegate> {
	
    id<BarfBagParserXMLDelegate> parserDelegate;
    
	NSMutableString *currentElementValue;
	NSString *tempString;
	Event *aEvent;

}

@property( nonatomic, assign ) id<BarfBagParserXMLDelegate> parserDelegate;

- (BarfBagParserXML*) initXMLParserWithDelegate:(id<BarfBagParserXMLDelegate>)_delegate;

@end

@protocol BarfBagParserXMLDelegate <NSObject>

- (void) xmlParser:(BarfBagParserXML*)parser setAllEvents:(NSMutableArray*)events;
- (void) xmlParser:(BarfBagParserXML*)parser addEvent:(Event*)event;

@end
