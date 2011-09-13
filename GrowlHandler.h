//
//  GrowlHandler.h
//  MillsyProxy
//
//  Created by Chris Mills on 13/09/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Growl/Growl.h>

@interface GrowlHandler : NSObject //<GrowlApplicationBridgeDelegate>
{

}

-(void) ProxySettingsApplied;
-(void) ProxySettingsFailed:(NSString*)reason;

@end
