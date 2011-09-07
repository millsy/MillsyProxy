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
        path = @"";
        source = @"";
        checked = false;
    }
    
    return self;
}

- (NSString*) Name {
    return name;
}

- (NSString*) Path {
    return path;
}

- (NSString*) Source {
    return source;
}

- (Boolean) IsChecked {
    return checked;
}

- (void) Setup: (NSString*)InterfaceName Path:(NSString*)InterfacePath{
    [name autorelease];
    [path autorelease];
    [source autorelease];
    name = [InterfaceName retain];
    path = [InterfacePath retain];
    
    NSUserDefaults *preferences = [[NSUserDefaults standardUserDefaults] retain];
    if([preferences boolForKey:name])
    {
        checked = [preferences boolForKey:name];
    }
    [preferences release];
    
    NSRange sourceRange = [path rangeOfString:@"/" options:NSBackwardsSearch];
    
    if(sourceRange.length > 0)
    {
        source = [[path substringFromIndex:(sourceRange.location + 1)] retain];        
    }else
    {
        source = @"Not set";
    }
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
