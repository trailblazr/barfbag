#import "UIDevice-Versions.h"
#include <sys/sysctl.h>  
#include <sys/types.h>
#include <mach/mach.h>

@implementation UIDevice (Versions)

- (double) availableMemory {
	vm_statistics_data_t	vmStats;
	mach_msg_type_number_t	infoCount = HOST_VM_INFO_COUNT;
	mach_port_t				machHost = mach_host_self();
	kern_return_t			kernReturn = host_statistics(machHost, HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
	
	if(KERN_SUCCESS != kernReturn) {
		return NSNotFound;
	}
	
	return (vm_page_size * vmStats.free_count);
}

- (NSString*) platform {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

- (NSString*) platformString {
	NSMutableDictionary *platformDict = [NSMutableDictionary dictionary];
	[platformDict setValue:@"iPhone 1G"             forKey:@"iPhone1,1"];
	[platformDict setValue:@"iPhone 3G"             forKey:@"iPhone1,2"];
	[platformDict setValue:@"iPhone 3GS"            forKey:@"iPhone2,1"];
	[platformDict setValue:@"iPhone 4"              forKey:@"iPhone3,1"];
	[platformDict setValue:@"iPhone 4 (Verizon)"    forKey:@"iPhone3,2"];
	[platformDict setValue:@"iPhone 4S"             forKey:@"iPhone4,1"];
	[platformDict setValue:@"iPhone 4S (Verizon)"   forKey:@"iPhone4,2"];
	[platformDict setValue:@"iPhone 5"              forKey:@"iPhone5,1"];
	[platformDict setValue:@"iPhone 5"              forKey:@"iPhone5,2"];
	[platformDict setValue:@"iPhone 5"              forKey:@"iPhone5,3"];
	[platformDict setValue:@"iPod Touch 1G"         forKey:@"iPod1,1"];
	[platformDict setValue:@"iPod Touch 2G"         forKey:@"iPod2,1"];
	[platformDict setValue:@"iPod Touch 3G"         forKey:@"iPod3,1"];
	[platformDict setValue:@"iPod Touch 4G"         forKey:@"iPod4,1"];
	[platformDict setValue:@"iPod Touch 5G"         forKey:@"iPod5,1"];
	[platformDict setValue:@"iPad"                  forKey:@"iPad1,1"];
	[platformDict setValue:@"iPad 2 (WiFi)"         forKey:@"iPad2,1"];
	[platformDict setValue:@"iPad 2 (GSM)"          forKey:@"iPad2,2"];
	[platformDict setValue:@"iPad 2 (CDMA)"         forKey:@"iPad2,3"];
	[platformDict setValue:@"iPad 3 (WiFi)"         forKey:@"iPad3,1"];
	[platformDict setValue:@"iPad 3 (GSM)"          forKey:@"iPad3,2"];
	[platformDict setValue:@"iPad 3 (CDMA)"         forKey:@"iPad3,3"];
	[platformDict setValue:@"iPad mini (WiFi)"		forKey:@"iPad4,1"];
	[platformDict setValue:@"iPad mini (GSM)"		forKey:@"iPad4,2"];
	[platformDict setValue:@"iPad mini (CDMA)"		forKey:@"iPad4,3"];
	[platformDict setValue:@"Simulator 386"			forKey:@"i386"];
	[platformDict setValue:@"Simulator x86 (64 bit)"			forKey:@"x86_64"];
	
    NSString *platform = [self platform];
	if( platform == nil || [platform length] == 0 ) return @"Unknown Platform";
	if( [platformDict valueForKey:platform] == nil ) {
		return platform;
	}
	else {
		return [NSString stringWithFormat:@"%@; %@",[platformDict valueForKey:platform], platform];
	}
}

- (NSString*) udid {
    return [self performSelector:@selector(uniqueIdentifier)];
}

- (BOOL) isLowerThanOS_3 {
    return( [self isOS_2] );
}

- (BOOL) isLowerThanOS_4 {
    return( [self isOS_2] || [self isOS_3] );
}

- (BOOL) isLowerThanOS_5 {
    return( [self isOS_2] || [self isOS_3] || [self isOS_4] );
}

- (BOOL) isOS_2 {
    NSString *versionString = [self systemVersion];
    return ( [[versionString substringToIndex:1] intValue] == 2 );
}

- (BOOL) isOS_3 {
    NSString *versionString = [self systemVersion];
    return ( [[versionString substringToIndex:1] intValue] == 3 );
}

- (BOOL) isOS_4 {
    NSString *versionString = [self systemVersion];
    return ( [[versionString substringToIndex:1] intValue] == 4 );
}

- (BOOL) isOS_5 {
    NSString *versionString = [self systemVersion];
    return ( [[versionString substringToIndex:1] intValue] == 5 );
}

- (BOOL) isOS_6 {
    NSString *versionString = [self systemVersion];
    return ( [[versionString substringToIndex:1] intValue] == 6 );
}

- (BOOL) isDevice4Inches {
    BOOL isRetina = ( [UIScreen mainScreen].scale == 2.0 );
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    // NSLog( @"SCREEN SIZE: %@", NSStringFromCGSize( screenSize ) );
    CGFloat minSize = MIN( screenSize.width, screenSize.height );
    CGFloat maxSize = MAX( screenSize.width, screenSize.height );
    return( isRetina && minSize == 320.0f && maxSize > 480.0f );
}

- (BOOL) isFon5 {
    return [self isDevice4Inches];
}

- (BOOL) isPad {
    if( ![[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] ) {
        return NO;
    }
    if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ) {
        return NO;
    }
    return YES;
}


@end
