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

- (void) Setup: (NSString*)InterfaceName Path:(NSString*)InterfacePath{
    [name autorelease];
    [path autorelease];
    [source autorelease];
    name = [InterfaceName retain];
    path = [InterfacePath retain];
    
    NSRange sourceRange = [path rangeOfString:@"/" options:NSBackwardsSearch];
    
    if(sourceRange.length > 0)
    {
        source = [path substringFromIndex:sourceRange.location + 1];
    }else
    {
        source = @"Not set";
    }
}

@end
