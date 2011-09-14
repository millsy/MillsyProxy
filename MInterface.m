//
//  MInterface.m
//  MillsyProxy
//
//  Created by Chris Mills on 07/09/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MInterface.h"

@implementation MInterface

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        name = @"";
        checked = false;
    }
    
    return self;
}

- (NSString*) Name {
    return name;
}

- (Boolean) IsChecked {
    return checked;
}

- (void) Setup: (NSString*)InterfaceName{
    [name autorelease];
    name = [InterfaceName retain];
    
    NSUserDefaults *preferences = [[NSUserDefaults standardUserDefaults] retain];
    if([preferences boolForKey:name])
    {
        checked = [preferences boolForKey:name];
    }
    [preferences release];
}

- (void) Checked:(Boolean)status
{
    checked = status;
    NSUserDefaults *preferences = [[NSUserDefaults standardUserDefaults] retain];
    [preferences setBool:status forKey:name];
    [preferences synchronize];
    [preferences release];
}

@end
