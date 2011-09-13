//
//  GrowlHandler.m
//  MillsyProxy
//
//  Created by Chris Mills on 13/09/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GrowlHandler.h"

static NSString *const PROXY_SETTINGS_APPLIED = @"Proxy Settings Applied";
static NSString *const PROXY_SETTINGS_FAILED = @"Proxy Settings Failed";


@implementation GrowlHandler

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        [GrowlApplicationBridge setGrowlDelegate:@""];
    }
    
    return self;
}

-(void) ProxySettingsApplied{
    [GrowlApplicationBridge notifyWithTitle:PROXY_SETTINGS_APPLIED
								description:PROXY_SETTINGS_APPLIED
						   notificationName:PROXY_SETTINGS_APPLIED
								   iconData:nil
								   priority:0
								   isSticky:NO
							   clickContext:nil];
}

-(void) ProxySettingsFailed:(NSString*)reason{
    [GrowlApplicationBridge notifyWithTitle:PROXY_SETTINGS_FAILED
								description:[NSString stringWithFormat:@"%@ with reason: %@", PROXY_SETTINGS_FAILED, reason]
						   notificationName:PROXY_SETTINGS_FAILED
								   iconData:nil
								   priority:0
								   isSticky:NO
							   clickContext:nil];
    
}

- (void) dealloc {
   
}

@end
